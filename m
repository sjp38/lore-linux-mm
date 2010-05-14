Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F1A256B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 23:31:40 -0400 (EDT)
Message-ID: <4BECC418.2080602@linux.intel.com>
Date: Fri, 14 May 2010 11:31:36 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC, 3/7] NUMA hotplug emulator
References: <20100513114835.GD2169@shaohui>
In-Reply-To: <20100513114835.GD2169@shaohui>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Greg Kroah-Hartman <gregkh@suse.de>, David Rientjes <rientjes@google.com>, Alex Chiang <achiang@hp.com>, linux-kernel@vger.kernel.org, ak@linux.intel.co, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

Shaohui Zheng wrote:
> Userland interface to hotplug-add fake offlined nodes.
> 
> Add a sysfs entry "probe" under /sys/devices/system/node/:
> 
>  - to show all fake offlined nodes:
>     $ cat /sys/devices/system/node/probe
> 
>  - to hotadd a fake offlined node, e.g. nodeid is N:
>     $ echo N > /sys/devices/system/node/probe
> 
> Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
> Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
> ---
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 057979a..a0be257 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -535,6 +535,26 @@ void unregister_one_node(int nid)
>  	unregister_node(&node_devices[nid]);
>  }
>  
> +#ifdef CONFIG_NODE_HOTPLUG_EMU
> +static ssize_t store_nodes_probe(struct sysdev_class *class,
> +				  struct sysdev_class_attribute *attr,
> +				  const char *buf, size_t count)
> +{
> +	long nid;
> +	int ret;
> +
> +	strict_strtol(buf, 0, &nid);
> +	if (nid < 0 || nid > nr_node_ids - 1) {

Shaohui,

In fact, no need to do such check here, hotadd_hidden_nodes() can handle such invalid parameter by 
itself.

> +		printk(KERN_ERR "Invalid NUMA node id: %d (0 <= nid < %d).\n",
> +			nid, nr_node_ids);
> +		return -EPERM;

Per Andi's earlier review comments, -EPERM is odd, we'd fix it.

> +	}
> +	hotadd_hidden_nodes(nid);
> +
> +	return count;
> +}
> +#endif

Pls. replace it with following code:

+#ifdef CONFIG_NODE_HOTPLUG_EMU
+static ssize_t store_nodes_probe(struct sysdev_class *class,
+                                 struct sysdev_class_attribute *attr,
+                                 const char *buf, size_t count)
+{
+       long nid;
+       int ret;
+
+       ret = strict_strtol(buf, 0, &nid);
+       if (ret == -EINVAL)
+               return ret;
+
+       ret = hotadd_hidden_nodes(nid);
+       if (!ret)
+               return count;
+       else
+               return -EIO;
+}
+#endif


-haicheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
