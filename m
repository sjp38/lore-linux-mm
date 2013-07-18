Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id D623D6B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 16:11:41 -0400 (EDT)
Message-ID: <1374178250.24916.131.camel@misato.fc.hp.com>
Subject: Re: [PATCH] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 18 Jul 2013 14:10:50 -0600
In-Reply-To: <51E83536.6070100@sr71.net>
References: <1374097503-25515-1-git-send-email-toshi.kani@hp.com>
	  <51E80973.9000308@intel.com> <1374164815.24916.84.camel@misato.fc.hp.com>
	 <51E83536.6070100@sr71.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Dave Hansen <dave.hansen@intel.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On Thu, 2013-07-18 at 11:34 -0700, Dave Hansen wrote:
> On 07/18/2013 09:26 AM, Toshi Kani wrote:
> > On Thu, 2013-07-18 at 08:27 -0700, Dave Hansen wrote:
> >> I'd really prefer you don't do this.  Do you really have random
> >> processes on your system poking at random sysfs files and then
> >> complaining when things break?
> > 
> > I am afraid that the "probe" interface does not provide the level of
> > quality suitable for regular users.  It takes any value and blindly
> > extends the page table.
> 
> That's like saying that /dev/sda takes any value and blindly writes it
> to the disk.

I do not think so.  Using echo command to write a value to /dev/sda is
not how it is instructed to use in the document.  I am not saying that
we need to protect from a privileged user doing something crazy.

> > Also, we are not aware of the use of this
> > interface on x86.  Would you elaborate why you need this interface on
> > x86?  Is it for your testing, or is it necessary for end-users?  If the
> > former, can you modify .config file to enable it?
> 
> For me, it's testing.  It allows testing of the memory hotplug software
> stack without actual hardware, which is incredibly valuable.  That
> includes testing on distribution kernels which I do not want to modify.
>  I thought there were some hypervisor users which don't use ACPI for
> hotplug event notifications too.

I think such hypervisor relies on a balloon driver and does not use this
interface.

> All that I'm asking is that you either leave it the way it is, or make a
> Kconfig menu entry for it.
> 
> But, really, what's the problem that you're solving?  Has this caused
> you issues somehow?  It's been there for, what, 10 years?  Surely it's
> part of the ABI.

The problem is that the probe interface is documented as one of the
steps that may be necessary for memory hotplug.  A typical user may or
may not know if his/her platform generates a hotplug notification to the
kernel to decide if this step is necessary.  If the user performs this
step on x86, it will likely mess up the system.  Since we do not need it
on x86, a prudent approach to protect such user is to disable or remove
the interface on x86 and document it accordingly.  We have not seen this
issue yet because we do not have many platforms that support memory
hotplug today.  Once memory hotplug support in KVM gets merged into the
mainline, anyone can start using this feature on their systems.  At that
time, their choice of a stable kernel may be 3.12.x.  This interface has
been there for while, but we need to fix it before the memory hotplug
feature becomes available for everyone.

Does it make sense?  I understand that you are using this interface for
your testing.  If I make a Kconfig menu entry, are you OK to disable
this option by default?

Motohiro, Yasuaki, do you have any suggestion?

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
