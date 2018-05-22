Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB6B6B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 13:03:16 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id r76-v6so461056itc.0
        for <linux-mm@kvack.org>; Tue, 22 May 2018 10:03:16 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id w10-v6si308081ita.17.2018.05.22.10.03.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 22 May 2018 10:03:15 -0700 (PDT)
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152694212460.5484.13180030631810166467.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180521161026.709d5f2876e44f151da3d179@linux-foundation.org>
 <CAPcyv4hMwMefMu3La+hZvN6r+Q6_N5t+eOgGE0bqVou=Cjpfwg@mail.gmail.com>
 <860a8c46-5171-78ac-0255-ee1d21b16ce8@deltatee.com>
 <CAPcyv4i-MAYLsmT1M4=D_fwMNF98MupDyNBjWNmOzwY5Lzz0Lw@mail.gmail.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <b636aa5e-205b-4d67-09f8-230755de31b6@deltatee.com>
Date: Tue, 22 May 2018 11:03:13 -0600
MIME-Version: 1.0
In-Reply-To: <CAPcyv4i-MAYLsmT1M4=D_fwMNF98MupDyNBjWNmOzwY5Lzz0Lw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 2/5] mm, devm_memremap_pages: handle errors allocating
 final devres action
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>



On 22/05/18 10:56 AM, Dan Williams wrote:
> On Tue, May 22, 2018 at 9:42 AM, Logan Gunthorpe <logang@deltatee.com> wrote:
>> Hey Dan,
>>
>> On 21/05/18 06:07 PM, Dan Williams wrote:
>>> Without this change we could fail to register the teardown of
>>> devm_memremap_pages(). The likelihood of hitting this failure is tiny
>>> as small memory allocations almost always succeed. However, the impact
>>> of the failure is large given any future reconfiguration, or
>>> disable/enable, of an nvdimm namespace will fail forever as subsequent
>>> calls to devm_memremap_pages() will fail to setup the pgmap_radix
>>> since there will be stale entries for the physical address range.
>>
>> Sorry, I don't follow this. The change only seems to prevent a warning
>> from occurring in this situation. Won't pgmap_radix_release() still be
>> called regardless of whether this patch is applied?
> 
> devm_add_action() does not call the release function,
> devm_add_action_or_reset() does.

Oh, yes. Thanks I see that now.

> Ah, true, good catch!
> 
> We should manually kill in the !registered case. I think this means we
> need to pass in the custom kill routine, because for the pmem driver
> it's blk_freeze_queue_start().

It may be cleaner to just have the caller call the specific kill
function if devm_memremap_pages fails... Though, I don't fully
understand how the nvdimm pmem driver cleans up the percpu counter.

Logan
