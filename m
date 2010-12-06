Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 03FC36B0087
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 07:36:04 -0500 (EST)
Date: Mon, 6 Dec 2010 07:34:48 -0500
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 01/13] writeback: IO-less balance_dirty_pages()
Message-ID: <20101206123448.GI4273@thunk.org>
References: <1290085474.2109.1480.camel@laptop>
 <20101129151719.GA30590@localhost>
 <1291064013.32004.393.camel@laptop>
 <20101130043735.GA22947@localhost>
 <1291156522.32004.1359.camel@laptop>
 <1291156765.32004.1365.camel@laptop>
 <20101201133818.GA13377@localhost>
 <20101205161435.GA1421@localhost>
 <20101206024231.GG4273@thunk.org>
 <87d3pf6xey.fsf@dmon-lap.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87d3pf6xey.fsf@dmon-lap.sw.ru>
Sender: owner-linux-mm@kvack.org
To: Dmitry <dmonakhov@openvz.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "Tang, Feng" <feng.tang@intel.com>, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 06, 2010 at 12:52:21PM +0300, Dmitry wrote:
> May be it is reasonable to introduce new mount option which control
> dynamic delalloc on/off behavior for example like this:
> 0) -odelalloc=off : analog of nodelalloc
> 1) -odelalloc=normal : Default mode (disable delalloc if close to full fs)
> 2) -odelalloc=force  : delalloc mode always enabled, so we have to do
>                      writeback more aggressive in case of ENOSPC.
> 
> So one can force delalloc and can safely use this writeback mode in 
> multi-user environment. Openvz already has this. I'll prepare the patch
> if you are interesting in that feature?

Yeah, I'd really rather not do that.  There are significant downsides
with your proposed odelalloc=force mode.  One of which is that we
could run out of space and not notice.  If the application doesn't
call fsync() and check the return value, and simply closes()'s the
file and then exits, when the writeback threads do get around to
writing the file, the block allocation could fail, and oops, data gets
lost.  There's a _reason_ why we disable delalloc when we're close to
a full fs.  The only alternative is to super conservative when doing
your block reservation calculations, and in that case, you end up
returning ENOSPC far too soon.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
