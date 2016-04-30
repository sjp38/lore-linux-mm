Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D04236B007E
	for <linux-mm@kvack.org>; Sat, 30 Apr 2016 18:20:33 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b203so273945571pfb.1
        for <linux-mm@kvack.org>; Sat, 30 Apr 2016 15:20:33 -0700 (PDT)
Received: from neil.brown.name (neil.brown.name. [103.29.64.221])
        by mx.google.com with ESMTPS id d2si24955876pfb.112.2016.04.30.15.20.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 30 Apr 2016 15:20:32 -0700 (PDT)
From: NeilBrown <mr@neil.brown.name>
Date: Sun, 01 May 2016 08:19:44 +1000
Subject: Re: [PATCH 0/2] scop GFP_NOFS api
In-Reply-To: <20160430001138.GO26977@dastard>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org> <8737q5ugcx.fsf@notabene.neil.brown.name> <20160430001138.GO26977@dastard>
Message-ID: <87r3dmu4cf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, Apr 30 2016, Dave Chinner wrote:

> On Fri, Apr 29, 2016 at 03:35:42PM +1000, NeilBrown wrote:
>> On Tue, Apr 26 2016, Michal Hocko wrote:
>>=20
>> > Hi,
>> > we have discussed this topic at LSF/MM this year. There was a general
>> > interest in the scope GFP_NOFS allocation context among some FS
>> > developers. For those who are not aware of the discussion or the issue
>> > I am trying to sort out (or at least start in that direction) please
>> > have a look at patch 1 which adds memalloc_nofs_{save,restore} api
>> > which basically copies what we have for the scope GFP_NOIO allocation
>> > context. I haven't converted any of the FS myself because that is way
>> > beyond my area of expertise but I would be happy to help with further
>> > changes on the MM front as well as in some more generic code paths.
>> >
>> > Dave had an idea on how to further improve the reclaim context to be
>> > less all-or-nothing wrt. GFP_NOFS. In short he was suggesting an opaque
>> > and FS specific cookie set in the FS allocation context and consumed
>> > by the FS reclaim context to allow doing some provably save actions
>> > that would be skipped due to GFP_NOFS normally.  I like this idea and
>> > I believe we can go that direction regardless of the approach taken he=
re.
>> > Many filesystems simply need to cleanup their NOFS usage first before
>> > diving into a more complex changes.>
>>=20
>> This strikes me as over-engineering to work around an unnecessarily
>> burdensome interface.... but without details it is hard to be certain.
>>=20
>> Exactly what things happen in "FS reclaim context" which may, or may
>> not, be safe depending on the specific FS allocation context?  Do they
>> need to happen at all?
>>=20
>> My research suggests that for most filesystems the only thing that
>> happens in reclaim context that is at all troublesome is the final
>> 'evict()' on an inode.  This needs to flush out dirty pages and sync the
>> inode to storage.  Some time ago we moved most dirty-page writeout out
>> of the reclaim context and into kswapd.  I think this was an excellent
>> advance in simplicity.
>
> No, we didn't move dirty page writeout to kswapd - we moved it back
> to the background writeback threads where it can be done
> efficiently.  kswapd should almost never do single page writeback
> because of how inefficient it is from an IO perspective, even though
> it can. i.e. if we are doing any significant amount of dirty page
> writeback from memory reclaim (direct, kswapd or otherwise) then
> we've screwed something up.
>
>> If we could similarly move evict() into kswapd (and I believe we can)
>> then most file systems would do nothing in reclaim context that
>> interferes with allocation context.
>
> When lots of GFP_NOFS allocation is being done, this already
> happens. The shrinkers that can't run due to context accumulate the
> work on the shrinker structure, and when the shrinker can next run
> (e.g. run from kswapd) it runs all the deferred work from GFP_NOFS
> reclaim contexts.
>
> IOWs, we already move shrinker work from direct reclaim to kswapd
> when appropriate.
>
>> The exceptions include:
>>  - nfs and any filesystem using fscache can block for up to 1 second
>>    in ->releasepage().  They used to block waiting for some IO, but that
>>    caused deadlocks and wasn't really needed.  I left the timeout because
>>    it seemed likely that some throttling would help.  I suspect that a
>>    careful analysis will show that there is sufficient throttling
>>    elsewhere.
>>=20
>>  - xfs_qm_shrink_scan is nearly unique among shrinkers in that it waits
>>    for IO so it can free some quotainfo things.=20
>
> No it's not. evict() can block on IO - waiting for data or inode
> writeback to complete, or even for filesystems to run transactions
> on the inode. Hence the superblock shrinker can and does block in
> inode cache reclaim.

That is why I said "nearly" :-)

>
> Indeed, blocking the superblock shrinker in reclaim is a key part of
> balancing inode cache pressure in XFS. If the shrinker starts
> hitting dirty inodes, it blocks on cleaning them, thereby slowing
> the rate of allocation to that which inodes can be cleaned and
> reclaimed. There are also background threads that walk ahead freeing
> clean inodes, but we have to throttle direct reclaim in this manner
> otherwise the allocation pressure vastly outweighs the ability to
> reclaim inodes. if we don't balance this, inode allocation triggers
> the OOM killer because reclaim keeps reporting "no progress being
> made" because dirty inodes are skipped. BY blocking on such inodes,
> the shrinker makes progress (slowly) and reclaim sees that memory is
> being freed and so continues without invoking the OOM killer...

