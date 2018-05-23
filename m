Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2FF6B0006
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:46:19 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id c23-v6so14726517oic.2
        for <linux-mm@kvack.org>; Wed, 23 May 2018 06:46:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 10-v6sor10173824otr.322.2018.05.23.06.46.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 May 2018 06:46:18 -0700 (PDT)
MIME-Version: 1.0
References: <20180418193220.4603-1-timofey.titovets@synesis.ru>
 <20180418193220.4603-3-timofey.titovets@synesis.ru> <20180522202242.otvdunkl75yfhkt4@xakep.localdomain>
In-Reply-To: <20180522202242.otvdunkl75yfhkt4@xakep.localdomain>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Wed, 23 May 2018 16:45:41 +0300
Message-ID: <CAGqmi76gJV=ZDX5=Y3toF2tPiJs8T=PiUJFQg5nq9O5yztx80Q@mail.gmail.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@oracle.com
Cc: linux-mm@kvack.org, Sioh Lee <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org

=D0=B2=D1=82, 22 =D0=BC=D0=B0=D1=8F 2018 =D0=B3. =D0=B2 23:22, Pavel Tatash=
in <pasha.tatashin@oracle.com>:

> Hi Timofey,

> >
> > Perf numbers:
> > Intel(R) Xeon(R) CPU E5-2420 v2 @ 2.20GHz
> > ksm: crc32c   hash() 12081 MB/s
> > ksm: xxh64    hash()  8770 MB/s
> > ksm: xxh32    hash()  4529 MB/s
> > ksm: jhash2   hash()  1569 MB/s

> That is a very nice improvement over jhash2!

> > Add function to autoselect hash algo on boot,
> > based on hashing speed, like raid6 code does.

> Are you aware of hardware where crc32c is slower compared to xxhash?
> Perhaps always use crc32c when available?

crc32c will always be available, because of Kconfig.
But if crc32c doesn't have HW acceleration, it will be slower.

For talk about range of HW, i must have that HW,
so i can't say that *all* supported HW, have crc32c with acceleration.

> > +
> > +static u32 fasthash(const void *input, size_t length)
> > +{
> > +again:
> > +     switch (fastest_hash) {
> > +     case HASH_CRC32C:
> > +             return crc32c(0, input, length);
> > +     case HASH_XXHASH:
> > +             return xxhash(input, length, 0);

> You are loosing half of 64-bit word in xxh64 case? Is this acceptable? Ma=
y
> be do one more xor: in 64-bit case in xxhash() do: (v >> 32) | (u32)v ?

AFAIK, that lead to make hash function worse.
Even, in ksm hash used only for check if page has changed since last scan,
so that doesn't matter really (IMHO).

> > +     default:
> > +             choice_fastest_hash();
> > +             /* The correct value depends on page size and endianness
*/
> > +             zero_checksum =3D fasthash(ZERO_PAGE(0), PAGE_SIZE);
> > +             goto again;
> > +     }
> > +}

> choice_fastest_hash() does not belong to fasthash(). We are loosing leaf
> function optimizations if you keep it in this hot-path. Also, fastest_has=
h
> should really be a static branch in order to avoid extra load and
conditional
> branch.

I don't think what that will give any noticeable performance benefit.
In compare to hash computation and memcmp in RB.

In theory, that can be replaced with self written jump table, to *avoid*
run time overhead.
AFAIK at 5 entries, gcc convert switch to jump table itself.

> I think, crc32c should simply be used when it is available, and use xxhas=
h
> otherwise, the decision should be made in ksm_init()

I already said, in above conversation, why i think do that at ksm_init() is
a bad idea.

> Thank you,
> Pavel

Thanks.

--=20
Have a nice day,
Timofey.
