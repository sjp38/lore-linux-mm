Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 7869D6B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 16:35:33 -0400 (EDT)
Received: by yenm8 with SMTP id m8so8897294yen.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 13:35:32 -0700 (PDT)
Date: Mon, 23 Apr 2012 13:35:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm:vmstat - Removed debug fs entries on failure of file
 creation and made extfrag_debug_root dentry local
In-Reply-To: <1335208126-25919-1-git-send-email-sasikanth.v19@gmail.com>
Message-ID: <alpine.DEB.2.00.1204231334200.11602@chino.kir.corp.google.com>
References: <1335208126-25919-1-git-send-email-sasikanth.v19@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasikantha babu <sasikanth.v19@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 24 Apr 2012, Sasikantha babu wrote:

> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index f600557..ddae476 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1220,7 +1220,6 @@ module_init(setup_vmstat)
>  #if defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)
>  #include <linux/debugfs.h>
>  
> -static struct dentry *extfrag_debug_root;
>  
>  /*
>   * Return an index indicating how much of the available free memory is
> @@ -1358,17 +1357,23 @@ static const struct file_operations extfrag_file_ops = {
>  
>  static int __init extfrag_debug_init(void)
>  {
> +	struct dentry *extfrag_debug_root;
> +
>  	extfrag_debug_root = debugfs_create_dir("extfrag", NULL);
>  	if (!extfrag_debug_root)
>  		return -ENOMEM;
>  
>  	if (!debugfs_create_file("unusable_index", 0444,
> -			extfrag_debug_root, NULL, &unusable_file_ops))
> +			extfrag_debug_root, NULL, &unusable_file_ops)) {
> +		debugfs_remove (extfrag_debug_root);
>  		return -ENOMEM;
> +	}
>  
>  	if (!debugfs_create_file("extfrag_index", 0444,
> -			extfrag_debug_root, NULL, &extfrag_file_ops))
> +			extfrag_debug_root, NULL, &extfrag_file_ops)) {
> +		debugfs_remove_recursive (extfrag_debug_root);
>  		return -ENOMEM;
> +	}
>  
>  	return 0;
>  }

Probably easier to do something like "goto fail" and then have a

		return 0;

	fail:
		debugfs_remove_recursive(extfrag_debug_root);
		return -ENOMEM;

at the end of the function.

Please run scripts/checkpatch.pl on your patch before proposing it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
