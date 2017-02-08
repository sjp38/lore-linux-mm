Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A6AB46B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 10:04:45 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id d201so99683386qkg.2
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 07:04:45 -0800 (PST)
Received: from mx4-phx2.redhat.com (mx4-phx2.redhat.com. [209.132.183.25])
        by mx.google.com with ESMTPS id n132si5769225qka.227.2017.02.08.07.04.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 07:04:44 -0800 (PST)
Date: Wed, 8 Feb 2017 10:04:39 -0500 (EST)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <1808730857.1637296.1486566279643.JavaMail.zimbra@redhat.com>
In-Reply-To: <bfb7f080-6f0a-743f-654b-54f41443e44a@intel.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com> <20170130033602.12275-13-khandual@linux.vnet.ibm.com> <26a17cd1-dd50-43b9-03b1-dd967466a273@intel.com> <e03e62e2-54fa-b0ce-0b58-5db7393f8e3c@linux.vnet.ibm.com> <bfb7f080-6f0a-743f-654b-54f41443e44a@intel.com>
Subject: Re: [RFC V2 12/12] mm: Tag VMA with VM_CDM flag explicitly during
 mbind(MPOL_BIND)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh kumar <aneesh.kumar@linux.vnet.ibm.com>, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, dan j williams <dan.j.williams@intel.com>

> On 01/30/2017 08:36 PM, Anshuman Khandual wrote:
> > On 01/30/2017 11:24 PM, Dave Hansen wrote:
> >> On 01/29/2017 07:35 PM, Anshuman Khandual wrote:
> >>> +=09=09if ((new_pol->mode =3D=3D MPOL_BIND)
> >>> +=09=09=09&& nodemask_has_cdm(new_pol->v.nodes))
> >>> +=09=09=09set_vm_cdm(vma);
> >> So, if you did:
> >>
> >> =09mbind(addr, PAGE_SIZE, MPOL_BIND, all_nodes, ...);
> >> =09mbind(addr, PAGE_SIZE, MPOL_BIND, one_non_cdm_node, ...);
> >>
> >> You end up with a VMA that can never have KSM done on it, etc...  Even
> >> though there's no good reason for it.  I guess /proc/$pid/smaps might =
be
> >> able to help us figure out what was going on here, but that still seem=
s
> >> like an awful lot of damage.
> >=20
> > Agreed, this VMA should not remain tagged after the second call. It doe=
s
> > not make sense. For this kind of scenarios we can re-evaluate the VMA
> > tag every time the nodemask change is attempted. But if we are looking =
for
> > some runtime re-evaluation then we need to steal some cycles are during
> > general VMA processing opportunity points like merging and split to do
> > the necessary re-evaluation. Should do we do these kind two kinds of
> > re-evaluation to be more optimal ?
>=20
> I'm still unconvinced that you *need* detection like this.  Scanning big
> VMAs is going to be really painful.
>=20
> I thought I asked before but I can't find it in this thread.  But, we
> have explicit interfaces for disabling KSM and khugepaged.  Why do we
> need implicit ones like this in addition to those?
>=20

I said it in other part of the thread i think the vma flag is a no go. Beca=
use
it try to set something that is orthogonal to vma. That you want some vma t=
o
use device memory on new allocation is a valid policy for a vma to have. Bu=
t to
have a flag that say various kernel subsystem hey my memory is special skip=
 me
is wrong.

The fact that you want to exclude device memory from KSM or autonuma is val=
id but
it should be done at struct page level ie KSM or autonuma should check the =
type
of page before doing anything. For CDM pages they would skip. It could be t=
he flags
idea that was discussed.

The overhead of doing it at page level is far lower than trying to manage a=
 vma
flags with all the issue related to vma merging, splitting and lifetime of =
such
flags. Moreover this flags is an all or nothing, it does not consider the c=
ase
where you have as much regular page as CDM page in a vma. It would block re=
gular
page from under going the usual KSM/autonuma ...

I do strongly believe that this vma flag is a bad idea.

Cheers,
J=C3=A9r=C3=B4me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
