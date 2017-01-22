Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3081B6B0260
	for <linux-mm@kvack.org>; Sat, 21 Jan 2017 23:45:13 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id t18so12745081wmt.7
        for <linux-mm@kvack.org>; Sat, 21 Jan 2017 20:45:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i74si9277966wmh.85.2017.01.21.20.45.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 21 Jan 2017 20:45:11 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Sun, 22 Jan 2017 15:45:01 +1100
Subject: Re: [ATTEND] many topics
In-Reply-To: <20170121131644.zupuk44p5jyzu5c5@thunk.org>
References: <20170118054945.GD18349@bombadil.infradead.org> <20170118133243.GB7021@dhcp22.suse.cz> <20170119110513.GA22816@bombadil.infradead.org> <20170119113317.GO30786@dhcp22.suse.cz> <20170119115243.GB22816@bombadil.infradead.org> <20170119121135.GR30786@dhcp22.suse.cz> <878tq5ff0i.fsf@notabene.neil.brown.name> <20170121131644.zupuk44p5jyzu5c5@thunk.org>
Message-ID: <87ziijem9e.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Michal Hocko <mhocko@kernel.org>, willy@bombadil.infradead.org, willy@infradead.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

--=-=-=
Content-Type: text/plain

On Sun, Jan 22 2017, Theodore Ts'o wrote:

> On Sat, Jan 21, 2017 at 11:11:41AM +1100, NeilBrown wrote:
>> What are the benefits of GFP_TEMPORARY?  Presumably it doesn't guarantee
>> success any more than GFP_KERNEL does, but maybe it is slightly less
>> likely to fail, and somewhat less likely to block for a long time??  But
>> without some sort of promise, I wonder why anyone would use the
>> flag.  Is there a promise?  Or is it just "you can be nice to the MM
>> layer by setting this flag sometimes". ???
>
> My understanding is that the idea is to allow short-term use cases not
> to be mixed with long-term use cases --- in the Java world, to declare
> that a particular object will never be promoted from the "nursury"
> arena to the "tenured" arena, so that we don't end up with a situation
> where a page is used 90% for temporary objects, and 10% for a tenured
> object, such that later on we have a page which is 90% unused.
>
> Many of the existing users may in fact be for things like a temporary
> bounce buffer for I/O, where declaring this to the mm system could
> lead to less fragmented pages, but which would violate your proposed
> contract:
>
>>   GFP_TEMPORARY should be used when the memory allocated will either be
>>   freed, or will be placed in a reclaimable cache, before the process
>>   which allocated it enters an TASK_INTERRUPTIBLE sleep or returns to
>>   user-space.  It allows access to memory which is usually reserved for
>>   XXX and so can be expected to succeed more quickly during times of
>>   high memory pressure.
>
> I think what you are suggested is something very different, where you
> are thinking that for *very* short-term usage perhaps we could have a
> pool of memory, perhaps the same as the GFP_ATOMIC memory, or at least
> similar in mechanism, where such usage could be handy.
>
> Is there enough use cases where this would be useful?  In the local
> disk backed file system world, I doubt it.  But maybe in the (for
> example) NFS world, such a use would in fact be common enough that it
> would be useful.
>
> I'd suggest doing this though as a new category, perhaps
> GFP_REALLY_SHORT_TERM, or GFP_MAYFLY for short.  :-)

I'm not suggesting this particular contract is necessarily a good thing
to have.  I just suggested it as a possible definition of
"GFP_TEMPORARY".
If you are correct, then I was clearly wrong - which nicely serves to
demonstrate that a clear definition is needed.

You have used terms like "nursery" and "tenured" which don't really help
without definitions of those terms.
How about

   GFP_TEMPORARY should be used when the memory allocated will either be
   freed, or will be placed in a reclaimable cache, after some sequence
   of events which is time-limited. i.e. there must be no indefinite
   wait on the path from allocation to freeing-or-caching.
   The memory will typically be allocated from a region dedicated to
   GFP_TEMPORARY allocations, thus ensuring that this region does not
   become fragmented.  Consequently, the delay imposed on GFP_TEMPORARY
   allocations is likely to be less than for non-TEMPORARY allocations
   when memory pressure is high.

??
I think that for this definition to work, we would need to make it "a
movable cache", meaning that any item can be either freed or
re-allocated (presumably to a "tenured" location).  I don't think we
currently have that concept for slabs do we?  That implies that this
flag would only apply to whole-page allocations  (which was part of the
original question).  We could presumably add movability to
slab-shrinkers if these seemed like a good idea.

I think that it would also make sense to require that the path from
allocation to freeing (or caching) of GFP_TEMPORARY allocation must not
wait for a non-TEMPORARY allocation, as that becomes an indefinite wait.

Is that any closer to your understanding?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliEOM0ACgkQOeye3VZi
gbnpDg//cuAffcwF9p4hcd548szQ+S58qosTnRkTQGjm5jAPsnbdynrh1XDEKCW7
BAtUVY/nOYNe2kjWKmjACzG7kqi85vYGslYxVV4BdfVL5LVV9KJTb2V4jyHquNcc
IlyN/TxWen+NGI4KpHeLytaNOocKncce6Adzrl9N50eTS/7ywGOioPNzgYy+lUkw
vheWjZS0BPCXcGtn2E9eUUK1w4UQ5sbjtEPH3sUzByZW0YNBAOiL90zo5f9rEWsQ
a1xfg6y+zskqJMs4RMLYROHiZwtRfNJYKP3zg4yNAO5a8q+vvXCPTbv8Dmvhd3t9
cd+yPO7YWzbiv09h1f/HMd5sKUn0WDiJXrM3+jZ5yLbcpKVo5E6gMhAaBiwFYTxc
xIZ5SkZOd7iKv5uR0vdpTNF05mVjzoysR7HWv/p3iWefVN/JfQUebHcBebXVrmp5
7kOY0twq8eLvzvc/JjXDyvmdZs00yUU53lDiD2uX7KwnC3mekAyes7WNLoi9NbT/
F3xQEG79fhwt9uM+gpipFAgZLOPBsbhQYrsp5vgDSxjO9dmPhz6+B52F+Z6ZX75S
4Y2HYpvEZWq1aQtPlqSSnusxEstS9oACsctmg4ItKka1uNaFySz8RqC1WxCfT9xH
m+2KnsjRt0Ph8TqqM+7KBBwv1JxBQ3pjA21hZyIkIeTOjoe+GwE=
=hSCh
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
