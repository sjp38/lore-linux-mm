Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D5A386B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 05:48:33 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so21364078wmw.0
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 02:48:33 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id mw9si41732227wjb.154.2016.11.25.02.48.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 02:48:32 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id u144so7361282wmu.0
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 02:48:31 -0800 (PST)
Date: Fri, 25 Nov 2016 13:48:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: BUG in pgtable_pmd_page_dtor
Message-ID: <20161125104829.GA3439@node.shutemov.name>
References: <CACT4Y+Z0QqeO-fpc_tuStBGPWMwcK-gT-2q+tPmDpQDCkqYUiQ@mail.gmail.com>
 <f8963cc3-69a8-a1ca-9b56-205d919eac41@suse.cz>
 <CACT4Y+Z0f51iJjwTLxqwY2PZObLQpF+GujKQ34enBA3fBp8QiQ@mail.gmail.com>
 <296bdd6b-5c9e-0fbc-8aa1-4e95d0aff031@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <296bdd6b-5c9e-0fbc-8aa1-4e95d0aff031@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, syzkaller <syzkaller@googlegroups.com>

On Fri, Nov 25, 2016 at 09:42:07AM +0100, Vlastimil Babka wrote:
> On 11/24/2016 03:23 PM, Dmitry Vyukov wrote:
> > On Thu, Nov 24, 2016 at 2:49 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> >> On 11/18/2016 11:19 AM, Dmitry Vyukov wrote:
> >>>
> >>> Hello,
> >>>
> >>> I've got the following BUG while running syzkaller on
> >>> a25f0944ba9b1d8a6813fd6f1a86f1bd59ac25a6 (4.9-rc5). Unfortunately it's
> >>> not reproducible.
> >>>
> >>> kernel BUG at ./include/linux/mm.h:1743!
> >>> invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
> >>
> >>
> >> Shouldn't there be also dump_page() output? Since you've hit this:
> >> VM_BUG_ON_PAGE(page->pmd_huge_pte, page);
> > 
> > Here it is:
> > 
> > [  250.326131] page:ffffea0000e196c0 count:1 mapcount:0 mapping:
> >    (null) index:0x0
> > [  250.343393] flags: 0x1fffc0000000000()
> > [  250.345328] page dumped because: VM_BUG_ON_PAGE(page->pmd_huge_pte)
> > [  250.346780] ------------[ cut here ]------------
> > [  250.347742] kernel BUG at ./include/linux/mm.h:1743!
> 
> Yeah, as expected, not very useful for this particular BUG_ON :/
> 
> >> Anyway the output wouldn't contain the value of pmd_huge_pte or stuff that's
> >> in union with it. I'd suggest adding a local patch that prints this in the
> >> error case, in case the fuzzer hits it again.
> >>
> >> Heck, it might even make sense to print raw contents of struct page in
> >> dump_page() as a catch-all solution? Should I send a patch?
> > 
> > Yes, please send.
> > We are moving towards continuous build without local patches.
> 
> Something like this?
> -------8<-------
> From 2ac2c9b83d7c4c8be076c24246865a2ed01f9032 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Fri, 25 Nov 2016 09:08:05 +0100
> Subject: [PATCH] mm, debug: print raw struct page data in __dump_page()
> 
> The __dump_page() function is used when a page metadata inconsistency is
> detected, either by standard runtime checks, or extra checks in CONFIG_DEBUG_VM
> builds. It prints some of the relevant metadata, but not the whole struct page,
> which is based on unions and interpretation is dependent on the context.
> 
> This means that sometimes e.g. a VM_BUG_ON_PAGE() checks certain field, which
> is however not printed by __dump_page() and the resulting bug report may then
> lack clues that could help in determining the root cause. This patch solves
> the problem by simply printing the whole struct page word by word, so no part
> is missing, but the interpretation of the data is left to developers. This is
> similar to e.g. x86_64 raw stack dumps.
> 
> Example output:
> 
>  page:ffffea00000475c0 count:1 mapcount:0 mapping:          (null) index:0x0
>  flags: 0x100000000000400(reserved)
>  raw struct page data:
>   0100000000000400 0000000000000000 0000000000000000 00000001ffffffff
>   ffffea00000475e0 ffffea00000475e0 0000000000000000 0000000000000000
>  page dumped because: VM_BUG_ON_PAGE(1)
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/debug.c | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> diff --git a/mm/debug.c b/mm/debug.c
> index 9feb699c5d25..9f67ad74d036 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -48,6 +48,8 @@ void __dump_page(struct page *page, const char *reason)
>  	 * encode own info.
>  	 */
>  	int mapcount = PageSlab(page) ? 0 : page_mapcount(page);
> +	int i;
> +	const int words_per_line = (sizeof(unsigned long) == 8) ? 4 : 8;
>  
>  	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
>  		  page, page_ref_count(page), mapcount,
> @@ -59,6 +61,21 @@ void __dump_page(struct page *page, const char *reason)
>  
>  	pr_emerg("flags: %#lx(%pGp)\n", page->flags, &page->flags);
>  
> +	pr_alert("raw struct page data:");

Do we really need this line? I would like to keep dump_page() output as
compact as possible.

> +	for (i = 0; i < sizeof(struct page) / sizeof(unsigned long); i++) {
> +		unsigned long *word_ptr;
> +
> +		word_ptr = ((unsigned long *) page) + i;
> +
> +		if ((i % words_per_line) == 0) {
> +			pr_cont("\n");
> +			pr_alert(" %016lx", *word_ptr);
> +		} else {
> +			pr_cont(" %016lx", *word_ptr);

16 is a waste on 32-bit system. And it will produce too long lines.

Maybe 'unsigned long long' a time?

> +		}
> +	}
> +	pr_cont("\n");
> +
>  	if (reason)
>  		pr_alert("page dumped because: %s\n", reason);
>  
> -- 
> 2.10.2
> 
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
