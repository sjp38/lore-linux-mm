Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1428B6B004D
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 12:14:57 -0400 (EDT)
Date: Wed, 29 Jul 2009 18:14:56 +0200
From: Lars Ellenberg <lars.ellenberg@linbit.com>
Subject: Why does __do_page_cache_readahead submit READ, not READA?
Message-ID: <20090729161456.GB8059@barkeeper1-xen.linbit>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, dm-devel@redhat.com, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

I naively assumed, from the "readahead" in the name, that readahead
would be submitting READA bios. It does not.

I recently did some statistics on how many READ and READA requests
we actually see on the block device level.
I was suprised that READA is basically only used for file system
internal meta data (and not even for all file systems),
but _never_ for file data.

A simple
	dd if=bigfile of=/dev/null bs=4k count=1
will absolutely cause readahead of the configured amount, no problem.
But on the block device level, these are READ requests, where I'd
expected them to be READA requests, based on the name.

This is because __do_page_cache_readahead() calls read_pages(),
which in turn is mapping->a_ops->readpages(), or, as fallback,
mapping->a_ops->readpage().

On that level, all variants end up submitting as READ.

This may even be intentional.
But if so, I'd like to understand that.

Please, anyone in the know, enlighten me ;)


	Lars

Annecdotical: I've seen an oracle being killed by OOM, because someone
did a grep -r . while accidentally having a bogusly huge readahead set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
