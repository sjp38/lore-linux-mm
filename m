Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4C86B0003
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 19:36:00 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id h13so1500917wrc.9
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 16:36:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r3si2212438wre.246.2018.02.07.16.35.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Feb 2018 16:35:58 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Thu, 08 Feb 2018 11:35:43 +1100
Subject: Re: [PATCH RFC] ashmem: Fix lockdep RECLAIM_FS false positive
In-Reply-To: <CAJWu+opo+mE-ZAsi3=u8ogUYurVM0_qaHi7keZJ6h0Sfa7oULQ@mail.gmail.com>
References: <20180206004903.224390-1-joelaf@google.com> <20180207080740.GH2269@hirez.programming.kicks-ass.net> <CAJWu+orvHb_-fSgtO0NqCai3PPc7fAe7LqNLVVhYbT+Wi-oATg@mail.gmail.com> <20180207165802.GC25219@hirez.programming.kicks-ass.net> <CAJWu+opo+mE-ZAsi3=u8ogUYurVM0_qaHi7keZJ6h0Sfa7oULQ@mail.gmail.com>
Message-ID: <87k1vomi74.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>, Peter Zijlstra <peterz@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Theodore Ts'o <tytso@mit.edu>, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>

--=-=-=
Content-Type: text/plain

On Wed, Feb 07 2018, Joel Fernandes wrote:

> Hi Peter,
>
> On Wed, Feb 7, 2018 at 8:58 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> [...]
>>
>>> Lockdep reports this issue when GFP_FS is infact set, and we enter
>>> this path and acquire the lock. So lockdep seems to be doing the right
>>> thing however by design it is reporting a false-positive.
>>
>> So I'm not seeing how its a false positive. fs/inode.c sets a different
>> lock class per filesystem type. So recursing on an i_mutex within a
>> filesystem does sound dodgy.
>
> But directory inodes and file inodes in the same filesystem share the
> same lock class right?

Not since v2.6.24
Commit: 14358e6ddaed ("lockdep: annotate dir vs file i_mutex")

You were using 4.9.60. so they should be separate....

Maybe shmem_get_inode() needs to call unlock_new_inode() or just
lockdep_annotate_inode_mutex_key() after inode_init_owner().

Maybe inode_init_owner() should call lockdep_annotate_inode_mutex_key()
directly.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlp7m2AACgkQOeye3VZi
gbmNRRAAqi6V+r4APrjzTHcs4mwJs7pCOqF/4P0knHwKGEeWt4ZVlToQAKVo93bB
Qm8g3Q80Xi242xobzmgDJBRSxdfU0E1TeqRU6UH+GWLAhLpZmGNhn6rDGmUDK/vQ
SuAh52OUpGZ6qbe/1A3+4igCC1clK9kmhNyofLc6qt1OesiqlX7/P3EQ3/eLDu/A
cF6RZJ2XtvxkHORl9eysHd131xOxvCH/0oC/h86qVUg/eqAU7P19BMJUU2veGY4t
FwRqJlqo98vcdPVKMVqOjH2bNbRbR+ggS8BQ/cXKRIz9nH37tRT0NUDL6lLS50k+
tV9I9YLpXrA5dIIeC7Ruh6ny5uz1voFqH70Y+ILxy1BFdkoVGC2xMAEHpo5HoAj/
cImyNayfD5IoT2yYI6nbYmzAEo2pXDDxojDrN9XA46WSL0ToYwHoOdTFDFPmYlTC
iSMWvM666qy/1DdF/woeHR2v9pIOn9D9N1r1lKGS8ou1sA8KSdnRoIj6ajeVybdP
rQ7p5XWrnnYA2bmbZttyMstGCtgIUhCPyz9bWpZ8HMRlA/gKB03csfDOyCGGjnBg
jY+C9DJei6mxKPFyZl/eSs8bhD3Np8v+PgU/Vm418QUCu4gSQ+tl7qX5F4wuq3Hg
oWfWdrKz5jpXWKE7PwM0+DD7YubTtXY2QeBRqaNTnBcWQOG1+VU=
=M4FL
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
