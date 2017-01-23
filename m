Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8FC6B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 01:30:50 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p192so16298136wme.1
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 22:30:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u66si17562151wrc.269.2017.01.22.22.30.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 Jan 2017 22:30:49 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Mon, 23 Jan 2017 17:30:39 +1100
Subject: Re: [ATTEND] many topics
In-Reply-To: <20170123060544.GA12833@bombadil.infradead.org>
References: <20170118054945.GD18349@bombadil.infradead.org> <20170118133243.GB7021@dhcp22.suse.cz> <20170119110513.GA22816@bombadil.infradead.org> <20170119113317.GO30786@dhcp22.suse.cz> <20170119115243.GB22816@bombadil.infradead.org> <20170119121135.GR30786@dhcp22.suse.cz> <878tq5ff0i.fsf@notabene.neil.brown.name> <20170121131644.zupuk44p5jyzu5c5@thunk.org> <87ziijem9e.fsf@notabene.neil.brown.name> <20170123060544.GA12833@bombadil.infradead.org>
Message-ID: <877f5me19s.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Theodore Ts'o <tytso@mit.edu>, Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 23 2017, Matthew Wilcox wrote:

> On Sun, Jan 22, 2017 at 03:45:01PM +1100, NeilBrown wrote:
>> On Sun, Jan 22 2017, Theodore Ts'o wrote:
>> > On Sat, Jan 21, 2017 at 11:11:41AM +1100, NeilBrown wrote:
>> >> What are the benefits of GFP_TEMPORARY?  Presumably it doesn't guaran=
tee
>> >> success any more than GFP_KERNEL does, but maybe it is slightly less
>> >> likely to fail, and somewhat less likely to block for a long time??  =
But
>> >> without some sort of promise, I wonder why anyone would use the
>> >> flag.  Is there a promise?  Or is it just "you can be nice to the MM
>> >> layer by setting this flag sometimes". ???
>> >
>> > My understanding is that the idea is to allow short-term use cases not
>> > to be mixed with long-term use cases --- in the Java world, to declare
>> > that a particular object will never be promoted from the "nursury"
>> > arena to the "tenured" arena, so that we don't end up with a situation
>> > where a page is used 90% for temporary objects, and 10% for a tenured
>> > object, such that later on we have a page which is 90% unused.
>> >
>> > Many of the existing users may in fact be for things like a temporary
>> > bounce buffer for I/O, where declaring this to the mm system could
>> > lead to less fragmented pages, but which would violate your proposed
>> > contract:
>
> I don't have a clear picture in my mind of when Java promotes objects
> from nursery to tenure ... which is not too different from my lack of
> understanding of what the MM layer considers "temporary" :-)  Is it
> acceptable usage to allocate a SCSI command (guaranteed to be freed
> within 30 seconds) from the temporary area?  Or should it only be used
> for allocations where the thread of control is not going to sleep between
> allocation and freeing?
>
>> You have used terms like "nursery" and "tenured" which don't really help
>> without definitions of those terms.
>> How about
>>=20
>>    GFP_TEMPORARY should be used when the memory allocated will either be
>>    freed, or will be placed in a reclaimable cache, after some sequence
>>    of events which is time-limited. i.e. there must be no indefinite
>>    wait on the path from allocation to freeing-or-caching.
>>    The memory will typically be allocated from a region dedicated to
>>    GFP_TEMPORARY allocations, thus ensuring that this region does not
>>    become fragmented.  Consequently, the delay imposed on GFP_TEMPORARY
>>    allocations is likely to be less than for non-TEMPORARY allocations
>>    when memory pressure is high.
>
> I think you're overcomplicating your proposed contract by allowing for
> the "adding to a reclaimable cache" case.  If that will happen, the
> code should be using GFP_RECLAIMABLE, not GFP_TEMPORARY as a matter of
> good documentation.  And to allow the definitions to differ in future.
> Maybe they will always be the same bit pattern, but the code should
> distinguish the two cases (obviously there is no problem with allocating
> memory with GFP_RECLAIMABLE, then deciding you didn't need it after all
> and freeing it).

I only included the "Reclaimable cache" possibility because Michal said:

   I guess the original intention was to use this flag for allocations
   which will be either freed shortly or they are reclaimable.


>
>> ??
>> I think that for this definition to work, we would need to make it "a
>> movable cache", meaning that any item can be either freed or
>> re-allocated (presumably to a "tenured" location).  I don't think we
>> currently have that concept for slabs do we?  That implies that this
>> flag would only apply to whole-page allocations  (which was part of the
>> original question).  We could presumably add movability to
>> slab-shrinkers if these seemed like a good idea.
>
> Funnily, Christoph Lameter and I are working on just such a proposal.
> He put it up as a topic discussion at the LCA Kernel Miniconf, and I've
> done a proof of concept implementation for radix tree nodes.  It needs
> changes to the radix tree API to make it work, so it's not published yet,
> but it's a useful proof of concept for things which can probably work
> and be more effective, like the dentry & inode caches.

Awesome!

>
>> I think that it would also make sense to require that the path from
>> allocation to freeing (or caching) of GFP_TEMPORARY allocation must not
>> wait for a non-TEMPORARY allocation, as that becomes an indefinite wait.
>
> ... can it even wait for *another* TEMPORARY allocation?  I really think
> this discussion needs to take place in a room with more people present
> so we can get misunderstandings hammered out and general acceptance of
> the consensus.

I suspect you are right, but throwing around some thoughts in advance,
to spark new ideas, can't hurt?  I hate going to meetings where the
agenda has a topic, but no background discussion.  It means that I have
to do all my thinking on my feet (not that I'll be at this meeting).

NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliFow8ACgkQOeye3VZi
gbn/MhAAlckUkxpnxfstJaXmAWza0Wb9nqklnv1+55Pe8O0jh1ubjfhEy+uub8gF
gW2n8mpA/WEoZXYQzcPMjIbYHzLRGEdR009ZXk+xNafnk+yVSr/Nhl/ySOpcK2l+
/RpKx6VPp716UxngR0jUyGbaGucy5S63TyFDNd0Z+sfE0FBKEj3SwAkz1Eak/Xr5
U00KxkvHragoVI3copv0N/4ZwuwEQEe1dgOddGTk05i25xJO8QjGnA0lfAZOWPsT
AXp6eMeoVrInab3fMIp9lYllWE3m/vSU01SH/OBgUTcfi0LuQUDIgTlznnHz5oaU
sYn1UkQBebb/My5DBLPe8RE93Awj7vpTIJJV5E5k1tT6LAb20oUOx9I0mKyGcu4/
08eVuVOdswVMuKjKtXCG03bWn7H+XVymqMviASA1GGl6r7iVBeLNk8sPXE4Q08gc
Lf7l48yArx4kcZHdmZXqpsgFXDmGV1vQGDCKj429sIpopheAIaL1OQuptKhBFbWB
XE2Ynjq238Jf7CHlgZqtsvzo7+BGQepyBCUSq686Ep3HXoP4tCPc1zIlkiCX8iZ/
9K/ga0+GSpT/ZRwCvRWDHWHpHcUcNsizILUab9olGDKEFPdNcVhVRn7+9aKYkXgy
ySGBm40Q858XQoiQDR5a0Uhb8TM3r6eggFgQvgcje0mz6Ionvp8=
=zt1i
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
