Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 722936B000E
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 13:50:17 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x20-v6so5932777eda.21
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 10:50:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n8si4211000edy.344.2018.10.04.10.50.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 10:50:16 -0700 (PDT)
Date: Thu, 4 Oct 2018 19:50:10 +0200
From: Michal =?UTF-8?B?U3VjaMOhbmVr?= <msuchanek@suse.de>
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
Message-ID: <20181004195010.3616fc40@kitsune.suse.cz>
In-Reply-To: <14992b68-5402-9168-0050-b3c6ac4a8c90@redhat.com>
References: <20181001084038.GD18290@dhcp22.suse.cz>
	<d54a8509-725f-f771-72f0-15a9d93e8a49@redhat.com>
	<20181002134734.GT18290@dhcp22.suse.cz>
	<98fb8d65-b641-2225-f842-8804c6f79a06@redhat.com>
	<8736tndubn.fsf@vitty.brq.redhat.com>
	<20181003134444.GH4714@dhcp22.suse.cz>
	<87zhvvcf3b.fsf@vitty.brq.redhat.com>
	<49456818-238e-2d95-9df6-d1934e9c8b53@linux.intel.com>
	<87tvm3cd5w.fsf@vitty.brq.redhat.com>
	<06a35970-e478-18f8-eae6-4022925a5192@redhat.com>
	<20181004061938.GB22173@dhcp22.suse.cz>
	<efd50413-4be4-06c4-5ef0-711fdf05db71@redhat.com>
	<20181004172807.1eef3a6b@kitsune.suse.cz>
	<14992b68-5402-9168-0050-b3c6ac4a8c90@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Kate Stewart <kstewart@linuxfoundation.org>, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, Rashmica Gupta <rashmica.g@gmail.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Michael Neuling <mikey@neuling.org>, Stephen Hemminger <sthemmin@microsoft.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-acpi@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, xen-devel@lists.xenproject.org, Rob Herring <robh@kernel.org>, Len Brown <lenb@kernel.org>, Pavel Tatashin <pavel.tatashin@microsoft.com>, linux-s390@vger.kernel.org, "mike.travis@hpe.com" <mike.travis@hpe.com>, Haiyang Zhang <haiyangz@microsoft.com>, Jonathan =?UTF-8?B?TmV1c2Now6Rm?= =?UTF-8?B?ZXI=?= <j.neuschaefer@gmx.net>, Nicholas Piggin <npiggin@gmail.com>, Joe Perches <joe@perches.com>, =?UTF-8?B?SsOpcsO0?= =?UTF-8?B?bWU=?= Glisse <jglisse@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <osalvador@suse.de>, Juergen Gross <jgross@suse.com>, Tony Luck <tony.luck@intel.com>, Mathieu Malaterre <malat@debian.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, devel@linuxdriverproject.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, 4 Oct 2018 17:45:13 +0200
David Hildenbrand <david@redhat.com> wrote:

> On 04/10/2018 17:28, Michal Such=C3=A1nek wrote:

> >=20
> > The state of the art is to determine what to do with hotplugged
> > memory in userspace based on platform and virtualization type. =20
>=20
> Exactly.
>=20
> >=20
> > Changing the default to depend on the driver that added the memory
> > rather than platform type should solve the issue of VMs growing
> > different types of memory device emulation. =20
>=20
> Yes, my original proposal (this patch) was to handle it in the kernel
> for known types. But as we learned, there might be some use cases that
> might still require to make a decision in user space.
>=20
> So providing the user space either with some type hint (auto-online
> vs. standby) or the driver that added it (system vs. hyper-v ...)
> would solve the issue.

Is that not available in the udev event?

Thanks

Michal
