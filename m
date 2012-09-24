Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id C95CC6B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 15:31:42 -0400 (EDT)
Date: Mon, 24 Sep 2012 21:31:35 +0200
From: Borislav Petkov <bp@amd64.org>
Subject: Re: divide error: bdi_dirty_limit+0x5a/0x9e
Message-ID: <20120924193135.GB25762@aftab.osrc.amd.com>
References: <20120924102324.GA22303@aftab.osrc.amd.com>
 <20120924142305.GD12264@quack.suse.cz>
 <20120924143609.GH22303@aftab.osrc.amd.com>
 <20120924201650.6574af64.conny.seidel@amd.com>
 <20120924181927.GA25762@aftab.osrc.amd.com>
 <5060AB0E.3070809@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5060AB0E.3070809@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Conny Seidel <conny.seidel@amd.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, Sep 25, 2012 at 12:18:46AM +0530, Srivatsa S. Bhat wrote:
> >> Sure thing.
> >> Out of ~25 runs I only triggered it once, without the patch the
> >> trigger-rate is higher.
> >>
> >> [   55.098249] Broke affinity for irq 81
> >> [   55.105108] smpboot: CPU 1 is now offline
> >> [   55.311216] smpboot: Booting Node 0 Processor 1 APIC 0x11
> >> [   55.333022] LVT offset 0 assigned for vector 0x400
> >> [   55.545877] smpboot: CPU 2 is now offline
> >> [   55.753050] smpboot: Booting Node 0 Processor 2 APIC 0x12
> >> [   55.775582] LVT offset 0 assigned for vector 0x400
> >> [   55.986747] smpboot: CPU 3 is now offline
> >> [   56.193839] smpboot: Booting Node 0 Processor 3 APIC 0x13
> >> [   56.212643] LVT offset 0 assigned for vector 0x400
> >> [   56.423201] Got negative events: -25
> > 
> > I see it:
> > 
> > __percpu_counter_sum does for_each_online_cpu without doing
> > get/put_online_cpus().
> > 
> 
> Maybe I'm missing something, but that doesn't immediately tell me
> what's the exact source of the bug.. Note that there is a hotplug
> callback percpu_counter_hotcpu_callback() that takes the same
> fbc->lock before updating/resetting the percpu counters of offline
> CPU. So, though the synchronization is a bit weird, I don't
> immediately see a problematic race condition there.

Well, those oopses both happen when a cpu comes online.

According to when percpu_counter_hotcpu_callback is run (at CPU_DEAD)
then those percpu variables should have correctly updated values.

So there has to be some other case where we read garbage which is a
negative value - otherwise we wouldn't be seeing the debug output.

For example, look at the log output above: we bring down cpu 3 just to
bring it right back online. So there has to be something fishy along
that codepath...

Hmm.

-- 
Regards/Gruss,
Boris.

Advanced Micro Devices GmbH
Einsteinring 24, 85609 Dornach
GM: Alberto Bozzo
Reg: Dornach, Landkreis Muenchen
HRB Nr. 43632 WEEE Registernr: 129 19551

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
