From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] block: Isolate the buffer cache in it's own mappings.
References: <200710151028.34407.borntraeger@de.ibm.com>
	<m1zlykj8zl.fsf_-_@ebiederm.dsl.xmission.com>
	<200710160956.58061.borntraeger@de.ibm.com>
	<200710171814.01717.borntraeger@de.ibm.com>
	<m1sl49ei8x.fsf@ebiederm.dsl.xmission.com>
	<1192648456.15717.7.camel@think.oraclecorp.com>
	<m17illeb8f.fsf@ebiederm.dsl.xmission.com>
	<1192654481.15717.16.camel@think.oraclecorp.com>
	<m1ve95ctuc.fsf@ebiederm.dsl.xmission.com>
	<1192661889.15717.27.camel@think.oraclecorp.com>
	<m16415cocs.fsf@ebiederm.dsl.xmission.com>
	<1192665785.15717.34.camel@think.oraclecorp.com>
	<m1tzopaxa1.fsf_-_@ebiederm.dsl.xmission.com>
	<20071017213216.b2d0c4bd.akpm@linux-foundation.org>
Date: Fri, 19 Oct 2007 15:27:25 -0600
In-Reply-To: <20071017213216.b2d0c4bd.akpm@linux-foundation.org> (Andrew
	Morton's message of "Wed, 17 Oct 2007 21:32:16 -0700")
Message-ID: <m11wbqg5he.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Mason <chris.mason@oracle.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:

>
> I don't think we little angels want to tread here.  There are so many
> weirdo things out there which will break if we bust the coherence between
> the fs and /dev/hda1.

We broke coherence between the fs and /dev/hda1 when we introduced
the page cache years ago, and weird hacky cases like
unmap_underlying_metadata don't change that.  Currently only
metadata is more or less in sync with the contents of /dev/hda1.

> Online resize, online fs checkers, various local
> tools which people have hacked up to look at metadata in a live fs,
> direct-io access to the underlying fs, heaven knows how many boot loader
> installers, etc.  Cerainly I couldn't enumerate  tham all.

Well I took a look at ext3.  For online resize all of the writes are
done by the fs not by the user space tool.  For e2fsck of a read-only
filesystem currently we do cache the buffers for the super block and
reexamine those blocks when we mount read-only.

Which makes my patch by itself unsafe.  If however ext3 and anyone
else who does things like that were to reread the data and not
to merely reexamine the data we should be fine.

Fundamentally doing anything like this requires some form of
synchronization, and if that synchronization does not exist
today there will be bugs.  Further decoupling things only makes that
requirement clearer.

Unfortunately because of things like the ext3 handling of remounting
from ro to rw this doesn't fall into the quick trivial fix category :(

> I don't actually see what the conceptual problem is with the existing
> implementation.  The buffer_head is a finer-grained view onto the
> blockdev's pagecache: it provides additional states and additional locking
> against a finer-grained section of the page.   It works well.

The buffer_head itself seems to be a reasonable entity.

The buffer cache is a monster.  It does not follow the ordinary rules
of the page cache, making it extremely hard to reason about.

Currently in the buffer cache there are buffer_heads we are not
allowed to make dirty which hold dirty data.  Some filesystems
panic the kernel when they notice this.  Others like ext3 use a
different bit to remember that the buffer is dirty.

Because of ordering considerations the buffer cache does not hold a
consistent view of what has been scheduled for being written to disk.
It instead holds partially complete pages.

The only place we should ever clear the dirty bit is just before
calling write_page but try_to_free_buffers clears the dirty bit!

We have buffers on pages without a mapping!

In general the buffer cache violates a primary rule for comprehensible
programming having.  The buffer cache does not have a clear enough
definition that it is clear what things are bugs and what things
are features.

99% of the weird strange behavior in rd.c is because of the buffer
cache not following the normal rules.

> Yeah, the highmem thing is a bit of a problem (but waning in importance). 
> But we can fix that by teaching individual filesystems about kmap and then
> tweak the blockdev's caching policy with mapping_set_gfp_mask() at mount
> time.  If anyone cares, which they don't.

This presumes I want to use a filesystem on my block device.  Where I
would care most is when I am doing things like fsck or mkfs on an
unmounted filesystem.  Where having buffer_heads is just extra memory
pressure slowing things down, and similarly for highmem.  We have
to sync the filesystem before mounting but we have to do that anyway
for all of the non metadata so that isn't new.

Anyway my main objective was to get a good grasp on the buffer cache
and the mm layer again.  Which I now more or less have.  While I think
the buffer cache needs a bunch of tender loving care before it becomes
sane I have other projects that I intend to complete before I try
anything in this area.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
