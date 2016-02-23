Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 892286B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 12:26:51 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id ts10so87380163obc.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 09:26:51 -0800 (PST)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id d127si34370813oif.101.2016.02.23.09.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 09:26:50 -0800 (PST)
Received: by mail-oi0-x234.google.com with SMTP id x21so83000386oix.2
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 09:26:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160223170530.GA15877@linux.intel.com>
References: <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
	<56CA2AC9.7030905@plexistor.com>
	<CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
	<20160221223157.GC25832@dastard>
	<x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
	<20160222174426.GA30110@infradead.org>
	<257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>
	<20160223095225.GB32294@infradead.org>
	<56CC686A.9040909@plexistor.com>
	<CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com>
	<20160223170530.GA15877@linux.intel.com>
Date: Tue, 23 Feb 2016 09:26:50 -0800
Message-ID: <CAPcyv4h_feFJ0aELArA+nAgGJhbcNTCqZzp=goK53vF0kN7wOQ@mail.gmail.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Boaz Harrosh <boaz@plexistor.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Feb 23, 2016 at 9:05 AM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Tue, Feb 23, 2016 at 08:56:57AM -0800, Dan Williams wrote:
>> On Tue, Feb 23, 2016 at 6:10 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
>> > On 02/23/2016 11:52 AM, Christoph Hellwig wrote:
>> [..]
>> > Please tell me what you find wrong with my approach?
>>
>> Setting aside fs interactions you didn't respond to my note about
>> architectures where the pmem-aware app needs to flush caches due to
>> other non-pmem aware apps sharing the mapping.  Non-temporal stores
>> guaranteeing persistence on their own is an architecture specific
>> feature.  I don't see how we can have a generic support for mixed
>> MAP_PMEM_AWARE / unaware shared mappings when the architecture
>> dependency exists [1].
>>
>> I think Christoph has already pointed out the roadmap.  Get the
>> existing crop of DAX bugs squashed and then *maybe* look at something
>> like a MAP_SYNC to opt-out of userspace needing to call *sync.
>>
>> [1]: 10.4.6.2 Caching of Temporal vs. Non-Temporal Data
>> "Some older CPU implementations (e.g., Pentium M) allowed addresses
>> being written with a non-temporal store instruction to be updated
>> in-place if the memory type was not WC and line was already in the
>> cache."
>>
>> I wouldn't be surprised if other architectures had similar constraints.
>
> I don't understand how this is an argument against Boaz's approach.  If
> non-temporal stores are essentially broken, they are broken for both the
> kernel use case and for the userspace use case, and (if we want to support
> these platforms, which I'm not sure we do) we would need to fall back to
> writes + explicit flushes for both kernel space and userspace.

MAP_PMEM_AWARE only declares self-awareness does not guarantee that
everyone else sharing the mapping is equally aware.  A pmem-aware app
on such an architecture would be free to flush once and use
non-temporal stores going forward, but if the mapping is shared it
needs to flush all the time.  Like I said before it needs to be
all-aware apps in a shared mapping or none, but it's moot because I
think something like MAP_SYNC is semantically much clearer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
