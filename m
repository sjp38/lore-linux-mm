Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 41A176B0009
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 07:45:58 -0500 (EST)
Date: Mon, 4 Feb 2013 04:48:10 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug
 framework
Message-ID: <20130204124810.GB22096@kroah.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
 <20130202145801.GB1434@kroah.com>
 <1810611.i6Sc4oLaux@vostro.rjw.lan>
 <5876609.Ic1nhHW6N2@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5876609.Ic1nhHW6N2@vostro.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Toshi Kani <toshi.kani@hp.com>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Sun, Feb 03, 2013 at 09:44:39PM +0100, Rafael J. Wysocki wrote:
> > Yes, but those are just remove events and we can only see how destructive they
> > were after the removal.  The point is to be able to figure out whether or not
> > we *want* to do the removal in the first place.
> > 
> > Say you have a computing node which signals a hardware problem in a processor
> > package (the container with CPU cores, memory, PCI host bridge etc.).  You
> > may want to eject that package, but you don't want to kill the system this
> > way.  So if the eject is doable, it is very much desirable to do it, but if it
> > is not doable, you'd rather shut the box down and do the replacement afterward.
> > That may be costly, however (maybe weeks of computations), so it should be
> > avoided if possible, but not at the expense of crashing the box if the eject
> > doesn't work out.
> 
> It seems to me that we could handle that with the help of a new flag, say
> "no_eject", in struct device, a global mutex, and a function that will walk
> the given subtree of the device hierarchy and check if "no_eject" is set for
> any devices in there.  Plus a global "no_eject" switch, perhaps.

I think this will always be racy, or at worst, slow things down on
normal device operations as you will always be having to grab this flag
whenever you want to do something new.

See my comments earlier about pci hotplug and the design decisions there
about "no eject" capabilities for why.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
