Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id E06DA6B0005
	for <linux-mm@kvack.org>; Sat,  7 May 2016 11:16:07 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id i5so154221317ige.1
        for <linux-mm@kvack.org>; Sat, 07 May 2016 08:16:07 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id dr5si5014301igc.3.2016.05.07.08.16.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 May 2016 08:16:07 -0700 (PDT)
From: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>
Subject: RE: [PATCH v2 1/2] mm, kasan: improve double-free detection
Date: Sat, 7 May 2016 15:15:59 +0000
Message-ID: <20E775CA4D599049A25800DE5799F6DD1F62744C@G4W3225.americas.hpqcorp.net>
References: <20160506114727.GA2571@cherokee.in.rdlabs.hpecorp.net>
 <20160507102505.GA27794@yury-N73SV>
In-Reply-To: <20160507102505.GA27794@yury-N73SV>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "cl@linux.com" <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "klimov.linux@gmail.com" <klimov.linux@gmail.com>

Thank you for the review!

> > +
> > +/* acquire per-object lock for access to KASAN metadata. */
>=20
> I believe there's strong reason not to use standard spin_lock() or
> similar. I think it's proper place to explain it.
>=20

will do.

> > +void kasan_meta_lock(struct kasan_alloc_meta *alloc_info)
> > +{
> > +	union kasan_alloc_data old, new;
> > +
> > +	preempt_disable();
>=20
> It's better to disable and enable preemption inside the loop
> on each iteration, to decrease contention.
>=20

ok, makes sense; will do.

> > +	for (;;) {
> > +		old.packed =3D READ_ONCE(alloc_info->data);
> > +		if (unlikely(old.lock)) {
> > +			cpu_relax();
> > +			continue;
> > +		}
> > +		new.packed =3D old.packed;
> > +		new.lock =3D 1;
> > +		if (likely(cmpxchg(&alloc_info->data, old.packed, new.packed)
> > +					=3D=3D old.packed))
> > +			break;
> > +	}
> > +}
> > +
> > +/* release lock after a kasan_meta_lock(). */
> > +void kasan_meta_unlock(struct kasan_alloc_meta *alloc_info)
> > +{
> > +	union kasan_alloc_data alloc_data;
> > +
> > +	alloc_data.packed =3D READ_ONCE(alloc_info->data);
> > +	alloc_data.lock =3D 0;
> > +	if (unlikely(xchg(&alloc_info->data, alloc_data.packed) !=3D
> > +				(alloc_data.packed | 0x1U)))
> > +		WARN_ONCE(1, "%s: lock not held!\n", __func__);
>=20
> Nitpick. It never happens in normal case, correct?. Why don't you place i=
t under
> some developer config, or even leave at dev branch? The function will
> be twice shorter without it.

ok, will remove/shorten.

> > +	alloc_data.packed =3D alloc_info->data;
> > +	if (alloc_data.state =3D=3D KASAN_STATE_ALLOC) {
> > +		free_info =3D get_free_info(cache, object);
> > +		quarantine_put(free_info, cache);
>=20
> I just pulled master and didn't find this function. If your patchset
> is based on other branch, please notice it.

Sorry; patchset is based on linux-next 'next-20160506' which has Alexander
Potapenko's patches for KASAN SLAB support with memory quarantine +
stackdepot features.

>=20
> > +		set_track(&free_info->track, GFP_NOWAIT);
>=20
> It may fail for many reasons. Is it OK to ignore it? If OK, I think it
> should be explained.

It's ok. A subsequent bug report on object would have a missing alloc/deall=
oc
stack trace.=20

>=20
> > +		kasan_poison_slab_free(cache, object);
> > +		alloc_data.state =3D KASAN_STATE_QUARANTINE;
> > +		alloc_info->data =3D alloc_data.packed;
> > +		kasan_meta_unlock(alloc_info);
> > +		return true;
> >  	}
> > +	switch (alloc_data.state) {
> > +	case KASAN_STATE_QUARANTINE:
> > +	case KASAN_STATE_FREE:
> > +		kasan_report((unsigned long)object, 0, false,
> > +				(unsigned long)__builtin_return_address(1));
>=20
> __builtin_return_address() is unsafe if argument is non-zero. Use
> return_address() instead.

hmm, I/cscope can't seem to find an x86 implementation for return_address()=
.
Will dig further; thanks.

> > +		local_irq_save(flags);
> > +		kasan_meta_lock(alloc_info);
> > +		alloc_data.packed =3D alloc_info->data;
> > +		alloc_data.state =3D KASAN_STATE_ALLOC;
> > +		alloc_data.size_delta =3D cache->object_size - size;
> > +		alloc_info->data =3D alloc_data.packed;
> >  		set_track(&alloc_info->track, flags);
>=20
> Same as above
>
As above.=20

Kuthonuzo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
