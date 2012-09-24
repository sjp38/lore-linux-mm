Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 4D4CE6B0062
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 16:17:31 -0400 (EDT)
Date: Mon, 24 Sep 2012 22:17:26 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: divide error: bdi_dirty_limit+0x5a/0x9e
Message-ID: <20120924201726.GB30997@quack.suse.cz>
References: <20120924102324.GA22303@aftab.osrc.amd.com>
 <20120924142305.GD12264@quack.suse.cz>
 <20120924143609.GH22303@aftab.osrc.amd.com>
 <20120924201650.6574af64.conny.seidel@amd.com>
 <20120924181927.GA25762@aftab.osrc.amd.com>
 <5060AB0E.3070809@linux.vnet.ibm.com>
 <20120924193135.GB25762@aftab.osrc.amd.com>
 <20120924200737.GA30997@quack.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="+HP7ph2BbKc20aGI"
Content-Disposition: inline
In-Reply-To: <20120924200737.GA30997@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@amd64.org>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Conny Seidel <conny.seidel@amd.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon 24-09-12 22:07:37, Jan Kara wrote:
> On Mon 24-09-12 21:31:35, Borislav Petkov wrote:
> > On Tue, Sep 25, 2012 at 12:18:46AM +0530, Srivatsa S. Bhat wrote:
> > > >> Sure thing.
> > > >> Out of ~25 runs I only triggered it once, without the patch the
> > > >> trigger-rate is higher.
> > > >>
> > > >> [   55.098249] Broke affinity for irq 81
> > > >> [   55.105108] smpboot: CPU 1 is now offline
> > > >> [   55.311216] smpboot: Booting Node 0 Processor 1 APIC 0x11
> > > >> [   55.333022] LVT offset 0 assigned for vector 0x400
> > > >> [   55.545877] smpboot: CPU 2 is now offline
> > > >> [   55.753050] smpboot: Booting Node 0 Processor 2 APIC 0x12
> > > >> [   55.775582] LVT offset 0 assigned for vector 0x400
> > > >> [   55.986747] smpboot: CPU 3 is now offline
> > > >> [   56.193839] smpboot: Booting Node 0 Processor 3 APIC 0x13
> > > >> [   56.212643] LVT offset 0 assigned for vector 0x400
> > > >> [   56.423201] Got negative events: -25
> > > > 
> > > > I see it:
> > > > 
> > > > __percpu_counter_sum does for_each_online_cpu without doing
> > > > get/put_online_cpus().
> > > > 
> > > 
> > > Maybe I'm missing something, but that doesn't immediately tell me
> > > what's the exact source of the bug.. Note that there is a hotplug
> > > callback percpu_counter_hotcpu_callback() that takes the same
> > > fbc->lock before updating/resetting the percpu counters of offline
> > > CPU. So, though the synchronization is a bit weird, I don't
> > > immediately see a problematic race condition there.
> > 
> > Well, those oopses both happen when a cpu comes online.
> > 
> > According to when percpu_counter_hotcpu_callback is run (at CPU_DEAD)
> > then those percpu variables should have correctly updated values.
> > 
> > So there has to be some other case where we read garbage which is a
> > negative value - otherwise we wouldn't be seeing the debug output.
> > 
> > For example, look at the log output above: we bring down cpu 3 just to
> > bring it right back online. So there has to be something fishy along
> > that codepath...
>   Well, I think the race happens when a CPU is dying and we call
> percpu_counter_sum() after it is marked offline but before callbacks are
> run. percpu_counter_sum() then does not add died CPU's counter in the sum
> and thus total can go negative. If get/put_online_cpus() fixes this race,
> I'd be happy.
> 
>   OTOH in theory, percpu_counter_sum() can return negative values even
> without CPU hotplug when percpu_counter_sum() races with cpu local
> operations. It cannot happen with the current flexible proportion code
> but I think making the code more robust is a good idea. I'll send a patch
> for this. Still fixing the percpu counters would be nice as these races
> could cause random errors to computed proportions and that's bad for
> writeback.
  In the attachment is a fix. Fengguang, can you please merge it? Thanks!

								Honza

--+HP7ph2BbKc20aGI
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-lib-Fix-corruption-of-denominator-in-flexible-propor.patch"


--+HP7ph2BbKc20aGI--
