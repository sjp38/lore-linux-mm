Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 698A36B421E
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 09:20:26 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b3so1639171edi.0
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 06:20:26 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t44si437774eda.120.2018.11.26.06.20.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 06:20:24 -0800 (PST)
Date: Mon, 26 Nov 2018 15:20:15 +0100
From: Michal =?UTF-8?B?U3VjaMOhbmVr?= <msuchanek@suse.de>
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
Message-ID: <20181126152015.7464c786@naga>
In-Reply-To: <b64a0e1e-6aaa-66a9-2fb7-12daa6383ce1@redhat.com>
References: <20180928150357.12942-1-david@redhat.com>
	<b01a956b-080c-c643-6473-eb132b9f7200@redhat.com>
	<20181123190653.6da91461@kitsune.suse.cz>
	<fad04d80-4e72-1bd8-3e67-a3f7dd0bc2fa@redhat.com>
	<b64a0e1e-6aaa-66a9-2fb7-12daa6383ce1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Kate Stewart <kstewart@linuxfoundation.org>, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Rashmica Gupta <rashmica.g@gmail.com>, "K. Y." Srinivasan" <kys@microsoft.com>, Dan Williams <dan.j.williams@intel.com>," linux-s390@vger.kernel.org, Michael Neuling <mikey@neuling.org>, Stephen Hemminger <sthemmin@microsoft.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-acpi@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, xen-devel@lists.xenproject.org, Len Brown <lenb@kernel.org>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Rob Herring <robh@kernel.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Haiyang Zhang <haiyangz@microsoft.com>, Jonathan =?UTF-8?B?TmV1c2Now6Rm?= =?UTF-8?B?ZXI=?= <j.neuschaefer@gmx.net>, Nicholas Piggin <npiggin@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, =?UTF-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <osalvador@suse.de>, Juergen Gross <jgross@suse.com>, Tony Luck <tony.luck@intel.com>, Mathieu Malaterre <malat@debian.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Joe Perches <joe@perches.com>, devel@linuxdriverproject.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org, Kirill A.

On Mon, 26 Nov 2018 14:33:29 +0100
David Hildenbrand <david@redhat.com> wrote:

> On 26.11.18 13:30, David Hildenbrand wrote:
> > On 23.11.18 19:06, Michal Such=C3=A1nek wrote: =20

> >>
> >> If we are going to fake the driver information we may as well add the
> >> type attribute and be done with it.
> >>
> >> I think the problem with the patch was more with the semantic than the
> >> attribute itself.
> >>
> >> What is normal, paravirtualized, and standby memory?
> >>
> >> I can understand DIMM device, baloon device, or whatever mechanism for
> >> adding memory you might have.
> >>
> >> I can understand "memory designated as standby by the cluster
> >> administrator".
> >>
> >> However, DIMM vs baloon is orthogonal to standby and should not be
> >> conflated into one property.
> >>
> >> paravirtualized means nothing at all in relationship to memory type and
> >> the desired online policy to me. =20
> >=20
> > Right, so with whatever we come up, it should allow to make a decision
> > in user space about
> > - if memory is to be onlined automatically =20
>=20
> And I will think about if we really should model standby memory. Maybe
> it is really better to have in user space something like (as Dan noted)

If it is possible to designate the memory as standby or online in the
s390 admin interface and the kernel does have access to this
information it makes sense to forward it to userspace (as separate
s390-specific property). If not then you need to make some kind of
assumption like below and the user can tune the script according to
their usecase.

>=20
> if (isS390x() && type =3D=3D "dimm") {
> 	/* don't online, on s390x system DIMMs are standby memory */
> }

Thanks

Michal
