Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id F0E436B0036
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 16:01:57 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id v10so1364449qac.33
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 13:01:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x8si8783690qcx.16.2014.08.14.13.01.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Aug 2014 13:01:57 -0700 (PDT)
Date: Thu, 14 Aug 2014 15:54:21 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: mm: compaction: buffer overflow in isolate_migratepages_range
Message-ID: <20140814185420.GA26367@optiplex.redhat.com>
References: <53E6CEAA.9020105@oracle.com>
 <CAPAsAGxcC0+V1ZzR3LL=ASx=KXifPbw_cyvHCBBJT4mZ1grg+Q@mail.gmail.com>
 <20140813153501.GE21041@optiplex.redhat.com>
 <20140814151329.GA22187@optiplex.redhat.com>
 <CAPAsAGwk7kF6XtJNz6Y41zn0SHHzEt1Nwi_wC0gWgt0fpdp-ZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPAsAGwk7kF6XtJNz6Y41zn0SHHzEt1Nwi_wC0gWgt0fpdp-ZQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <a.ryabinin@samsung.com>

On Thu, Aug 14, 2014 at 10:07:40PM +0400, Andrey Ryabinin wrote:
> 2014-08-14 19:13 GMT+04:00 Rafael Aquini <aquini@redhat.com>:
> > It still a harmless condition as before, but considering what goes above
> > I'm now convinced & confident the patch proposed by Andrey is the real fix
> > for such occurrences.
> >
> 
> I don't think that it's harmless, because we could cross page boundary here and
> try to read from a memory hole.
>
I think isolate_migratepages_range() skips over holes, doesn't it? 


> And this code has more potential problems like use after free. Since
> we don't hold locks properly here,
> page->mapping could point to freed struct address_space.
>
Thinking on how things go for isolate_migratepages_range() and balloon
pages, I struggle to find a way where that could happen. OTOH, I failed
to see things more blatant before, so I won't argue here. Defensive
programming is always better than negating possibilities ;)

 
> We discussed this with Konstantin and he suggested a better solution for this.
> If I understood him correctly the main idea was to store bit
> identifying ballon page
> in struct page (special value in _mapcount), so we won't need to check
> mapping->flags.
>
I liked it. Something in the line of PageBuddy()/PAGE_BUDDY_MAPCOUNT_VALUE scheme.
This is clearly cleaner than what we have in place today, and I'm
ashamed I didn't think of it before. Thanks for pointing that out.

Cheers,
-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
