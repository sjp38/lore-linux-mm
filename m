Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 60E146B025E
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 06:41:24 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y68so102113923pfb.6
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 03:41:24 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30118.outbound.protection.outlook.com. [40.107.3.118])
        by mx.google.com with ESMTPS id c41si15724995plj.134.2016.11.25.03.41.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 Nov 2016 03:41:23 -0800 (PST)
Subject: Re: mm: BUG in pgtable_pmd_page_dtor
References: <CACT4Y+Z0QqeO-fpc_tuStBGPWMwcK-gT-2q+tPmDpQDCkqYUiQ@mail.gmail.com>
 <f8963cc3-69a8-a1ca-9b56-205d919eac41@suse.cz>
 <CACT4Y+Z0f51iJjwTLxqwY2PZObLQpF+GujKQ34enBA3fBp8QiQ@mail.gmail.com>
 <296bdd6b-5c9e-0fbc-8aa1-4e95d0aff031@suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <ab7996b4-baf6-cf8f-6dba-006735e0587c@virtuozzo.com>
Date: Fri, 25 Nov 2016 14:41:43 +0300
MIME-Version: 1.0
In-Reply-To: <296bdd6b-5c9e-0fbc-8aa1-4e95d0aff031@suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>



On 11/25/2016 11:42 AM, Vlastimil Babka wrote:

>  	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
>  		  page, page_ref_count(page), mapcount,
> @@ -59,6 +61,21 @@ void __dump_page(struct page *page, const char *reason)
>  
>  	pr_emerg("flags: %#lx(%pGp)\n", page->flags, &page->flags);
>  
> +	pr_alert("raw struct page data:");
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
> +		}
> +	}
> +	pr_cont("\n");
> +

Single call to print_hex_dump() could replace this loop.

>  	if (reason)
>  		pr_alert("page dumped because: %s\n", reason);
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
