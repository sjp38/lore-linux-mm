Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id A8FCE6B0253
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 10:54:53 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id 23so9202902uat.4
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 07:54:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h93si728538uad.221.2016.12.15.07.54.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 07:54:52 -0800 (PST)
Date: Thu, 15 Dec 2016 17:54:50 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Qemu-devel] [PATCH kernel v5 0/5] Extend virtio-balloon for
 fast (de)inflating & fast live migration
Message-ID: <20161215173901-mutt-send-email-mst@kernel.org>
References: <0b83db29-ebad-2a70-8d61-756d33e33a48@intel.com>
 <2171e091-46ee-decd-7348-772555d3a5e3@redhat.com>
 <d3ff453c-56fa-19de-317c-1c82456f2831@intel.com>
 <20161207183817.GE28786@redhat.com>
 <b58fd9f6-d9dd-dd56-d476-dd342174dac5@intel.com>
 <20161207202824.GH28786@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A14E2AD@SHSMSX104.ccr.corp.intel.com>
 <060287c7-d1af-45d5-70ea-ad35d4bbeb84@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3C31D0E6@SHSMSX104.ccr.corp.intel.com>
 <01886693-c73e-3696-860b-086417d695e1@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01886693-c73e-3696-860b-086417d695e1@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Li, Liang Z" <liang.z.li@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On Thu, Dec 15, 2016 at 07:34:33AM -0800, Dave Hansen wrote:
> On 12/14/2016 12:59 AM, Li, Liang Z wrote:
> >> Subject: Re: [Qemu-devel] [PATCH kernel v5 0/5] Extend virtio-balloon for
> >> fast (de)inflating & fast live migration
> >>
> >> On 12/08/2016 08:45 PM, Li, Liang Z wrote:
> >>> What's the conclusion of your discussion? It seems you want some
> >>> statistic before deciding whether to  ripping the bitmap from the ABI,
> >>> am I right?
> >>
> >> I think Andrea and David feel pretty strongly that we should remove the
> >> bitmap, unless we have some data to support keeping it.  I don't feel as
> >> strongly about it, but I think their critique of it is pretty valid.  I think the
> >> consensus is that the bitmap needs to go.
> >>
> >> The only real question IMNHO is whether we should do a power-of-2 or a
> >> length.  But, if we have 12 bits, then the argument for doing length is pretty
> >> strong.  We don't need anywhere near 12 bits if doing power-of-2.
> > 
> > Just found the MAX_ORDER should be limited to 12 if use length instead of order,
> > If the MAX_ORDER is configured to a value bigger than 12, it will make things more
> > complex to handle this case. 
> > 
> > If use order, we need to break a large memory range whose length is not the power of 2 into several
> > small ranges, it also make the code complex.
> 
> I can't imagine it makes the code that much more complex.  It adds a for
> loop.  Right?
> 
> > It seems we leave too many bit  for the pfn, and the bits leave for length is not enough,
> > How about keep 45 bits for the pfn and 19 bits for length, 45 bits for pfn can cover 57 bits
> > physical address, that should be enough in the near feature. 
> > 
> > What's your opinion?
> 
> I still think 'order' makes a lot of sense.  But, as you say, 57 bits is
> enough for x86 for a while.  Other architectures.... who knows?

I think you can probably assume page size >= 4K. But I would not want
to make any other assumptions. E.g. there are systems that absolutely
require you to set high bits for DMA.

I think we really want both length and order.

I understand how you are trying to pack them as tightly as possible.

However, I thought of a trick, we don't need to encode all
possible orders. For example, with 2 bits of order,
we can make them mean:
00 - 4K pages
01 - 2M pages
02 - 1G pages

guest can program the sizes for each order through config space.

We will have 10 bits left for legth.

It might make sense to also allow guest to program the number of bits
used for order, this will make it easy to extend without
host changes.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
