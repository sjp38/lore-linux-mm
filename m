Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3876D6B0268
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:15:06 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f144so285939582pfa.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 14:15:06 -0800 (PST)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id w28si8926135pfk.112.2017.01.25.14.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 14:15:05 -0800 (PST)
Received: by mail-pg0-x231.google.com with SMTP id 204so67813740pge.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 14:15:05 -0800 (PST)
Date: Wed, 25 Jan 2017 14:14:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, madvise: fail with ENOMEM when splitting vma will
 hit max_map_count
In-Reply-To: <4c884355-0753-3b6e-a5a5-27b2a426c88b@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1701251407290.118946@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1701241431120.42507@chino.kir.corp.google.com> <4c884355-0753-3b6e-a5a5-27b2a426c88b@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Johannes Weiner <hannes@cmpxchg.org>, mtk.manpages@gmail.com, Jerome Marchand <jmarchan@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 25 Jan 2017, Anshuman Khandual wrote:

> But in the due course there might be other changes in number of VMAs of
> the process because of unmap() or merge() which could reduce the total
> number of VMAs and hence this condition may not exist afterwards. In
> that case EAGAIN still makes sense.
> 

Imagine a singlethreaded process that is operating on its own privately 
mapped memory.  Attempting to split an existing vma and meeting 
vm.max_map_count is not something that will be fixed by trying again, i.e. 
it is not helpful to loop when madvise() returns -1 with errno EAGAIN if 
vm.max_map_count will always be encountered.  The other cases where ENOMEM 
is blindly converted to EAGAIN is when slab allocation fails which can 
encounter external freeing, the meaning of "kernel resource is temporarily 
unavailable."  There is no such guarantee for vm.max_map_count, so ENOMEM 
clearly indicates the failure.

After this, it makes sense for userspace to loop for advice such as 
MADV_DONTNEED because we are actively freeing memory when EAGAIN is 
returned.  If we are meeting vm.max_map_count, this will infinitely loop.  
This is the case in tcmalloc and this patch addresses the issue when 
vm.max_map_count is low.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
