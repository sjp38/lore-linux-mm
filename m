Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 413E66B026C
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 11:23:57 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l19-v6so3396999edq.20
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 08:23:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q19-v6sor9084470edg.4.2018.10.10.08.23.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 08:23:56 -0700 (PDT)
Date: Wed, 10 Oct 2018 15:23:54 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm: remove a redundant check in do_munmap()
Message-ID: <20181010152354.25jfskblqdmjmlzd@master>
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
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org

On Wed, Oct 10, 2018 at 07:13:55AM -0700, Matthew Wilcox wrote:
>On Wed, Oct 10, 2018 at 08:53:27PM +0800, Wei Yang wrote:
>> A non-NULL vma returned from find_vma() implies:
>> 
>>    vma->vm_start <= start
>> 
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

Thanks for your comment.

Agree, this will not have impact on performance.

The intentinon here is to make the code more clear, otherwise this is a
little misleading. Especially for the comment just before this *if*
clause, audience may think it is possible to have a non-overlap region.

-- 
Wei Yang
Help you, Help me
