Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 17C0E6B0027
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 18:46:54 -0400 (EDT)
Date: Thu, 14 Mar 2013 15:46:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] bounce:fix bug, avoid to flush dcache on slab page from
 jbd2.
Message-Id: <20130314154651.b454fc7c6de6222c6c3a1a4a@linux-foundation.org>
In-Reply-To: <20130313210216.GA7754@quack.suse.cz>
References: <5139DB90.5090302@gmail.com>
	<20130312153221.0d26fe5599d4885e51bb0c7c@linux-foundation.org>
	<20130313011020.GA5313@blackbox.djwong.org>
	<20130313085021.GA29730@quack.suse.cz>
	<20130313194429.GE5313@blackbox.djwong.org>
	<20130313210216.GA7754@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Shuge <shugelinux@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Kevin <kevin@allwinneretch.com>, Theodore Ts'o <tytso@mit.edu>, Jens Axboe <axboe@kernel.dk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org

On Wed, 13 Mar 2013 22:02:16 +0100 Jan Kara <jack@suse.cz> wrote:

> > > ... remembering why we need to get to sb and why ext3 needs this ... So
> > > maybe a better solution would be to have a bio flag meaning that pages need
> > > bouncing? And we would set it from filesystems that need it - in case of
> > > ext3 only writeback of data from kjournald actually needs to bounce the
> > > pages. Thoughts?
> > 
> > What about dirty pages that don't result in journal transactions?  I think
> > ext3_sync_file() eventually calls ext3_ordered_writepage, which then calls
> > __block_write_full_page, which in turn calls submit_bh().
>   So here we have two options:
> Either we let ext3 wait the same way as other filesystems when stable pages
> are required. Then only data IO from kjournald needs to be bounced (all
> other IO is properly protected by PageWriteback bit).
> 
> Or we won't let ext3 wait (as it is now), keep the superblock flag that fs
> needs bouncing, and set the bio flag in __block_write_full_page() and
> kjournald based on the sb flag.
> 
> I think the first option is slightly better but I don't feel strongly
> about that.

It seems Just Wrong that we're dicking around with filesystem
superblocks at this level.  It's the bounce code, for heavens sake!


What the heck's going on here and why wasn't I able to work that out
from reading the code :( The need to stabilise these pages is driven by
the characteristics of the underlying device and driver stack, isn't
it?  Things like checksumming?  What else drives this requirement? 
</rant>

Because I *think* it should be sufficient to maintain this boolean in
the backing_dev.  My *guess* is that this is all here because we want
to enable stable-snapshotting on a per-fs basis rather than on a
per-device basis?  If so, why?  If not, what?



btw, local variable `bdi' in must_snapshot_stable_pages() doesn't do
anything.


None of this will stop Shuge's kernel from going splat either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
