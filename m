Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 755AB6B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 14:49:28 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 25 Sep 2012 00:19:23 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8OInJMP32178336
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 00:19:20 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8OInJvN030148
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 04:49:19 +1000
Message-ID: <5060AB0E.3070809@linux.vnet.ibm.com>
Date: Tue, 25 Sep 2012 00:18:46 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: divide error: bdi_dirty_limit+0x5a/0x9e
References: <20120924102324.GA22303@aftab.osrc.amd.com> <20120924142305.GD12264@quack.suse.cz> <20120924143609.GH22303@aftab.osrc.amd.com> <20120924201650.6574af64.conny.seidel@amd.com> <20120924181927.GA25762@aftab.osrc.amd.com>
In-Reply-To: <20120924181927.GA25762@aftab.osrc.amd.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@amd64.org>
Cc: Conny Seidel <conny.seidel@amd.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On 09/24/2012 11:49 PM, Borislav Petkov wrote:
> On Mon, Sep 24, 2012 at 08:16:50PM +0200, Conny Seidel wrote:
>> Hi,
>>
>> On Mon, 24 Sep 2012 16:36:09 +0200
>> Borislav Petkov <bp@amd64.org> wrote:
>>> [ a?| ]
>>>
>>> Conny, would you test pls?
>>
>> Sure thing.
>> Out of ~25 runs I only triggered it once, without the patch the
>> trigger-rate is higher.
>>
>> [   55.098249] Broke affinity for irq 81
>> [   55.105108] smpboot: CPU 1 is now offline
>> [   55.311216] smpboot: Booting Node 0 Processor 1 APIC 0x11
>> [   55.333022] LVT offset 0 assigned for vector 0x400
>> [   55.545877] smpboot: CPU 2 is now offline
>> [   55.753050] smpboot: Booting Node 0 Processor 2 APIC 0x12
>> [   55.775582] LVT offset 0 assigned for vector 0x400
>> [   55.986747] smpboot: CPU 3 is now offline
>> [   56.193839] smpboot: Booting Node 0 Processor 3 APIC 0x13
>> [   56.212643] LVT offset 0 assigned for vector 0x400
>> [   56.423201] Got negative events: -25
> 
> I see it:
> 
> __percpu_counter_sum does for_each_online_cpu without doing
> get/put_online_cpus().
> 

Maybe I'm missing something, but that doesn't immediately tell me
what's the exact source of the bug.. Note that there is a hotplug
callback percpu_counter_hotcpu_callback() that takes the same
fbc->lock before updating/resetting the percpu counters of offline
CPU. So, though the synchronization is a bit weird, I don't
immediately see a problematic race condition there.

And, speaking of hotplug callbacks, on a slightly different note,
I see one defined as ratelimit_handler(), which calls
writeback_set_ratelimit() for *every single* state change in the
hotplug sequence! Is that really intentional? num_online_cpus()
changes its value only -once- for every hotplug :-)

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
