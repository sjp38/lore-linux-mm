Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 7453A6B0023
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 09:17:03 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so1966955bkb.14
        for <linux-mm@kvack.org>; Wed, 14 Sep 2011 06:17:00 -0700 (PDT)
Date: Wed, 14 Sep 2011 17:16:30 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [RFC PATCH 2/2] mm: restrict access to /proc/slabinfo
Message-ID: <20110914131630.GA7001@albatros>
References: <20110910164001.GA2342@albatros>
 <20110910164134.GA2442@albatros>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110910164134.GA2442@albatros>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>, Dan Rosenberg <drosenberg@vsecurity.com>, Theodore Tso <tytso@mit.edu>, Alan Cox <alan@linux.intel.com>, Jesper Juhl <jj@chaosbits.net>, Linus Torvalds <torvalds@linux-foundation.org>

(cc'ed all members of the previous discussion as currently lists might
not work as they should)

On Sat, Sep 10, 2011 at 20:41 +0400, Vasiliy Kulikov wrote:
> Historically /proc/slabinfo has 0444 permissions and is accessible to
> the world.  slabinfo contains rather private information related both to
> the kernel and userspace tasks.  Depending on the situation, it might
> reveal either private information per se or information useful to make
> another targeted attack.  Some examples of what can be learned by
> reading/watching for /proc/slabinfo entries:
> 
> 1) dentry (and different *inode*) number might reveal other processes fs
> activity.  The number of dentry "active objects" doesn't strictly show
> file count opened/touched by a process, however, there is a good
> correlation between them.  The patch "proc: force dcache drop on
> unauthorized access" relies on the privacy of dentry count.
> 
> 2) different inode entries might reveal the same information as (1), but
> these are more fine granted counters.  If a filesystem is mounted in a
> private mount point (or even a private namespace) and fs type differs from
> other mounted fs types, fs activity in this mount point/namespace is
> revealed.  If there is a single ecryptfs mount point, the whole fs
> activity of a single user is revealed.  Number of files in ecryptfs
> mount point is a private information per se.
> 
> 3) fuse_* reveals number of files / fs activity of a user in a user
> private mount point.  It is approx. the same severity as ecryptfs
> infoleak in (2).
> 
> 4) sysfs_dir_cache similar to (2) reveals devices' addition/removal,
> which can be otherwise hidden by "chmod 0700 /sys/".  With 0444 slabinfo
> the precise number of sysfs files is known to the world.
> 
> 5) buffer_head might reveal some kernel activity.  With other
> information leaks an attacker might identify what specific kernel
> routines generate buffer_head activity.
> 
> 6) *kmalloc* infoleaks are very situational.  Attacker should watch for
> the specific kmalloc size entry and filter the noise related to the unrelated
> kernel activity.  If an attacker has relatively silent victim system, he
> might get rather precise counters.
> 
> Additional information sources might significantly increase the slabinfo
> infoleak benefits.  E.g. if an attacker knows that the processes
> activity on the system is very low (only core daemons like syslog and
> cron), he may run setxid binaries / trigger local daemon activity /
> trigger network services activity / await sporadic cron jobs activity
> / etc. and get rather precise counters for fs and network activity of
> these privileged tasks, which is unknown otherwise.
> 
> 
> Also hiding slabinfo is a one step to complicate exploitation of kernel
> heap overflows (and possibly, other bugs).  The related discussion:
> 
> http://thread.gmane.org/gmane.linux.kernel/1108378
> 
> 
> World readable slabinfo simplifies kernel developers' job of debugging
> kernel bugs (e.g. memleaks), but I believe it does more harm than
> benefits.  For most users 0444 slabinfo is an unreasonable attack vector.

Please tell if anybody has complains about the restriction - whether it
forces someone besides kernel developers to do "chmod/chgrp".  But if
someone want to debug the kernel, it shouldn't significantly influence
on common users, especially it shouldn't create security issues.

Thanks!

> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
> ---
>  mm/slab.c |    3 ++-
>  mm/slub.c |    2 +-
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> --
> diff --git a/mm/slab.c b/mm/slab.c
> index 6d90a09..560ffd0 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -4584,7 +4584,8 @@ static const struct file_operations proc_slabstats_operations = {
>  
>  static int __init slab_proc_init(void)
>  {
> -	proc_create("slabinfo",S_IWUSR|S_IRUGO,NULL,&proc_slabinfo_operations);
> +	proc_create("slabinfo", S_IWUSR | S_IRUSR, NULL,
> +		    &proc_slabinfo_operations);
>  #ifdef CONFIG_DEBUG_SLAB_LEAK
>  	proc_create("slab_allocators", 0, NULL, &proc_slabstats_operations);
>  #endif
> diff --git a/mm/slub.c b/mm/slub.c
> index 9f662d7..f440fc7 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -5257,7 +5257,7 @@ static const struct file_operations proc_slabinfo_operations = {
>  
>  static int __init slab_proc_init(void)
>  {
> -	proc_create("slabinfo", S_IRUGO, NULL, &proc_slabinfo_operations);
> +	proc_create("slabinfo", S_IRUSR, NULL, &proc_slabinfo_operations);
>  	return 0;
>  }
>  module_init(slab_proc_init);

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
