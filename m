Date: Fri, 29 Feb 2008 03:26:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/6] mm: bdi: export BDI attributes in sysfs
Message-Id: <20080229032601.4a9e31eb.akpm@linux-foundation.org>
In-Reply-To: <20080129154948.823761079@szeredi.hu>
References: <20080129154900.145303789@szeredi.hu>
	<20080129154948.823761079@szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Kay Sievers <kay.sievers@vrfy.org>, Greg KH <greg@kroah.com>, Trond Myklebust <trond.myklebust@fys.uio.no>, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2008 16:49:02 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:

> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> Provide a place in sysfs (/sys/class/bdi) for the backing_dev_info
> object.  This allows us to see and set the various BDI specific
> variables.
> 
> In particular this properly exposes the read-ahead window for all
> relevant users and /sys/block/<block>/queue/read_ahead_kb should be
> deprecated.
> 
> With patient help from Kay Sievers and Greg KH
> 
> [mszeredi@suse.cz]
> 
>  - split off NFS and FUSE changes into separate patches
>  - document new sysfs attributes under Documentation/ABI
>  - do bdi_class_init as a core_initcall, otherwise the "default" BDI
>    won't be initialized
>  - remove bdi_init_fmt macro, it's not used very much

please always provide diffstats.

 Documentation/ABI/testing/sysfs-class-bdi |   50 +++++++++++++                
 block/genhd.c                             |    3 
 include/linux/backing-dev.h               |    8 ++
 include/linux/writeback.h                 |    3 
 lib/percpu_counter.c                      |    1 
 mm/backing-dev.c                          |  108 ++++++++++++++++++++++++++++++
 mm/page-writeback.c                       |    2 
 mm/readahead.c                            |    8 +-
 8 files changed, 181 insertions(+), 2 deletions(-)

would you believe this breaks ia64 allmodconfig, in the usual place:

In file included from arch/ia64/ia32/sys_ia32.c:59:
arch/ia64/ia32/ia32priv.h:342:1: warning: "SET_PERSONALITY" redefined
In file included from include/linux/elf.h:7,
                 from include/linux/module.h:14,
                 from include/linux/device.h:21,
                 from include/linux/backing-dev.h:15,
                 from include/linux/nfs_fs_sb.h:5,
                 from include/linux/nfs_fs.h:50,
                 from arch/ia64/ia32/sys_ia32.c:35:
include/asm/elf.h:180:1: warning: this is the location of the previous definition


We keep on hitting stupid build errors in this area: ia64 and elf.  It is
obviously quite fragile.  It would be nice to fix it properly.


For now, the easy fix:

--- a/include/linux/backing-dev.h~mm-bdi-export-bdi-attributes-in-sysfs-ia64-fix
+++ a/include/linux/backing-dev.h
@@ -12,10 +12,10 @@
 #include <linux/log2.h>
 #include <linux/proportions.h>
 #include <linux/kernel.h>
-#include <linux/device.h>
 #include <asm/atomic.h>
 
 struct page;
+struct device;
 
 /*
  * Bits in backing_dev_info.state

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
