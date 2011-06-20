Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A04029000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 12:50:39 -0400 (EDT)
Date: Mon, 20 Jun 2011 18:50:35 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/3] mm: completely disable THP by
 transparent_hugepage=never
Message-ID: <20110620165035.GE20843@redhat.com>
References: <1308587683-2555-1-git-send-email-amwang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308587683-2555-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, Jun 21, 2011 at 12:34:28AM +0800, Amerigo Wang wrote:
> transparent_hugepage=never should mean to disable THP completely,
> otherwise we don't have a way to disable THP completely.
> The design is broken.

We want to allow people to boot with transparent_hugepage=never but to
still allow people to enable it later at runtime. Not sure why you
find it broken... Your patch is just crippling down the feature with
no gain. There is absolutely no gain to disallow root to enable THP
later at runtime with sysfs, root can enable it anyway by writing into
/dev/mem.

Unless you're root and you enable it, it's completely disabled, so I
don't see what you mean it's not completely disabled. Not even
khugepaged is started, try to grep of khugepaged... (that wouldn't be
the same with ksm where ksm daemon runs even when it's off for no
gain, but I explicitly solved the locking so khugepaged will go away
when enabled=never and return when enabled=always).

> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> ---
>  mm/huge_memory.c |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 81532f2..9c63c90 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -488,19 +488,26 @@ static struct attribute_group khugepaged_attr_group = {
>  };
>  #endif /* CONFIG_SYSFS */
>  
> +#define hugepage_enabled()	khugepaged_enabled()
> +
>  static int __init hugepage_init(void)
>  {
> -	int err;
> +	int err = 0;
>  #ifdef CONFIG_SYSFS
>  	static struct kobject *hugepage_kobj;
>  #endif
>  
> -	err = -EINVAL;
>  	if (!has_transparent_hugepage()) {
> +		err = -EINVAL;
>  		transparent_hugepage_flags = 0;
>  		goto out;

Original error setting was better IMHO.

>  	}
>  
> +	if (!hugepage_enabled()) {
> +		printk(KERN_INFO "hugepage: totally disabled\n");
> +		goto out;
> +	}
> +
>  #ifdef CONFIG_SYSFS
>  	err = -ENOMEM;
>  	hugepage_kobj = kobject_create_and_add("transparent_hugepage", mm_kobj);

Changing the initialization to "never" at boot, doesn't mean we must
never allow it to be enabled again during the runtime of the kernel
(by root with sysfs, which is certainly less error prone than doing
that with /dev/mem), and there is no gain in preventing that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
