Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id C876B6B00E3
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 18:10:58 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id p10so15500637pdj.33
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 15:10:58 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id fg6si26774083pad.209.2014.11.13.15.10.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 15:10:57 -0800 (PST)
Message-ID: <54653A7C.80803@oracle.com>
Date: Thu, 13 Nov 2014 18:10:52 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: rcu_preempt detected stalls.
References: <20141013173504.GA27955@redhat.com> <543DDD5E.9080602@oracle.com> <20141023183917.GX4977@linux.vnet.ibm.com> <54494F2F.6020005@oracle.com> <20141023195808.GB4977@linux.vnet.ibm.com> <544A45F8.2030207@oracle.com> <20141024161337.GQ4977@linux.vnet.ibm.com> <544A80B3.9070800@oracle.com> <20141027211329.GJ5718@linux.vnet.ibm.com> <20141027234425.GA19438@linux.vnet.ibm.com> <20141113230751.GB26051@linux.vnet.ibm.com>
In-Reply-To: <20141113230751.GB26051@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, htejun@gmail.com, linux-mm@kvack.org

On 11/13/2014 06:07 PM, Paul E. McKenney wrote:
> On Mon, Oct 27, 2014 at 04:44:25PM -0700, Paul E. McKenney wrote:
>> > On Mon, Oct 27, 2014 at 02:13:29PM -0700, Paul E. McKenney wrote:
>>> > > On Fri, Oct 24, 2014 at 12:39:15PM -0400, Sasha Levin wrote:
>>>> > > > On 10/24/2014 12:13 PM, Paul E. McKenney wrote:
>>>>> > > > > On Fri, Oct 24, 2014 at 08:28:40AM -0400, Sasha Levin wrote:
>>>>>>> > > > >> > On 10/23/2014 03:58 PM, Paul E. McKenney wrote:
>>>>>>>>> > > > >>> > > On Thu, Oct 23, 2014 at 02:55:43PM -0400, Sasha Levin wrote:
>>>>>>>>>>>>> > > > >>>>> > >> > On 10/23/2014 02:39 PM, Paul E. McKenney wrote:
>>>>>>>>>>>>>>>>> > > > >>>>>>> > >>> > > On Tue, Oct 14, 2014 at 10:35:10PM -0400, Sasha Levin wrote:
>>>>>>>>>>>>>>>>>>>>> > > > >>>>>>>>> > >>>> > >> On 10/13/2014 01:35 PM, Dave Jones wrote:
>>>>>>>>>>>>>>>>>>>>>>>>> > > > >>>>>>>>>>> > >>>>> > >>> oday in "rcu stall while fuzzing" news:
>>>>>>>>>>>>>>>>>>>>>>>>> > > > >>>>>>>>>>> > >>>>> > >>>
>>>>>>>>>>>>>>>>>>>>>>>>> > > > >>>>>>>>>>> > >>>>> > >>> INFO: rcu_preempt detected stalls on CPUs/tasks:
>>>>>>>>>>>>>>>>>>>>>>>>> > > > >>>>>>>>>>> > >>>>> > >>> 	Tasks blocked on level-0 rcu_node (CPUs 0-3): P766 P646
>>>>>>>>>>>>>>>>>>>>>>>>> > > > >>>>>>>>>>> > >>>>> > >>> 	Tasks blocked on level-0 rcu_node (CPUs 0-3): P766 P646
>>>>>>>>>>>>>>>>>>>>>>>>> > > > >>>>>>>>>>> > >>>>> > >>> 	(detected by 0, t=6502 jiffies, g=75434, c=75433, q=0)
>>>>>>>>>>>>>>>>>>>>> > > > >>>>>>>>> > >>>> > >>
>>>>>>>>>>>>>>>>>>>>> > > > >>>>>>>>> > >>>> > >> I've complained about RCU stalls couple days ago (in a different context)
>>>>>>>>>>>>>>>>>>>>> > > > >>>>>>>>> > >>>> > >> on -next. I guess whatever causing them made it into Linus's tree?
>>>>>>>>>>>>>>>>>>>>> > > > >>>>>>>>> > >>>> > >>
>>>>>>>>>>>>>>>>>>>>> > > > >>>>>>>>> > >>>> > >> https://lkml.org/lkml/2014/10/11/64
>>>>>>>>>>>>>>>>> > > > >>>>>>> > >>> > > 
>>>>>>>>>>>>>>>>> > > > >>>>>>> > >>> > > And on that one, I must confess that I don't see where the RCU read-side
>>>>>>>>>>>>>>>>> > > > >>>>>>> > >>> > > critical section might be.
>>>>>>>>>>>>>>>>> > > > >>>>>>> > >>> > > 
>>>>>>>>>>>>>>>>> > > > >>>>>>> > >>> > > Hmmm...  Maybe someone forgot to put an rcu_read_unlock() somewhere.
>>>>>>>>>>>>>>>>> > > > >>>>>>> > >>> > > Can you reproduce this with CONFIG_PROVE_RCU=y?
>>>>>>>>>>>>> > > > >>>>> > >> > 
>>>>>>>>>>>>> > > > >>>>> > >> > Paul, if that was directed to me - Yes, I see stalls with CONFIG_PROVE_RCU
>>>>>>>>>>>>> > > > >>>>> > >> > set and nothing else is showing up before/after that.
>>>>>>>>> > > > >>> > > Indeed it was directed to you.  ;-)
>>>>>>>>> > > > >>> > > 
>>>>>>>>> > > > >>> > > Does the following crude diagnostic patch turn up anything?
>>>>>>> > > > >> > 
>>>>>>> > > > >> > Nope, seeing stalls but not seeing that pr_err() you added.
>>>>> > > > > OK, color me confused.  Could you please send me the full dmesg or a
>>>>> > > > > pointer to it?
>>>> > > > 
>>>> > > > Attached.
>>> > > 
>>> > > Thank you!  I would complain about the FAULT_INJECTION messages, but
>>> > > they don't appear to be happening all that frequently.
>>> > > 
>>> > > The stack dumps do look different here.  I suspect that this is a real
>>> > > issue in the VM code.
>> > 
>> > And to that end...  The filemap_map_pages() function does have loop over
>> > a list of pages.  I wonder if the rcu_read_lock() should be moved into
>> > the radix_tree_for_each_slot() loop.  CCing linux-mm for their thoughts,
>> > though it looks to me like the current radix_tree_for_each_slot() wants
>> > to be under RCU protection.  But I am not seeing anything that requires
>> > all iterations of the loop to be under the same RCU read-side critical
>> > section.  Maybe something like the following patch?
> Just following up, did the patch below help?

I'm not seeing any more stalls with filemap in them, but I don see different
traces.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
