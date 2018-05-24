Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id E34396B0005
	for <linux-mm@kvack.org>; Thu, 24 May 2018 04:02:02 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id g67-v6so486155otb.10
        for <linux-mm@kvack.org>; Thu, 24 May 2018 01:02:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l12-v6sor9832038otd.316.2018.05.24.01.01.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 May 2018 01:01:57 -0700 (PDT)
MIME-Version: 1.0
References: <20180418193220.4603-1-timofey.titovets@synesis.ru>
 <20180418193220.4603-3-timofey.titovets@synesis.ru> <20180522202242.otvdunkl75yfhkt4@xakep.localdomain>
 <CAGqmi76gJV=ZDX5=Y3toF2tPiJs8T=PiUJFQg5nq9O5yztx80Q@mail.gmail.com> <CAGM2reaZ2YoxFhEDtcXi=hMFoGFi8+SROOn+_SRMwnx3cW15kw@mail.gmail.com>
In-Reply-To: <CAGM2reaZ2YoxFhEDtcXi=hMFoGFi8+SROOn+_SRMwnx3cW15kw@mail.gmail.com>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Thu, 24 May 2018 11:01:20 +0300
Message-ID: <CAGqmi76-qK9q_OTvyqpb-9k_m0CLMt3o860uaN5LL8nBkf5RTg@mail.gmail.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@oracle.com
Cc: linux-mm@kvack.org, Sioh Lee <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org

=D1=81=D1=80, 23 =D0=BC=D0=B0=D1=8F 2018 =D0=B3. =D0=B2 17:24, Pavel Tatash=
in <pasha.tatashin@oracle.com>:

> Hi Timofey,

> > crc32c will always be available, because of Kconfig.
> > But if crc32c doesn't have HW acceleration, it will be slower.

> > For talk about range of HW, i must have that HW,
> > so i can't say that *all* supported HW, have crc32c with acceleration.

> How about always defaulting to crc32c when HW acceleration is present
> without doing timings?
IIRC, yes, shash api can return 'cra_priority'.

> Do you have performance numbers of crc32c without acceleration?
Yes, https://lkml.org/lkml/2017/12/30/222

The experimental results (the experimental value is the average of the
measured values)
crc32c_intel: 1084.10ns
crc32c (no hardware acceleration): 7012.51ns
xxhash32: 2227.75ns
xxhash64: 1413.16ns
jhash2: 5128.30ns

> > > You are loosing half of 64-bit word in xxh64 case? Is this acceptable=
?
> May
> > > be do one more xor: in 64-bit case in xxhash() do: (v >> 32) | (u32)v
?

> > AFAIK, that lead to make hash function worse.
> > Even, in ksm hash used only for check if page has changed since last
scan,
> > so that doesn't matter really (IMHO).

> I understand that losing half of the hash result might be acceptable in
> this case, but I am not really sure how XOirng one more time can possibly
> make hash function worse, could you please elaborate?

IIRC, because of xor are symmetric
i.e. shift:
0b01011010 >> 4 =3D 0b0101
and xor:
0b0101 ^ 0b1010 =3D 0b1111
Xor will decrease randomness/entropy and will lead to hash collisions.

> > > choice_fastest_hash() does not belong to fasthash(). We are loosing
leaf
> > > function optimizations if you keep it in this hot-path. Also,
> fastest_hash
> > > should really be a static branch in order to avoid extra load and
> > conditional
> > > branch.

> > I don't think what that will give any noticeable performance benefit.
> > In compare to hash computation and memcmp in RB.

> You are right, it is small compared to hash and memcmp, but still I think
> it makes sense to use static branch, after all the value will never chang=
e
> during runtime after the first time it is set.


> > In theory, that can be replaced with self written jump table, to *avoid=
*
> > run time overhead.
> > AFAIK at 5 entries, gcc convert switch to jump table itself.

> > > I think, crc32c should simply be used when it is available, and use
> xxhash
> > > otherwise, the decision should be made in ksm_init()

> > I already said, in above conversation, why i think do that at ksm_init(=
)
> is
> > a bad idea.

> It really feels wrong to keep  choice_fastest_hash() in fasthash(), it is
> done only once and really belongs to the init function, like ksm_init().
As

That possible to move decision from lazy load, to ksm_thread,
that will allow us to start bench and not slowdown boot.

But for that to works, ksm must start later, after init of crypto.

> I understand, you think it is a bad idea to keep it in ksm_init() because
> it slows down boot by 0.25s, which I agree with your is substantial. But,
I
> really do not think that we should spend those 0.25s at all deciding what
> hash function is optimal, and instead default to one or another during
boot
> based on hardware we are booting on. If crc32c without hw acceleration is
> no worse than jhash2, maybe we should simply switch to  crc32c?

crc32c with no hw, are slower in compare to jhash2 on x86, so i think on
other arches result will be same.

> Thank you,
> Pavel

Thanks.

--
Have a nice day,
Timofey.
