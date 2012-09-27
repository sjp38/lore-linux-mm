Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 711006B005D
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 06:38:39 -0400 (EDT)
Received: by oagk14 with SMTP id k14so2060474oag.14
        for <linux-mm@kvack.org>; Thu, 27 Sep 2012 03:38:38 -0700 (PDT)
Message-ID: <50642CA7.5070208@gmail.com>
Date: Thu, 27 Sep 2012 18:38:31 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] memory-hotplug: add node_device_release
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com> <1348724705-23779-3-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1348724705-23779-3-git-send-email-wency@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

On 09/27/2012 01:45 PM, wency@cn.fujitsu.com wrote:
> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>
> When calling unregister_node(), the function shows following message at
> device_release().
>
> Device 'node2' does not have a release() function, it is broken and must be
> fixed.
>
> So the patch implements node_device_release()
looks reasonable to me.
>
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> CC: Len Brown <len.brown@intel.com>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Paul Mackerras <paulus@samba.org>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> ---
>   drivers/base/node.c |   11 +++++++++++
>   1 files changed, 11 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index af1a177..07523fb 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -252,6 +252,16 @@ static inline void hugetlb_register_node(struct node *node) {}
>   static inline void hugetlb_unregister_node(struct node *node) {}
>   #endif
>   
> +static void node_device_release(struct device *dev)
> +{
> +	struct node *node_dev = to_node(dev);
> +
> +#if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
> +	flush_work(&node_dev->node_work);
> +#endif
> +
> +	memset(node_dev, 0, sizeof(struct node));
> +}
>   
>   /*
>    * register_node - Setup a sysfs device for a node.
> @@ -265,6 +275,7 @@ int register_node(struct node *node, int num, struct node *parent)
>   
>   	node->dev.id = num;
>   	node->dev.bus = &node_subsys;
> +	node->dev.release = node_device_release;
>   	error = device_register(&node->dev);
>   
>   	if (!error){

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
