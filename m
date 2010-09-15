Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DFC9C6B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 00:38:39 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8F4caio022622
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 15 Sep 2010 13:38:36 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DBC745DE58
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:38:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 017BD45DE54
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:38:35 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A34D7E08002
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:38:34 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C37771DB803F
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:38:33 +0900 (JST)
Date: Wed, 15 Sep 2010 13:33:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] update /proc/sys/vm/drop_caches documentation
Message-Id: <20100915133303.0b232671.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100914234714.8AF506EA@kernel.beaverton.ibm.com>
References: <20100914234714.8AF506EA@kernel.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, lnxninja@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 14 Sep 2010 16:47:14 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> 
> There seems to be an epidemic spreading around.  People get the idea
> in their heads that the kernel caches are evil.  They eat too much
> memory, and there's no way to set a size limit on them!  Stupid
> kernel!
> 
> There is plenty of anecdotal evidence and a load of blog posts
> suggesting that using "drop_caches" periodically keeps your system
> running in "tip top shape".  I do not think that is true.
> 
> If we are not shrinking caches effectively, then we have real bugs.
> Using drop_caches will simply mask the bugs and make them harder
> to find, but certainly does not fix them, nor is it an appropriate
> "workaround" to limit the size of the caches.
> 
> It's a great debugging tool, and is really handy for doing things
> like repeatable benchmark runs.  So, add a bit more documentation
> about it, and add a WARN_ONCE().  Maybe the warning will scare
> some sense into people.
> 
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> ---
> 
>  linux-2.6.git-dave/Documentation/sysctl/vm.txt |   14 ++++++++++++--
>  linux-2.6.git-dave/fs/drop_caches.c            |    2 ++
>  2 files changed, 14 insertions(+), 2 deletions(-)
> 
> diff -puN Documentation/sysctl/vm.txt~update-drop_caches-documentation Documentation/sysctl/vm.txt
> --- linux-2.6.git/Documentation/sysctl/vm.txt~update-drop_caches-documentation	2010-09-14 15:30:19.000000000 -0700
> +++ linux-2.6.git-dave/Documentation/sysctl/vm.txt	2010-09-14 16:40:58.000000000 -0700
> @@ -145,8 +145,18 @@ To free dentries and inodes:
>  To free pagecache, dentries and inodes:
>  	echo 3 > /proc/sys/vm/drop_caches
>  
> -As this is a non-destructive operation and dirty objects are not freeable, the
> -user should run `sync' first.
> +This is a non-destructive operation and will not free any dirty objects.
> +To increase the number of objects freed by this operation, the user may run
> +`sync' prior to writing to /proc/sys/vm/drop_caches.  This will minimize the
> +number of dirty objects on the system and create more candidates to be
> +dropped.
> +
> +This file is not a means to control the growth of the various kernel caches
> +(inodes, dentries, pagecache, etc...)  These objects are automatically
> +reclaimed by the kernel when memory is needed elsewhere on the system.
> +
> +Outside of a testing or debugging environment, use of
> +/proc/sys/vm/drop_caches is not recommended.
>  
>  ==============================================================
>  
> diff -puN fs/drop_caches.c~update-drop_caches-documentation fs/drop_caches.c
> --- linux-2.6.git/fs/drop_caches.c~update-drop_caches-documentation	2010-09-14 15:44:29.000000000 -0700
> +++ linux-2.6.git-dave/fs/drop_caches.c	2010-09-14 15:58:31.000000000 -0700
> @@ -47,6 +47,8 @@ int drop_caches_sysctl_handler(ctl_table
>  {
>  	proc_dointvec_minmax(table, write, buffer, length, ppos);
>  	if (write) {
> +		WARN_ONCE(1, "kernel caches forcefully dropped, "
> +			     "see Documentation/sysctl/vm.txt\n");

Documentation updeta seems good but showing warning seems to be meddling to me.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
