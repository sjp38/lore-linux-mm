Date: Mon, 19 Feb 2007 19:13:51 -0500
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: dirty balancing deadlock
Message-ID: <20070220001351.GJ6133@think.oraclecorp.com>
References: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu> <20070218125307.4103c04a.akpm@linux-foundation.org> <E1HIurG-0005Bw-00@dorka.pomaz.szeredi.hu> <20070218145929.547c21c7.akpm@linux-foundation.org> <E1HIvMB-0005Fd-00@dorka.pomaz.szeredi.hu> <20070218155916.0d3c73a9.akpm@linux-foundation.org> <E1HJC3P-0006tz-00@dorka.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1HJC3P-0006tz-00@dorka.pomaz.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 19, 2007 at 06:11:55PM +0100, Miklos Szeredi wrote:
> How about this?
> 
> Solves the FUSE deadlock, but not the throttle_vm_writeout() one.
> I'll try to tackle that one as well.
> 
> If the per-bdi dirty counter goes below 16, balance_dirty_pages()
> returns.
> 
> Does the constant need to tunable?  If it's too large, then the global
> threshold is more easily exceeded.  If it's too small, then in a tight
> situation progress will be slower.

Ok, what is supposed to happen here is that filesystems are supposed to
be throttled from making more dirty pages when the system is over the
threshold.  Even if filesystem A doesn't have much to contribute, and
filesystem B is the cause of 99% of the dirty pages, the goal of the
threshold is to prevent more dirty data from happening, and filesystem A
should block.

But, with the producer consumer setup of fuse, I think this is a pretty
good compromise.  16 dirty/writeback pages shouldn't hurt the overall
limits too badly.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
