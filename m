Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9D65D6B00D9
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 18:14:27 -0500 (EST)
Received: by wf-out-1314.google.com with SMTP id 28so175751wfa.11
        for <linux-mm@kvack.org>; Thu, 05 Mar 2009 15:14:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090305225921.GE918@n2100.arm.linux.org.uk>
References: <alpine.LFD.2.00.0903040014140.5511@xanadu.home>
	 <20090304171429.c013013c.minchan.kim@barrios-desktop>
	 <alpine.LFD.2.00.0903041101170.5511@xanadu.home>
	 <20090305080717.f7832c63.minchan.kim@barrios-desktop>
	 <alpine.LFD.2.00.0903042129140.5511@xanadu.home>
	 <20090305132054.888396da.minchan.kim@barrios-desktop>
	 <alpine.LFD.2.00.0903042350210.5511@xanadu.home>
	 <28c262360903051423g1fbf5067i9835099d4bf324ae@mail.gmail.com>
	 <20090305225921.GE918@n2100.arm.linux.org.uk>
Date: Fri, 6 Mar 2009 08:14:25 +0900
Message-ID: <28c262360903051514n53e54df8x935aa398e16795ce@mail.gmail.com>
Subject: Re: [RFC] atomic highmem kmap page pinning
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Nicolas Pitre <nico@cam.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 6, 2009 at 7:59 AM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Fri, Mar 06, 2009 at 07:23:44AM +0900, Minchan Kim wrote:
>> > +#ifdef ARCH_NEEDS_KMAP_HIGH_GET
>> > +/**
>> > + * kmap_high_get - pin a highmem page into memory
>> > + * @page: &struct page to pin
>> > + *
>> > + * Returns the page's current virtual memory address, or NULL if no m=
apping
>> > + * exists. =C2=A0When and only when a non null address is returned th=
en a
>> > + * matching call to kunmap_high() is necessary.
>> > + *
>> > + * This can be called from any context.
>> > + */
>> > +void *kmap_high_get(struct page *page)
>> > +{
>> > + =C2=A0 =C2=A0 =C2=A0 unsigned long vaddr, flags;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 spin_lock_kmap_any(flags);
>> > + =C2=A0 =C2=A0 =C2=A0 vaddr =3D (unsigned long)page_address(page);
>> > + =C2=A0 =C2=A0 =C2=A0 if (vaddr) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(pkmap_count[=
PKMAP_NR(vaddr)] < 1);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pkmap_count[PKMAP_N=
R(vaddr)]++;
>> > + =C2=A0 =C2=A0 =C2=A0 }
>> > + =C2=A0 =C2=A0 =C2=A0 spin_unlock_kmap_any(flags);
>> > + =C2=A0 =C2=A0 =C2=A0 return (void*) vaddr;
>> > +}
>> > +#endif
>>
>> Let's add empty function for architecture of no ARCH_NEEDS_KMAP_HIGH_GET=
,
>
> The reasoning being?

I thought it can be used in common arm function.
so, for VIVT, it can be work but for VIPT, it can be nulled as
preventing compile error.

But, I don't know where we use kmap_high_get since I didn't see any
patch which use it.
If it is only used architecture specific place,  pz, forgot my comment.

--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
