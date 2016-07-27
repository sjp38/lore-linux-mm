Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 260826B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 00:03:04 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id e7so8804825lfe.0
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 21:03:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tj3si4467315wjb.290.2016.07.26.21.03.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jul 2016 21:03:02 -0700 (PDT)
From: NeilBrown <neilb@suse.com>
Date: Wed, 27 Jul 2016 14:02:53 +1000
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle PF_LESS_THROTTLE tasks
In-Reply-To: <alpine.LRH.2.02.1607251730280.11852@file01.intranet.prod.int.rdu2.redhat.com>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org> <1468831285-27242-1-git-send-email-mhocko@kernel.org> <1468831285-27242-2-git-send-email-mhocko@kernel.org> <87oa5q5abi.fsf@notabene.neil.brown.name> <20160722091558.GF794@dhcp22.suse.cz> <878twt5i1j.fsf@notabene.neil.brown.name> <alpine.LRH.2.02.1607251730280.11852@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <87invr4tjm.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

--=-=-=
Content-Type: text/plain

On Tue, Jul 26 2016, Mikulas Patocka wrote:

> On Sat, 23 Jul 2016, NeilBrown wrote:
>
>> "dirtying ... from the reclaim context" ??? What does that mean?
>> According to
>>   Commit: 26eecbf3543b ("[PATCH] vm: pageout throttling")
>> From the history tree, the purpose of throttle_vm_writeout() is to
>> limit the amount of memory that is concurrently under I/O.
>> That seems strange to me because I thought it was the responsibility of
>> each backing device to impose a limit - a maximum queue size of some
>> sort.
>
> Device mapper doesn't impose any limit for in-flight bios.

I would suggest that it probably should. At least it should
"set_wb_congested()" when the number of in-flight bios reaches some
arbitrary threshold.

The write-back throttling needs this to get an estimate of how fast the
backing device is, so it can share the dirty_threshold space fairly
among the different backing devices.

I added an arbitrary limit to raid1 back in 2011 (34db0cd60f8a1f)
because the lack of a limit was causing problems.
Specifically the write queue would get so long that ext3 would block for
an extended period when trying to flush a transaction, and that blocked
lots of other things, like atime updates.

Maybe there have been other fixes since then to other parts of the
puzzle, but the congestion tracking still seems to be an important part
of the picture and I think it would be best if every bdi would admit to
being congested well before it has consumed a significant fraction of
memory in its output queue.

> I've made some patches that limit in-flight bios for device mapper in
> the past, but there were not integrated into upstream.

I second the motion to resurrect these.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXmDJtAAoJEDnsnt1WYoG5nOgP/0XJg515n6zK4s9J6ZFRmfdZ
cn+o3q+38/NGlnXvKa+YRml4a/M4gVT98bD7XtQhg6LxtEI6Gydj4H+raSxJ7qAN
KLDmouzZBQ95F8myGjPVflprRmfReuJHxmCY2qZWnRi78Amb+TisSh1WavZGZocd
xAEShMDPQ/UAO2R77fICqD5x8OPIK7D9p7IJXn4/Yb1GPW9aFTOH2OpYcI4BrKfu
qjI3mlEqLrtoI2YA0KW+BsZIn0AO6lNDBemkFyqmp5P9IXEa49+o7C89IZLon5u7
/wGwsSVkTFojiluc+vsIkQHTkSBJuFNRkIHe/FwKEVM6lzi7m5m/tNEOjQMRArUR
EoQhq7BEwlUsJSmkY2uarQz68raYYkVksnvnqUYn75GNFQA2/gGuZ2Lzlw8TPb3A
a6K+fGVJCKwm0OLXcSuemG2fUYwb52EdpX/IdlUeNWH08Dj04T6XY07bE3cFgcK1
HQ8hWzWAFNgruD/BvsmNhdHvfW8c1dJFiceBSZN8UIXCNpRpqNXG/rW7YmByOqP/
UaZ9ziTcXsj6w0hrk+Xo8l5jWsCaeH4orHD4opIEgT4JDjLvYARFdv9FY/bnW6V5
XID7b9Vgj6OJh7GGVkgVmxSiuUhnl9VCd9CyRDYmjb8BsiqIICIPA2o7SYlFy3OA
/IQviZ0iWlBWtHqL5Sjp
=I237
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
