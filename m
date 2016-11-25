Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 373BE6B0253
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 11:02:46 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e9so177527669pgc.5
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 08:02:46 -0800 (PST)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10115.outbound.protection.outlook.com. [40.107.1.115])
        by mx.google.com with ESMTPS id k5si45239185pgn.247.2016.11.25.08.02.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 Nov 2016 08:02:45 -0800 (PST)
Subject: Re: mm: BUG in pgtable_pmd_page_dtor
References: <CACT4Y+Z0QqeO-fpc_tuStBGPWMwcK-gT-2q+tPmDpQDCkqYUiQ@mail.gmail.com>
 <f8963cc3-69a8-a1ca-9b56-205d919eac41@suse.cz>
 <CACT4Y+Z0f51iJjwTLxqwY2PZObLQpF+GujKQ34enBA3fBp8QiQ@mail.gmail.com>
 <296bdd6b-5c9e-0fbc-8aa1-4e95d0aff031@suse.cz>
 <ab7996b4-baf6-cf8f-6dba-006735e0587c@virtuozzo.com>
 <2ff6eee6-8828-821a-7dde-c2f68da697a5@suse.cz>
 <20161125130757.GC3439@node.shutemov.name>
 <2ff83214-70fe-741e-bf05-fe4a4073ec3e@suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <ba397708-953b-d24f-21e9-32c9925a2f76@virtuozzo.com>
Date: Fri, 25 Nov 2016 19:03:06 +0300
MIME-Version: 1.0
In-Reply-To: <2ff83214-70fe-741e-bf05-fe4a4073ec3e@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>



On 11/25/2016 05:08 PM, Vlastimil Babka wrote:
> On 11/25/2016 02:07 PM, Kirill A. Shutemov wrote:
>>> --- a/mm/debug.c
>>> +++ b/mm/debug.c
>>> @@ -59,6 +59,10 @@ void __dump_page(struct page *page, const char *reason)
>>>  
>>>  	pr_emerg("flags: %#lx(%pGp)\n", page->flags, &page->flags);
>>>  
>>> +	print_hex_dump(KERN_ALERT, "raw: ", DUMP_PREFIX_NONE,
>>> +			32, (sizeof(unsigned long) == 8) ? 8 : 4,
>>
>> That's a very fancy way to write sizeof(unsigned long) ;)
>  
> Ah, damnit, thanks.
> 
> ----8<----
> From 08d2ee803567c13e3de7ce7e19338fe5286cc6b8 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Fri, 25 Nov 2016 09:08:05 +0100
> Subject: [PATCH v3] mm, debug: print raw struct page data in __dump_page()
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

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
