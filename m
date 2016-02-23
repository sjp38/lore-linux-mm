Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id BE5A06B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 04:52:32 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id ho8so110720344pac.2
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 01:52:32 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id d83si46287621pfb.108.2016.02.23.01.52.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 01:52:32 -0800 (PST)
Date: Tue, 23 Feb 2016 01:52:25 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160223095225.GB32294@infradead.org>
References: <56C9EDCF.8010007@plexistor.com>
 <CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>
 <56CA1CE7.6050309@plexistor.com>
 <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
 <56CA2AC9.7030905@plexistor.com>
 <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
 <20160221223157.GC25832@dastard>
 <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
 <20160222174426.GA30110@infradead.org>
 <257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rudoff, Andy" <andy.rudoff@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

[Hi Andy - care to properly line break after ~75 character, that makes
 ready the message a lot easier, thanks!]

On Mon, Feb 22, 2016 at 08:05:44PM +0000, Rudoff, Andy wrote:
> I think several things are getting mixed together in this discussion:
> 
> First, one primary reason DAX exists is so that applications can access
> persistence directly.

Agreed.

> Once mappings are set up, latency-sensitive apps get load/store access
> and can flush stores themselves using instructions rather than kernel calls.

Disagreed.  That's not how the architecture has worked at any point
since the humble ext2/XIP days.  It might be a worthwhile goal in the
long run, but it's never been part of the architecture as discussed on
the Linux lists, and it's not trivially implementable.

> Second, programming to load/store persistence is tricky, but the usual API
> for programming to memory-mapped files will "just work" and we built on
> that to avoid needlessly creating new permission & naming models.

Agreed.

> If you want to use msync() or fsync(), it will work, but may not perform as
> well as using the instructions.

And this is BS.  Using msync or fsync might not perform as well as not
actually using them, but without them you do not get persistence.  If
you use your pmem as a throw away cache that's fine, but for most people
that is not the case.

> The instructions give you very fine-grain flushing control, but the
> downside is that the app must track what it changes at that fine
> granularity.  Both models work, but there's a trade-off.

No, the cache flush model simply does not work without a lot of hard
work to enable it first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
