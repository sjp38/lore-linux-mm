Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4EFC16B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 15:29:08 -0400 (EDT)
Date: Wed, 2 Jun 2010 12:29:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 2/7] Cleancache (was Transcendent Memory): core files
Message-Id: <20100602122900.6c893a6a.akpm@linux-foundation.org>
In-Reply-To: <20100528173550.GA12219@ca-server1.us.oracle.com>
References: <20100528173550.GA12219@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

On Fri, 28 May 2010 10:35:50 -0700
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> [PATCH V2 2/7] Cleancache (was Transcendent Memory): core files
> 
> Cleancache core files.
> 
> Credits: Cleancache_ops design derived from Jeremy Fitzhardinge
> design for tmem; sysfs code modelled after mm/ksm.c
> 
> Note that CONFIG_CLEANCACHE defaults to on; all hooks devolve
> to a compare-pointer-to-NULL so performance impact should
> be negligible, but can be reduced to zero impact if config'ed off.
> 
> ...
>
> --- linux-2.6.34/include/linux/cleancache.h	1969-12-31 17:00:00.000000000 -0700
> +++ linux-2.6.34-cleancache/include/linux/cleancache.h	2010-05-24 18:14:33.000000000 -0600
> @@ -0,0 +1,90 @@
> +#ifndef _LINUX_CLEANCACHE_H
> +#define _LINUX_CLEANCACHE_H
> +
> +#include <linux/fs.h>
> +#include <linux/mm.h>
> +
> +#define CLEANCACHE_GET_PAGE_SUCCESS 1
> +
> +struct cleancache_ops {
> +	int (*init_fs)(size_t);
> +	int (*init_shared_fs)(char *uuid, size_t);
> +	int (*get_page)(int, ino_t, pgoff_t, struct page *);
> +	int (*put_page)(int, ino_t, pgoff_t, struct page *);
> +	int (*flush_page)(int, ino_t, pgoff_t);
> +	int (*flush_inode)(int, ino_t);
> +	void (*flush_fs)(int);
> +};
> +
> +extern struct cleancache_ops *cleancache_ops;

Why does this exist?  If there's only ever one cleancache_ops
system-wide then we'd be better off doing

	(*cleancache_ops.init_fs)()

and save a zillion pointer hops.

If instead there are different flavours of cleancache_ops then making
this pointer a system-wide singleton seems an odd decision.

>
> ...
>
> +int __cleancache_get_page(struct page *page)
> +{
> +	int ret = 0;
> +	int pool_id = page->mapping->host->i_sb->cleancache_poolid;
> +
> +	if (pool_id >= 0) {
> +		ret = (*cleancache_ops->get_page)(pool_id,
> +						  page->mapping->host->i_ino,
> +						  page->index,
> +						  page);
> +		if (ret == CLEANCACHE_GET_PAGE_SUCCESS)
> +			succ_gets++;
> +		else
> +			failed_gets++;
> +	}
> +	return ret;
> +}
> +EXPORT_SYMBOL(__cleancache_get_page);

All these undocumeted functions would appear to be racy and buggy if
the passed-in page isn't locked.  But because they're undocumented, I
don't know if "the page must be locked" was an API requirement and I
ain't going to go and review all callers.

> +#ifdef CONFIG_SYSFS
> +
> +#define CLEANCACHE_ATTR_RO(_name) \
> +	static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
> +
> +static ssize_t succ_gets_show(struct kobject *kobj,
> +			       struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%lu\n", succ_gets);
> +}
> +CLEANCACHE_ATTR_RO(succ_gets);
> +
> +static ssize_t failed_gets_show(struct kobject *kobj,
> +			       struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%lu\n", failed_gets);
> +}
> +CLEANCACHE_ATTR_RO(failed_gets);
> +
> +static ssize_t puts_show(struct kobject *kobj,
> +			       struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%lu\n", puts);
> +}
> +CLEANCACHE_ATTR_RO(puts);
> +
> +static ssize_t flushes_show(struct kobject *kobj,
> +			       struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%lu\n", flushes);
> +}
> +CLEANCACHE_ATTR_RO(flushes);
> +
> +static struct attribute *cleancache_attrs[] = {
> +	&succ_gets_attr.attr,
> +	&failed_gets_attr.attr,
> +	&puts_attr.attr,
> +	&flushes_attr.attr,
> +	NULL,
> +};
> +
> +static struct attribute_group cleancache_attr_group = {
> +	.attrs = cleancache_attrs,
> +	.name = "cleancache",
> +};
> +
> +#endif /* CONFIG_SYSFS */

Please completely document the sysfs API, preferably in the changelogs.
It's the first thing reviewers should look at, because it's one thing
we can never change.  And Documentation/ABI/ is a place for permanent
documentation.


> --- linux-2.6.34/mm/Kconfig	2010-05-16 15:17:36.000000000 -0600
> +++ linux-2.6.34-cleancache/mm/Kconfig	2010-05-24 12:14:44.000000000 -0600
> @@ -287,3 +287,25 @@ config NOMMU_INITIAL_TRIM_EXCESS
>  	  of 1 says that all excess pages should be trimmed.
>  
>  	  See Documentation/nommu-mmap.txt for more information.
> +
> +config CLEANCACHE
> +	bool "Enable cleancache pseudo-RAM driver to cache clean pages"
> +	default y
> +	help
> + 	  Cleancache can be thought of as a page-granularity victim cache
> +	  for clean pages that the kernel's pageframe replacement algorithm
> +	  (PFRA) would like to keep around, but can't since there isn't enough
> +	  memory.  So when the PFRA "evicts" a page, it first attempts to put
> +	  it into a synchronous concurrency-safe page-oriented pseudo-RAM
> +	  device (such as Xen's Transcendent Memory, aka "tmem") which is not
> +	  directly accessible or addressable by the kernel and is of unknown
> +	  (and possibly time-varying) size.  And when a cleancache-enabled
> +	  filesystem wishes to access a page in a file on disk, it first
> +	  checks cleancache to see if it already contains it; if it does,
> + 	  the page is copied into the kernel and a disk access is avoided.
> +	  When a pseudo-RAM device is available, a significant I/O reduction
> +	  may be achieved.  When none is available, all cleancache calls
> +	  are reduced to a single pointer-compare-against-NULL resulting
> +	  in a negligible performance hit.
> +
> +	  If unsure, say Y to enable cleancache


I'm a bit surprised that cleancache and frontswap have their sticky
fingers so deep inside swap and filesystems and the VFS.

I'd have thought that the places where pages are added to the caches
would be highly concentrated in the page-reclaim page eviction code,
and that for reads the place where pages are retrieved would be at the
pagecache/swapcache <-> I/O boundary.  Those transition points are
reasonably narrow and seem to be the obvious site at which to interpose
a cache, but it wasn't done that way.

In core MM there's been effort to treat swap-backed and file-backed pages
in the same manner (indeed in a common manner) and that effort has been
partially successful.  These changes are going in the other direction.


There have been any number of compressed-swap and compressed-file
projects (if not compressed-pagecache).  Where do cleancache/frontswap
overlap those and which is superior?


And the big vague general issue: where's the value?  What does all this
code buy us?  Why would we want to include it in Linux?  When Aunt
Tillie unwraps her shiny new kernel, what would she notice was
different?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
