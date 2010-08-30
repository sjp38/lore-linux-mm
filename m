Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 835FE6B01F2
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 18:53:30 -0400 (EDT)
Message-ID: <4C7C3666.2080601@goop.org>
Date: Mon, 30 Aug 2010 15:53:26 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH V4 5/8] Cleancache: ext3 hook for cleancache
References: <20100830223233.GA1317@ca-server1.us.oracle.com>
In-Reply-To: <20100830223233.GA1317@ca-server1.us.oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com
List-ID: <linux-mm.kvack.org>

 On 08/30/2010 03:32 PM, Dan Magenheimer wrote:
> [PATCH V4 5/8] Cleancache: ext3 hook for cleancache
>
> Filesystems must explicitly enable cleancache by calling
> cleancache_init_fs anytime a instance of the filesystem
> is mounted and must save the returned poolid.  For ext3,
> all other cleancache hooks are in the VFS layer including
> the matching cleancache_flush_fs hook which must be
> called on unmount.
>
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Acked-by: Andreas Dilger <adilger@sun.com>
>
> Diffstat:
>  super.c                                  |    2 ++
>  1 file changed, 2 insertions(+)
>
> --- linux-2.6.36-rc3/fs/ext3/super.c	2010-08-29 09:36:04.000000000 -0600
> +++ linux-2.6.36-rc3-cleancache/fs/ext3/super.c	2010-08-30 09:20:42.000000000 -0600
> @@ -37,6 +37,7 @@
>  #include <linux/quotaops.h>
>  #include <linux/seq_file.h>
>  #include <linux/log2.h>
> +#include <linux/cleancache.h>
>  
>  #include <asm/uaccess.h>
>  
> @@ -1349,6 +1350,7 @@ static int ext3_setup_super(struct super
>  	} else {
>  		ext3_msg(sb, KERN_INFO, "using internal journal");
>  	}
> +	sb->cleancache_poolid = cleancache_init_fs(PAGE_SIZE);

Do you really need to pass in the page size?  What about just
"cleancache_init_fs(sb)" rather than exposing the
"sb->cleancache_poolid"?  In other words, what if you want to do
more/other per-filesystem init at some point?

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
