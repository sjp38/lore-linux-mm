Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id BD9D76B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 17:15:38 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id g62so220519070wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 14:15:38 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id c16si527568wmd.81.2016.02.23.14.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 14:15:37 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id g62so4428059wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 14:15:37 -0800 (PST)
Message-ID: <56CCDA06.6000005@plexistor.com>
Date: Wed, 24 Feb 2016 00:15:34 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <56CA2AC9.7030905@plexistor.com> <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com> <20160221223157.GC25832@dastard> <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com> <20160222174426.GA30110@infradead.org> <257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com> <20160223095225.GB32294@infradead.org> <7168B635-938B-44A0-BECD-C0774207B36D@intel.com> <20160223120644.GL25832@dastard> <20160223171059.GB15877@linux.intel.com> <20160223214729.GH14668@dastard>
In-Reply-To: <20160223214729.GH14668@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 02/23/2016 11:47 PM, Dave Chinner wrote:
<>
> 
> i.e. what we've implemented right now is a basic, slow,
> easy-to-make-work-correctly brute force solution. That doesn't mean
> we always need to implement it this way, or that we are bound by the
> way dax_clear_sectors() currently flushes cachelines before it
> returns. It's just a simple implementation that provides the
> ordering the *filesystem requires* to provide the correct data
> integrity semantics to userspace.
> 

Or it can be written properly with movnt instructions and be even
faster the a simple memset, and no need for any cl_flushing let alone
any radix-tree locking.

That said your suggestion above is 25%-100% slower than current code
because the cl_flushes will be needed eventually, and the atomics of a
lock takes 25% the time of a full page copy. You are forgetting we are
talking about memory and not harddisk. the rules are different.
(Cumming from NFS it took me a long time to adjust)

I'll send a patch to fix this
Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
