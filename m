Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B148A9000C4
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 14:21:35 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p8RILWqG028142
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 11:21:32 -0700
Received: from ywa6 (ywa6.prod.google.com [10.192.1.6])
	by hpaq13.eem.corp.google.com with ESMTP id p8RIKhmd031598
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 11:21:31 -0700
Received: by ywa6 with SMTP id 6so5716535ywa.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 11:21:27 -0700 (PDT)
Date: Tue, 27 Sep 2011 11:21:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: restrict access to slab files under procfs and
 sysfs
In-Reply-To: <20110927175453.GA3393@albatros>
Message-ID: <alpine.DEB.2.00.1109271117200.17876@chino.kir.corp.google.com>
References: <20110927175453.GA3393@albatros>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: kernel-hardening@lists.openwall.com, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Valdis.Kletnieks@vt.edu, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, 27 Sep 2011, Vasiliy Kulikov wrote:

> Historically /proc/slabinfo and files under /sys/kernel/slab/* have
> world read permissions and are accessible to the world.  slabinfo
> contains rather private information related both to the kernel and
> userspace tasks.  Depending on the situation, it might reveal either
> private information per se or information useful to make another
> targeted attack.  Some examples of what can be learned by
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
> Also hiding slabinfo and /sys/kernel/slab/* is a one step to complicate
> exploitation of kernel heap overflows (and possibly, other bugs).  The
> related discussion:
> 
> http://thread.gmane.org/gmane.linux.kernel/1108378
> 
> 
> To keep compatibility with old permission model where non-root
> monitoring daemon could watch for kernel memleaks though slabinfo one
> should do:
> 
>     groupadd slabinfo
>     usermod -a -G slabinfo $MONITOR_USER
> 
> And add the following commands to init scripts (to mountall.conf in
> Ubuntu's upstart case):
> 
>     chmod g+r /proc/slabinfo /sys/kernel/slab/*/*
>     chgrp slabinfo /proc/slabinfo /sys/kernel/slab/*/*
> 
> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
> Reviewed-by: Kees Cook <kees@ubuntu.com>
> Reviewed-by: Dave Hansen <dave@linux.vnet.ibm.com>
> CC: Christoph Lameter <cl@gentwo.org>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Valdis.Kletnieks@vt.edu
> CC: Linus Torvalds <torvalds@linux-foundation.org>
> CC: David Rientjes <rientjes@google.com>
> CC: Alan Cox <alan@linux.intel.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
