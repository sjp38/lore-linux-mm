Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 943C16B01E5
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 08:40:33 -0400 (EDT)
Message-ID: <4C16233C.1040108@redhat.com>
Date: Mon, 14 Jun 2010 15:40:28 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com> <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com> <4C10B3AF.7020908@redhat.com> <20100610142512.GB5191@balbir.in.ibm.com> <1276214852.6437.1427.camel@nimitz> <20100611045600.GE5191@balbir.in.ibm.com> <4C15E3C8.20407@redhat.com> <20100614084810.GT5191@balbir.in.ibm.com>
In-Reply-To: <20100614084810.GT5191@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 06/14/2010 11:48 AM, Balbir Singh wrote:
>>>
>>> In this case the order is as follows
>>>
>>> 1. First we pick free pages if any
>>> 2. If we don't have free pages, we go after unmapped page cache and
>>> slab cache
>>> 3. If that fails as well, we go after regularly memory
>>>
>>> In the scenario that you describe, we'll not be able to easily free up
>>> the frequently referenced page from /etc/*. The code will move on to
>>> step 3 and do its regular reclaim.
>>>        
>> Still it seems to me you are subverting the normal order of reclaim.
>> I don't see why an unmapped page cache or slab cache item should be
>> evicted before a mapped page.  Certainly the cost of rebuilding a
>> dentry compared to the gain from evicting it, is much higher than
>> that of reestablishing a mapped page.
>>
>>      
> Subverting to aviod memory duplication, the word subverting is
> overloaded,

Right, should have used a different one.

> let me try to reason a bit. First let me explain the
> problem
>
> Memory is a precious resource in a consolidated environment.
> We don't want to waste memory via page cache duplication
> (cache=writethrough and cache=writeback mode).
>
> Now here is what we are trying to do
>
> 1. A slab page will not be freed until the entire page is free (all
> slabs have been kfree'd so to speak). Normal reclaim will definitely
> free this page, but a lot of it depends on how frequently we are
> scanning the LRU list and when this page got added.
> 2. In the case of page cache (specifically unmapped page cache), there
> is duplication already, so why not go after unmapped page caches when
> the system is under memory pressure?
>
> In the case of 1, we don't force a dentry to be freed, but rather a
> freed page in the slab cache to be reclaimed ahead of forcing reclaim
> of mapped pages.
>    

Sounds like this should be done unconditionally, then.  An empty slab 
page is worth less than an unmapped pagecache page at all times, no?

> Does the problem statement make sense? If so, do you agree with 1 and
> 2? Is there major concern about subverting regular reclaim? Does
> subverting it make sense in the duplicated scenario?
>
>    

In the case of 2, how do you know there is duplication?  You know the 
guest caches the page, but you have no information about the host.  
Since the page is cached in the guest, the host doesn't see it 
referenced, and is likely to drop it.

If there is no duplication, then you may have dropped a recently-used 
page and will likely cause a major fault soon.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
