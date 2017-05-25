Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 12C306B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 15:35:34 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z142so85228582qkz.8
        for <linux-mm@kvack.org>; Thu, 25 May 2017 12:35:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t72si4075938qkt.211.2017.05.25.12.35.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 12:35:32 -0700 (PDT)
Date: Thu, 25 May 2017 16:35:08 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
Message-ID: <20170525193508.GA30252@amt.cnet>
References: <alpine.DEB.2.20.1705121002310.22243@east.gentwo.org>
 <20170512154026.GA3556@amt.cnet>
 <alpine.DEB.2.20.1705121103120.22831@east.gentwo.org>
 <20170512161915.GA4185@amt.cnet>
 <alpine.DEB.2.20.1705121154240.23503@east.gentwo.org>
 <20170515191531.GA31483@amt.cnet>
 <alpine.DEB.2.20.1705160825480.32761@east.gentwo.org>
 <20170519143407.GA19282@amt.cnet>
 <alpine.DEB.2.20.1705191205580.19631@east.gentwo.org>
 <20170519134934.0c298882@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170519134934.0c298882@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>, Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

On Fri, May 19, 2017 at 01:49:34PM -0400, Luiz Capitulino wrote:
> On Fri, 19 May 2017 12:13:26 -0500 (CDT)
> Christoph Lameter <cl@linux.com> wrote:
> 
> > > So why are you against integrating this simple, isolated patch which
> > > does not affect how current logic works?  
> > 
> > Frankly the argument does not make sense. Vmstat updates occur very
> > infrequently (probably even less than you IPIs and the other OS stuff that
> > also causes additional latencies that you seem to be willing to tolerate).
> 
> Infrequently is not good enough. It only has to happen once to
> cause a problem.
> 
> Also, IPIs take a few us, usually less. That's not a problem. In our
> testing we see the preemption caused by the kworker take 10us or
> even more. I've never seeing it take 3us. I'm not saying this is not
> true, I'm saying if this is causing a problem to us it will cause
> a problem to other people too.

Christoph, 

Some data:

 qemu-system-x86-12902 [003] ....1..  6517.621557: kvm_exit: reason
EXTERNAL_INTERRUPT rip 0x4004f1 info 0 800000fc
 qemu-system-x86-12902 [003] d...2..  6517.621557: kvm_entry: vcpu 2
 qemu-system-x86-12902 [003] ....1..  6517.621560: kvm_exit: reason
EXTERNAL_INTERRUPT rip 0x4004f1 info 0 800000fc
 qemu-system-x86-12902 [003] d...2..  6517.621561: kvm_entry: vcpu 2
 qemu-system-x86-12902 [003] ....1..  6517.621563: kvm_exit: reason
EXTERNAL_INTERRUPT rip 0x4004f1 info 0 800000fc
 qemu-system-x86-12902 [003] d...2..  6517.621564: kvm_entry: vcpu 2
 qemu-system-x86-12902 [003] d..h1..  6517.622037: empty_smp_call_func:
empty_smp_call_func ran
 qemu-system-x86-12902 [003] ....1..  6517.622040: kvm_exit: reason
EXTERNAL_INTERRUPT rip 0x4004f1 info 0 800000fb
 qemu-system-x86-12902 [003] d...2..  6517.622041: kvm_entry: vcpu 2

empty_smp_function_call: 3us.

 qemu-system-x86-12902 [003] ....1..  6517.702739: kvm_exit: reason
EXTERNAL_INTERRUPT rip 0x4004f1 info 0 800000ef
 qemu-system-x86-12902 [003] d...2..  6517.702741: kvm_entry: vcpu 2
 qemu-system-x86-12902 [003] d..h1..  6517.702758: scheduler_tick
<-update_process_times
 qemu-system-x86-12902 [003] ....1..  6517.702760: kvm_exit: reason
EXTERNAL_INTERRUPT rip 0x4004f1 info 0 800000ef
 qemu-system-x86-12902 [003] d...2..  6517.702760: kvm_entry: vcpu 2

scheduler_tick: 2us.

 qemu-system-x86-12902 [003] ....1..  6518.194570: kvm_exit: reason
EXTERNAL_INTERRUPT rip 0x4004f1 info 0 800000ef
 qemu-system-x86-12902 [003] d...2..  6518.194571: kvm_entry: vcpu 2
 qemu-system-x86-12902 [003] ....1..  6518.194591: kvm_exit: reason
EXTERNAL_INTERRUPT rip 0x4004f1 info 0 800000ef
 qemu-system-x86-12902 [003] d...2..  6518.194593: kvm_entry: vcpu 2

That, and the 10us number for kworker mentioned above changes your
point of view of your 
"Frankly the argument does not make sense. Vmstat updates occur very
infrequently (probably even less than you IPIs and the other OS stuff that
also causes additional latencies that you seem to be willing to tolerate).
And you can configure the interval of vmstat updates freely.... Set
 the vmstat_interval to 60 seconds instead of 2 for a try? Is that rare
enough?" 

Argument? We're showing you the data that this is causing a latency
problem for us.

Is there anything you'd like to be improved on the patch?
Is there anything you dislike about it?

> No, we'd have to set it high enough to disable it and this will
> affect all CPUs.
> 
> Something that crossed my mind was to add a new tunable to set
> the vmstat_interval for each CPU, this way we could essentially
> disable it to the CPUs where DPDK is running. What's the implications
> of doing this besides not getting up to date stats in /proc/vmstat
> (which I still have to confirm would be OK)? Can this break anything
> in the kernel for example?

Well, you get incorrect statistics. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
