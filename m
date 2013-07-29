Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id A18286B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 16:57:45 -0400 (EDT)
Date: Mon, 29 Jul 2013 13:57:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH resend] drop_caches: add some documentation and info
 message
Message-Id: <20130729135743.c04224fb5d8e64b2730d8263@linux-foundation.org>
In-Reply-To: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
References: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, bp@suse.de, Dave Hansen <dave@linux.vnet.ibm.com>

On Fri, 26 Jul 2013 14:44:29 +0200 Michal Hocko <mhocko@suse.cz> wrote:

> ...
>
> : There is plenty of anecdotal evidence and a load of blog posts
> : suggesting that using "drop_caches" periodically keeps your system
> : running in "tip top shape".  Perhaps adding some kernel
> : documentation will increase the amount of accurate data on its use.
> :
> : If we are not shrinking caches effectively, then we have real bugs.
> : Using drop_caches will simply mask the bugs and make them harder
> : to find, but certainly does not fix them, nor is it an appropriate
> : "workaround" to limit the size of the caches.
> :
> : It's a great debugging tool, and is really handy for doing things
> : like repeatable benchmark runs.  So, add a bit more documentation
> : about it, and add a little KERN_NOTICE.  It should help developers
> : who are chasing down reclaim-related bugs.
> 
> ...
>
> --- a/fs/drop_caches.c
> +++ b/fs/drop_caches.c
> @@ -59,6 +59,8 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
>  	if (ret)
>  		return ret;
>  	if (write) {
> +		printk(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
> +		       current->comm, task_pid_nr(current), sysctl_drop_caches);
>  		if (sysctl_drop_caches & 1)
>  			iterate_supers(drop_pagecache_sb, NULL);
>  		if (sysctl_drop_caches & 2)

How about we do

	if (!(sysctl_drop_caches & 4))
		printk(....)

so people can turn it off if it's causing problems?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
