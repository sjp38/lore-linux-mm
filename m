Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC788E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 09:21:13 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id j1-v6so3015867edq.23
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 06:21:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h16-v6si284463ejp.119.2018.09.27.06.21.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 06:21:12 -0700 (PDT)
Subject: Re: [v2 PATCH 2/2 -mm] mm: brk: dwongrade mmap_sem to read when
 shrinking
References: <1537985434-22655-1-git-send-email-yang.shi@linux.alibaba.com>
 <1537985434-22655-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180927125025.xnvoh2btdq5kjmai@kshutemo-mobl1>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3ba966a4-abf9-1363-3e82-41fe73bc0919@suse.cz>
Date: Thu, 27 Sep 2018 15:21:09 +0200
MIME-Version: 1.0
In-Reply-To: <20180927125025.xnvoh2btdq5kjmai@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 9/27/18 2:50 PM, Kirill A. Shutemov wrote:
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 017bcfa..0d2fae1 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -193,9 +193,11 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
>>  	unsigned long retval;
>>  	unsigned long newbrk, oldbrk;
>>  	struct mm_struct *mm = current->mm;
>> +	unsigned long origbrk = mm->brk;
> 
> Is it safe to read mm->brk outside the lock?

Good catch! I guess not, parallel brk()'s could then race.
