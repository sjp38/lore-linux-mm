Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id EB0426B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 18:29:59 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t134so12416755oih.6
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 15:29:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s12sor861567oie.76.2017.10.20.15.29.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 15:29:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171020162933.GA26320@lst.de>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150846714747.24336.14704246566580871364.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171020075735.GA14378@lst.de> <CAPcyv4hA1nrhDf=DA6_j7s7ezGOBhvEVZ8cu81DNui_p3bhhaA@mail.gmail.com>
 <20171020162933.GA26320@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 20 Oct 2017 15:29:57 -0700
Message-ID: <CAPcyv4jP0ws7dcBrXafS7ON+0_J1BTp_LCB6XB3od4d6db071A@mail.gmail.com>
Subject: Re: [PATCH v3 02/13] dax: require 'struct page' for filesystem dax
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Fri, Oct 20, 2017 at 9:29 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Fri, Oct 20, 2017 at 08:23:02AM -0700, Dan Williams wrote:
>> Yes, however it seems these drivers / platforms have been living with
>> the lack of struct page for a long time. So they either don't use DAX,
>> or they have a constrained use case that never triggers
>> get_user_pages(). If it is the latter then they could introduce a new
>> configuration option that bypasses the pfn_t_devmap() check in
>> bdev_dax_supported() and fix up the get_user_pages() paths to fail.
>> So, I'd like to understand how these drivers have been using DAX
>> support without struct page to see if we need a workaround or we can
>> go ahead delete this support. If the usage is limited to
>> execute-in-place perhaps we can do a constrained ->direct_access() for
>> just that case.
>
> For axonram I doubt anyone is using it any more - it was a very for
> the IBM Cell blades, which were produce=D1=95 in a rather limited number.
> And Cell basically seems to be dead as far as I can tell.
>
> For S/390 Martin might be able to help out what the status of xpram
> in general and DAX support in particular is.

Ok, I'd also like to kill DAX support in the brd driver. It's a source
of complexity and maintenance burden for zero benefit. It's the only
->direct_access() implementation that sleeps and it's the only
implementation where there is a non-linear relationship between
sectors and pfns. Having a 1:1 sector to pfn relationship will help
with the dma-extent-busy management since we don't need to keep
calling into the driver to map pfns back to sectors once we know the
pfn[0] sector[0] relationship.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
