Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id C3CD98E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 06:35:57 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id r10-v6so579821oti.19
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 03:35:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o6-v6sor511589otk.309.2018.09.13.03.35.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Sep 2018 03:35:56 -0700 (PDT)
MIME-Version: 1.0
References: <20180418193220.4603-3-timofey.titovets@synesis.ru>
 <20180522202242.otvdunkl75yfhkt4@xakep.localdomain> <CAGqmi76gJV=ZDX5=Y3toF2tPiJs8T=PiUJFQg5nq9O5yztx80Q@mail.gmail.com>
 <CAGM2reaZ2YoxFhEDtcXi=hMFoGFi8+SROOn+_SRMwnx3cW15kw@mail.gmail.com>
 <CAGqmi76-qK9q_OTvyqpb-9k_m0CLMt3o860uaN5LL8nBkf5RTg@mail.gmail.com>
 <20180527130325.GB4522@rapoport-lnx> <CAGM2rea2GBvOAiKcSpHkQ9F+jgvy3sCsBw7hFz26DvQ+c_677A@mail.gmail.com>
 <CAGqmi74G-7bM5mbbaHjzOkTvuEpCcAbZ8Q0PVCMkyP09XaVSkA@mail.gmail.com>
 <20180607115232.GA8245@rapoport-lnx> <CAGM2rebK=gNbcAwkmt7W9kwtd=QWoPRogQMaoXOv=bmX+_d+yw@mail.gmail.com>
 <20180625084806.GB13791@rapoport-lnx>
In-Reply-To: <20180625084806.GB13791@rapoport-lnx>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Thu, 13 Sep 2018 13:35:20 +0300
Message-ID: <CAGqmi75emzhU_coNv_8qaf1LkdG7gsFWNAFTwUC+1FikH7h1WQ@mail.gmail.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: pasha.tatashin@oracle.com, linux-mm@kvack.org, Sioh Lee <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org

=D0=BF=D0=BD, 25 =D0=B8=D1=8E=D0=BD. 2018 =D0=B3. =D0=B2 11:48, Mike Rapopo=
rt <rppt@linux.vnet.ibm.com>:
>
> On Thu, Jun 07, 2018 at 09:29:49PM -0400, Pavel Tatashin wrote:
> > > With CONFIG_SYSFS=3Dn there is nothing that will set ksm_run to anyth=
ing but
> > > zero and ksm_do_scan will never be called.
> > >
> >
> > Unfortunatly, this is not so:
> >
> > In: /linux-master/mm/ksm.c
> >
> > 3143#else
> > 3144 ksm_run =3D KSM_RUN_MERGE; /* no way for user to start it */
> > 3145
> > 3146#endif /* CONFIG_SYSFS */
> >
> > So, we do set ksm_run to run right from ksm_init() when CONFIG_SYSFS=3D=
n.
> >
> > I wonder if this is acceptible to only use xxhash when CONFIG_SYSFS=3Dn=
 ?
>
> BTW, with CONFIG_SYSFS=3Dn KSM may start running before hardware accelera=
tion
> for crc32c is initialized...
>
> > Thank you,
> > Pavel
> >
>
> --
> Sincerely yours,
> Mike.
>

Little thread bump.
That patchset can't move forward already for about ~8 month.
As i see main question in thread: that we have a race with ksm
initialization and availability of crypto api.
Maybe we then can fall back to simple plan, and just replace old good
buddy jhash by just more fast xxhash?
That allow move question with crypto api & crc32 to background, and
make things better for now, in 2-3 times.

What you all think about that?

> crc32c_intel: 1084.10ns
> crc32c (no hardware acceleration): 7012.51ns
> xxhash32: 2227.75ns
> xxhash64: 1413.16ns
> jhash2: 5128.30ns

--=20
Have a nice day,
Timofey.
