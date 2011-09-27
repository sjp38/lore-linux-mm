Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id F3CEE9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 15:39:06 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so9699237bkb.14
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 12:39:02 -0700 (PDT)
Date: Tue, 27 Sep 2011 23:38:10 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH 2/2] mm: restrict access to /proc/meminfo
Message-ID: <20110927193810.GA5416@albatros>
References: <20110927175453.GA3393@albatros>
 <20110927175642.GA3432@albatros>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110927175642.GA3432@albatros>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Valdis.Kletnieks@vt.edu, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, Sep 27, 2011 at 21:56 +0400, Vasiliy Kulikov wrote:
> /proc/meminfo stores information related to memory pages usage, which
> may be used to monitor the number of objects in specific caches (and/or
> the changes of these numbers).  This might reveal private information
> similar to /proc/slabinfo infoleaks.  To remove the infoleak, just
> restrict meminfo to root.  If it is used by unprivileged daemons,
> meminfo permissions can be altered the same way as slabinfo:
> 
>     groupadd meminfo
>     usermod -a -G meminfo $MONITOR_USER
>     chmod g+r /proc/meminfo
>     chgrp meminfo /proc/meminfo

Just to make it clear: since this patch breaks "free", I don't propose
it anymore.


> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
> CC: Kees Cook <kees@ubuntu.com>
> CC: Dave Hansen <dave@linux.vnet.ibm.com>
> CC: Christoph Lameter <cl@gentwo.org>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Valdis.Kletnieks@vt.edu
> CC: Linus Torvalds <torvalds@linux-foundation.org>
> CC: David Rientjes <rientjes@google.com>
> CC: Alan Cox <alan@linux.intel.com>
> ---
>  fs/proc/meminfo.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> --
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index 5861741..949bdee 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -187,7 +187,7 @@ static const struct file_operations meminfo_proc_fops = {
>  
>  static int __init proc_meminfo_init(void)
>  {
> -	proc_create("meminfo", 0, NULL, &meminfo_proc_fops);
> +	proc_create("meminfo", S_IFREG | S_IRUSR, NULL, &meminfo_proc_fops);
>  	return 0;
>  }
>  module_init(proc_meminfo_init);

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
