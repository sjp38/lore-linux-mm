Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 9E1316B0089
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 18:52:26 -0400 (EDT)
Date: Mon, 22 Oct 2012 15:52:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 2/9] suppress
 "Device nodeX does not have a release() function" warning
Message-Id: <20121022155224.e8f306f9.akpm@linux-foundation.org>
In-Reply-To: <1350629202-9664-3-git-send-email-wency@cn.fujitsu.com>
References: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com>
	<1350629202-9664-3-git-send-email-wency@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Greg KH <greg@kroah.com>

On Fri, 19 Oct 2012 14:46:35 +0800
wency@cn.fujitsu.com wrote:

> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> 
> When calling unregister_node(), the function shows following message at
> device_release().
> 
> "Device 'node2' does not have a release() function, it is broken and must
> be fixed."
> 
> The reason is node's device struct does not have a release() function.
> 
> So the patch registers node_device_release() to the device's release()
> function for suppressing the warning message. Additionally, the patch adds
> memset() to initialize a node struct into register_node(). Because the node
> struct is part of node_devices[] array and it cannot be freed by
> node_device_release(). So if system reuses the node struct, it has a garbage.
> 
> ...
>
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -252,6 +252,9 @@ static inline void hugetlb_register_node(struct node *node) {}
>  static inline void hugetlb_unregister_node(struct node *node) {}
>  #endif
>  
> +static void node_device_release(struct device *dev)
> +{
> +}
>  
>  /*
>   * register_node - Setup a sysfs device for a node.
> @@ -263,8 +266,11 @@ int register_node(struct node *node, int num, struct node *parent)
>  {
>  	int error;
>  
> +	memset(node, 0, sizeof(*node));
> +
>  	node->dev.id = num;
>  	node->dev.bus = &node_subsys;
> +	node->dev.release = node_device_release;
>  	error = device_register(&node->dev);
>  
>  	if (!error){

Greg won't like that empty ->release function ;)

As you say, this device item does not reside in per-device dynamically
allocated memory - it is part of an externally managed array.

So a proper fix here would be to convert this storage so that it *is*
dynamically allocated on a per-device basis.

Or perhaps we should recognize that the whole kobject
get/put/release-on-last-put model is inappropriate for these objects,
and stop using it entirely.

>From Kosaki's comment, it does sound that we plan to take the first
option: convert to per-device dynamically allocated memory?  If so, I
suggest that we just leave the warning as-is for now, until we fix
things proprely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
