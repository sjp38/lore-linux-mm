Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m84MFnRl008842
	for <linux-mm@kvack.org>; Thu, 4 Sep 2008 18:15:49 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m84MFn1N231108
	for <linux-mm@kvack.org>; Thu, 4 Sep 2008 18:15:49 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m84MFmCU018865
	for <linux-mm@kvack.org>; Thu, 4 Sep 2008 18:15:49 -0400
Subject: Re: [PATCH] Show memory section to node relationship in sysfs
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080904202212.GB26795@us.ibm.com>
References: <20080904202212.GB26795@us.ibm.com>
Content-Type: text/plain
Date: Thu, 04 Sep 2008 15:15:46 -0700
Message-Id: <1220566546.23386.65.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-09-04 at 13:22 -0700, Gary Hade wrote:
> 
> --- linux-2.6.27-rc5.orig/drivers/base/memory.c 2008-09-03 14:24:54.000000000 -0700
> +++ linux-2.6.27-rc5/drivers/base/memory.c      2008-09-03 14:25:14.000000000 -0700
> @@ -150,6 +150,22 @@
>         return len;
>  }
> 
> +/*
> + * node on which memory section resides
> + */
> +static ssize_t show_mem_node(struct sys_device *dev,
> +                       struct sysdev_attribute *attr, char *buf)
> +{
> +       unsigned long start_pfn;
> +       int ret;
> +       struct memory_block *mem =
> +               container_of(dev, struct memory_block, sysdev);
> +
> +       start_pfn = section_nr_to_pfn(mem->phys_index);
> +       ret = pfn_to_nid(start_pfn);
> +       return sprintf(buf, "%d\n", ret);
> +}

I only wonder if this is the "sysfs" way to do it.

I mean, we don't put a file with the PCI id of a device in the device's
sysfs directory.  We put a symlink to its place in the bus tree.

Should we just link over to the NUMA node directory?  We have it there,
so we might as well use it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
