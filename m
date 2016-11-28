Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A1F36B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 04:41:38 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id o3so19503056wjo.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 01:41:38 -0800 (PST)
Received: from mx5-phx2.redhat.com (mx5-phx2.redhat.com. [209.132.183.37])
        by mx.google.com with ESMTPS id n26si25030252wmi.56.2016.11.28.01.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 01:41:37 -0800 (PST)
Date: Mon, 28 Nov 2016 04:41:30 -0500 (EST)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <249830138.374473.1480326090692.JavaMail.zimbra@redhat.com>
In-Reply-To: <583B9D64.7020005@linux.vnet.ibm.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com> <1479493107-982-9-git-send-email-jglisse@redhat.com> <58351517.2060405@linux.vnet.ibm.com> <20161127131043.GA3710@redhat.com> <583B9D64.7020005@linux.vnet.ibm.com>
Subject: Re: [HMM v13 08/18] mm/hmm: heterogeneous memory management (HMM
 for short)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

> On 11/27/2016 06:40 PM, Jerome Glisse wrote:
> > On Wed, Nov 23, 2016 at 09:33:35AM +0530, Anshuman Khandual wrote:
> >> On 11/18/2016 11:48 PM, J=C3=A9r=C3=B4me Glisse wrote:
> >=20
> > [...]
> >=20
> >>> + *
> >>> + *      hmm_vma_migrate(vma, start, end, ops);
> >>> + *
> >>> + * With ops struct providing 2 callback alloc_and_copy() which alloc=
ated
> >>> the
> >>> + * destination memory and initialize it using source memory. Migrati=
on
> >>> can fail
> >>> + * after this step and thus last callback finalize_and_map() allow t=
he
> >>> device
> >>> + * driver to know which page were successfully migrated and which we=
re
> >>> not.
> >>
> >> So we have page->pgmap->free_devpage() to release the individual page =
back
> >> into the device driver management during migration and also we have th=
is
> >> ops
> >> based finalize_and_mmap() to check on the failed instances inside a si=
ngle
> >> migration context which can contain set of pages at a time.
> >>
> >>> + *
> >>> + * This can easily be use outside of HMM intended use case.
> >>
> >> Where you think this can be used outside of HMM ?
> >=20
> > Well on the radar is new memory hierarchy that seems to be on every CPU
> > designer
> > roadmap. Where you have a fast small HBM like memory package with the C=
PU
> > and then
> > you have the regular memory.
> >=20
> > In the embedded world they want to migrate active process to fast CPU
> > memory and
> > shutdown the regular memory to save power.
> >=20
> > In the HPC world they want to migrate hot data of hot process to this f=
ast
> > memory.
> >=20
> > In both case we are talking about process base memory migration and in =
case
> > of
> > embedded they also have DMA engine they can use to offload the copy
> > operation
> > itself.
> >=20
> > This are the useful case i have in mind but other people might see that
> > code and
> > realise they could also use it for their own specific corner case.
>=20
> If there are plans for HBM or specialized type of memory which will be
> packaged inside the CPU (without any other device accessing it like in
> the case of GPU or Network Card), then I think in that case using HMM
> is not ideal. CPU will be the only thing accessing this memory and
> there is never going to be any other device or context which can access
> this outside of CPU. Hence role of a device driver is redundant, it
> should be initialized and used as a basic platform component.

AFAIK no CPU can saturate the bandwidth of this memory and thus they only
make sense when there is something like a GPU on die. So in my mind this
kind of memory is always use preferably by a GPU but could still be use by
CPU. In that context you also always have a DMA engine to offload memory
from CPU. I was more selling the HMM migration code in that context :)

=20
> In that case what we need is a core VM managed memory with certain kind
> of restrictions around the allocation and a way of explicit allocation
> into it if required. Representing these memory like a cpu less restrictiv=
e
> coherent device memory node is a better solution IMHO. These RFCs what I
> have posted regarding CDM representation are efforts in this direction.
>=20
> [RFC Specialized Zonelists]    https://lkml.org/lkml/2016/10/24/19
> [RFC Restrictive mems_allowed] https://lkml.org/lkml/2016/11/22/339
>=20
> I believe both HMM and CDM have their own use cases and will complement
> each other.

Yes how this memory is represented probably better be represented by someth=
ing
like CDM.=20

Cheers,
J=C3=A9r=C3=B4me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