I'm very aware of the need to throttle allocation based on IO.  I
remember when NFS didn't quite get this right and filled up memory :-)

balance_dirty_pages() used to force threads to wait on the write-out of
one page for every page that they dirtied (or wait on 128 pages for every 1=
28
dirtied or whatever).  This was exactly to provide the sort of
throttling you are talking about.

We don't do that any more.  It was problematic.  I don't recall all the
reasons but I think that different backing devices having different
clearance rates was part of the problem.
So now we monitor clearance rates and wait for some number of blocks to
be written, rather than waiting for some specific blocks to be written.

We should be able to do the same thing to balance dirty inodes as we do
to balance dirty pages.


>
>>    If it could be changed
>>    to just schedule the IO without waiting for it then I think this
>>    would be safe to be called in any FS allocation context.  It already
>>    uses a 'trylock' in xfs_dqlock_nowait() to avoid deadlocking
>>    if the lock is held.
>
> We could, but then we have the same problem as the inode cache -
> there's no indication of progress going back to the memory reclaim
> subsystem, nor is reclaim able to throttle memory allocation back to
> the rate at which reclaim is making progress.
>
> There's feedback loops all throughout the XFS reclaim code - it's
> designed specifically that way - I made changes to the shrinker
> infrastructure years ago to enable this. It's no different to the
> dirty page throttling that was done at roughly the same time -
> that's also one big feedback loop controlled by the rate at which
> pages can be cleaned. Indeed, it was designed was based on the same
> premise as all the XFS shrinker code: in steady state conditions
> we can't allocate a resource faster than we can reclaim it, so we
> need to make reclaim as efficient at possible...

You seem to be referring here to the same change that I was referred to
above, but seem to be seeing it from a different perspective.

Waiting for inodes to be freed in important.  Waiting for any one
specific inode to be freed is dangerous.

>
>> I think you/we would end up with a much simpler system if instead of
>> focussing on the places where GFP_NOFS is used, we focus on places where
>> __GFP_FS is tested, and try to remove them.  If we get rid of enough of
>> them the remainder could just use __GFP_IO.
>
> The problem with this is that a single kswapd thread can't keep up
> with all of the allocation pressure that occurs. e.g. a 20-core
> intel CPU with local memory will be seen as a single node and so
> will have a single kswapd thread to do reclaim. There's a massive
> imbalance between maximum reclaim rate and maximum allocation rate
> in situations like this. If we want memory reclaim to run faster,
> we to be able to do more work *now*, not defer it to a context with
> limited execution resources.

I agree it makes sense to do *work* locally on the core that sees the
need.  What I want to avoid is *sleeping* locally.
How would it be to make evict_inode non-blocking?  It would do as much work
as it can, which in many cases would presumably complete the whole task.
But if it cannot progress for some reason, it returns -EAGAIN and then
the rest gets queued for later.
Might that work, or is there often still lots of CPU work to be done
after things have been waited for?

Thanks,
NeilBrown


>
> i.e. IMO deferring more work to a single reclaim thread per node is
> going to limit memory reclaim scalability and performance, not
> improve it.
>
> Cheers,
>
> Dave.
> --=20
> Dave Chinner
> david@fromorbit.com

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXJS+AAAoJEDnsnt1WYoG5I88P/1gZUoyYvh8e/ZH1R4eDYgWO
0x3C4JM8Z1bYsF8l8YIl8Mb1rOPIZ5tPuWt6MdNamOb3TNLTSbgNSEyqShVs3v7E
9eHAFMGLyVE9Sb708olIfHpJoX0cvDXzhs2nS5miWmh1qTmNhAkotLyo9sVMTWr8
6lQhlcWTCeRA/RLFp4fx07AFpPr/J7NXTXXNXvMxExoGvz+EevoFL5TQ9oF8VaTN
Q30Ojl2wRdRVZlclmYgOS+EuPHPLND/jOwJILqOTRwEP8HA31rcRZaoelSCtx4rQ
NP3uTXWos3p8m5J+8sWXhFSL2hOYbptkohedNdt8wfxBbPnt15P3pqdzcOwyqAUM
qsQWYNJBwaP1aK9KdMqafvJ2k5Z00p7QmSiWCzDMsH9j5ScRA7dIktZ4pD8+IkvB
u+OE6S9Auhf2yL67OGesRqu3dTYxi9JJMTWN4MwlLUta6IruZZbLdgEeJCFaZGwd
JXBTg/I1wisudqWvbM2wGv/Shomwo7bmtmPW2BNYC+n9I6BK41D8NEpGQZ/6CXPM
TkWoT9R0fQf0WMyDKtf+jS4yYUKD/cKoYkyoUbBMqtYrv5q+fO8SE6gbhcwtfDA3
hqgvZf/eVbXQZNUrXjOXJduL/SDVNX0+Nu5eub0K+JI9/gaIidqzYN+NmCFjIsFZ
WgUoj2nE/Eil/6xWp+hJ
=HwAg
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
