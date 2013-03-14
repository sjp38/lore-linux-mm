Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id AA5D56B0027
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 19:27:21 -0400 (EDT)
Date: Thu, 14 Mar 2013 16:27:03 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH] bounce:fix bug, avoid to flush dcache on slab page from
 jbd2.
Message-ID: <20130314232703.GJ5313@blackbox.djwong.org>
References: <5139DB90.5090302@gmail.com>
 <20130312153221.0d26fe5599d4885e51bb0c7c@linux-foundation.org>
 <20130313011020.GA5313@blackbox.djwong.org>
 <20130313085021.GA29730@quack.suse.cz>
 <20130313194429.GE5313@blackbox.djwong.org>
 <20130313210216.GA7754@quack.suse.cz>
 <20130314154651.b454fc7c6de6222c6c3a1a4a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130314154651.b454fc7c6de6222c6c3a1a4a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Shuge <shugelinux@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Kevin <kevin@allwinneretch.com>, Theodore Ts'o <tytso@mit.edu>, Jens Axboe <axboe@kernel.dk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org

On Thu, Mar 14, 2013 at 03:46:51PM -0700, Andrew Morton wrote:
> On Wed, 13 Mar 2013 22:02:16 +0100 Jan Kara <jack@suse.cz> wrote:
> 
> > > > ... remembering why we need to get to sb and why ext3 needs this ... So
> > > > maybe a better solution would be to have a bio flag meaning that pages need
> > > > bouncing? And we would set it from filesystems that need it - in case of
> > > > ext3 only writeback of data from kjournald actually needs to bounce the
> > > > pages. Thoughts?
> > > 
> > > What about dirty pages that don't result in journal transactions?  I think
> > > ext3_sync_file() eventually calls ext3_ordered_writepage, which then calls
> > > __block_write_full_page, which in turn calls submit_bh().
> >   So here we have two options:
> > Either we let ext3 wait the same way as other filesystems when stable pages
> > are required. Then only data IO from kjournald needs to be bounced (all
> > other IO is properly protected by PageWriteback bit).
> > 
> > Or we won't let ext3 wait (as it is now), keep the superblock flag that fs
> > needs bouncing, and set the bio flag in __block_write_full_page() and
> > kjournald based on the sb flag.
> > 
> > I think the first option is slightly better but I don't feel strongly
> > about that.
> 
> It seems Just Wrong that we're dicking around with filesystem
> superblocks at this level.  It's the bounce code, for heavens sake!
> 
> 
> What the heck's going on here and why wasn't I able to work that out
> from reading the code :( The need to stabilise these pages is driven by
> the characteristics of the underlying device and driver stack, isn't
> it?  Things like checksumming?  What else drives this requirement? 
> </rant>

Right now, checksumming for weird DIF/DIX devices is the only requirement for
this behavior.  In theory we can also hook checksumming iscsi and other things
up to this, but for now they have their own solutions for keeping writeback
page contents stable.

> Because I *think* it should be sufficient to maintain this boolean in
> the backing_dev.  My *guess* is that this is all here because we want
> to enable stable-snapshotting on a per-fs basis rather than on a
> per-device basis?  If so, why?  If not, what?

Yes, we do want to enable stable-snapshotting on a per-fs basis.  Here's why:

The first time I tried to solve this problem, I simply had everything use the
bounce buffer.  That was shot down because bounce buffers add memory pressure,
there might not be free pages available when we're doing writeback, etc.

The second attempt was to simply make everything wait for writeback to finish
before dirtying pages.  That's what everything (except ext3) does now.  jbd
initiates writeback on pages without setting PG_writeback, which means that our
convenient wait_on_stable_pages is broken in this case.  Hence ext3/jbd need to
be able to stable-snapshot.  However, it's the /only/ filesystem in the kernel
that needs this.  Everything else is either ok with waiting (ext4, xfs) or
implements their own tricks (tux3, btrfs) to make stable pages work correctly.

Fixing jbd to set PG_writeback has been discussed and rejected, because it's a
lot of work and you'd end up with something rather jbd2-like.  However,
bouncing the outgoing buffers is a fairly small change to jbd.  Jan (at least a
few months ago) was ok with band-aiding ext3.

I could rip out ext3 entirely, but people seem uncomfortable with that, and it
hasn't (yet) been proven that ext4 can provide a perfect imitation of ext3.

I could also just fix up Kconfig so that you can't use a BLK_DEV_INTEGRITY
device with JBD, but that was also shot down as ridiculous.

Given that a backing_dev covers a whole disk, which could contain several
different filesystems and an ext3, I don't want to make /all/ of them use
bounce buffering just because jbd is broken.  We've already established that
bounce pages should be used only when necessary, and (as it turns out), ext3
can initiate writeout of certain dirty user data pages without needing to go
through jbd, which means that those pages don't need to be bounced either.

Therefore, this really is a per-fs thing.

> btw, local variable `bdi' in must_snapshot_stable_pages() doesn't do
> anything.
>
> None of this will stop Shuge's kernel from going splat either.

I'm not trying to fix that in this patch; his splat resulted from stuff going
on in ext4/jbd2.

--D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
