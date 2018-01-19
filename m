Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2FBA56B0069
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 17:53:28 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id h8so2004811ote.8
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 14:53:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e14sor3890966oih.175.2018.01.19.14.53.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 14:53:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180119221243.GL13338@ZenIV.linux.org.uk>
References: <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name> <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
 <20180118145830.GA6406@redhat.com> <20180118165629.kpdkezarsf4qymnw@node.shutemov.name>
 <CA+55aFy43ypm0QvA5SqNR4O0ZJETbkR3NDR=dnSdvejc_nmSJQ@mail.gmail.com>
 <20180118234955.nlo55rw2qsfnavfm@node.shutemov.name> <20180119125503.GA2897@bombadil.infradead.org>
 <CA+55aFwWCeFrhN+WJDD8u9nqBzmvknXk428Q0dVwwXAvwhg_-w@mail.gmail.com> <20180119221243.GL13338@ZenIV.linux.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 19 Jan 2018 14:53:25 -0800
Message-ID: <CA+55aFw4mw32Mu0_+cgKAzxCNvDW1VPcESv7CyajexfDfMju1A@mail.gmail.com>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>

On Fri, Jan 19, 2018 at 2:12 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Fri, Jan 19, 2018 at 10:42:18AM -0800, Linus Torvalds wrote:
>>
>> We *should* be careful about it. I guess sparse could be made to warn,
>> but I'm afraid that we have so many of these things that a warning
>> isn't reasonable.
>
> You mean like -Wptr-subtraction-blows?

Heh. Apparently I already did that trivial warning back in 2005. I'd
forgotten about it.

> FWIW, allmodconfig on amd64 with C=2 CF=-Wptr-subtraction-blows is not too large
>
> IOW it's not terribly noisy.  Might be an interesting idea to teach sparse to
> print the type in question...  Aha - with
>
> --- a/evaluate.c
> +++ b/evaluate.c
> @@ -848,7 +848,8 @@ static struct symbol *evaluate_ptr_sub(struct expression *expr)
>
>                 if (value & (value-1)) {
>                         if (Wptr_subtraction_blows)
> -                               warning(expr->pos, "potentially expensive pointer subtraction");
> +                               warning(expr->pos, "[%s] potentially expensive pointer subtraction",
> +                                       show_typename(lbase));
>                 }
>
>                 sub->op = '-';
>
> we get things like
> drivers/gpu/drm/i915/i915_gem_execbuffer.c:435:17: warning: [struct drm_i915_gem_exec_object2] potentially expensive pointer subtraction

It would probably be good to add the size too, just to explain why
it's potentially expensive.

That said, apparently we do have hundreds of them, with just
cpufreq_frequency_table having a ton. Maybe some are hidden in macros
and removing one removes a lot.

The real problem is that sometimes the subtraction is simply the right
thing to do, and there's no sane way to say "yeah, this is one of
those cases you shouldn't warn about".

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
