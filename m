Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 57ED66B0036
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 11:48:40 -0400 (EDT)
Message-ID: <51CDB056.5090308@sr71.net>
Date: Fri, 28 Jun 2013 08:48:38 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] mm: madvise: MADV_POPULATE for quick pre-faulting
References: <20130627231605.8F9F12E6@viggo.jf.intel.com> <20130628054757.GA10429@gmail.com>
In-Reply-To: <20130628054757.GA10429@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/27/2013 10:47 PM, Zheng Liu wrote:
>> I've been doing some testing involving large amounts of
>> page cache.  It's quite painful to get hundreds of GB
>> of page cache mapped in, especially when I am trying to
>> do it in parallel threads.  This is true even when the
>> page cache is already allocated and I only need to map
>> it in.  The test:
>>
>> 1. take 160 16MB files
>> 2. clone 160 threads, mmap the 16MB files, and either
>>   a. walk through the file touching each page
> 
> Why not change MAP_POPULATE flag in mmap(2)?  Now it is only for private
> mappings.  But maybe we could let it support shared mapping.

Adding that support to mmap() will certainly _help_ some folks.  But,
anything that mmap()s something is taking mmap_sem for write.  That
means that threaded apps doing mmap()/munmap() frequently are _not_
scalable.

IOW, a process needing to do a bunch of MAP_POPULATEs isn't
parallelizable, but one using this mechanism would be.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
