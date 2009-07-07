Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 208216B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 04:19:52 -0400 (EDT)
Message-ID: <4A530FD4.7060606@redhat.com>
Date: Tue, 07 Jul 2009 12:05:24 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com> <20090707084750.GX2714@wotan.suse.de>
In-Reply-To: <20090707084750.GX2714@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 07/07/2009 11:47 AM, Nick Piggin wrote:
> On Tue, Jul 07, 2009 at 04:51:01PM +0900, KAMEZAWA Hiroyuki wrote:
>    
>> Hi, this is ZERO_PAGE mapping revival patch v2.
>>
>> ZERO PAGE was removed in 2.6.24 (=>  http://lkml.org/lkml/2007/10/9/112)
>> and I had no objections.
>>
>> In these days, at user support jobs, I noticed a few of customers
>> are making use of ZERO_PAGE intentionally...brutal mmap and scan, etc.
>> (For example, scanning big sparse table and save the contents.)
>>
>> They are using RHEL4-5(before 2.6.18) then they don't notice that ZERO_PAGE
>> is gone, yet.
>> yes, I can say  "ZERO PAGE is gone" to them in next generation distro.
>>
>> Recently, a question comes to lkml (http://lkml.org/lkml/2009/6/4/383
>>
>> Maybe there are some users of ZERO_PAGE other than my customers.
>> So, can't we use ZERO_PAGE again ?
>>
>> IIUC, the problem of ZERO_PAGE was
>>    - reference count cache ping-pong
>>    - complicated handling.
>>    - the behavior page-fault-twice can make applications slow.
>>
>> This patch is a trial to de-refcounted ZERO_PAGE.
>>
>> This includes 4 patches.
>> [1/4] introduce pte_zero() at el.
>> [2/4] use ZERO_PAGE for READ fault in anonymous mapping.
>> [3/4] corner cases, get_user_pages()
>> [4/4] introduce get_user_pages_nozero().
>>
>> I feel these patches needs to be clearer but includes almost all
>> messes we have to handle at using ZERO_PAGE again.
>>
>> What I feel now is
>>   a. technically, we can do because we did.
>>   b. Considering maintenance, code's beauty etc.. ZERO_PAGE adds messes.
>>   c. Very big benefits for some (a few?) users but no benefits to usual programs.
>>
>>   There are trade-off between b. and c.
>>
>> Any comments are welcome.
>>      
>
> Can we just try to wean them off it? Using zero page for huge sparse
> matricies is probably not ideal anyway because it needs to still be
> faulted in and it occupies TLB space. They might see better performance
> by using a better algorithm.
>    

For kvm live migration, I've thought of extending mincore() to report if 
a page will be read as zeros.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
