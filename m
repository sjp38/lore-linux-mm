Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id D85E76B0008
	for <linux-mm@kvack.org>; Mon, 21 May 2018 19:10:29 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g92-v6so10877259plg.6
        for <linux-mm@kvack.org>; Mon, 21 May 2018 16:10:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f95-v6si15308216plb.401.2018.05.21.16.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 16:10:29 -0700 (PDT)
Date: Mon, 21 May 2018 16:10:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/5] mm, devm_memremap_pages: handle errors allocating
 final devres action
Message-Id: <20180521161026.709d5f2876e44f151da3d179@linux-foundation.org>
In-Reply-To: <152694212460.5484.13180030631810166467.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
	<152694212460.5484.13180030631810166467.stgit@dwillia2-desk3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: stable@vger.kernel.org, Christoph Hellwig <hch@lst.de>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 21 May 2018 15:35:24 -0700 Dan Williams <dan.j.williams@intel.com> =
wrote:

> The last step before devm_memremap_pages() returns success is to
> allocate a release action to tear the entire setup down. However, the
> result from devm_add_action() is not checked.
>=20
> Checking the error also means that we need to handle the fact that the
> percpu_ref may not be killed by the time devm_memremap_pages_release()
> runs. Add a new state flag for this case.
>=20
> Cc: <stable@vger.kernel.org>
> Fixes: e8d513483300 ("memremap: change devm_memremap_pages interface...")
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: "J=E9r=F4me Glisse" <jglisse@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Why the cc:stable?  The changelog doesn't describe the end-user-visible
impact of the bug (it always should, for this reason).

AFAICT we only go wrong when a small GFP_KERNEL allocation fails
(basically never happens), with undescribed results :(
