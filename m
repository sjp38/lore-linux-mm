Date: Thu, 19 Apr 2007 10:36:50 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: dio_get_page() lockdep complaints
Message-ID: <20070419143650.GF32720@think.oraclecorp.com>
References: <20070419073828.GB20928@kernel.dk> <20070419010142.5b7b00cd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070419010142.5b7b00cd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, linux-aio@kvack.org, reiserfs-dev@namesys.com, "Vladimir V. Saveliev" <vs@namesys.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 19, 2007 at 01:01:42AM -0700, Andrew Morton wrote:
> On Thu, 19 Apr 2007 09:38:30 +0200 Jens Axboe <jens.axboe@oracle.com> wrote:
> 
> > Hi,
> > 
> > Doing some testing on CFQ, I ran into this 100% reproducible report:
> > 
> > =======================================================
> > [ INFO: possible circular locking dependency detected ]
> > 2.6.21-rc7 #5
> > -------------------------------------------------------
> > fio/9741 is trying to acquire lock:
> >  (&mm->mmap_sem){----}, at: [<b018cb34>] dio_get_page+0x54/0x161
> > 
> > but task is already holding lock:
> >  (&inode->i_mutex){--..}, at: [<b038c6e5>] mutex_lock+0x1c/0x1f
> > 
> > which lock already depends on the new lock.
> > 
> 
> This is the correct ranking: i_mutex outside mmap_sem.

[ ... ]

> But here reiserfs is taking i_mutex in its file_operations.release(), which
> can be called under mmap_sem.
> 
> Vladimir's recent de14569f94513279e3d44d9571a421e9da1759ae.  "resierfs:
> avoid tail packing if an inode was ever mmapped" comes real close to this
> code, but afaict it did not cause this bug.
> 
> I can't think of anything which we've done in the 2.6.21 cycle which would have
> caused this to start happening.  Odd.

In this case, reiserfs is taking i_mutex to safely discard the
preallocation blocks.  The best solution would probably be to just put
in a preallocation mutex other than i_sem (even i_mmap would probably
work).

This shouldn't be a new regression, the file_release prelloc stuff
hasn't changed in ages.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
