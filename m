Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id F068C6B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 22:20:05 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp16so2916505pbb.0
        for <linux-mm@kvack.org>; Fri, 28 Jun 2013 19:20:05 -0700 (PDT)
Message-ID: <51CE4451.4060708@gmail.com>
Date: Sat, 29 Jun 2013 10:20:01 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] mm: madvise: MADV_POPULATE for quick pre-faulting
References: <20130627231605.8F9F12E6@viggo.jf.intel.com> <20130628054757.GA10429@gmail.com> <51CDB056.5090308@sr71.net>
In-Reply-To: <51CDB056.5090308@sr71.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/28/2013 11:48 PM, Dave Hansen wrote:
> On 06/27/2013 10:47 PM, Zheng Liu wrote:
>>> I've been doing some testing involving large amounts of
>>> page cache.  It's quite painful to get hundreds of GB
>>> of page cache mapped in, especially when I am trying to
>>> do it in parallel threads.  This is true even when the
>>> page cache is already allocated and I only need to map
>>> it in.  The test:
>>>
>>> 1. take 160 16MB files
>>> 2. clone 160 threads, mmap the 16MB files, and either
>>>   a. walk through the file touching each page
>>
>> Why not change MAP_POPULATE flag in mmap(2)?  Now it is only for private
>> mappings.  But maybe we could let it support shared mapping.
> 
> Adding that support to mmap() will certainly _help_ some folks.  But,
> anything that mmap()s something is taking mmap_sem for write.  That
> means that threaded apps doing mmap()/munmap() frequently are _not_
> scalable.
> 
> IOW, a process needing to do a bunch of MAP_POPULATEs isn't
> parallelizable, but one using this mechanism would be.

I look at the code, and it seems that we will handle MAP_POPULATE flag
after we release mmap_sem locking in vm_mmap_pgoff():

                down_write(&mm->mmap_sem);
                ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
                                    &populate);
                up_write(&mm->mmap_sem);
                if (populate)
                        mm_populate(ret, populate);

Am I missing something?

Regards,
						- Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
