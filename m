Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9194A6B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 18:12:15 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so8137644pde.21
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 15:12:15 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id sj5si20443849pab.255.2014.02.11.15.12.06
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 15:12:07 -0800 (PST)
Date: Tue, 11 Feb 2014 16:12:11 -0700 (MST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v5 19/22] ext4: Add XIP functionality
In-Reply-To: <CF1FF3EB.24114%matthew.r.wilcox@intel.com>
Message-ID: <alpine.OSX.2.00.1402111536290.55274@scrumpy>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com> <CF1FF3EB.24114%matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed, 15 Jan 2014, Matthew Wilcox wrote:
> From: Ross Zwisler <ross.zwisler@linux.intel.com>
> 
> This is a port of the XIP functionality found in the current version of
> ext2.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> [heavily tweaked]
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>

...

> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index c767666..8b73d77 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -663,6 +663,18 @@ found:
>  			WARN_ON(1);
>  		}
>  
> +		/* this is probably wrong for ext4.  unlike ext2, ext4 supports
> +		 * uninitialised extents, so we should probably be hooking
> +		 * into the "make it initialised" code instead. */
> +		if (IS_XIP(inode)) {

With the very first version of this patch the above logic seemed to work
correctly, zeroing blocks as we allocated them.  With the current XIP
infrastructure based tightly on direct IO this ends up being wrong because in
some cases we can call ext4_map_blocks() twice for a given block.  

A quick userland test program that creates a new file, truncates it up to 4k
and then does a partial block write will end up giving you a file filled with
all zeros.  This is because we zero the data before the write, do the write,
and then zero again, overwriting the data.  The second call to
ext4_map_blocks() happens via ext4_ext_direct_IO =>
ext4_convert_unwritten_extents() => ext4_map_blocks().

We can know in ext4_map_blocks() that we are being called after a write has
already completed by looking at the flags.  One solution to get around this
double-zeroing would be to change the above test to:

+                 if (IS_XIP(inode) && !(flags & EXT4_GET_BLOCKS_CONVERT)) {

This fixes the tests I've been able to come up with, but I'm not certain it's
the correct fix for the long term.  It seems wasteful to zero the blocks we're
allocating, just to have the zeros overwritten immediately by a write.  Maybe
a cleaner way would be to try and zero the unwritten bits inside of
ext4_convert_unwritten_extents(), or somewhere similar?

It's worth noting that I don't think the direct I/O path has this kind of
logic because they don't allow partial block writes.  The regular I/O path
knows to zero unwritten space based on the BH_New flag, as set via the
set_buffer_new() call in ext4_da_map_blocks().  This is a pretty different I/O
path, though, so I'm not sure how much we can borrow for the XIP code.

Thoughts on the correct fix?

- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
