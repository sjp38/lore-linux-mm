Date: Mon, 25 Jun 2007 09:19:17 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [patch 1/3] add the fsblock layer
Message-ID: <20070625131917.GD12852@think.oraclecorp.com>
References: <20070624014528.GA17609@wotan.suse.de> <20070624014613.GB17609@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070624014613.GB17609@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 24, 2007 at 03:46:13AM +0200, Nick Piggin wrote:
> Rewrite the buffer layer.

Overall, I like the basic concepts, but it is hard to track the locking
rules.  Could you please write them up?

I like the way you split out the assoc_buffers from the main fsblock
code, but the list setup is still something of a wart.  It also provides
poor ordering of blocks for writeback.

I think it makes sense to replace the assoc_buffers list head with a
radix tree sorted by block number.  mark_buffer_dirty_inode would up the
reference count and put it into the radix, the various flushing routines
would walk the radix etc.

If you wanted to be able to drop the reference count once the block was
written you could have a back pointer to the appropriate inode.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
