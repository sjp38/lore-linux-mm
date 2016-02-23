Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id BDC716B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 18:08:01 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id a4so5789038wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:08:01 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id 19si65496wjq.210.2016.02.23.15.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 15:08:00 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id g62so246183297wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:07:59 -0800 (PST)
Message-ID: <56CCE647.70408@plexistor.com>
Date: Wed, 24 Feb 2016 01:07:51 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <56C9EDCF.8010007@plexistor.com>	<CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>	<56CA1CE7.6050309@plexistor.com>	<CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>	<56CA2AC9.7030905@plexistor.com>	<CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>	<20160221223157.GC25832@dastard>	<x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>	<20160222174426.GA30110@infradead.org>	<257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>	<20160223095225.GB32294@infradead.org>	<56CC686A.9040909@plexistor.com>	<CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com>	<56CCD54C.3010600@plexistor.com> <CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com>
In-Reply-To: <CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Dave Chinner <david@fromorbit.com>, Jeff Moyer <jmoyer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 02/24/2016 12:33 AM, Dan Williams wrote:
<>
> 
> In general MAP_SYNC, makes more sense semantic sense in that the
> filesystem knows that the application is not going to be calling *sync
> and it avoids triggering flushes for cachelines we don't care about.
> 

I'm not sure I understand what you meant by
	"avoids triggering flushes for cachelines we don't care about". 

But again MAP_SYNC is nice but too nice, and will never just be. And
why does it need to be either/or why not a progression turds.
[In fact our system already has MAP_SYNC.]

And you are contradicting yourself because with MAP_SYNC an application
still needs to do its magical pmem_memcpy()

> Although if we had MAP_SYNC today we'd still be in the situation that
> an app that fails to do its own cache flushes / bypass correctly gets
> to keep the broken pieces.
> 

Yes that is true today and was always true and will always be true, your
point being?

> The crux of the problem, in my opinion, is that we're asking for an "I
> know what I'm doing" flag, and I expect that's an impossible statement
> for a filesystem to trust generically.  If you can get MAP_PMEM_AWARE
> in, great, but I'm more and more of the opinion that the "I know what
> I'm doing" interface should be something separate from today's trusted
> filesystems.
> 

I disagree. I'm not saying any "trust me I know what I'm doing" flag.
the FS reveals nothing and trusts nothing.
All I'm saying is that the libc library I'm using as the new pmem_memecpy()
and I'm using that instead of the old memecpy(). So the FS does not need to
wipe my face after I eat. Failing to do so just means a bug in the application
that failed to actually move the proper data to the place it needs to move to.
The FS did its contract by providing the exact blocks back as was written to
pmem this time by the app using pmem_memecpy(). So an FS did not violate any
trust, and nothing the app did can cause any break to the the shared filesystem
except a bad thing to itself.

This is true anyway and was not invented by this patch.

Cheers
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
