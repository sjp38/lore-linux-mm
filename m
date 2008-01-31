Date: Wed, 30 Jan 2008 16:28:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/6] mm: bdi: export BDI attributes in sysfs
Message-Id: <20080130162839.977d1e63.akpm@linux-foundation.org>
In-Reply-To: <20080129154948.823761079@szeredi.hu>
References: <20080129154900.145303789@szeredi.hu>
	<20080129154948.823761079@szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, kay.sievers@vrfy.org, greg@kroah.com, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2008 16:49:02 +0100
Miklos Szeredi <miklos@szeredi.hu> wrote:

> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> Provide a place in sysfs (/sys/class/bdi) for the backing_dev_info
> object.  This allows us to see and set the various BDI specific
> variables.
> 
> In particular this properly exposes the read-ahead window for all
> relevant users and /sys/block/<block>/queue/read_ahead_kb should be
> deprecated.

This description is not complete.  It implies that the readahead window is
not "properly" exposed for some "relevant" users.  The reader is left
wondering what on earth this is referring to.  I certainly don't know.
Perhaps when this information is revealed, we can work out what was
wrong with per-queue readahead tuning.

> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux/Documentation/ABI/testing/sysfs-class-bdi	2008-01-29 13:02:46.000000000 +0100
> @@ -0,0 +1,50 @@
> +What:		/sys/class/bdi/<bdi>/
> +Date:		January 2008
> +Contact:	Peter Zijlstra <a.p.zijlstra@chello.nl>
> +Description:
> +
> +Provide a place in sysfs for the backing_dev_info object.
> +This allows us to see and set the various BDI specific variables.
> +
> +The <bdi> identifyer can take the following forms:

"identifier"

> +blk-NAME
> +
> +	Block devices, NAME is 'sda', 'loop0', etc...

But if I've done `mknod /dev/pizza-party 8 0', I'm looking for
blk-pizza-party, not blk-sda.

But I might still have /dev/sda, too.

> +FSTYPE-MAJOR:MINOR
> +
> +	Non-block device backed filesystems which provide their own
> +	BDI, such as NFS and FUSE.  MAJOR:MINOR is the value of st_dev
> +	for files on this filesystem.
> +
> +default
> +
> +	The default backing dev, used for non-block device backed
> +	filesystems which do not provide their own BDI.
> +
> +Files under /sys/class/bdi/<bdi>/
> +---------------------------------
> +
> +read_ahead_kb (read-write)
> +
> +	Size of the read-ahead window in kilobytes
> +
> +reclaimable_kb (read-only)
> +
> +	Reclaimable (dirty or unstable) memory destined for writeback
> +	to this device
> +
> +writeback_kb (read-only)
> +
> +	Memory currently under writeback to this device
> +
> +dirty_kb (read-only)
> +
> +	Global threshold for reclaimable + writeback memory
> +
> +bdi_dirty_kb (read-only)
> +
> +	Current threshold on this BDI for reclaimable + writeback
> +	memory
> +

I dunno.  A number of the things which you're exposing are closely tied to
present-day kernel implementation and may be irrelevant or even
unimplementable in a few years' time.

At the very least you should put a HUGE warning in here telling everyone
that these files may disappear or be renamed with new semantics in the
future, and that they should design their userspace code with this in mind.

But that will only prevent userspace from outright crashing.  Once we
expose functionality of this nature, people will come to depend upon it.
We can't stop this.

Suppose $CLUELESS_CORP modifies $LARGE_DATABASE so that it uses these new
fields to optimise its cache population and cache flushout strategies. 
Later, we are forced to remove these fields.  The database now runs all
slowly.

It's just a bad idea to expose deep kernelguts in this way.  We need really
good reasons for doing so, and those reasons should be in the changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
