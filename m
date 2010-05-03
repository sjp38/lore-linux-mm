Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 773096B0288
	for <linux-mm@kvack.org>; Mon,  3 May 2010 05:39:27 -0400 (EDT)
Message-ID: <4BDE99C8.1090002@redhat.com>
Date: Mon, 03 May 2010 12:39:20 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com>> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>> <4BD1A74A.2050003@redhat.com>> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>> <4BD1B427.9010905@redhat.com> <4BD1B626.7020702@redhat.com>> <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>> <4BD3377E.6010303@redhat.com>> <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>> <ce808441-fae6-4a33-8335-f7702740097a@default>> <20100428055538.GA1730@ucw.cz> <1272591924.23895.807.camel@nimitz> <4BDA8324.7090409@redhat.com> <084f72bf-21fd-4721-8844-9d10cccef316@default> <4BDB026E.1030605@redhat.com> <4BDB18CE.2090608@goop.org> <4BDB2069.4000507@redhat.com> <3a62a058-7976-48d7-acd2-8c6a8312f10f@default> <4BDD3079.5060101@vflare.org> <b09a9cc6-8481-4dd3-8374-68ff6fb714d9@default 4BDDACF5.90601@redhat.com> <b6cfd097-1003-47ce-9f1c-278835ba52d2@default>
In-Reply-To: <b6cfd097-1003-47ce-9f1c-278835ba52d2@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: ngupta@vflare.org, Jeremy Fitzhardinge <jeremy@goop.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 05/02/2010 08:22 PM, Dan Magenheimer wrote:
>> It's bad, but it's better than ooming.
>>
>> The same thing happens with vcpus: you run 10 guests on one core, if
>> they all wake up, your cpu is suddenly 10x slower and has 30000x
>> interrupt latency (30ms vs 1us, assuming 3ms timeslices).  Your disks
>> become slower as well.
>>
>> It's worse with memory, so you try to swap as a last resort.  However,
>> swap is still faster than a crashed guest.
>>      
> Your analogy only holds when the host administrator is either
> extremely greedy or stupid.

10x vcpu is reasonable in some situations (VDI, powersave at night).  
Even a 2x vcpu overcommit will cause a 10000x interrupt latency degradation.

> My analogy only requires some
> statistical bad luck: Multiple guests with peaks and valleys
> of memory requirements happen to have their peaks align.
>    

Not sure I understand.

>>> Third, host swapping makes live migration much more difficult.
>>> Either the host swap disk must be accessible to all machines
>>> or data sitting on a local disk MUST be migrated along with
>>> RAM (which is not impossible but complicates live migration
>>> substantially).
>>>        
>> kvm does live migration with swapping, and has no special code to
>> integrate them.
>>   :
>> Don't know about vmware, but kvm supports page sharing, swapping, and
>> live migration simultaneously.
>>      
> Hmmm... I'll bet I can break it pretty easily.  I think the
> case you raised that you thought would cause host OOM'ing
> will cause kvm live migration to fail.
>
> Or maybe not... when a guest is in the middle of a live migration,
> I believe (in Xen), the entire guest memory allocation (possibly
> excluding ballooned-out pages) must be simultaneously in RAM briefly
> in BOTH the host and target machine.  That is, live migration is
> not "pipelined".  Is this also true of KVM?

No.  The entire guest address space can be swapped out on the source and 
target, less the pages being copied to or from the wire, and pages 
actively accessed by the guest.  Of course performance will suck if all 
memory is swapped out.

> If so, your
> statement above is just waiting a corner case to break it.
> And if not, I expect you've got fault tolerance issues.
>    

Not that I'm aware of.

>>> If you talk to VMware customers (especially web-hosting services)
>>> that have attempted to use overcommit technologies that require
>>> host-swapping, you will find that they quickly become allergic
>>> to memory overcommit and turn it off.  The end users (users of
>>> the VMs that inexplicably grind to a halt) complain loudly.
>>> As a result, RAM has become a bottleneck in many many systems,
>>> which ultimately reduces the utility of servers and the value
>>> of virtualization.
>>>        
>> Choosing the correct overcommit ratio is certainly not an easy task.
>> However, just hoping that memory will be available when you need it is
>> not a good solution.
>>      
> Choosing the _optimal_ overcommit ratio is impossible without a
> prescient knowledge of the workload in each guest.  Hoping memory
> will be available is certainly not a good solution, but if memory
> is not available guest swapping is much better than host swapping.
>    

You cannot rely on guest swapping.

> And making RAM usage as dynamic as possible and live migration
> as easy as possible are keys to maximizing the benefits (and
> limiting the problems) of virtualization.
>    

That is why you need overcommit.  You make things dynamic with page 
sharing and ballooning and live migration, but at some point you need a 
failsafe fallback.  The only failsafe fallback I can see (where the host 
doesn't rely on guests) is swapping.

As far as I can tell, frontswap+tmem increases the problem.  You loan 
the guest some memory without the means to take it back, this increases 
memory pressure on the host.  The result is that if you want to avoid 
swapping (or are unable to) you need to undercommit host resources.  
Instead of sum(guest mem) + reserve < (host mem), you need sum(guest mem 
+ committed tmem) + reserve < (host mem).  You need more host memory, or 
less guests, or to be prepared to swap if the worst happens.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
