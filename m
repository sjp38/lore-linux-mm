Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 64C7B6B01F1
	for <linux-mm@kvack.org>; Sat, 28 Aug 2010 19:50:41 -0400 (EDT)
Date: Sun, 29 Aug 2010 07:50:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/4] writeback: nr_dirtied and nr_cleaned in
 /proc/vmstat
Message-ID: <20100828235029.GA7071@localhost>
References: <1282963227-31867-1-git-send-email-mrubin@google.com>
 <1282963227-31867-4-git-send-email-mrubin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1282963227-31867-4-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 28, 2010 at 10:40:26AM +0800, Michael Rubin wrote:
> To help developers and applications gain visibility into writeback
> behaviour adding two entries to /proc/vmstat.
> 
>    # grep nr_dirtied /proc/vmstat
>    nr_dirtied 3747
>    # grep nr_cleaned /proc/vmstat
>    nr_cleaned 3618
> 
> In order to track the "cleaned" and "dirtied" counts we added two
> vm_stat_items. Per memory node stats have been added also. So we can
> see per node granularity:
> 
>    # cat /sys/devices/system/node/node20/vmstat
>    Node 20 pages_cleaned: 0 times
>    Node 20 pages_dirtied: 0 times

It's silly to have the different names nr_dirtied and pages_cleaned
for the same item.

> Signed-off-by: Michael Rubin <mrubin@google.com>
> ---
>  drivers/base/node.c    |   14 ++++++++++++++
>  include/linux/mmzone.h |    2 ++
>  mm/page-writeback.c    |    2 ++
>  mm/vmstat.c            |    3 +++
>  4 files changed, 21 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 2872e86..facd920 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -160,6 +160,18 @@ static ssize_t node_read_numastat(struct sys_device * dev,
>  }
>  static SYSDEV_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
>  
> +static ssize_t node_read_vmstat(struct sys_device *dev,
> +				struct sysdev_attribute *attr, char *buf)
> +{
> +	int nid = dev->id;
> +	return sprintf(buf,
> +		"Node %d pages_cleaned: %lu times\n"
> +		"Node %d pages_dirtied: %lu times\n",
> +		nid, node_page_state(nid, NR_PAGES_CLEANED),
> +		nid, node_page_state(nid, NR_FILE_PAGES_DIRTIED));
> +}

The output format is quite different from /proc/vmstat.
Do we really need to "Node X", ":" and "times" decorations?

And the "_PAGES" in NR_FILE_PAGES_DIRTIED looks redundant to
the "_page" in node_page_state(). It's a bit long to be a pleasant
name. NR_FILE_DIRTIED/NR_CLEANED looks nicer.

> +static SYSDEV_ATTR(vmstat, S_IRUGO, node_read_vmstat, NULL);
> +
>  static ssize_t node_read_distance(struct sys_device * dev,
>  			struct sysdev_attribute *attr, char * buf)
>  {
> @@ -243,6 +255,7 @@ int register_node(struct node *node, int num, struct node *parent)
>  		sysdev_create_file(&node->sysdev, &attr_meminfo);
>  		sysdev_create_file(&node->sysdev, &attr_numastat);
>  		sysdev_create_file(&node->sysdev, &attr_distance);
> +		sysdev_create_file(&node->sysdev, &attr_vmstat);
>  
>  		scan_unevictable_register_node(node);
>  
> @@ -267,6 +280,7 @@ void unregister_node(struct node *node)
>  	sysdev_remove_file(&node->sysdev, &attr_meminfo);
>  	sysdev_remove_file(&node->sysdev, &attr_numastat);
>  	sysdev_remove_file(&node->sysdev, &attr_distance);
> +	sysdev_remove_file(&node->sysdev, &attr_vmstat);
>  
>  	scan_unevictable_unregister_node(node);
>  	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 6e6e626..d42f179 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -104,6 +104,8 @@ enum zone_stat_item {
>  	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
>  	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
>  	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
> +	NR_FILE_PAGES_DIRTIED,	/* number of times pages get dirtied */
> +	NR_PAGES_CLEANED,	/* number of times pages enter writeback */

How about the comments /* accumulated number of pages ... */?

Note that NR_CLEANED won't match NR_FILE_DIRTIED in long term because
it also accounts for anon pages, and does not account for dirty pages
that are truncated before they go writeback.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
