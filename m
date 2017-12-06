Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C3B5A6B035A
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 03:07:00 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id s3so578437plp.11
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 00:07:00 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id j88si1639219pfj.101.2017.12.06.00.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 00:06:56 -0800 (PST)
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
References: <20171129144219.22867-1-mhocko@kernel.org>
 <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
 <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz> <20171201152640.GA3765@rei>
 <87wp20e9wf.fsf@concordia.ellerman.id.au>
 <20171206045433.GQ26021@bombadil.infradead.org>
 <20171206070355.GA32044@bombadil.infradead.org>
 <5f4fc834-274a-b8f1-bda0-5bcddc5902ed@nvidia.com>
 <b4cc4225-d49c-51b0-dd18-e8038b5136e1@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <27ee1755-76d8-f086-5760-9c973b31108a@nvidia.com>
Date: Wed, 6 Dec 2017 00:06:52 -0800
MIME-Version: 1.0
In-Reply-To: <b4cc4225-d49c-51b0-dd18-e8038b5136e1@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: Cyril Hrubis <chrubis@suse.cz>, Michal Hocko <mhocko@kernel.org>, Kees Cook <keescook@chromium.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>

On 12/05/2017 11:35 PM, Florian Weimer wrote:
> On 12/06/2017 08:33 AM, John Hubbard wrote:
>> In that case, maybe:
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0 MAP_EXACT
>>
>> ? ...because that's the characteristic behavior.
>=20
> Is that true?=C2=A0 mmap still silently rounding up the length to the pag=
e size, I assume, so even that name is misleading.

Hi Florian,

Not as far as I can tell, it's not doing that.

For both MAP_FIXED, and this new flag, the documented (and actual)
behavior is *not* to do any such rounding. Instead, the requested
input address is required to be page-aligned itself, and mmap()
should be honoring the exact addr.

>From the mmap(2) man page:

   MAP_FIXED
          Don't  interpret  addr  as  a  hint: place the mapping at
          exactly that address.  addr must be  a  multiple  of  the
          page  size.=20


And from what I can see, the do_mmap() implementation leaves addr
unchanged, in the MAP_FIXED case:

do_mmap(...)
{
        /* ... */
	if (!(flags & MAP_FIXED))
		addr =3D round_hint_to_min(addr);

...although it does look like device drivers have the opportunity
to break that:

mmap_region(...)
{
		/* Can addr have changed??
		 *
		 * Answer: Yes, several device drivers can do it in their
		 *         f_op->mmap method. -DaveM
		 * Bug: If addr is changed, prev, rb_link, rb_parent should
		 *      be updated for vma_link()
		 */
		WARN_ON_ONCE(addr !=3D vma->vm_start);

		addr =3D vma->vm_start;
  =20

--
thanks,
John Hubbard
NVIDIA

>=20
> Thanks,
> Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
