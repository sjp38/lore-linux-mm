Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B2BD96B007E
	for <linux-mm@kvack.org>; Tue,  3 May 2016 19:27:08 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so70124906pfy.2
        for <linux-mm@kvack.org>; Tue, 03 May 2016 16:27:08 -0700 (PDT)
Received: from neil.brown.name (neil.brown.name. [103.29.64.221])
        by mx.google.com with ESMTPS id o6si934675pfj.110.2016.05.03.16.27.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 03 May 2016 16:27:07 -0700 (PDT)
From: NeilBrown <mr@neil.brown.name>
Date: Wed, 04 May 2016 09:26:15 +1000
Subject: Re: [PATCH 0/2] scop GFP_NOFS api
In-Reply-To: <20160503151312.GA4470@dhcp22.suse.cz>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org> <8737q5ugcx.fsf@notabene.neil.brown.name> <20160429120418.GK21977@dhcp22.suse.cz> <87twiiu5gs.fsf@notabene.neil.brown.name> <20160503151312.GA4470@dhcp22.suse.cz>
Message-ID: <87futyd8q0.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, May 04 2016, Michal Hocko wrote:

> Hi,
>
> On Sun 01-05-16 07:55:31, NeilBrown wrote:
> [...]
>> One particular problem with your process-context idea is that it isn't
>> inherited across threads.
>> Steve Whitehouse's example in gfs shows how allocation dependencies can
>> even cross into user space.
>
> Hmm, I am still not sure I understand that example completely but making
> a dependency between direct reclaim and userspace can hardly work.

No it can't.  Specifically: if direct reclaim blocks on user-space that
must be a problem.
I think the point of this example is that some filesystem things can
block on user-space in ways that are very hard to encode in with flags
as they are multi-level indirect.
So the conclusion (my conclusion) is that direct reclaim mustn't block.

When I was working on deadlock avoidance in loop-back NFS I went down
the path of adding GFP flags and extended the PF_FSTRANS flag and got it
working (think) but no-one liked it.  It was way too intrusive.

Some how I landed on the idea of making nfs_release_page non blocking
and everything suddenly became much much simpler.  Problems evaporated.

NFS has a distinct advantage here.  The "Close-to-open" cache semantic
means that all dirty pages must be flushed on last close.  So when
=2D>evict_inode is finally called there is nothing much to do - just free
everything up.  So I could fix NFS without worrying about (or even
noticing) evict_inode.


> Especially when the direct reclaim might be sitting on top of hard to
> guess pile of locks. So unless I've missed anything what Steve has
> described is a clear NOFS context.
>
>> A more localized one that I have seen is that NFSv4 sometimes needs to
>> start up a state-management thread (particularly if the server
>> restarted).
>> It uses kthread_run(), which doesn't actually create the thread but asks
>> kthreadd to do it.  If NFS writeout is waiting for state management it
>> would need to make sure that kthreadd runs in allocation context to
>> avoid deadlock.
>> I feel that I've forgotten some important detail here and this might
>> have been fixed somehow, but the point still stands that the allocation
>> context can cross from thread to thread and can effectively become
>> anything and everything.
>
> Not sure I understand your point here but relying on kthread_run
> from GFP_NOFS context has always been deadlock prone with or without
> scope GFP_NOFS semantic so I am not really sure I see your point
> here. Similarly relying on a work item which doesn't have a dedicated
> WQ_MEM_RECLAIM WQ is deadlock prone.  You simply shouldn't do that.

The point is really that saying "You shouldn't do that" isn't much good
when "that" is exactly what the fs developer wants to do and it seems to
work and never triggers a warning.

You can create lots of rules about what is or is not allowed, or
you can make everything that it not explicit forbidden (ideally at
compile time but possibly at runtime with might_sleep or lockdep),
permitted.

I prefer the latter.

>
>> It is OK to wait for memory to be freed.  It is not OK to wait for any
>> particular piece of memory to be freed because you don't always know who
>> is waiting for you, or who you really are waiting on to free that
>> memory.
>>=20
>> Whenever trying to free memory I think you need to do best-effort
>> without blocking.
>
> I agree with that. Or at least you have to wait on something that is
> _guaranteed_ to make a forward progress. I am not really that sure this
> is easy to achieve with the current code base.

I accept that it isn't "easy".  But I claim that it isn't particularly
difficult either.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXKTOXAAoJEDnsnt1WYoG5eugQALaVi36cVlv3XUWoqQkoecRW
Sh+gP4igqZwrsa+rKJ6N0SAKf2Ckg5hRnQ8pXs4gg+k8AtoQpEjRNqt0W6uCrMVz
foj53Bwv0C/QYJiFUWxT+ExaA/iBp35HUkNpJZifwL5YYsWL1mRvVV4FINA5VpTV
tSIAAIEM955RacQYX77m523pkH5oh4/SaZowW6u0sBi0jUCD1KsrD156mV61ah6L
HCOzm1mMSaAxjDvFzu1dA2yz7Kjq5spqHZyYO47N+7ice7b0QHfvqFMS8beX2zzT
5DMis1MWLrZOUhw6yej+hW3aQO9Ch1hOwRRu9E49T32FWuh9qEo9Ia79it6OI4/1
xBCpqkhToiBDioB4H1NtF45qwEa8m4dyMYBGUfKyop8JlaUS/foMaK8uHS0xG1MO
LICkLC7y/7l/N3GNQ1Ia3bLFdQJmHdOpZO1NbzlIbWMC9sV3r6KdlCeLoBC7GvF8
eM8tAM4W4dXOSK/JMz/nsRXBCXvQgT1L9eXvwrKFmEkVGyXWGA+th3fCCexKNUP6
ab5aas5pj9AseznwfOP3EYEhLRvPKSP8qeu6Wkezodwi/LIjb8v+Y9h96a46FbkA
viFdp7ZWP/nQ3wQ4g0T89RdIX9zY8Xv+8yNbKaxmL4B6L5nI4mer4XaV63V36Qge
/NBmt+ZGgYKghbndVHaz
=zENk
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
