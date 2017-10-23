Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 64CF16B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 06:44:40 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id m6so14767714qtc.6
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 03:44:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g48si2459599qtk.317.2017.10.23.03.44.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 03:44:39 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9NAiORg048046
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 06:44:38 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dse3tt919-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 06:44:37 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 23 Oct 2017 11:44:34 +0100
Date: Mon, 23 Oct 2017 12:44:27 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH v3 02/13] dax: require 'struct page' for filesystem dax
In-Reply-To: <CAPcyv4hqiV6oHMgFik3MBTw5SJ6hcq4RzngPn2Xtp9kAv1E+Ow@mail.gmail.com>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
	<150846714747.24336.14704246566580871364.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20171020075735.GA14378@lst.de>
	<CAPcyv4hA1nrhDf=DA6_j7s7ezGOBhvEVZ8cu81DNui_p3bhhaA@mail.gmail.com>
	<20171020162933.GA26320@lst.de>
	<20171023071835.67ee5210@mschwideX1>
	<CAPcyv4hqiV6oHMgFik3MBTw5SJ6hcq4RzngPn2Xtp9kAv1E+Ow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Message-Id: <20171023124427.10d15ee3@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Mon, 23 Oct 2017 01:55:20 -0700
Dan Williams <dan.j.williams@intel.com> wrote:

> On Sun, Oct 22, 2017 at 10:18 PM, Martin Schwidefsky
> <schwidefsky@de.ibm.com> wrote:
> > On Fri, 20 Oct 2017 18:29:33 +0200
> > Christoph Hellwig <hch@lst.de> wrote:
> > =20
> >> On Fri, Oct 20, 2017 at 08:23:02AM -0700, Dan Williams wrote: =20
> >> > Yes, however it seems these drivers / platforms have been living with
> >> > the lack of struct page for a long time. So they either don't use DA=
X,
> >> > or they have a constrained use case that never triggers
> >> > get_user_pages(). If it is the latter then they could introduce a new
> >> > configuration option that bypasses the pfn_t_devmap() check in
> >> > bdev_dax_supported() and fix up the get_user_pages() paths to fail.
> >> > So, I'd like to understand how these drivers have been using DAX
> >> > support without struct page to see if we need a workaround or we can
> >> > go ahead delete this support. If the usage is limited to
> >> > execute-in-place perhaps we can do a constrained ->direct_access() f=
or
> >> > just that case. =20
> >>
> >> For axonram I doubt anyone is using it any more - it was a very for
> >> the IBM Cell blades, which were produce=D1=95 in a rather limited numb=
er.
> >> And Cell basically seems to be dead as far as I can tell.
> >>
> >> For S/390 Martin might be able to help out what the status of xpram
> >> in general and DAX support in particular is. =20
> >
> > The goes back to the time where DAX was called XIP. The initial design
> > point has been *not* to have struct pages for a large read-only memory
> > area. There is a block device driver for z/VM that maps a DCSS segment
> > somewhere in memore (no struct page!) with e.g. the complete /usr
> > filesystem. The xpram driver is a different beast and has nothing to
> > do with XIP/DAX.
> >
> > Now, if any there are very few users of the dcssblk driver out there.
> > The idea to save a few megabyte for /usr never really took of.
> >
> > We have to look at our get_user_pages() implementation to see how hard
> > it would be to make it fail if the target address is for an area without
> > struct pages. =20
>=20
> For read-only memory I think we can enable a subset of DAX, and
> explicitly turn off the paths that require get_user_pages(). However,
> I wonder if anyone has tested DAX with dcssblk because fork() requires
> get_user_pages()?
=20
I did not test it recently, someone else might have. Gerald?

Looking at the code I see this in the s390 version of gup_pte_range:

        mask =3D (write ? _PAGE_PROTECT : 0) | _PAGE_INVALID | _PAGE_SPECIA=
L;
	...
                if ((pte_val(pte) & mask) !=3D 0)
                        return 0;
	...

The XIP code used the pte_mkspecial mechanics to make it work. As far as
I can see the pfn_t_devmap returns true for the DAX mappins, yes?
Then I would say that dcssblk and DAX currently do not work together.

--=20
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
