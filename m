Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BDB7F6B0225
	for <linux-mm@kvack.org>; Sun,  2 May 2010 12:49:06 -0400 (EDT)
Message-ID: <4BDDACF5.90601@redhat.com>
Date: Sun, 02 May 2010 19:48:53 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com>> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>> <4BD1A74A.2050003@redhat.com>> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>> <4BD1B427.9010905@redhat.com> <4BD1B626.7020702@redhat.com>> <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>> <4BD3377E.6010303@redhat.com>> <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>> <ce808441-fae6-4a33-8335-f7702740097a@default>> <20100428055538.GA1730@ucw.cz> <1272591924.23895.807.camel@nimitz> <4BDA8324.7090409@redhat.com> <084f72bf-21fd-4721-8844-9d10cccef316@default> <4BDB026E.1030605@redhat.com> <4BDB18CE.2090608@goop.org> <4BDB2069.4000507@redhat.com> <3a62a058-7976-48d7-acd2-8c6a8312f10f@default 4BDD3079.5060101@vflare.org> <b09a9cc6-8481-4dd3-8374-68ff6fb714d9@default>
In-Reply-To: <b09a9cc6-8481-4dd3-8374-68ff6fb714d9@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: ngupta@vflare.org, Jeremy Fitzhardinge <jeremy@goop.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 05/02/2010 07:06 PM, Dan Magenheimer wrote:
>>> NO!  Frontswap on Xen+tmem never *never* _never_ NEVER results
>>> in host swapping.  Host swapping is evil.  Host swapping is
>>> the root of most of the bad reputation that memory overcommit
>>> has gotten from VMware customers.  Host swapping can't be
>>> avoided with some memory overcommit technologies (such as page
>>> sharing), but frontswap on Xen+tmem CAN and DOES avoid it.
>>>        
>> Why host-level swapping is evil? In KVM case, VM is just another
>> process and host will just swap out pages using the same LRU like
>> scheme as with any other process, AFAIK.
>>      
> The first problem is that you are simulating a fast resource
> (RAM) with a resource that is orders of magnitude slower with
> NO visibility to the user that suffers the consequences.  A good
> analogy (and no analogy is perfect) is if Linux discovers a 16MHz
> 80286 on a serial card in addition to the 32 3GHz cores on a
> Nehalem box and, whenever the 32 cores are all busy, randomly
> schedules a process on the 80286, while recording all CPU usage
> data as if the 80286 is a "real" processor.... "Hmmm... why
> did my compile suddenly run 100 times slower?"
>    

It's bad, but it's better than ooming.

The same thing happens with vcpus: you run 10 guests on one core, if 
they all wake up, your cpu is suddenly 10x slower and has 30000x 
interrupt latency (30ms vs 1us, assuming 3ms timeslices).  Your disks 
become slower as well.

It's worse with memory, so you try to swap as a last resort.  However, 
swap is still faster than a crashed guest.


> The second problem is "double swapping": A guest may choose
> a page to swap to "guest swap", but invisibly to the guest,
> the host first must fetch it from "host swap".  (This may
> seem like it is easy to avoid... it is not and happens more
> frequently than you might think.)
>    

True.  In fact when the guest and host use the same LRU algorithm, it 
becomes even likelier.  That's one of the things CMM2 addresses.

> Third, host swapping makes live migration much more difficult.
> Either the host swap disk must be accessible to all machines
> or data sitting on a local disk MUST be migrated along with
> RAM (which is not impossible but complicates live migration
> substantially).

kvm does live migration with swapping, and has no special code to 
integrate them.

>    Last I checked, VMware does not allow
> page-sharing and live migration to both be enabled for the
> same host.
>    

Don't know about vmware, but kvm supports page sharing, swapping, and 
live migration simultaneously.

> If you talk to VMware customers (especially web-hosting services)
> that have attempted to use overcommit technologies that require
> host-swapping, you will find that they quickly become allergic
> to memory overcommit and turn it off.  The end users (users of
> the VMs that inexplicably grind to a halt) complain loudly.
> As a result, RAM has become a bottleneck in many many systems,
> which ultimately reduces the utility of servers and the value
> of virtualization.
>    

Choosing the correct overcommit ratio is certainly not an easy task.  
However, just hoping that memory will be available when you need it is 
not a good solution.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
