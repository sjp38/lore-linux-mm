Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AD8D16B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 17:36:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so4791259wmz.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 14:36:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qb10si9063958wjb.116.2016.07.27.14.36.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jul 2016 14:36:21 -0700 (PDT)
From: NeilBrown <neilb@suse.com>
Date: Thu, 28 Jul 2016 07:36:12 +1000
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle PF_LESS_THROTTLE tasks
In-Reply-To: <alpine.LRH.2.02.1607270948040.1779@file01.intranet.prod.int.rdu2.redhat.com>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org> <1468831285-27242-1-git-send-email-mhocko@kernel.org> <1468831285-27242-2-git-send-email-mhocko@kernel.org> <87oa5q5abi.fsf@notabene.neil.brown.name> <20160722091558.GF794@dhcp22.suse.cz> <878twt5i1j.fsf@notabene.neil.brown.name> <alpine.LRH.2.02.1607251730280.11852@file01.intranet.prod.int.rdu2.redhat.com> <87invr4tjm.fsf@notabene.neil.brown.name> <alpine.LRH.2.02.1607270948040.1779@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <87bn1i4vcj.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 28 2016, Mikulas Patocka wrote:

> On Wed, 27 Jul 2016, NeilBrown wrote:
>
>> On Tue, Jul 26 2016, Mikulas Patocka wrote:
>>=20
>> > On Sat, 23 Jul 2016, NeilBrown wrote:
>> >
>> >> "dirtying ... from the reclaim context" ??? What does that mean?
>> >> According to
>> >>   Commit: 26eecbf3543b ("[PATCH] vm: pageout throttling")
>> >> From the history tree, the purpose of throttle_vm_writeout() is to
>> >> limit the amount of memory that is concurrently under I/O.
>> >> That seems strange to me because I thought it was the responsibility =
of
>> >> each backing device to impose a limit - a maximum queue size of some
>> >> sort.
>> >
>> > Device mapper doesn't impose any limit for in-flight bios.
>>=20
>> I would suggest that it probably should. At least it should
>> "set_wb_congested()" when the number of in-flight bios reaches some
>> arbitrary threshold.
>
> If we set the device mapper device as congested, it can again trigger tha=
t=20
> mempool alloc throttling bug.
>
> I.e. suppose that we swap to a dm-crypt device. The dm-crypt device=20
> becomes clogged and sets its state as congested. The underlying block=20
> device is not congested.
>
> The mempool_alloc function in the dm-crypt workqueue sets the=20
> PF_LESS_THROTTLE flag, and tries to allocate memory, but according to=20
> Michal's patches, processes with PF_LESS_THROTTLE may still get throttled.
>
> So if we set the dm-crypt device as congested, it can incorrectly throttl=
e=20
> the dm-crypt workqueue that does allocations of temporary pages and=20
> encryption.
>
> I think that approach with PF_LESS_THROTTLE in mempool_alloc is incorrect=
=20
> and that mempool allocations should never be throttled.

I very much agree with that last statement!  It may be that to get to
that point we will need all backing devices to signal congestion
correctly.

>
>> > I've made some patches that limit in-flight bios for device mapper in
>> > the past, but there were not integrated into upstream.
>>=20
>> I second the motion to resurrect these.
>
> I uploaded those patches here:
>
> http://people.redhat.com/~mpatocka/patches/kernel/dm-limit-outstanding-bi=
os/

Thanks!  I'll have a look.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXmSlMAAoJEDnsnt1WYoG5PcIP/Av4d4LSFVDzocrYrTluQLvp
UynpvW3WQzeIyabbX6XfaBE4nwUm+vec/4Tj3voFcn6TrldBMeRkfT+rdV+fktnU
71IX8tuutfcD4fkFkbz/tOYuMQX6oSfZl2YBIGfdfx/CYzqCICYbXoq4HphdPZ1R
e2ry/q7Jg/x3uq4rswpLuCGV6ivboACiE4TcS2rirHl5IaIVFx7I/U7cpTAISeKq
BmysAdvFKMvcDMqMBj+GD3g4PL4dOFjHhrhG0uF454K5fRNyZ4H3tIQu0/6iwkhK
NTMxtPvkr5qgjvxh6JHv60HOEZaOtOZy+Tcnaq4PUi2Ui8tSa8YQy9/AP1CqbuEs
hIn5LLdRzsg4Jzue9e/FbIJtsARXJCP86ItqE0MBi+LISi+TbFKEWpBnVh8C5H5V
gYyAvudBfKSPncoiUslC0BcOFpydCRS40nBH2ozvBCAribdjnWfh/nTVaV9AgPuX
AFaBVvYr/cXbdsXpreCHpePT3bfNkfJJTik45amUFR2tUTKkKueEpjOZlbhxyeTA
0CvrmdJ6taNj7AUfUUrUlUuS7Czw3zMwSIG7NaiqDP9yYB0HtR/lL2333iNehVkV
SWmACtVEmN0vuPbCdwefeLiW8+R0k1ucBFgslwutrPFA9t3KmOWY0o2heM9gpWRu
rtQ5CPohPmKiahWfnnpz
=DogW
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
