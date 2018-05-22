Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC3A6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 20:07:52 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id u29-v6so12807665ote.18
        for <linux-mm@kvack.org>; Mon, 21 May 2018 17:07:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 22-v6sor7671780otu.132.2018.05.21.17.07.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 17:07:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180521161026.709d5f2876e44f151da3d179@linux-foundation.org>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152694212460.5484.13180030631810166467.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180521161026.709d5f2876e44f151da3d179@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 21 May 2018 17:07:49 -0700
Message-ID: <CAPcyv4hMwMefMu3La+hZvN6r+Q6_N5t+eOgGE0bqVou=Cjpfwg@mail.gmail.com>
Subject: Re: [PATCH 2/5] mm, devm_memremap_pages: handle errors allocating
 final devres action
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: stable <stable@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

[ resend as the last attempt dropped all the cc's ]

On Mon, May 21, 2018 at 4:10 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 21 May 2018 15:35:24 -0700 Dan Williams <dan.j.williams@intel.com=
> wrote:
>
>> The last step before devm_memremap_pages() returns success is to
>> allocate a release action to tear the entire setup down. However, the
>> result from devm_add_action() is not checked.
>>
>> Checking the error also means that we need to handle the fact that the
>> percpu_ref may not be killed by the time devm_memremap_pages_release()
>> runs. Add a new state flag for this case.
>>
>> Cc: <stable@vger.kernel.org>
>> Fixes: e8d513483300 ("memremap: change devm_memremap_pages interface..."=
)
>> Cc: Christoph Hellwig <hch@lst.de>
>> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
>> Cc: Logan Gunthorpe <logang@deltatee.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> Why the cc:stable?  The changelog doesn't describe the end-user-visible
> impact of the bug (it always should, for this reason).

True, I should have included that, one of these years I'll stop making
this mistake.

>
> AFAICT we only go wrong when a small GFP_KERNEL allocation fails
> (basically never happens), with undescribed results :(
>

Here's a better changelog:

---
The last step before devm_memremap_pages() returns success is to
allocate a release action to tear the entire setup down. However, the
result from devm_add_action() is not checked.

Checking the error also means that we need to handle the fact that the
percpu_ref may not be killed by the time devm_memremap_pages_release()
runs. Add a new state flag for this case.

Without this change we could fail to register the teardown of
devm_memremap_pages(). The likelihood of hitting this failure is tiny
as small memory allocations almost always succeed. However, the impact
of the failure is large given any future reconfiguration, or
disable/enable, of an nvdimm namespace will fail forever as subsequent
calls to devm_memremap_pages() will fail to setup the pgmap_radix
since there will be stale entries for the physical address range.
