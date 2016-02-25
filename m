Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id B89186B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 02:44:40 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id a4so15096980wme.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 23:44:40 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id d62si2611073wmf.64.2016.02.24.23.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 23:44:39 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id a4so15096470wme.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 23:44:39 -0800 (PST)
Message-ID: <56CEB0E4.8080305@plexistor.com>
Date: Thu, 25 Feb 2016 09:44:36 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com> <20160223095225.GB32294@infradead.org> <56CC686A.9040909@plexistor.com> <CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com> <56CCD54C.3010600@plexistor.com> <CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com> <x49egc3c8gf.fsf@segfault.boston.devel.redhat.com> <CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com> <x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com> <CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com> <20160224040947.GA10313@linux.intel.com>
In-Reply-To: <20160224040947.GA10313@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 02/24/2016 06:09 AM, Ross Zwisler wrote:
> On Tue, Feb 23, 2016 at 03:56:17PM -0800, Dan Williams wrote:
<>
> 
> MAP_PMEM_AWARE is interesting, but even in a perfect world it seems like a
> partial solution - applications still need to call *sync to get the FS
> metadata to be durable, and they have no reliable way of knowing which of
> their actions will cause the metadata to be out of sync.
> 

So there is the very simple answer:
	Just like today.

Today you need to call m/fsync after you have finished all modifications
and you want a persistent point. This of course will work. .I.E write
the application same as if the mount is not dax. But do set the flag
and switch to pmem_memcpy all over. BTW pmem_memcpy() will give you
10% gain on memory performance with fully-cached FS a swell.

I do not mind that. Just that with MAP_PMEM_AWARE the call to sync will
be fast and the page-faults much much faster. I'm a pragmatic person I'm saying
to application writers.
	Change nothing, have the same source code for both DAX and none DAX
	mode. Just switch to pmem_memcpy() / pmem_flush() everywhere and set
	the mmap flag, and you have 3x boost on your mmap performance.

> Dave, is your objection to the MAP_SYNC idea a practical one about complexity
> and time to get it implemented, or do you think it's is the wrong solution?

So you see with MAP_SYNC you are asking developers to write two versions of their
app, the later which does not call m/fsync.

[BTW MAP_SYNC is a *very bad* name because with it you are requiring the applications
 to switch to pmem_memcpy() and persistent stores everywhere. It might be very
 confusing and people might assume that the Kernel can magically guess every time
 an mmap pointer was modified, even after the page-fault.
 It should be called something like MAP_PMEM_SYNC
]

> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
