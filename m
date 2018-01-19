Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB2216B0069
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 13:42:20 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id e69so2669578iod.17
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:42:20 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n132sor1093290ita.136.2018.01.19.10.42.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 10:42:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180119125503.GA2897@bombadil.infradead.org>
References: <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name> <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
 <20180118145830.GA6406@redhat.com> <20180118165629.kpdkezarsf4qymnw@node.shutemov.name>
 <CA+55aFy43ypm0QvA5SqNR4O0ZJETbkR3NDR=dnSdvejc_nmSJQ@mail.gmail.com>
 <20180118234955.nlo55rw2qsfnavfm@node.shutemov.name> <20180119125503.GA2897@bombadil.infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 19 Jan 2018 10:42:18 -0800
Message-ID: <CA+55aFwWCeFrhN+WJDD8u9nqBzmvknXk428Q0dVwwXAvwhg_-w@mail.gmail.com>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>

On Fri, Jan 19, 2018 at 4:55 AM, Matthew Wilcox <willy@infradead.org> wrote:
>
> So really we should be casting 'b' and 'a' to uintptr_t to be fully
> compliant with the spec.

That's an unnecessary technicality.

Any compiler that doesn't get pointer inequality testing right is not
worth even worrying about. We wouldn't want to use such a compiler,
because it's intentionally generating garbage just to f*ck with us.
Why would you go along with that?

So the only real issue is that pointer subtraction case.

I actually asked (long long ago) for an optinal compiler warning for
"pointer subtraction with non-power-of-2 sizes". Not because of it
being undefined, but simply because it's expensive. The
divide->multiply thing doesn't always work, and a real divide is
really quite expensive on many architectures.

We *should* be careful about it. I guess sparse could be made to warn,
but I'm afraid that we have so many of these things that a warning
isn't reasonable.

And most of the time, a pointer difference really is inside the same
array. The operation doesn't tend to make sense otherwise.

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
