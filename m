Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 859B96B01DA
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 05:44:35 -0400 (EDT)
Message-ID: <4C174B7F.8070504@redhat.com>
Date: Tue, 15 Jun 2010 12:44:31 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
References: <20100614084810.GT5191@balbir.in.ibm.com> <4C16233C.1040108@redhat.com> <20100614125010.GU5191@balbir.in.ibm.com> <4C162846.7030303@redhat.com> <1276529596.6437.7216.camel@nimitz> <4C164E63.2020204@redhat.com> <1276530932.6437.7259.camel@nimitz> <4C1659F8.3090300@redhat.com> <20100614174548.GB5191@balbir.in.ibm.com> <4C172499.7090800@redhat.com> <20100615074949.GA4306@balbir.in.ibm.com>
In-Reply-To: <20100615074949.GA4306@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 06/15/2010 10:49 AM, Balbir Singh wrote:
>
>> All we need is to select the right page to drop.
>>
>>      
> Do we need to drop to the granularity of the page to drop? I think
> figuring out the class of pages and making sure that we don't write
> our own reclaim logic, but work with what we have to identify the
> class of pages is a good start.
>    

Well, the class of pages are 'pages that are duplicated on the host'.  
Unmapped page cache pages are 'pages that might be duplicated on the 
host'.  IMO, that's not close enough.

>> How can the host tell if there is duplication?  It may know it has
>> some pagecache, but it has no idea whether or to what extent guest
>> pagecache duplicates host pagecache.
>>
>>      
> Well it is possible in host user space, I for example use memory
> cgroup and through the stats I have a good idea of how much is duplicated.
> I am ofcourse making an assumption with my setup of the cached mode,
> that the data in the guest page cache and page cache in the cgroup
> will be duplicated to a large extent. I did some trivial experiments
> like drop the data from the guest and look at the cost of bringing it
> in and dropping the data from both guest and host and look at the
> cost. I could see a difference.
>
> Unfortunately, I did not save the data, so I'll need to redo the
> experiment.
>    

I'm sure we can detect it experimentally, but how do we do it 
programatically at run time (without dropping all the pages).  
Situations change, and I don't think we can infer from a few experiments 
that we'll have a similar amount of sharing.  The cost of an incorrect 
decision is too high IMO (not that I think the kernel always chooses the 
right pages now, but I'd like to avoid regressions from the 
unvirtualized state).

btw, when running with a disk controller that has a very large cache, we 
might also see duplication between "guest" and host.  So, if this is a 
good idea, it shouldn't be enabled just for virtualization, but for any 
situation where we have a sizeable cache behind us.

>> It doesn't, really.  The host only has aggregate information about
>> itself, and no information about the guest.
>>
>> Dropping duplicate pages would be good if we could identify them.
>> Even then, it's better to drop the page from the host, not the
>> guest, unless we know the same page is cached by multiple guests.
>>
>>      
> On the exact pages to drop, please see my comments above on the class
> of pages to drop.
>    

Well, we disagree about that.  There is some value in dropping 
duplicated pages (not always), but that's not what the patch does.  It 
drops unmapped pagecache pages, which may or may not be duplicated.

> There are reasons for wanting to get the host to cache the data
>    

There are also reasons to get the guest to cache the data - it's more 
efficient to access it in the guest.

> Unless the guest is using cache = none, the data will still hit the
> host page cache
> The host can do a better job of optimizing the writeouts
>    

True, especially for non-raw storage.  But even there we have to fsync 
all the time to keep the metadata right.

>> But why would the guest voluntarily drop the cache?  If there is no
>> memory pressure, dropping caches increases cpu overhead and latency
>> even if the data is still cached on the host.
>>
>>      
> So, there are basically two approaches
>
> 1. First patch, proactive - enabled by a boot option
> 2. When ballooned, we try to (please NOTE try to) reclaim cached pages
> first. Failing which, we go after regular pages in the alloc_page()
> call in the balloon driver.
>    

Doesn't that mean you may evict a RU mapped page ahead of an LRU 
unmapped page, just in the hope that it is double-cached?

Maybe we need the guest and host to talk to each other about which pages 
to keep.

>>> 2. Drop the cache on either a special balloon option, again the host
>>> knows it caches that very same information, so it prefers to free that
>>> up first.
>>>        
>> Dropping in response to pressure is good.  I'm just not convinced
>> the patch helps in selecting the correct page to drop.
>>
>>      
> That is why I've presented data on the experiments I've run and
> provided more arguments to backup the approach.
>    

I'm still unconvinced, sorry.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
