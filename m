Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7456B0033
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 12:22:54 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id c85so6146385oib.13
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 09:22:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u184sor3845325oie.163.2017.12.17.09.22.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Dec 2017 09:22:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4g_6izDX780Fqv=zx=aYrASivwYpQcNkRmZW3iSZfKQHQ@mail.gmail.com>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-5-hch@lst.de>
 <CAPcyv4g_6izDX780Fqv=zx=aYrASivwYpQcNkRmZW3iSZfKQHQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 17 Dec 2017 09:22:52 -0800
Message-ID: <CAPcyv4h2EsZO2g+YVyVVJFx_Cv3wiZH+xNj=koAux1+_uuF1UA@mail.gmail.com>
Subject: Re: [PATCH 04/17] mm: pass the vmem_altmap to arch_add_memory and __add_pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 5:48 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
>> We can just pass this on instead of having to do a radix tree lookup
>> without proper locking 2 levels into the callchain.
>>
>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>
> Yeah, the lookup of vmem_altmap is too magical and surprising this is better.
>
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>

I'll also note that the locking is not necessary in the memory map
init path because we can't possibly be racing mutations of the radix
as everyone who might touch the radix is serialized by the
mem_hotplug_begin() lock. It's only accesses outside of the
arch_{add,remove}_memory() that need the rcu lock. However, that is
another subtle/magic assumption of this code and its better to pass
the altmap down through the call chain. I just don't want people
thinking that -stable needs to pick any of this up, because afaics the
locking is fine as is, and we can drop that mention from the
changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
