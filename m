Date: Sun, 5 Aug 2007 11:00:29 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805150029.GB28263@thunk.org>
References: <20070803123712.987126000@chello.nl> <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org> <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <p73hcnen7w2.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <p73hcnen7w2.fsf@bingen.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

On Sun, Aug 05, 2007 at 02:26:53AM +0200, Andi Kleen wrote:
> I always thought the right solution would be to just sync atime only
> very very lazily. This means if a inode is only dirty because of an
> atime update put it on a "only write out when there is nothing to do
> or the memory is really needed" list.

As I've mentioend earlier, the memory balancing issues that arise when
we add an "atime dirty" bit scare me a little.  It can be addressed,
obviously, but at the cost of more code complexity.

An alternative is to simply have a tunable parameter, via either a
mount option or stashed in the superblock which controls atime's
granularity guarantee.  That is, only update the atime if it is older
than some set time that could be configurable as a mount option or in
the superblock.  Most of the time, an HSM system simply wants to know
if a file has been used sometime "recently", where recently might be
measured in hours or in days.

This is IMHO slightly better than relatime, since it keeps the spirit
of the atime update, while keeping the performance impact to a very
minimal (and tunable) level.

						- Ted

P.S.  Yet alternative is to specify noatime on an individual
file/directory basis.  We've had this capability for a *long* time,
and if a distro were to set noatime for all files in certain
hierarchies (i.e., /usr/include) and certain top-level directories
(since the chattr +A flag is inherited), I think folks would find that
this would reduce the I/O traffic of noatime by a huge amount.  This
also would be 100% POSIX compliant, since we are extending the
filesystem and setting certain files to use it.  But if users want to
know when was the last time they looked at a particular file in their
home directory, they would still have that facility.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
