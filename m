Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 231D06B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 11:46:44 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c76so2321035qkj.11
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 08:46:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h6si611545qtb.290.2017.08.28.08.46.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 08:46:43 -0700 (PDT)
Date: Mon, 28 Aug 2017 11:46:40 -0400 (EDT)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <1201125186.4681340.1503935200216.JavaMail.zimbra@redhat.com>
In-Reply-To: <20170828083157.GE17097@dhcp22.suse.cz>
References: <59a0a9d1.jzOblYrHfdIDuDZw%akpm@linux-foundation.org> <3c9df006-0cc5-3a32-b715-1fbb43cb9ea8@infradead.org> <20170828075931.GC17097@dhcp22.suse.cz> <20170828182705.150afe66@canb.auug.org.au> <20170828083157.GE17097@dhcp22.suse.cz>
Subject: Re: mmotm 2017-08-25-15-50 uploaded
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, broonie@kernel.org

> On Mon 28-08-17 18:27:05, Stephen Rothwell wrote:
> > Hi Michal,
> >=20
> > On Mon, 28 Aug 2017 09:59:31 +0200 Michal Hocko <mhocko@kernel.org> wro=
te:
> > >
> > > From 31d551dbcb1b7987a4cd07767c1e2805849b7a26 Mon Sep 17 00:00:00 200=
1
> > > From: Michal Hocko <mhocko@suse.com>
> > > Date: Mon, 28 Aug 2017 09:41:39 +0200
> > > Subject: [PATCH]
> > >  mm-hmm-struct-hmm-is-only-use-by-hmm-mirror-functionality-v2-fix
> > >=20
> > > Compiler is complaining for allnoconfig
> > >=20
> > > kernel/fork.c: In function 'mm_init':
> > > kernel/fork.c:814:2: error: implicit declaration of function
> > > 'hmm_mm_init' [-Werror=3Dimplicit-function-declaration]
> > >   hmm_mm_init(mm);
> > >   ^
> > > kernel/fork.c: In function '__mmdrop':
> > > kernel/fork.c:893:2: error: implicit declaration of function
> > > 'hmm_mm_destroy' [-Werror=3Dimplicit-function-declaration]
> > >   hmm_mm_destroy(mm);
> > >=20
> > > Make sure that hmm_mm_init/hmm_mm_destroy empty stups are defined whe=
n
> > > CONFIG_HMM is disabled.
> > >=20
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > ---
> > >  include/linux/hmm.h | 7 +++----
> > >  1 file changed, 3 insertions(+), 4 deletions(-)
> > >=20
> > > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > > index 9583d9a15f9c..aeb94e682dda 100644
> > > --- a/include/linux/hmm.h
> > > +++ b/include/linux/hmm.h
> > > @@ -508,11 +508,10 @@ static inline void hmm_mm_init(struct mm_struct
> > > *mm)
> > >  {
> > >  =09mm->hmm =3D NULL;
> > >  }
> > > -#else /* IS_ENABLED(CONFIG_HMM_MIRROR) */
> > > +#endif
> > > +
> > > +#else /* IS_ENABLED(CONFIG_HMM) */
> > >  static inline void hmm_mm_destroy(struct mm_struct *mm) {}
> > >  static inline void hmm_mm_init(struct mm_struct *mm) {}
> > > -#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
> > > -
> > > -
> > >  #endif /* IS_ENABLED(CONFIG_HMM) */
> > >  #endif /* LINUX_HMM_H */
> >=20
> > What happens when CONFIG_HMM is defined but CONFIG_HMM_MIRROR is not?
> > Or is that not possible (in which case why would we have
> > CONFIG_HMM_MIRROR)?
>=20
> This is something to Jerome to answer but hmm_mm_init/hmm_mm_destroy are
> used regardless of the specific HMM configuration so an empty stub
> should be defined unconditionally AFAIU.

Sorry for the build issue i posted a patch on friday that i tested against
all combination :

https://lkml.org/lkml/2017/8/25/802

Michal is right this function needs to be defined no matter what but they
only need to be stub if HMM_MIRROR is not enabled.

The fix i posted has the correct logic. I missplaced the endif when i was
fixing Arnd build issue when HMM_MIRROR was not enabled but other HMM featu=
re
were.

J=C3=A9r=C3=B4me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
