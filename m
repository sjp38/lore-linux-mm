Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 781FA6B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 19:00:23 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so3335204pbb.35
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 16:00:23 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ek3si8466159pbd.55.2014.01.16.16.00.21
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 16:00:22 -0800 (PST)
Date: Thu, 16 Jan 2014 17:00:12 -0700 (MST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v5 19/22] ext4: Add XIP functionality
In-Reply-To: <CEFDA737.22F87%matthew.r.wilcox@intel.com>
Message-ID: <alpine.OSX.2.00.1401161653120.41367@scrumpy>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com> <CEFDA737.22F87%matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed, 15 Jan 2014, Matthew Wilcox wrote:

> +#ifdef CONFIG_FS_XIP
> +const struct file_operations ext4_xip_file_operations = {
> +	.llseek		= ext4_llseek,
> +	.read		= do_sync_read,
> +	.write		= do_sync_write,

I think we may always need to define ext2_xip_file_operations and
ext4_xip_file_operations, even if we have XIP compiled out.  We make the
decision on which file operations table to use at runtime:

from ext4_iget:
		if (test_opt(inode->i_sb, XIP))
                        inode->i_fop = &ext4_xip_file_operations;
                else    
                        inode->i_fop = &ext4_file_operations;

With CONFIG_FS_XIP undefined, we get a compile error:
	ERROR: "ext4_xip_file_operations" [fs/ext4/ext4.ko] undefined!
	ERROR: "ext2_xip_file_operations" [fs/ext2/ext2.ko] undefined!

My guess is that with the old ext2 XIP code and with the first pass of the ext4
XIP code, we weren't seeing this because the uses of the xip file operations
table were optimized out, removing the undefined symbol?

- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
