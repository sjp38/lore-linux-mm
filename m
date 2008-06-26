Date: Thu, 26 Jun 2008 14:32:31 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] Re: [PATCH] - Fix stack overflow for large values of
	MAX_APICS
Message-ID: <20080626123231.GP29619@elte.hu>
References: <20080620025104.GA25571@sgi.com> <20080620103921.GC32500@elte.hu> <20080624102401.GA27614@elte.hu> <20080625205628.GA17411@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080625205628.GA17411@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Travis <travis@sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

* Jack Steiner <steiner@sgi.com> wrote:

> >> I added trace code & isolated the hang to a call to 
> >> synchronize_rcu(). Usually from netlink_change_ngroups().
> >> 
> >> If I boot with "maxcpus=1, it never hangs (obviously) but always fails
> >> to mount /root.
> >> 
> >> Next I changed NR_CPUS to 128. I still see random hangs.
> >> 
> >> 
> >> I'll chase this more tomorrow. Has anyone else seen any failures that might be
> >> related???
> >> 
> >> 
> 
> Is this already fixed? I see a number of patches to this area have been merged
> since the failure occurred.
> 
> I added enough hacks to get backtraces on threads at the time a hang occurs.
> show_state() shows 79 "kstopmachine" tasks. Most have one of the following backtraces:
> 
> 
> 	<6>kstopmachine  R  running task     6400   375    369
> 	 ffff8101ad28bd80 ffffffff8068c5c6 ffff8101ad28bb20 0000000000000002
> 	 0000000000000046 0000000000000000 0000000000002f42 ffff8101ad28c8b8
> 	 ffff8101ad28bb90 ffffffff80254fac 0000000100000000 0000000000000000
> 	Call Trace:
> 	   [<ffffffff8068c5c6>] ? thread_return+0x4d/0xbd
> 	   [<ffffffff80254fac>] ? __lock_acquire+0x643/0x6ad
> 	   [<ffffffff80212507>] ? sched_clock+0x9/0xc
> 	   [<ffffffff8022cf41>] ? update_curr_rt+0x111/0x11a
> 	   [<ffffffff80212507>] ? sched_clock+0x9/0xc
> 	   [<ffffffff8068c5f2>] ? thread_return+0x79/0xbd
> 	   [<ffffffff8068ef48>] ? _spin_unlock_irq+0x2b/0x37
> 	   [<ffffffff8068c5f2>] ? thread_return+0x79/0xbd
> 	   [<ffffffff80254fac>] ? __lock_acquire+0x643/0x6ad
> 	   [<ffffffff80212507>] ? sched_clock+0x9/0xc
> 	   [<ffffffff8068c806>] wait_for_common+0x150/0x160
> 	   [<ffffffff8068ef48>] ? _spin_unlock_irq+0x2b/0x37
> 	   [<ffffffff80254fac>] ? __lock_acquire+0x643/0x6ad
> 	   [<ffffffff80212507>] ? sched_clock+0x9/0xc
> 	   [<ffffffff8023422b>] ? sys_sched_yield+0x0/0x6e
> 	   [<ffffffff8026736d>] ? stopmachine+0xaf/0xda
> 	   [<ffffffff8020d558>] ? child_rip+0xa/0x12
> 	   [<ffffffff802672be>] ? stopmachine+0x0/0xda
> 	   [<ffffffff8020d54e>] ? child_rip+0x0/0x12
> 
> 	<6>kstopmachine  ? 0000000000000000  6400   367      1
> 	  ffff8101af9b9ee0 0000000000000046 0000000000000000 0000000000000000
> 	  0000000000000000 ffff8101af9b4000 ffff8101afdc0000 ffff8101af9b4540
> 	  0000000600000000 00000000ffff909f ffffffffffffffff ffffffffffffffff
> 	Call Trace:
> 	     [<ffffffff8023be98>] do_exit+0x6fe/0x702
> 	     [<ffffffff8020d55f>] child_rip+0x11/0x12
> 	     [<ffffffff802672be>] ? stopmachine+0x0/0xda
> 	     [<ffffffff8020d54e>] ? child_rip+0x0/0x12
> 
> 
> The boot thread shows:
> 	 <6>swapper       D 0000000000000002  2640     1      0
> 	  ffff8101afc3fcd0 0000000000000046 ffffffff807d8341 0000000000000200
> 	  ffffffff807d8335 ffff8101afc40000 ffff8101ad284000 ffff8101afc40540
> 	  00000005afc3faa0 ffffffff8021e837 ffff8101afc3fab0 ffff8101afc3fd50
> 
> 	 [<ffffffff8068c961>] schedule_timeout+0x27/0xb9
> 	 [<ffffffff8068ef48>] ? _spin_unlock_irq+0x2b/0x37
> 	 [<ffffffff8068c79c>] wait_for_common+0xe6/0x160
> 	 [<ffffffff8022d88a>] ? default_wake_function+0x0/0xf
> 	 [<ffffffff8068c8a0>] wait_for_completion+0x18/0x1a
> 	 [<ffffffff8024981a>] synchronize_rcu+0x3a/0x41
> 	 [<ffffffff802498a3>] ? wakeme_after_rcu+0x0/0x15
> 	 [<ffffffff805d8e1b>] netlink_change_ngroups+0xce/0xfc
> 	 [<ffffffff805da2c9>] genl_register_mc_group+0xfd/0x160
> 	 [<ffffffff80ac6d5d>] ? acpi_event_init+0x0/0x57
> 	 [<ffffffff80ac6d92>] acpi_event_init+0x35/0x57
> 	 [<ffffffff80aaca8c>] kernel_init+0x1c5/0x31f
> 
> 
> Is this hang already fixed or should I dig deeper?

there's no known hang in tip/master. I.e. removing your MAX_APICS patch 
clearly resolved that crash.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
