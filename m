Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id D51A26B0253
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 11:56:58 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id ts10so86476806obc.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:56:58 -0800 (PST)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com. [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id x133si34328525oig.143.2016.02.23.08.56.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 08:56:57 -0800 (PST)
Received: by mail-ob0-x229.google.com with SMTP id ts10so86476301obc.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:56:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56CC686A.9040909@plexistor.com>
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
	<20160223095225.GB32294@infradead.org>
	<56CC686A.9040909@plexistor.com>
Date: Tue, 23 Feb 2016 08:56:57 -0800
Message-ID: <CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Dave Chinner <david@fromorbit.com>, Jeff Moyer <jmoyer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Feb 23, 2016 at 6:10 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
> On 02/23/2016 11:52 AM, Christoph Hellwig wrote:
[..]
> Please tell me what you find wrong with my approach?

Setting aside fs interactions you didn't respond to my note about
architectures where the pmem-aware app needs to flush caches due to
other non-pmem aware apps sharing the mapping.  Non-temporal stores
guaranteeing persistence on their own is an architecture specific
feature.  I don't see how we can have a generic support for mixed
MAP_PMEM_AWARE / unaware shared mappings when the architecture
dependency exists [1].

I think Christoph has already pointed out the roadmap.  Get the
existing crop of DAX bugs squashed and then *maybe* look at something
like a MAP_SYNC to opt-out of userspace needing to call *sync.

[1]: 10.4.6.2 Caching of Temporal vs. Non-Temporal Data
"Some older CPU implementations (e.g., Pentium M) allowed addresses
being written with a non-temporal store instruction to be updated
in-place if the memory type was not WC and line was already in the
cache."

I wouldn't be surprised if other architectures had similar constraints.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
