Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id AC8626B0032
	for <linux-mm@kvack.org>; Sat, 18 Apr 2015 17:57:29 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so144288418wgy.2
        for <linux-mm@kvack.org>; Sat, 18 Apr 2015 14:57:29 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id w20si25075271wjr.194.2015.04.18.14.57.27
        for <linux-mm@kvack.org>;
        Sat, 18 Apr 2015 14:57:28 -0700 (PDT)
Date: Sun, 19 Apr 2015 00:56:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel BUG at mm/swap.c:134! - page dumped because:
 VM_BUG_ON_PAGE(page_mapcount(page) != 0)
Message-ID: <20150418215656.GA13928@node.dhcp.inet.fi>
References: <20150418205656.GA7972@pd.tnic>
 <CA+55aFxfGOw7VNqpDN2hm+P8w-9F2pVZf+VN9rZnDqGXe2VQTg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxfGOw7VNqpDN2hm+P8w-9F2pVZf+VN9rZnDqGXe2VQTg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@alien8.de>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, x86-ml <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

On Sat, Apr 18, 2015 at 05:27:49PM -0400, Linus Torvalds wrote:
> On Sat, Apr 18, 2015 at 4:56 PM, Borislav Petkov <bp@alien8.de> wrote:
> >
> > so I'm running some intermediate state of linus/master + tip/master from
> > Thursday and probably I shouldn't be even taking such splat seriously
> > and wait until 4.1-rc1 has been done but let me report it just in case
> > so that it is out there, in case someone else sees it too.
> >
> > I don't have a reproducer yet except the fact that it happened twice
> > already, the second time while watching the new Star Wars teaser on
> > youtube (current->comm is "AudioThread" probably from chrome, as shown
> > in the splat below).

I would guess it's related to sound: the most common source of PTE-mapeed
compund pages into userspace.

> Hmm. The only recent commit in this area seems to be 822fc61367f0
> ("mm: don't call __page_cache_release for hugetlb") although I don't
> see why it would cause anything like that. But it changes code that
> has been stable for many years, which makes me wonder how valid it is
> (__put_compound_page() has been unchanged since 2011, and now suddenly
> it grew that "!PageHuge()" test).
> 
> So quite frankly, I'd almost suggest changing that
> 
>         if (!PageHuge(page))
>                 __page_cache_release(page);
> 
> back to the old unconditional __page_cache_release(page), and maybe add a single
> 
>         WARN_ON_ONCE(PageHuge(page));
> 
> just to see if that condition actually happens. The new comment says
> it shouldn't happen and that the change shouldn't matter, but...
> 
> Of course, your recent BUG_ON may well be entirely unrelated to this
> change in mm/swap.c, but it *is* in kind of the same area, and the
> timing would match too...

Andrea has already seen the bug and pointed to 8d63d99a5dfb as possible
cause. I don't see why the commit could broke anything, but it worth
trying to revert and test.

Borislav, could you try?


> ---
> [115258.861335] page:ffffea0010a15040 count:0 mapcount:1 mapping:
>     (null) index:0x0
> [115258.869511] flags: 0x8000000000008014(referenced|dirty|tail)
> [115258.874159] page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) != 0)
> [115258.874179] kernel BUG at mm/swap.c:134!
> [115258.874262] RIP: put_compound_page+0x3b9/0x480
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
