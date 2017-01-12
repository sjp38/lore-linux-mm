Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 36CDF6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 18:59:02 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id a194so8425996oib.5
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 15:59:02 -0800 (PST)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id e46si4245408ote.105.2017.01.12.15.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 15:59:01 -0800 (PST)
Received: by mail-oi0-x233.google.com with SMTP id w204so42171393oiw.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 15:59:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170112231430.GA10096@redhat.com>
References: <CAPcyv4hWNL7=MmnUj65A+gz=eHAnUrVzqV+24QiNQDW--ag8WQ@mail.gmail.com>
 <20170112231430.GA10096@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 12 Jan 2017 15:59:00 -0800
Message-ID: <CAPcyv4hjW7JshX0ewaFrXBuWq6DSHkHE3DaZRfKDTSr9ZKDD=g@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Memory hotplug, ZONE_DEVICE, and the future of
 struct page
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, linux-block@vger.kernel.org, Stephen Bates <sbates@raithlin.com>, Logan Gunthorpe <logang@deltatee.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

On Thu, Jan 12, 2017 at 3:14 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Thu, Jan 12, 2017 at 02:43:03PM -0800, Dan Williams wrote:
>> Back when we were first attempting to support DMA for DAX mappings of
>> persistent memory the plan was to forgo 'struct page' completely and
>> develop a pfn-to-scatterlist capability for the dma-mapping-api. That
>> effort died in this thread:
>>
>>     https://lkml.org/lkml/2015/8/14/3
>>
>> ...where we learned that the dependencies on struct page for dma
>> mapping are deeper than a PFN_PHYS() conversion for some
>> architectures. That was the moment we pivoted to ZONE_DEVICE and
>> arranged for a 'struct page' to be available for any persistent memory
>> range that needs to be the target of DMA. ZONE_DEVICE enables any
>> device-driver that can target "System RAM" to also be able to target
>> persistent memory through a DAX mapping.
>>
>> Since that time the "page-less" DAX path has continued to mature [1]
>> without growing new dependencies on struct page, but at the same time
>> continuing to rely on ZONE_DEVICE to satisfy get_user_pages().
>>
>> Peer-to-peer DMA appears to be evolving from a niche embedded use case
>> to something general purpose platforms will need to comprehend. The
>> "map_peer_resource" [2] approach looks to be headed to the same
>> destination as the pfn-to-scatterlist effort. It's difficult to avoid
>> 'struct page' for describing DMA operations without custom driver
>> code.
>>
>> With that background, a statement and a question to discuss at LSF/MM:
>>
>> General purpose DMA, i.e. any DMA setup through the dma-mapping-api,
>> requires pfn_to_page() support across the entire physical address
>> range mapped.
>
> Note that in my case it is even worse. The pfn of the page does not
> correspond to anything so it need to go through a special function
> to find if a page can be mapped for another device and to provide a
> valid pfn at which the page can be access by other device.

I still haven't quite wrapped my head about how these pfn ranges are
created. Would this be a use case for a new pfn_t flag? It doesn't
sound like something we'd want to risk describing with raw 'unsigned
long' pfns.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
