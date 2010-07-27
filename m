Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EF192600365
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 05:01:20 -0400 (EDT)
Date: Tue, 27 Jul 2010 11:01:07 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: struct backing_dev - purpose and life time rules
Message-ID: <20100727090107.GA9572@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: jaxboe@fusionio.com, peterz@infradead.org, akpm@linux-foundation.org, kay.sievers@vrfy.org, viro@zeniv.linux.org.uk
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The struct backing_dev was introduced back in Linux 2.5 days by Andrew's

	"[PATCH] pdflush exclusion infrastructure"

at which point it was still fairly simple, having a simple ra_pages
field, and a state with two flags.  Lifetime rules at that point where
rather simple, too - we either had one embedded into the block queue,
or a default_backing_dev_info that was statically allocated.  At little
later we got congestion information, per-bdi unplug support and the
complicated capabilies scheme we have now, but until 2007 things stay
very simple, and we don't have any interesting life time rules.

In 2007 Peter added per-cpu statistics counters to the BDI, which at
this point required bdi_init / bdi_destroy calls to guard the lifetime
of the BDI.  Now we actively need to manage the life time, but it's
still pretty simple.

It starts to get interesting with

	"mm: bdi: export BDI attributes in sysfs"

that Peter added in April 2008, which ties the previously simple
structure into the device model / sysfs life time rules.  And at
least for the block device it does so rather badly given that it
tries to register the per-queue backing-device object during
add_disk, ignoring that we can have multiple gendisks for a
given request_queue.

Even worse it really mixes up the unregister vs destroy concepts
by simply calling bdi_unregister from bdi_destroy, which means we'll
easily get duplicate unregisters.  It more or less protects by
checking bdi->dev (without synchronization) and doesn't do too
stupid mixups between unregister and destroy yet, so life isn't
that bad.

Commit

	"bdi: register sysfs bdi device only once per queue"

from December 2008 tries to work around this by simply skipping
out of bdi_register if a device is already registered, which ignores
the fundamental problems with the issue.  And also leaves the duplicate
removals in place.

Then last year in commit

	"writeback: switch to per-bdi threads for flushing data"

The per-bdi flusher thread preparion and shutdown gets added to
bdi_register/unregister.  Now that's where the next big pile of
issues start.  If a disk is surprise removed that means that both
the flusher thread disappear and the newly added s_bdi pointer
in the superblock disappear.  But we still have a life filesystem
that might reference s->bdi and we don't have any good thing
preventing it from doing it.  If it had been done in destroy
we could skip all these efforts.

In the meantime we've also grown two names for the bdi: bdi->name,
which has a generic name, afaik only used for a single debug printk,
and the name for the sysfs device which we use in a couple other
places.

So what do we need to do to sort this mess out?

For one thing the bdi needs it's own life time rules, and if we want
to keep it in sysfs it needs to get a name independent of the block
device dev_t pointing to it.  Just generalizing bdi object naming to
bdi->name + sequence number would fix this nicely while also
simplifying the code.  The links from the disk device could remain
their current names, which should keep userspace looking at it working.
of the disks.

Second bdi_register/unregister would go away in their current form,
we'd always keep the bdi registered during it's life time, only the
links from a disk get added / removed by add_disk / unlink_gendisk
but that will be handled outside the bdi code (it already is).  A bdi
will never go away while a superblock uses it.  For the non block
based filesystems that's already true, but for block ones that means
we need to stop unliking it in unlink_gendisk.

One issue with this is that some of the "random" backing devices
are initialized too early to actually create the sysfs representation.
Maybe we should never bother to register bdis like the /dev/zero one
and not allow people to tweak the settings?  The only thing that could
be tweaked would be the ra_pages number anyway, which doesn't make
sense for these non-writeable bdis.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
