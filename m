Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E12C96B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 07:59:03 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id o3so10141378wjo.1
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 04:59:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y84si13660996wmg.11.2016.11.25.04.59.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Nov 2016 04:59:02 -0800 (PST)
Subject: Re: mm: BUG in pgtable_pmd_page_dtor
References: <CACT4Y+Z0QqeO-fpc_tuStBGPWMwcK-gT-2q+tPmDpQDCkqYUiQ@mail.gmail.com>
 <f8963cc3-69a8-a1ca-9b56-205d919eac41@suse.cz>
 <CACT4Y+Z0f51iJjwTLxqwY2PZObLQpF+GujKQ34enBA3fBp8QiQ@mail.gmail.com>
 <296bdd6b-5c9e-0fbc-8aa1-4e95d0aff031@suse.cz>
 <ab7996b4-baf6-cf8f-6dba-006735e0587c@virtuozzo.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2ff6eee6-8828-821a-7dde-c2f68da697a5@suse.cz>
Date: Fri, 25 Nov 2016 13:58:57 +0100
MIME-Version: 1.0
In-Reply-To: <ab7996b4-baf6-cf8f-6dba-006735e0587c@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>

On 11/25/2016 12:41 PM, Andrey Ryabinin wrote:
> 
> 
> On 11/25/2016 11:42 AM, Vlastimil Babka wrote:
> 
>>  	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
>>  		  page, page_ref_count(page), mapcount,
>> @@ -59,6 +61,21 @@ void __dump_page(struct page *page, const char *reason)
>>  
>>  	pr_emerg("flags: %#lx(%pGp)\n", page->flags, &page->flags);
>>  
>> +	pr_alert("raw struct page data:");
>> +	for (i = 0; i < sizeof(struct page) / sizeof(unsigned long); i++) {
>> +		unsigned long *word_ptr;
>> +
>> +		word_ptr = ((unsigned long *) page) + i;
>> +
>> +		if ((i % words_per_line) == 0) {
>> +			pr_cont("\n");
>> +			pr_alert(" %016lx", *word_ptr);
>> +		} else {
>> +			pr_cont(" %016lx", *word_ptr);
>> +		}
>> +	}
>> +	pr_cont("\n");
>> +
> 
> Single call to print_hex_dump() could replace this loop.

Ah, didn't know about that one, thanks!

This also addresses Kirill's comment:

-----8<-----
