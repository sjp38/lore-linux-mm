Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id BB7E46B0258
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 09:10:54 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id b205so201300972wmb.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 06:10:54 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id b188si39799538wmh.99.2016.02.23.06.10.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 06:10:53 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id g62so224103119wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 06:10:53 -0800 (PST)
Message-ID: <56CC686A.9040909@plexistor.com>
Date: Tue, 23 Feb 2016 16:10:50 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <56C9EDCF.8010007@plexistor.com> <CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com> <56CA1CE7.6050309@plexistor.com> <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com> <56CA2AC9.7030905@plexistor.com> <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com> <20160221223157.GC25832@dastard> <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com> <20160222174426.GA30110@infradead.org> <257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com> <20160223095225.GB32294@infradead.org>
In-Reply-To: <20160223095225.GB32294@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Dave Chinner <david@fromorbit.com>, Jeff Moyer <jmoyer@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 02/23/2016 11:52 AM, Christoph Hellwig wrote:
<>
> 
> And this is BS.  Using msync or fsync might not perform as well as not
> actually using them, but without them you do not get persistence.  If
> you use your pmem as a throw away cache that's fine, but for most people
> that is not the case.
> 

Hi Christoph

So is exactly my suggestion. My approach is *not* the we do not call
m/fsync to let the FS clean up.

In my model we still do that, only we eliminate the m/fsync slowness
and the all page faults overhead by being instructed by the application
that we do not need to track the data modified cachelines. Since the
application is telling us that it will do so.

In my model the job is split:
 App will take care of data persistence by instructing a MAP_PMEM_AWARE,
 and doing its own cl_flushing / movnt.
 Which is the heavy cost

 The FS will keep track of the Meta-Data persistence as it already does, via the
 call to m/fsync. Which is marginal performance compared to the above heavy
 IO.

Note that the FS is still free to move blocks around, as Dave said:
lockout pagefaultes, unmap from user space, let app fault again on a new
block. this will still work as before, already in COW we flush the old
block so there will be no persistence lost.

So this all thread started with my patches, and my patches do not say
"no m/fsync" they say, make this 3-8 times faster than today if the app
is participating in the heavy lifting.

Please tell me what you find wrong with my approach?

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
