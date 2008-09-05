Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8510LkG024062
	for <linux-mm@kvack.org>; Thu, 4 Sep 2008 21:00:21 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m8510FMU233558
	for <linux-mm@kvack.org>; Thu, 4 Sep 2008 21:00:15 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8510EPi008098
	for <linux-mm@kvack.org>; Thu, 4 Sep 2008 21:00:15 -0400
Date: Thu, 4 Sep 2008 18:00:10 -0700
From: Gary Hade <garyhade@us.ibm.com>
Subject: Re: [PATCH] Show memory section to node relationship in sysfs
Message-ID: <20080905010010.GE26795@us.ibm.com>
References: <20080904202212.GB26795@us.ibm.com> <1220566546.23386.65.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1220566546.23386.65.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 04, 2008 at 03:15:46PM -0700, Dave Hansen wrote:
> On Thu, 2008-09-04 at 13:22 -0700, Gary Hade wrote:
> > 
> > --- linux-2.6.27-rc5.orig/drivers/base/memory.c 2008-09-03 14:24:54.000000000 -0700
> > +++ linux-2.6.27-rc5/drivers/base/memory.c      2008-09-03 14:25:14.000000000 -0700
> > @@ -150,6 +150,22 @@
> >         return len;
> >  }
> > 
> > +/*
> > + * node on which memory section resides
> > + */
> > +static ssize_t show_mem_node(struct sys_device *dev,
> > +                       struct sysdev_attribute *attr, char *buf)
> > +{
> > +       unsigned long start_pfn;
> > +       int ret;
> > +       struct memory_block *mem =
> > +               container_of(dev, struct memory_block, sysdev);
> > +
> > +       start_pfn = section_nr_to_pfn(mem->phys_index);
> > +       ret = pfn_to_nid(start_pfn);
> > +       return sprintf(buf, "%d\n", ret);
> > +}
> 
> I only wonder if this is the "sysfs" way to do it.
> 
> I mean, we don't put a file with the PCI id of a device in the device's
> sysfs directory.  We put a symlink to its place in the bus tree.
> 
> Should we just link over to the NUMA node directory?  We have it there,
> so we might as well use it.

Dave, Good comment from both you and Nish.

The "sysfs" way appears to be a bit inconsistent. :)
w/2.6.27-rc5:
elm3a153:~ # ls -ld /sys/devices/pci0000:0f/0000:0f:00.0/numa_node
-r--r--r-- 1 root root 4096 2008-09-04 15:14 /sys/devices/pci0000:0f/0000:0f:00.0/numa_node
elm3a153:~ # cat /sys/devices/pci0000:0f/0000:0f:00.0/numa_node
1
I think this may have been the model I was trying to follow.

Also, Using your PCI id example there are already instances of
PCI address containing files in the sysfs tree which I believe could
have been symlinks.  When the 'pci_slot' or 'acpiphp' drivers are loaded
/sys/bus/pci/slots/<slot num>/address files are created.  I believe
these PCI address containing files could have been symlinks.  Alex Chiang
recently posted a change that adds /sys/bus/pci/slots/<slot_num>/device
symlinks pointing to the approproate place in /sys/devices which will be
quite useful but I think the PCI address containing files are also useful.

In any case, the symlink sounds like a good idea and would be
sufficient by itself but I'm wondering if it would be overkill to
provide both? e.g. a 'node' symlink and a 'node_num' file.

Gary

-- 
Gary Hade
System x Enablement
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
