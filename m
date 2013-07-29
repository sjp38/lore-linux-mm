Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 133C26B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 17:51:45 -0400 (EDT)
Date: Mon, 29 Jul 2013 14:51:41 -0700
From: Zach Brown <zab@redhat.com>
Subject: Re: [PATCH] truncate: drop 'oldsize' truncate_pagecache() parameter
Message-ID: <20130729215141.GE32145@lenny.home.zabbo.net>
References: <1375099760-7614-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375099760-7614-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Lukas Czerner <lczerner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

> @@ -50,7 +50,7 @@ static void adfs_write_failed(struct address_space *mapping, loff_t to)
>  	struct inode *inode = mapping->host;
>  
>  	if (to > inode->i_size)
> -		truncate_pagecache(inode, to, inode->i_size);
> +		truncate_pagecache(inode, inode->i_size);
>  }

All these _write_failed() boiler plate functions still technically use
'to', so I *guess* they can stay :).

> @@ -226,7 +226,7 @@ int btrfs_truncate_free_space_cache(struct btrfs_root *root,
>  
>  	oldsize = i_size_read(inode);
>  	btrfs_i_size_write(inode, 0);
> -	truncate_pagecache(inode, oldsize, 0);
> +	truncate_pagecache(inode, 0);

But after this change 'oldsize' is set but never used.  That'll generate
a warning on some versions of gcc.

Can you redo the patch with an eye to removing unused arguments and
variables further up the call stack?

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
