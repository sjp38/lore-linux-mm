Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 656EC6B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 16:21:10 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r126so47495586wmr.2
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 13:21:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h7si297593wma.160.2017.01.26.13.21.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 13:21:08 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Fri, 27 Jan 2017 08:20:00 +1100
Subject: Re: [ATTEND] many topics
In-Reply-To: <20170126085639.GA6590@dhcp22.suse.cz>
References: <20170119115243.GB22816@bombadil.infradead.org> <20170119121135.GR30786@dhcp22.suse.cz> <878tq5ff0i.fsf@notabene.neil.brown.name> <20170121131644.zupuk44p5jyzu5c5@thunk.org> <87ziijem9e.fsf@notabene.neil.brown.name> <20170123060544.GA12833@bombadil.infradead.org> <20170123170924.ubx2honzxe7g34on@thunk.org> <87mvehd0ze.fsf@notabene.neil.brown.name> <58357cf1-65fc-b637-de8e-6cf9c9d91882@suse.cz> <8760l2vibg.fsf@notabene.neil.brown.name> <20170126085639.GA6590@dhcp22.suse.cz>
Message-ID: <87tw8ltt6n.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <willy@infradead.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

--=-=-=
Content-Type: text/plain

On Thu, Jan 26 2017, Michal Hocko wrote:

> On Thu 26-01-17 10:19:31, NeilBrown wrote:
>
>> I think it would be better if we could discard the idea of "reclaimable"
>> and just stick with "movable" and "unmovable".  Lots of things are not
>> movable at present, but could be made movable with relatively little
>> effort.  Once the interfaces are in place to allow arbitrary kernel code
>> to find out when things should be moved, I suspect that a lot of
>> allocations could become movable.
>
> I believe we need both. There will be many objects which are hard to be
> movable yet they are reclaimable which can help to reduce the
> fragmentation longterm.

Do we?  Any "reclaimable" objects which are "busy", are really
"unmovable" objects, and so contribute to fragmentation.

I've been thinking about inodes and dentries - which usually come up as
problematic objects in this context.
It would be quite complex to support moving arbitrary inodes or dentries
given the current design.  But maybe we don't need to.
Suppose these objects were allocated as 'movable', but when the first
long-term reference was taken (i.e. the first non-movable reference),
they were first moved to the "non-movable" region?
Then we only need to be able to move a subset of these, which will often
account for the bulk of the memory usage.
There would be costs of course, but I think it might be worth pursuing.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliKaAAACgkQOeye3VZi
gbnOYRAAuVT9L+RpKBcZLtal6YUZfi9aZuaj/umbq+dJeOYR6SZXF4OzI+wE0TwC
HXvkxyBMhPcCGV6tRQcsfYH+YrI32WzM7BS2KC4RLvel3i5CU08aI5OFRCUTTQYD
zM8jLUc/KoaIhbr/vNggXeX0FXB3MXn9vxDlq82s8Jr+OfkeeSRtTM8oQG8sUxl7
4CdWrqNsbo1d5I9EaTCvezSjwbe0bHyiIXAzLPohkWXeVOnupKaP8SMgPmiueH2X
bFpPt8JJyMhL8+7pZ8a/ao+BecLe+1xxGVjfgLWeLmOIVZmtVdssMpi7TOBkFYr3
bDDx64aHU5ALe2qCpMMKbzCjszZ8SvFL16k77Zrqs0FIg4yolOMhZJzIj0PPk2oA
BCkZVq50XU6/l4PUYDORmW3x6FOOOrMppnYjahUpmyQEhtdOgz5UzjLdAT5A7n61
Q3X841n30lG7EBmebjGzu4WHUVasNB+6PvIuDp3TAkOD02/6P6YfYR1lr6y5pOnQ
7Co0R+4cW2+zrEqUN5+zswkL+2282ITIBPRLYp6YwgjEBTw99knoVjcbznp98/p1
e0ynGzXKA+1ucKeuejiHIdwVmm2Qxo8HzCM/zf0DfOE4sSJorFJhvwseyv3aClwZ
SMqxPZRcuTsRY/B7iHJg6dqxvz9ayBnY4iRzk5gqQYhdNiyxto0=
=I0zJ
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
