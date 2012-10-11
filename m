Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 532A36B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 18:33:44 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so2815281oag.14
        for <linux-mm@kvack.org>; Thu, 11 Oct 2012 15:33:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50765896.4000300@jp.fujitsu.com>
References: <507656D1.5020703@jp.fujitsu.com> <50765896.4000300@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 11 Oct 2012 18:33:23 -0400
Message-ID: <CAHGf_=rvdU+TymYZSXvx1bz4xdp43bqnyjRMGEoiBizC5rP0sQ@mail.gmail.com>
Subject: Re: [PATCH 2/2]suppress "Device nodeX does not have a release()
 function" warning
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, minchan.kim@gmail.com, akpm@linux-foundation.org, wency@cn.fujitsu.com

On Thu, Oct 11, 2012 at 1:26 AM, Yasuaki Ishimatsu
<isimatu.yasuaki@jp.fujitsu.com> wrote:
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
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> ---
>  drivers/base/node.c |   11 +++++++++++
>  1 file changed, 11 insertions(+)
>
> Index: linux-3.6/drivers/base/node.c
> ===================================================================
> --- linux-3.6.orig/drivers/base/node.c  2012-10-11 10:04:02.149758748 +0900
> +++ linux-3.6/drivers/base/node.c       2012-10-11 10:20:34.111806931 +0900
> @@ -252,6 +252,14 @@ static inline void hugetlb_register_node
>  static inline void hugetlb_unregister_node(struct node *node) {}
>  #endif
>
> +static void node_device_release(struct device *dev)
> +{
> +#if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
> +       struct node *node_dev = to_node(dev);
> +
> +       flush_work(&node_dev->node_work);
> +#endif
> +}

The patch description don't explain why this flush_work() is needed.


>  /*
>   * register_node - Setup a sysfs device for a node.
> @@ -263,8 +271,11 @@ int register_node(struct node *node, int
>  {
>         int error;
>
> +       memset(node, 0, sizeof(*node));
> +

You should add a comment why we need initialize a node here. A lot
of developers don't have hotplug knowledge.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
