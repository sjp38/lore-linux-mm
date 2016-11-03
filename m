Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D62A16B02E3
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 16:55:01 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id w39so27505226qtw.0
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 13:55:01 -0700 (PDT)
Received: from mail5.wrs.com (mail5.windriver.com. [192.103.53.11])
        by mx.google.com with ESMTPS id c6si5276808qtb.27.2016.11.03.13.55.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 13:55:00 -0700 (PDT)
Date: Thu, 3 Nov 2016 16:54:33 -0400
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [RFC PATCH] hugetlbfs: fix the hugetlbfs can not be mounted
Message-ID: <20161103205433.GD26342@windriver.com>
References: <1477721311-54522-1-git-send-email-zhongjiang@huawei.com>
 <20161103121721.50040185d201e3aac27fd366@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20161103121721.50040185d201e3aac27fd366@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: zhongjiang <zhongjiang@huawei.com>, nyc@holomorphy.com, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, rientjes@google.com, hillf.zj@alibaba-inc.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

[Re: [RFC PATCH] hugetlbfs: fix the hugetlbfs can not be mounted] On 03/11/2016 (Thu 12:17) Andrew Morton wrote:

> On Sat, 29 Oct 2016 14:08:31 +0800 zhongjiang <zhongjiang@huawei.com> wrote:
> 
> > From: zhong jiang <zhongjiang@huawei.com>
> > 
> > Since 'commit 3e89e1c5ea84 ("hugetlb: make mm and fs code explicitly non-modular")'
> > bring in the mainline. mount hugetlbfs will result in the following issue.
> > 
> > mount: unknown filesystme type 'hugetlbfs'

The fact that the above has a typo makes me doubt it was real output
from "mount".   In any case, that just means they didn't enable the
Kconfig option for it and hence it is not in /proc/filesystems as they
can easily verify.

> > 
> > because previous patch remove the module_alias_fs, when we mount the fs type,
> > the caller get_fs_type can not find the filesystem.
> > 
> > The patch just recover the module_alias_fs to identify the hugetlbfs.
> 
> hm, 3e89e1c5ea84 ("hugetlb: make mm and fs code explicitly
> non-modular") was merged almost a year ago.  And you are apparently the
> first person to discover this regression.  Can you think why that is?

Agreed -- I'd like to know just how this conclusion was reached.  Maybe
they are running some out-of-tree patches to make it modular?  Who
knows.  It would be nice if we hear back, but I don't have high hopes.

In any case, 3e89e1c5ea84 commit log says:

    Also note that MODULE_ALIAS is a no-op for non-modular code.

This isn't fundamentally hard to verify; the macros are:

#define MODULE_ALIAS_FS(NAME) MODULE_ALIAS("fs-" NAME)

#define MODULE_ALIAS(_alias) MODULE_INFO(alias, _alias)

#define MODULE_INFO(tag, info) __MODULE_INFO(tag, tag, info)

...and then finally:

#ifdef MODULE
#define __MODULE_INFO(tag, name, info)                                    \
static const char __UNIQUE_ID(name)[]                                     \
  __used __attribute__((section(".modinfo"), unused, aligned(1)))         \
  = __stringify(tag) "=" info
#else  /* !MODULE */
/* This struct is here for syntactic coherency, it is not used */
#define __MODULE_INFO(tag, name, info)                                    \
  struct __UNIQUE_ID(name) {}
#endif

...so a commit like this would have to explain how the patch does anything in
the !MODULE case, when the syntax comment above even indicates it is not used.

I remember this commit since there was patch order issue that the kbuild
robot uncovered (as listed in the commit log) in an earlier version of it.

So I can assure the patch poster that hugetlbfs was mounted for testing,
and they should revisit the logic that led to this no-op patch.

Paul.
--

> 
> > index 4fb7b10..b63e7de 100644
> > --- a/fs/hugetlbfs/inode.c
> > +++ b/fs/hugetlbfs/inode.c
> > @@ -35,6 +35,7 @@
> >  #include <linux/security.h>
> >  #include <linux/magic.h>
> >  #include <linux/migrate.h>
> > +#include <linux/module.h>
> >  #include <linux/uio.h>
> >  
> >  #include <asm/uaccess.h>
> > @@ -1209,6 +1210,7 @@ static struct dentry *hugetlbfs_mount(struct file_system_type *fs_type,
> >  	.mount		= hugetlbfs_mount,
> >  	.kill_sb	= kill_litter_super,
> >  };
> > +MODULE_ALIAS_FS("hugetlbfs");
> >  
> >  static struct vfsmount *hugetlbfs_vfsmount[HUGE_MAX_HSTATE];
> >  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
