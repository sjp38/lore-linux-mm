Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 38CAE6B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 08:08:01 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so22272975wmf.3
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 05:08:01 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id g8si42332504wje.166.2016.11.25.05.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 05:07:59 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id g23so7764611wme.1
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 05:07:59 -0800 (PST)
Date: Fri, 25 Nov 2016 16:07:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: BUG in pgtable_pmd_page_dtor
Message-ID: <20161125130757.GC3439@node.shutemov.name>
References: <CACT4Y+Z0QqeO-fpc_tuStBGPWMwcK-gT-2q+tPmDpQDCkqYUiQ@mail.gmail.com>
 <f8963cc3-69a8-a1ca-9b56-205d919eac41@suse.cz>
 <CACT4Y+Z0f51iJjwTLxqwY2PZObLQpF+GujKQ34enBA3fBp8QiQ@mail.gmail.com>
 <296bdd6b-5c9e-0fbc-8aa1-4e95d0aff031@suse.cz>
 <ab7996b4-baf6-cf8f-6dba-006735e0587c@virtuozzo.com>
 <2ff6eee6-8828-821a-7dde-c2f68da697a5@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2ff6eee6-8828-821a-7dde-c2f68da697a5@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>

On Fri, Nov 25, 2016 at 01:58:57PM +0100, Vlastimil Babka wrote:
> On 11/25/2016 12:41 PM, Andrey Ryabinin wrote:
> > 
> > 
> > On 11/25/2016 11:42 AM, Vlastimil Babka wrote:
> > 
> >>  	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
> >>  		  page, page_ref_count(page), mapcount,
> >> @@ -59,6 +61,21 @@ void __dump_page(struct page *page, const char *reason)
> >>  
> >>  	pr_emerg("flags: %#lx(%pGp)\n", page->flags, &page->flags);
> >>  
> >> +	pr_alert("raw struct page data:");
> >> +	for (i = 0; i < sizeof(struct page) / sizeof(unsigned long); i++) {
> >> +		unsigned long *word_ptr;
> >> +
> >> +		word_ptr = ((unsigned long *) page) + i;
> >> +
> >> +		if ((i % words_per_line) == 0) {
> >> +			pr_cont("\n");
> >> +			pr_alert(" %016lx", *word_ptr);
> >> +		} else {
> >> +			pr_cont(" %016lx", *word_ptr);
> >> +		}
> >> +	}
> >> +	pr_cont("\n");
> >> +
> > 
> > Single call to print_hex_dump() could replace this loop.
> 
> Ah, didn't know about that one, thanks!
> 
> This also addresses Kirill's comment:
> 
> -----8<-----
> From 417467521d0a68fb70dc2d5bd151524bf0c79437 Mon Sep 17 00:00:00 2001
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
>  raw: 0100000000000400 0000000000000000 0000000000000000 00000001ffffffff
>  raw: ffffea00000475e0 ffffea00000475e0 0000000000000000 0000000000000000
>  page dumped because: VM_BUG_ON_PAGE(1)
> 
> [aryabinin@virtuozzo.com: suggested print_hex_dump()]
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/debug.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/debug.c b/mm/debug.c
> index 9feb699c5d25..185c19bda078 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -59,6 +59,10 @@ void __dump_page(struct page *page, const char *reason)
>  
>  	pr_emerg("flags: %#lx(%pGp)\n", page->flags, &page->flags);
>  
> +	print_hex_dump(KERN_ALERT, "raw: ", DUMP_PREFIX_NONE,
> +			32, (sizeof(unsigned long) == 8) ? 8 : 4,

That's a very fancy way to write sizeof(unsigned long) ;)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
