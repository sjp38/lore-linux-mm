Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 621786B0033
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 17:39:07 -0400 (EDT)
Message-ID: <1374183496.24916.170.camel@misato.fc.hp.com>
Subject: Re: [PATCH] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 18 Jul 2013 15:38:16 -0600
In-Reply-To: <51E85016.2090403@intel.com>
References: <1374097503-25515-1-git-send-email-toshi.kani@hp.com>
	   <51E80973.9000308@intel.com> <1374164815.24916.84.camel@misato.fc.hp.com>
	  <51E83536.6070100@sr71.net> <1374178250.24916.131.camel@misato.fc.hp.com>
	 <51E85016.2090403@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave@sr71.net>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On Thu, 2013-07-18 at 13:29 -0700, Dave Hansen wrote:
> On 07/18/2013 01:10 PM, Toshi Kani wrote:
> > On Thu, 2013-07-18 at 11:34 -0700, Dave Hansen wrote:
> > I do not think so.  Using echo command to write a value to /dev/sda is
> > not how it is instructed to use in the document.  I am not saying that
> > we need to protect from a privileged user doing something crazy.
> 
> If the document is the issue, then let's fix the document.

I will clarify the document as well.

> >> All that I'm asking is that you either leave it the way it is, or make a
> >> Kconfig menu entry for it.
> >>
> >> But, really, what's the problem that you're solving?  Has this caused
> >> you issues somehow?  It's been there for, what, 10 years?  Surely it's
> >> part of the ABI.
> > 
> > The problem is that the probe interface is documented as one of the
> > steps that may be necessary for memory hotplug.  A typical user may or
> > may not know if his/her platform generates a hotplug notification to the
> > kernel to decide if this step is necessary.
> 
> A typical user will never see any of this stuff.  It's buried deep under
> the covers.

Users will need to use sysfs "memoryX/online" interface to online
hot-added memory, which is located in the same directory as "probe".
The name "probe" is also misleading that one would expect it checks if a
given memory address is present on the system.

> > If the user performs this
> > step on x86, it will likely mess up the system.  Since we do not need it
> > on x86, a prudent approach to protect such user is to disable or remove
> > the interface on x86 and document it accordingly.  We have not seen this
> > issue yet because we do not have many platforms that support memory
> > hotplug today.  Once memory hotplug support in KVM gets merged into the
> > mainline, anyone can start using this feature on their systems.  At that
> > time, their choice of a stable kernel may be 3.12.x.  This interface has
> > been there for while, but we need to fix it before the memory hotplug
> > feature becomes available for everyone.
> 
> It sounds like you're arguing that anyone using memory hotplug on x86
> might be confused by the probe file.  There's been a lot of hardware out
> there that's supported memory hotplug for many, many years.  I've never
> heard a complaint about it in practice.  Are KVM users more apt to be
> confused than folks running on bare-metal? :)

I know ia64 (which Kconfig does not have this option) and powerpc (which
this interface is required, but I believe it is well-automated by LPAR
mgmt tools) platforms support memory hotplug for many years, but I did
not know it is also the case with x86 platforms.  The fact that ia64
does not have this interface makes me wonder why we enabled it on x86.

> > Does it make sense?  I understand that you are using this interface for
> > your testing.  If I make a Kconfig menu entry, are you OK to disable
> > this option by default?
> 
> I kinda wish you wouldn't mess with it.  But, sure, put it in the memory
> debugging, and make sure it stays enabled on powerpc by default.

I understand and I appreciate your flexibility.  Since it is defined in
x86/Kconfig, the prompt will be under "Processor type and features".
Yes, it stays enabled on powerpc as I won't touch powerpc/Kconfig.

> Another method would be to just change the default permissions of the
> file on x86 instead of disabling it completely:
> 
> 	# chmod u-w /sys/devices/system/memory/probe
> 	# echo x > /sys/devices/system/memory/probe
> 	bash: /sys/devices/system/memory/probe: Permission denied
> 
> That way folks can re-chmod it if they *really* want it back (me), and
> they can still use it for testing.

That's an interesting idea, but I'd prefer not to introduce #ifdef to
the common code for this.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
