Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 207266B01B5
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 09:02:04 -0400 (EDT)
Message-ID: <4C162846.7030303@redhat.com>
Date: Mon, 14 Jun 2010 16:01:58 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com> <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com> <4C10B3AF.7020908@redhat.com> <20100610142512.GB5191@balbir.in.ibm.com> <1276214852.6437.1427.camel@nimitz> <20100611045600.GE5191@balbir.in.ibm.com> <4C15E3C8.20407@redhat.com> <20100614084810.GT5191@balbir.in.ibm.com> <4C16233C.1040108@redhat.com> <20100614125010.GU5191@balbir.in.ibm.com>
In-Reply-To: <20100614125010.GU5191@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 06/14/2010 03:50 PM, Balbir Singh wrote:
>
>>
>>> let me try to reason a bit. First let me explain the
>>> problem
>>>
>>> Memory is a precious resource in a consolidated environment.
>>> We don't want to waste memory via page cache duplication
>>> (cache=writethrough and cache=writeback mode).
>>>
>>> Now here is what we are trying to do
>>>
>>> 1. A slab page will not be freed until the entire page is free (all
>>> slabs have been kfree'd so to speak). Normal reclaim will definitely
>>> free this page, but a lot of it depends on how frequently we are
>>> scanning the LRU list and when this page got added.
>>> 2. In the case of page cache (specifically unmapped page cache), there
>>> is duplication already, so why not go after unmapped page caches when
>>> the system is under memory pressure?
>>>
>>> In the case of 1, we don't force a dentry to be freed, but rather a
>>> freed page in the slab cache to be reclaimed ahead of forcing reclaim
>>> of mapped pages.
>>>        
>> Sounds like this should be done unconditionally, then.  An empty
>> slab page is worth less than an unmapped pagecache page at all
>> times, no?
>>
>>      
> In a consolidated environment, even at the cost of some CPU to run
> shrinkers, I think potentially yes.
>    

I don't understand.  If you're running the shrinkers then you're 
evicting live entries, which could cost you an I/O each.  That's 
expensive, consolidated or not.

If you're not running the shrinkers, why does it matter if you're 
consolidated or not?  Drop that age unconditionally.

>>> Does the problem statement make sense? If so, do you agree with 1 and
>>> 2? Is there major concern about subverting regular reclaim? Does
>>> subverting it make sense in the duplicated scenario?
>>>
>>>        
>> In the case of 2, how do you know there is duplication?  You know
>> the guest caches the page, but you have no information about the
>> host.  Since the page is cached in the guest, the host doesn't see
>> it referenced, and is likely to drop it.
>>      
> True, that is why the first patch is controlled via a boot parameter
> that the host can pass. For the second patch, I think we'll need
> something like a balloon<size>  <cache?>  with the cache argument being
> optional.
>    

Whether a page is duplicated on the host or not is per-page, it cannot 
be a boot parameter.

If we drop unmapped pagecache pages, we need to be sure they can be 
backed by the host, and that depends on the amount of sharing.

Overall, I don't see how a user can tune this.  If I were a guest admin, 
I'd play it safe by not assuming the host will back me, and disabling 
the feature.

To get something like this to work, we need to reward cooperating guests 
somehow.

>> If there is no duplication, then you may have dropped a
>> recently-used page and will likely cause a major fault soon.
>>      
> Yes, agreed.
>    

So how do we deal with this?



-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
