Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 625C96B005A
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 13:19:18 -0500 (EST)
Received: by qabg40 with SMTP id g40so1850805qab.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 10:19:17 -0800 (PST)
Message-ID: <4EF0D1A3.7010700@gmail.com>
Date: Tue, 20 Dec 2011 13:19:15 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mempolicy: refix mbind_range() vma issue
References: <1323449709-25923-1-git-send-email-kosaki.motohiro@gmail.com> <20111212112000.GB18789@cmpxchg.org>
In-Reply-To: <20111212112000.GB18789@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Caspar Zhang <caspar@casparzhang.com>

>> +		pgoff = vma->vm_pgoff + ((vmstart - vma->vm_start)>>  PAGE_SHIFT);
>>   		prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
>> -				  vma->anon_vma, vma->vm_file, vma->vm_pgoff,
>> +				  vma->anon_vma, vma->vm_file, pgoff,
>>   				  new_pol);
>>   		if (prev) {
>>   			vma = prev;
>
> This is essentially a revert of the aforementioned commit.
>
> What you added instead is the fixing of @prev: only when mbind is
> vma-aligned can the new area be potentially merged into the preceding
> one.  Otherwise that original vma is the one we need to check for
> compatibility with the mbind range and leave the original prev alone:
>
> 	[prev         ][vma            ]
> 	                    |start
>
> 	[prev         ][vma][mbind vma ]
>
> This should NOT attempt to merge mbind vma with prev (and forget about
> and leak vma, iirc), but check if vma and the mbind vma are compatible
> or should be separate areas.
>
> Could you please add something to that extent to the changelog?

When making new test case, I've found one bug in my patch. So, I've
sent new patch w/ detailed bug explanaion. :)

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
