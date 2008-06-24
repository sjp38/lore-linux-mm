Date: Tue, 24 Jun 2008 17:03:35 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [bug] Re: [PATCH] - Fix stack overflow for large values of MAX_APICS
Message-ID: <20080624220335.GA8039@sgi.com>
References: <20080620025104.GA25571@sgi.com> <20080620103921.GC32500@elte.hu> <20080624102401.GA27614@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080624102401.GA27614@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Travis <travis@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 24, 2008 at 12:24:01PM +0200, Ingo Molnar wrote:
> 
> * Ingo Molnar <mingo@elte.hu> wrote:
> 
> > * Jack Steiner <steiner@sgi.com> wrote:
> > 
> > > physid_mask_of_physid() causes a huge stack (12k) to be created if 
> > > the number of APICS is large. Replace physid_mask_of_physid() with a 
> > > new function that does not create large stacks. This is a problem 
> > > only on large x86_64 systems.
> > 
> > this indeed fixes the crash i reported here:
> > 
> >    http://lkml.org/lkml/2008/6/19/98
> > 
> > so i've added both this and the MAXAPICS patch to tip/x86/uv, and will 
> > test it some more. Lets hope it goes all well this time :-)
> 
> -tip auto-testing found a new boot failure on x86 which happens if 
> NR_CPUS is changed from 8 to 4096. The hang goes like this:
> 

Still looking but here is what I have found so far.

The most obvious change was to revert the patch that changed MAX_APICS to
32k. With this patch reverted, the system still hangs at the same spot.

I noticed that the hang is random. It usually occurs  at acpi_event_init()
but sometimes it hangs at a different place.

I also observed that the hang does not always occur. The system will
boot to the point of mounting /root, then panics because the mount
fails. I expect that this is a different failure due to missing drivers.
I'll chase that down later.


I added trace code & isolated the hang to a call to synchronize_rcu().
Usually from netlink_change_ngroups().

If I boot with "maxcpus=1, it never hangs (obviously) but always fails
to mount /root.

Next I changed NR_CPUS to 128. I still see random hangs at the call
to acpi_event_init().


I'll chase this more tomorrow. Has anyone else seen any failures that might be
related???




>  Linux version 2.6.26-rc7-tip (mingo@dione) (gcc version 4.2.3) #10233 SMP
>  Tue Jun 24 12:13:46 CEST 2008
>  [...]
>  initcall init_mnt_writers+0x0/0x8c returned 0 after 0 msecs
>  calling  eventpoll_init+0x0/0x9a
>  initcall eventpoll_init+0x0/0x9a returned 0 after 0 msecs
>  calling  anon_inode_init+0x0/0x11a
>  initcall anon_inode_init+0x0/0x11a returned 0 after 0 msecs
>  calling  pcie_aspm_init+0x0/0x27
>  initcall pcie_aspm_init+0x0/0x27 returned 0 after 0 msecs
>  calling  acpi_event_init+0x0/0x57
>  [... hard hang ...]
> 
> on a good bootup, it would continue like this:
> 
>  initcall acpi_event_init+0x0/0x57 returned 0 after 38 msecs
>  calling  pnp_system_init+0x0/0x17
>  [...]
> 
> the config, full bootlog and reproducer bzImage is at:
> 
>   http://redhat.com/~mingo/misc/config-Tue_Jun_24_07_44_17_CEST_2008.bad
>   http://redhat.com/~mingo/misc/log-Tue_Jun_24_07_44_17_CEST_2008.bad
>   http://redhat.com/~mingo/misc/bzImage-Tue_Jun_24_07_44_17_CEST_2008.bad
> 
> changing CONFIG_NR_CPUS from 4096 to 8 causes the system to boot up 
> fine.
> 
> 	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
