Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 996A06B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 13:37:04 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id k21-v6so15701615ioj.19
        for <linux-mm@kvack.org>; Tue, 22 May 2018 10:37:04 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id n128-v6si957719iof.123.2018.05.22.10.37.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 22 May 2018 10:37:03 -0700 (PDT)
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152694212460.5484.13180030631810166467.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180521161026.709d5f2876e44f151da3d179@linux-foundation.org>
 <CAPcyv4hMwMefMu3La+hZvN6r+Q6_N5t+eOgGE0bqVou=Cjpfwg@mail.gmail.com>
 <860a8c46-5171-78ac-0255-ee1d21b16ce8@deltatee.com>
 <CAPcyv4i-MAYLsmT1M4=D_fwMNF98MupDyNBjWNmOzwY5Lzz0Lw@mail.gmail.com>
 <b636aa5e-205b-4d67-09f8-230755de31b6@deltatee.com>
 <CAPcyv4ga3e0WSe4LeGbzpwj2QNU-XMezYDh54TPon6UKbhpP0Q@mail.gmail.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <8fa535d5-7f8d-8036-0e02-1aee7768bdef@deltatee.com>
Date: Tue, 22 May 2018 11:36:58 -0600
MIME-Version: 1.0
In-Reply-To: <CAPcyv4ga3e0WSe4LeGbzpwj2QNU-XMezYDh54TPon6UKbhpP0Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 2/5] mm, devm_memremap_pages: handle errors allocating
 final devres action
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>



On 22/05/18 11:25 AM, Dan Williams wrote:
> As far as I can see by then it's too late, or we need to expose
> release details to the caller which defeats the purpose of devm
> semantics.

In the dax/pmem case, I *think* it should be fine...

devm_add_action_or_reset() only calls the action it is passed on failure
not the entire devm chain. In which case, it should drop all the
references to the percpu counter. Then, if on an error return from
devm_memremap_pages() we call dax_pmem_percpu_kill(), the rest of the
devm chain should be called when we return from a failed probe and it
should proceed as usual.

I think dax_pmem_percpu_kill() also must be called on any error return
from devm_memremap_pages and it is currently not...

Logan
