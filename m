Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id DD99C6B004D
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 03:48:48 -0500 (EST)
Date: Fri, 20 Jan 2012 08:48:40 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm: page allocator: Do not drain per-cpu lists via
 IPI from page allocator context
Message-ID: <20120120084840.GG3143@suse.de>
References: <1326276668-19932-1-git-send-email-mgorman@suse.de>
 <1326276668-19932-3-git-send-email-mgorman@suse.de>
 <1326381492.2442.188.camel@twins>
 <20120112153712.GL4118@suse.de>
 <1326383551.2442.203.camel@twins>
 <20120112171847.GN4118@suse.de>
 <no-drain-reply@mdm.bga.com>
 <20120119162057.GD3143@suse.de>
 <4F188F52.1060303@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F188F52.1060303@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Milton Miller <miltonm@bga.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, mszeredi@novell.com, ebiederm@xmission.com, Greg Kroah-Hartman <gregkh@suse.de>, gong.chen@intel.com, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@amd64.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, linux-edac@vger.kernel.org, Andi Kleen <andi@firstfloor.org>

On Fri, Jan 20, 2012 at 03:16:58AM +0530, Srivatsa S. Bhat wrote:
> [Reinstating the original Cc list]
> 
> On 01/19/2012 09:50 PM, Mel Gorman wrote:> 
> 
> > On a different x86-64 machines with an intel-specific MCE, I have
> > also noted that the value of num_online_cpus() can change while
> > stop_machine() is running.
> 
> 
> That is expected and intentional right? Meaning, it is during the
> stop_machine() thing itself that a CPU is actually taken offline.
> And at the same time, it is removed from the cpu_online_mask.
> 

It's intentional sometimes and no others. The machine does halt
sometimes and stays there.

> On Intel boxes, essentially, the following gets executed on the dying
> CPU, as set up by the stop_machine stuff.
> 
> __cpu_disable()
>     native_cpu_disable()
>         cpu_disable_common()
>             remove_cpu_from_maps()
>                 set_cpu_online(cpu, false)
> 			^^^^^^
> So, set_cpu_online will remove this CPU from the cpu_online_mask.
> And all this runs while still under the stop machine context.
> And this is exactly what we want right?
> 

We don't want it to halt in stop_machine forever waiting on acknowledges
that are never received until the NMI handler fires.

> > This is sensitive to timing and part of
> > the problem seems to be due to cmci_rediscover() running without the
> > CPU hotplug mutex held. This is not related to the IPI mess and is
> > unrelated to memory pressure but is just to note that CPU hotplug in
> > general can be fragile in parts.
> > 
> 
> 
> For the cmci_rediscover() part, I feel a simple get/put_online_cpus()
> around it should work.
> 

Yeah, that's the first thing I tried first too. Doesn't work though.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
