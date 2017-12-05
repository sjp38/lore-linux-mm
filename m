Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4806B0038
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 11:39:19 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id e41so2063442itd.5
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 08:39:19 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 123sor430843itw.107.2017.12.05.08.39.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Dec 2017 08:39:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171205121614.ek45btdgrpbmvf45@armageddon.cambridge.arm.com>
References: <1511845670-12133-1-git-send-email-vinmenon@codeaurora.org>
 <CAADWXX8FmAs1qB9=fsWZjt8xTEnGOAMS=eCHnuDLJrZiX6x=7w@mail.gmail.com> <20171205121614.ek45btdgrpbmvf45@armageddon.cambridge.arm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 5 Dec 2017 08:39:16 -0800
Message-ID: <CA+55aFyFc-+pAx80zx0xsYpCiU25KUFVzUEL=z-gj+iRDzUgbQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: make faultaround produce old ptes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Tue, Dec 5, 2017 at 4:16 AM, Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> I would be more in favour of some heuristics to dynamically reduce the
> fault-around bytes based on the memory pressure rather than choosing
> between young or old ptes. Or, if we are to go with old vs young ptes,
> make this choice dependent on the memory pressure regardless of whether
> the CPU supports hardware accessed bit.

That sounds like a good idea, but possibly a bit _too_ smart for
something that likely isn't a big deal.

The current behavior definitely is based on a "swapping is not a big
deal" mindset, and that getting the best LRU isn't worth it. That's
probably true in most circumstances, but if you really do have low
memory, and you really do have fairly random access behavior that
where the actual working set size is close to the actual memory size,
then a "get rid of faultaround pages earlier" mode would be a good
thing.

So I'm not at all against your idea - it sounds like the
RightThing(tm) to do - I just wonder how painful it is to generate a
sane heuristic that actually works in practice..

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
