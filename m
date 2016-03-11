Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id F307E6B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 01:44:19 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id tt10so87284538pab.3
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 22:44:19 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id u7si11693144pfa.128.2016.03.10.22.44.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 22:44:18 -0800 (PST)
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <56C9EDCF.8010007@plexistor.com>
From: Andy Lutomirski <luto@kernel.org>
Message-ID: <56E26940.8020203@kernel.org>
Date: Thu, 10 Mar 2016 22:44:16 -0800
MIME-Version: 1.0
In-Reply-To: <56C9EDCF.8010007@plexistor.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Chinner <david@fromorbit.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>

On 02/21/2016 09:03 AM, Boaz Harrosh wrote:
> Hi all
>
> Recent DAX code fixed the cl_flushing ie durability of mmap access
> of direct persistent-memory from applications. It uses the radix-tree
> per inode to track the indexes of a file that where page-faulted for
> write. Then at m/fsync time it would cl_flush these pages and clean
> the radix-tree, for the next round.
>
> Sigh, that is life, for legacy applications this is the price we must
> pay. But for NV aware applications like nvml library, we pay extra extra
> price, even if we do not actually call m/fsync eventually. For these
> applications these extra resources and especially the extra radix locking
> per page-fault, costs a lot, like x3 a lot.
>
> What we propose here is a way for those applications to enjoy the
> boost and still not sacrifice any correctness of legacy applications.
> Any concurrent access from legacy apps vs nv-aware apps even to the same
> file / same page, will work correctly.
>
> We do that by defining a new MMAP flag that is set by the nv-aware
> app. this flag is carried by the VMA. In the dax code we bypass any
> radix handling of the page if this flag is set. Those pages accessed *without*
> this flag will be added to the radix-tree, those with will not.
> At m/fsync time if the radix tree is then empty nothing will happen.
>

I'm a little late to the party, but let me offer a variant that might be 
considerably safer:

Add a flag MAP_DAX_WRITETHROUGH (name could be debated -- 
MAP_DAX_FASTFLUSH might be more architecture-neutral, but I'm only 
familiar with the x86 semantics).

MAP_DAX_WRITETHROUGH does whatever is needed to ensure that writing 
through the mapping and then calling fsync is both safe and fast.  On 
x86, it would (surprise, surprise!) map the pages writethrough and skip 
adding them to the radix tree.  fsync makes sure to do sfence before 
pcommit.

This is totally safe.  You *can't* abuse this to cause fsync to leave 
non-persistent dirty cached data anywhere.

It makes sufficiently DAX-aware applications very fast.  Reads are 
unaffected, and non-temporal writes should be the same speed as they are 
under any other circumstances.

It makes applications that set it blindly very slow.  Applications that 
use standard writes (i.e. plain stores that are neither fast string 
operations nor explicit non-temporal writes) will suffer.  But they'll 
still work correctly.

Applications that want a WB mapping with manually-managed persistence 
can still do it, but fsync will be slow.  Adding an fmetadatasync() for 
their benefit might be a decent idea, but it would just be icing on the 
cake.

Unlike with MAP_DAX_AWARE, there's no issue with malicious users who map 
the thing with the wrong flag, write, call fsync, and snicker because 
now the other applications might read data and be surprised that the 
data they just read isn't persistent even if they subsequently call fsync.

There would be details to be hashed out in case a page is mapped 
normally and with MAP_DAX_WRITETHROUGH in separate mappings.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
