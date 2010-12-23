Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C2DF16B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 22:48:56 -0500 (EST)
Date: Thu, 23 Dec 2010 10:24:28 +0800
From: Shaohui Zheng <shaohui.zheng@linux.intel.com>
Subject: Re: [5/7, v9] NUMA Hotplug Emulator: Support cpu probe/release in
 x86_64
Message-ID: <20101223022428.GB12333@shaohui>
References: <20101210073119.156388875@intel.com>
 <20101210073242.670777298@intel.com>
 <20101222162727.56b830b0.akpm@linux-foundation.org>
 <20101223013410.GA11356@shaohui>
 <20101222192118.2d286ca9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101222192118.2d286ca9.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: shaohui.zheng@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Ingo Molnar <mingo@elte.hu>, Len Brown <len.brown@intel.com>, Yinghai Lu <Yinghai.Lu@Sun.COM>, Tejun Heo <tj@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 22, 2010 at 07:21:18PM -0800, Andrew Morton wrote:
> > > 
> > > checkpatch?
> > 
> > it is a warning, so I ignore it.
> 
> Don't ignore warnings!  At least, not until you've understood the
> reason for them and have a *reason* to ignore them.
> 
> simple_strtoul() will silently accept input of the form "42foo",
> treating it as "42".  That's a userspace bug and the kernel should
> report it.  This means that the code should be changed to handle error
> returns from strict_strtoul().  And those error paths should be tested.
> 

> > > > +			break;
> > > > +		}
> > > > +	}
> > > > +
> > > > +	if (selected >= num_possible_cpus()) {
> > > > +		printk(KERN_ERR "No free cpu, give up cpu probing.\n");
> > > > +		return -EPERM;
> > > > +	}
> > > > +
> > > > +	/* register cpu */
> > > > +	arch_register_cpu_node(selected, nid);
> > > > +	acpi_map_lsapic_emu(selected, nid);
> > > > +
> > > > +	return count;
> > > > +}
> > > > +EXPORT_SYMBOL(arch_cpu_probe);
> > > 
> > > arch_cpu_probe() is global and exported to modules, but is undocumented.
> > > 
> > > If it had been documented, I might have been able to work out why arg
> > > `count' is checked, but never used.
> > > 
> > 
> > Sorry, Andrew, I did not catch it. Do you mean to add the document before
> >  the definition of the function arch_cpu_probe?
> 
> Sure, add a comment documenting the function.

I understand, I will add comments for both arch_cpu_probe/arch_cpu_release.

> 
> Why *does* it check `count' and then not use it?
> 

it is a tricky thing. When I debug it under a Virtual Machine, If I do a cpu
probe via sysfs cpu/probe interface, The function arch_cpu_probe will be called
__three__ times, but only one call is valid, so I add a check on `count` to
ignore the invalid calls.

> > 
> > > > +	/* cpu 0 is not hotplugable */
> > > > +	if (cpu == 0) {
> > > > +		printk(KERN_ERR "can not release cpu 0.\n");
> > > 
> > > It's generally better to make kernel messages self-identifying. 
> > > Especially error messages.  If someone comes along and sees "can not
> > > release cpu 0" in their logs, they don't have a clue what caused it
> > > unless they download the kernel sources and go grepping.
> > > 
> > 
> > How about "arch_cpu_release: can not release cpu 0.\n"?
> 
> Better, although "arch_cpu_release" isn't very meaningful to an
> administrator.  "NUMA hotplug remove" or something like that would be
> more useful.

> 
> All these messages should be looked at from the point of view of the
> people who they are to serve.  Although in this special case, that's
> most likely to be a kernel developer so I guess such clarity isn't
> needed.
> 

It is a good lesson for me, when I meet the similar problem next time, I should
consider more from the point of the user.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
