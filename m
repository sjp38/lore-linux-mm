Date: Wed, 28 Jul 2004 16:53:43 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
Message-ID: <20040728235343.GG2334@holomorphy.com>
References: <Pine.SGI.4.58.0407131449330.111843@kzerza.americas.sgi.com> <Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain> <20040728022625.249c78da.akpm@osdl.org> <20040728095925.GQ2334@holomorphy.com> <Pine.SGI.4.58.0407281707370.33392@kzerza.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.SGI.4.58.0407281707370.33392@kzerza.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jul 2004, William Lee Irwin III wrote:
>> For the general case it may still make sense to do this. SGI will have
>> to comment here, as the workloads I'm involved with are kernel intensive
>> enough in other areas and generally run on small enough systems to have
>> no visible issues in or around the areas described.

On Wed, Jul 28, 2004 at 05:21:58PM -0500, Brent Casavant wrote:
> With Hugh's fix, the problem has now moved to other areas -- I consider
> the stat_lock issue solved.  Now I'm running up against the shmem_inode_info
> lock field.  A per-CPU structure isn't appropriate here because what it's
> mostly protecting is the inode swap entries, and that isn't at all amenable
> to a per-CPU breakdown (i.e. this is real data, not statistics).

This does look like it needs ad hoc methods for each of the various
fields.


On Wed, Jul 28, 2004 at 05:21:58PM -0500, Brent Casavant wrote:
> The "obvious" fix is to morph the code so that the swap entries can be
> updated in parallel to eachother and in parallel to the other miscellaneous
> fields in the shmem_inode_info structure.  But this would be one *nasty*
> piece of work to accomplish, much less accomplish cleanly and correctly.
> I'm pretty sure my Linux skillset isn't up to the task, though it hasn't
> kept me from trying.  On the upside I don't think it would significantly
> impact performance on low processor-count systems, if we can manage to
> do it at all.
> I'm kind of hoping for a fairy godmother to drop in, wave her magic wand,
> and say "Here's the quick and easy and obviously correct solution".  But
> what're the chances of that :).

This may actually have some positive impact on highly kernel-intensive
low processor count database workloads (where kernel intensiveness makes
up for the reduced processor count vs. the usual numerical applications
at high processor counts on SGI systems). At the moment a number of
stability issues have piled up that I need to take care of, but I would
be happy to work with you on devising methods of addressing this when
those clear up, which should be by the end of this week.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
