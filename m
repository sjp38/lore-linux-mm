Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 611866B0035
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 08:35:07 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id j7so5185355qaq.36
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 05:35:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 50si3205102qgh.27.2014.04.11.05.35.03
        for <linux-mm@kvack.org>;
        Fri, 11 Apr 2014 05:35:04 -0700 (PDT)
Date: Fri, 11 Apr 2014 07:43:11 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <5347e178.b5138c0a.3d90.ffffc373SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <alpine.DEB.2.02.1404110325210.30610@chino.kir.corp.google.com>
References: <87eh1ix7g0.fsf@x240.local.i-did-not-set--mail-host-address--so-tickle-me>
 <533a1563.ad318c0a.6a93.182bSMTPIN_ADDED_BROKEN@mx.google.com>
 <CAOPLpQc8R2SfTB+=BsMa09tcQ-iBNJHg+tGnPK-9EDH1M47MJw@mail.gmail.com>
 <5343806c.100cc30a.0461.ffffc401SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.02.1404091734060.1857@chino.kir.corp.google.com>
 <5345fe27.82dab40a.0831.0af9SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.02.1404101500280.11995@chino.kir.corp.google.com>
 <53474709.e59ec20a.3bd5.3b91SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.02.1404110325210.30610@chino.kir.corp.google.com>
Subject: Re: [PATCH] drivers/base/node.c: export physical address range of
 given node (Re: NUMA node information for pages)
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: drepper@gmail.com, anatol.pomozov@gmail.com, jkosina@suse.cz, akpm@linux-foundation.org, xemul@parallels.com, paul.gortmaker@windriver.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Apr 11, 2014 at 04:00:20AM -0700, David Rientjes wrote:
> On Thu, 10 Apr 2014, Naoya Horiguchi wrote:
> 
> > Yes, that's right, but it seems to me that just node_start_pfn and node_end_pfn
> > is not enough because there can be holes (without any page struct backed) inside
> > [node_start_pfn, node_end_pfn), and it's not aware of memory hotplug.
> > 
> 
> So?  Who cares if there are non-addressable holes in part of the span?  
> Ulrich, correct me if I'm wrong, but it seems you're looking for just a 
> address-to-nodeid mapping (or pfn-to-nodeid mapping) and aren't actually 
> expecting that there are no holes in a node for things like acpi or I/O or 
> reserved memory.
> 
> The node spans a contiguous length of memory, there's no consideration for 
> addresses that aren't actually backed by physical memory.  We are just 
> representing proximity domains that have a base address and length in the 
> acpi world.
> 
> Memory hotplug is already taken care of because onlining and offlining 
> nodes already add these node classes and {start,end}_phys_addr would 
> show up automatically.  If you use node_start_pfn(nid) and 
> node_end_pfn(nid) as suggested, there's no futher consideration needed for 
> hotplug.
> 
> I think trying to represent holes and handling different memory models and 
> hotplug in special ways is complete overkill.

OK, I agree to your idea.
Your patch looks good to me.

Thanks,
Naoya Horiguchi

> Ulrich, can I have your ack?
> ---
>  Documentation/ABI/stable/sysfs-devices-node | 12 ++++++++++++
>  drivers/base/node.c                         | 18 ++++++++++++++++++
>  2 files changed, 30 insertions(+)
> 
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -63,6 +63,18 @@ Description:
>  		The node's hit/miss statistics, in units of pages.
>  		See Documentation/numastat.txt
>  
> +What:		/sys/devices/system/node/nodeX/start_phys_addr
> +Date:		April 2014
> +Contact:	David Rientjes <rientjes@google.com>
> +Description:
> +		The physical base address of this node.
> +
> +What:		/sys/devices/system/node/nodeX/end_phys_addr
> +Date:		April 2014
> +Contact:	David Rientjes <rientjes@google.com>
> +Description:
> +		The physical base + length address of this node.
> +
>  What:		/sys/devices/system/node/nodeX/distance
>  Date:		October 2002
>  Contact:	Linux Memory Management list <linux-mm@kvack.org>
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -170,6 +170,20 @@ static ssize_t node_read_numastat(struct device *dev,
>  }
>  static DEVICE_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
>  
> +static ssize_t node_read_start_phys_addr(struct device *dev,
> +				struct device_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "0x%lx\n", node_start_pfn(dev->id) << PAGE_SHIFT);
> +}
> +static DEVICE_ATTR(start_phys_addr, S_IRUGO, node_read_start_phys_addr, NULL);
> +
> +static ssize_t node_read_end_phys_addr(struct device *dev,
> +				struct device_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "0x%lx\n", node_end_pfn(dev->id) << PAGE_SHIFT);
> +}
> +static DEVICE_ATTR(end_phys_addr, S_IRUGO, node_read_end_phys_addr, NULL);
> +
>  static ssize_t node_read_vmstat(struct device *dev,
>  				struct device_attribute *attr, char *buf)
>  {
> @@ -286,6 +300,8 @@ static int register_node(struct node *node, int num, struct node *parent)
>  		device_create_file(&node->dev, &dev_attr_cpulist);
>  		device_create_file(&node->dev, &dev_attr_meminfo);
>  		device_create_file(&node->dev, &dev_attr_numastat);
> +		device_create_file(&node->dev, &dev_attr_start_phys_addr);
> +		device_create_file(&node->dev, &dev_attr_end_phys_addr);
>  		device_create_file(&node->dev, &dev_attr_distance);
>  		device_create_file(&node->dev, &dev_attr_vmstat);
>  
> @@ -311,6 +327,8 @@ void unregister_node(struct node *node)
>  	device_remove_file(&node->dev, &dev_attr_cpulist);
>  	device_remove_file(&node->dev, &dev_attr_meminfo);
>  	device_remove_file(&node->dev, &dev_attr_numastat);
> +	device_remove_file(&node->dev, &dev_attr_start_phys_addr);
> +	device_remove_file(&node->dev, &dev_attr_end_phys_addr);
>  	device_remove_file(&node->dev, &dev_attr_distance);
>  	device_remove_file(&node->dev, &dev_attr_vmstat);
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
