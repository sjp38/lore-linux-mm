Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 451106B0005
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 12:03:16 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id g62so133716861wme.0
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 09:03:16 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id w128si19392513wmb.61.2016.02.21.09.03.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 09:03:14 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id a4so132956486wme.1
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 09:03:14 -0800 (PST)
Message-ID: <56C9EDCF.8010007@plexistor.com>
Date: Sun, 21 Feb 2016 19:03:11 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Chinner <david@fromorbit.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>

Hi all

Recent DAX code fixed the cl_flushing ie durability of mmap access
of direct persistent-memory from applications. It uses the radix-tree
per inode to track the indexes of a file that where page-faulted for
write. Then at m/fsync time it would cl_flush these pages and clean
the radix-tree, for the next round.

Sigh, that is life, for legacy applications this is the price we must
pay. But for NV aware applications like nvml library, we pay extra extra
price, even if we do not actually call m/fsync eventually. For these
applications these extra resources and especially the extra radix locking
per page-fault, costs a lot, like x3 a lot.

What we propose here is a way for those applications to enjoy the
boost and still not sacrifice any correctness of legacy applications.
Any concurrent access from legacy apps vs nv-aware apps even to the same
file / same page, will work correctly.

We do that by defining a new MMAP flag that is set by the nv-aware
app. this flag is carried by the VMA. In the dax code we bypass any
radix handling of the page if this flag is set. Those pages accessed *without*
this flag will be added to the radix-tree, those with will not.
At m/fsync time if the radix tree is then empty nothing will happen.

These are very simple none intrusive patches with minimum risk. (I think)
They are based on v4.5-rc5. If you need a rebase on any other tree please
say.

Please consider this new flag for those of us people who specialize in
persistent-memory setups and want to extract any possible mileage out
of our systems.

Also attached for reference a 3rd patch to the nvml library to use
the new flag. Which brings me to the issue of persistent_memcpy / persistent_flush.
Currently this library is for x86_64 only, using the movnt instructions. The gcc
compiler should have a per ARCH facility for durable memory accesses. So applications
can be portable across systems.

Please advise?

list of patches:
[RFC 1/2] mmap: Define a new MAP_PMEM_AWARE mmap flag
[RFC 2/2] REVIEWME: dax: Support MAP_PMEM_AWARE for optimal

	Two Kernel patches

[RFC 1/1] util: add pmem-aware flag to mmap

	A patch for the nvml library

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
