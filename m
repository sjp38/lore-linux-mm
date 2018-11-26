Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B1D876B4374
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 14:56:56 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id h86-v6so12188476pfd.2
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 11:56:56 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i35si1237567plg.396.2018.11.26.11.56.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 11:56:55 -0800 (PST)
Date: Mon, 26 Nov 2018 12:53:53 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 4/7] node: Add memory caching attributes
Message-ID: <20181126195352.GS26707@localhost.localdomain>
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181114224921.12123-5-keith.busch@intel.com>
 <20181126190619.GA32595@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126190619.GA32595@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rafael Wysocki <rafael@kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>

On Mon, Nov 26, 2018 at 11:06:19AM -0800, Greg Kroah-Hartman wrote:
> On Wed, Nov 14, 2018 at 03:49:17PM -0700, Keith Busch wrote:
> > System memory may have side caches to help improve access speed. While
> > the system provided cache is transparent to the software accessing
> > these memory ranges, applications can optimize their own access based
> > on cache attributes.
> > 
> > In preparation for such systems, provide a new API for the kernel to
> > register these memory side caches under the memory node that provides it.
> > 
> > The kernel's sysfs representation is modeled from the cpu cacheinfo
> > attributes, as seen from /sys/devices/system/cpu/cpuX/cache/. Unlike CPU
> > cacheinfo, though, a higher node's memory cache level is nearer to the
> > CPU, while lower levels are closer to the backing memory. Also unlike
> > CPU cache, the system handles flushing any dirty cached memory to the
> > last level the memory on a power failure if the range is persistent.
> > 
> > The exported attributes are the cache size, the line size, associativity,
> > and write back policy.
> > 
> > Signed-off-by: Keith Busch <keith.busch@intel.com>
> > ---
> >  drivers/base/node.c  | 117 +++++++++++++++++++++++++++++++++++++++++++++++++++
> >  include/linux/node.h |  23 ++++++++++
> >  2 files changed, 140 insertions(+)
> > 
> > diff --git a/drivers/base/node.c b/drivers/base/node.c
> > index 232535761998..bb94f1d18115 100644
> > --- a/drivers/base/node.c
> > +++ b/drivers/base/node.c
> > @@ -60,6 +60,12 @@ static DEVICE_ATTR(cpumap,  S_IRUGO, node_read_cpumask, NULL);
> >  static DEVICE_ATTR(cpulist, S_IRUGO, node_read_cpulist, NULL);
> >  
> >  #ifdef CONFIG_HMEM
> > +struct node_cache_obj {
> > +	struct kobject kobj;
> > +	struct list_head node;
> > +	struct node_cache_attrs cache_attrs;
> > +};
> 
> I know you all are off in the weeds designing some new crazy api for
> this instead of this current proposal (sorry, I lost the thread, I'll
> wait for the patches before commenting on it), but I do want to say one
> thing here.
> 
> NEVER use a raw kobject as a child for a 'struct device' unless you
> REALLY REALLY REALLY REALLY know what you are doing and have a VERY good
> reason to do so.
> 
> Just use a 'struct device', otherwise you end up having to reinvent all
> of the core logic that struct device provides you, like attribute
> callbacks (which you had to create), and other good stuff like telling
> userspace that a device has shown up so it knows to look at it.
> 
> That last one is key, a kobject is suddenly a "black hole" in sysfs as
> far as userspace knows because it does not see them for the most part
> (unless you are mucking around in the filesystem on your own, and
> really, don't do that, use a library like the rest of the world unless
> you really like reinventing everything, which, from your patchset it
> feels like...)
> 
> Anyway, use 'struct device'.  That's all.
> 
> greg k-h

Okay, thank you for the advice. I prefer to reuse over reinvent. :)

I only used kobject because the power/ directory was automatically
created with 'struct device', but I now I see there are better ways to
suppress that.
