Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3A3C46B01D6
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 07:39:06 -0400 (EDT)
Message-ID: <4C18B7D6.5070300@redhat.com>
Date: Wed, 16 Jun 2010 14:39:02 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>	 <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>	 <4C10B3AF.7020908@redhat.com> <20100610142512.GB5191@balbir.in.ibm.com>	 <1276214852.6437.1427.camel@nimitz>	 <20100611045600.GE5191@balbir.in.ibm.com> <4C15E3C8.20407@redhat.com>	 <20100614084810.GT5191@balbir.in.ibm.com> <4C16233C.1040108@redhat.com>	 <20100614125010.GU5191@balbir.in.ibm.com> <4C162846.7030303@redhat.com>	 <1276529596.6437.7216.camel@nimitz> <4C164E63.2020204@redhat.com>	 <1276530932.6437.7259.camel@nimitz> <4C1659F8.3090300@redhat.com>	 <1276538293.6437.7528.camel@nimitz>  <4C1726C4.8050300@redhat.com> <1276613249.6437.11516.camel@nimitz>
In-Reply-To: <1276613249.6437.11516.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: balbir@linux.vnet.ibm.com, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 06/15/2010 05:47 PM, Dave Hansen wrote:
>
>> That's a bug that needs to be fixed.  Eventually the host will come
>> under pressure and will balloon the guest.  If that kills the guest, the
>> ballooning is not effective as a host memory management technique.
>>      
> I'm not convinced that it's just a bug that can be fixed.  Consider a
> case where a host sees a guest with 100MB of free memory at the exact
> moment that a database app sees that memory.  The host tries to balloon
> that memory away at the same time that the app goes and allocates it.
> That can certainly lead to an OOM very quickly, even for very small
> amounts of memory (much less than 100MB).  Where's the bug?
>
> I think the issues are really fundamental to ballooning.
>    

There are two issues involved.

One is, can the kernel accurately determine the amount of memory it 
needs to work?  We have resources such as RAM and swap.  We have 
liabilities in the form of swappable userspace memory, mlocked userspace 
memory, kernel memory to support these, and various reclaimable and 
non-reclaimable kernel caches.  Can we determine the minimum amount of 
RAM to support are workload at a point in time?

If we had this, we could modify the balloon to refuse to balloon if it 
takes the kernel beneath the minimum amount of RAM needed.

In fact, this is similar to allocating memory with overcommit_memory = 
0.  The difference is the balloon allocates mlocked memory, while normal 
allocations can be charged against swap.  But fundamentally it's the same.

>>> If all the guests do this, then it leaves that much more free memory on
>>> the host, which can be used flexibly for extra host page cache, new
>>> guests, etc...
>>>        
>> If the host detects lots of pagecache misses it can balloon guests
>> down.  If pagecache is quiet, why change anything?
>>      
> Page cache misses alone are not really sufficient.  This is the classic
> problem where we try to differentiate streaming I/O (which we can't
> effectively cache) from I/O which can be effectively cached.
>    

True.  Random I/O across a very large dataset is also difficult to cache.

>> If the host wants to start new guests, it can balloon guests down.  If
>> no new guests are wanted, why change anything?
>>      
> We're talking about an environment which we're always trying to
> optimize.  Imagine that we're always trying to consolidate guests on to
> smaller numbers of hosts.  We're effectively in a state where we
> _always_ want new guests.
>    

If this came at no cost to the guests, you'd be right.  But at some 
point guest performance will be hit by this, so the advantage gained 
from freeing memory will be balanced by the disadvantage.

Also, memory is not the only resource.  At some point you become cpu 
bound; at that point freeing memory doesn't help and in fact may 
increase your cpu load.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
