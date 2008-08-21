Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m7L3QoZR030111
	for <linux-mm@kvack.org>; Thu, 21 Aug 2008 13:26:50 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7L3Q124183962
	for <linux-mm@kvack.org>; Thu, 21 Aug 2008 13:26:01 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7L3Q0qk023370
	for <linux-mm@kvack.org>; Thu, 21 Aug 2008 13:26:01 +1000
Message-ID: <48ACE040.2030807@linux.vnet.ibm.com>
Date: Thu, 21 Aug 2008 08:55:52 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [discuss] memrlimit - potential applications that can use
References: <48AA73B5.7010302@linux.vnet.ibm.com> <1219161525.23641.125.camel@nimitz>  <48AAF8C0.1010806@linux.vnet.ibm.com> <1219167669.23641.156.camel@nimitz>  <48ABD545.8010209@linux.vnet.ibm.com> <1219249757.8960.22.camel@nimitz>
In-Reply-To: <1219249757.8960.22.camel@nimitz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Andrea Righi <righi.andrea@gmail.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Wed, 2008-08-20 at 13:56 +0530, Balbir Singh wrote:
>> Dave Hansen wrote:
>>> On Tue, 2008-08-19 at 22:15 +0530, Balbir Singh wrote:
>>>> Dave Hansen wrote:
>>>>> On Tue, 2008-08-19 at 12:48 +0530, Balbir Singh wrote:
>>>>>> 1. To provide a soft landing mechanism for applications that exceed their memory
>>>>>> limit. Currently in the memory resource controller, we swap and on failure OOM.
>>>>>> 2. To provide a mechanism similar to memory overcommit for control groups.
>>>>>> Overcommit has finer accounting, we just account for virtual address space usage.
>>>>>> 3. Vserver will directly be able to port over on top of memrlimit (their address
>>>>>> space limitation feature)
>>>>> Balbir,
>>>>>
>>>>> This all seems like a little bit too much hand waving to me.  I don't
>>>> Dave, there is no hand waving, just an honest discussion. Although, you may not
>>>> see it in the background, we still need overcommit protection and we have it
>>>> enabled by default for the system. There are applications that can deal with the
>>>> constraints setup by the administrator and constraints of the environment,
>>>> please see http://en.wikipedia.org/wiki/Autonomic_computing.
>>> OK, let's get back to describing the basic problem here.  What is the
>>> basic problem being solved?  Applications basically want to get a
>>> failure back from malloc() when the machine is (nearly?) out of memory
>>> so they can stop consuming?
>>>
>>> Is this the only way to do autonomic computing with memory?  Or, are
>>> there other or better approaches?
>>>
>> Yes, an application does know it's memory footprint, but does it know how it is
>> supposed to consume resources in the system. Consider a linear algebra package
>> trying to do a multiplication of 1 million x 1 million rows. Depending on how
>> much resources it is allowed to consume, it could do so in one shot or if there
>> was a restriction, it could multiply smaller matrices and then collate results.
>> The application wants to stretch itself (memory footprint) for performance, but
>> at the same time does not want to get killed because
>>
>> 1. Other applications came in and caused an OOM
>> 2. It stretched itself too much beyond what the system can support
> 
> So, in (2) it deserves to be oom'd.
> 

Not really, how does an application know how to trade-off between maximum
performance on a system vs consuming so much of the memory resource that it OOMs?

> If other applications came in and caused the oom, then we do
> have /proc/$pid/oom_adj to help out.  That's a much better tunable than
> overcommit.
> 

And oom_adj is not a hack? What if several memory hungry applications striving
for performance all turn oom_adj to preven themselves from being oom'ed?

>>>>> really see a single concrete user in the "potential applications" here.
>>>>> I really don't understand why you're pushing this so hard if you don't
>>>>> have anyone to actually use it.
>>>>>
>>>>> I just don't see anyone that *needs* it.  There's a lot of "it would be
>>>>> nice", but no "needs".
>>>> If you see the original email, I've sent - I've mentioned that we need
>>>> overcommit support (either via memrlimit or by porting over the overcommit
>>>> feature) and the exploiters you are looking for is the same as the ones who need
>>>> overcommit and RLIMIT_AS support.
>>>>
>>>> On the memory overcommit front, please see PostgreSQL Server Administrator's
>>>> Guide at
>>>> http://www.network-theory.co.uk/docs/postgresql/vol3/LinuxMemoryOvercommit.html
>>>>
>>>> The guide discusses turning off memory overcommit so that the database is never
>>>> OOM killed, how do we provide these guarantees for a particular control group?
>>>> We can do it system wide, but ideally we want the control point to be per
>>>> control group.
>>> Heh.  That suggestion is, at best, working around a kernel bug.  The DB
>>> guys are just saying to do that because they're the biggest memory users
>>> and always seem to get OOM killed first.
>>>
>>> The base problem here is the OOM killer, not an application that truly
>>> uses memory overcommit restriction in an interesting way.
>>>
>> No it is not a kernel BUG, agreed that the database is using a lot of memory,
>> but how can it predict what else will run on the system. Why is it bad for a
>> database for the sake of data integrity to ensure that it does not get OOM
>> killed and thus make sure memory is never overcommitted. Yes, you need
>> performance, so the application expands it's footprint, but at the same time,
>> the stretching should not cause it to be killed. How would you propose to solve
>> the problem without overcommit control?
> 
> I think that we're tying OOM'ing and overcommit a little too close
> together here.  It's not like you can't have OOMs when strict overcommit
> is being observed.
> 
> There are lots of other ways to lock memory down, and any one of those
> can also cause an oom.
> 

The other ways of locking memory down is mlock(), which by default is limited on
most distros. We'll end up implementing mlock() control per control group as well.

> Yes, userspace mapped memory is usually the largest single consumer, but
> the problem space is well beyond overcommit control.  Agreed?  Just look
> at why beancounters were implemented and track things far beyond
> userspace memory use.  
> 

I've looked at http://wiki.openvz.org/User_pages_accounting and it states

"Account a part of memory on mmap/brk and reject there, and account the rest of
the memory in page fault handlers without any rejects."
    This type of accounting is used in UBC.

I looked through the code in mm/mmap.c for beancounters, ub_memory_charge() is
called from almost the same places that the memrlimit controller does
accounting. Please see their git tree at git.openvz.org. My understanding of the
code is the private vm and locked vm pages are only charged in that
implementation. Agreed, they have additional finer accounting of kernel data
structures, but beancounters account for VM usage too.


>>> So, before we expand the use of those features to control groups by
>>> adding a bunch of new code, let's make sure that there will be users
>> for
>>> it and that those users have no better way of doing it.
>> I am all ears to better ways of doing it. Are you suggesting that overcommit was
>> added even though we don't actually need it?
> 
> It serves a purpose, certainly.  We have have better ways of doing it
> now, though.  "i>>?So, before we expand the use of those features to
> control groups by adding a bunch of new code, let's make sure that there
> will be users for it and that those users have no better way of doing
> it."
> 
> The one concrete user that's been offered so far is postgres.  I've

No, you've been offered several, including php and apache that use memory limits.

> suggested something that I hope will be more effective than enforcing
> overcommit.  

Is your suggestion beancounters?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
