Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 41BEE6B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 02:24:12 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b13-v6so13469252edb.1
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 23:24:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4-v6sor2548122ejb.18.2018.10.15.23.24.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 23:24:10 -0700 (PDT)
Date: Tue, 16 Oct 2018 06:24:08 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm: remove a redundant check in do_munmap()
Message-ID: <20181016062408.2ui42v3g3fwctd3x@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181010125327.68803-1-richard.weiyang@gmail.com>
 <20181010141355.GA22625@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010141355.GA22625@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.com, linux-mm@kvack.org, rong.a.chen@intel.com

Well, this change is not correct.

On Wed, Oct 10, 2018 at 07:13:55AM -0700, Matthew Wilcox wrote:
>On Wed, Oct 10, 2018 at 08:53:27PM +0800, Wei Yang wrote:
>> A non-NULL vma returned from find_vma() implies:
>> 
>>    vma->vm_start <= start
>> 

My misunderstanding of find_vma(), the non-NULL return value from
find_vma() doesn't impley vma->vm_start <= start. Instead it just
implies addr < vma->vm_end.

This means the original check between vm_start and end is necessary.

Thanks for testing from Rong.

>> Since len != 0, the following condition always hods:
>> 
>>    vma->vm_start < start + len = end
>> 
>> This means the if check would never be true.
>
>This is true because earlier in the function, start + len is checked to
>be sure that it does not wrap.
>
>> This patch removes this redundant check and fix two typo in comment.
>
>> @@ -2705,12 +2705,8 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>> -	/* we have  start < vma->vm_end  */
>> -
>> -	/* if it doesn't overlap, we have nothing.. */
>> +	/* we have vma->vm_start <= start < vma->vm_end */
>>  	end = start + len;
>> -	if (vma->vm_start >= end)
>> -		return 0;
>
>I agree that it's not currently a useful check, but it's also not going
>to have much effect on anything to delete it.  I think there are probably
>more worthwhile places to look for inefficiencies.

-- 
Wei Yang
Help you, Help me
