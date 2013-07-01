Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 8C7796B0031
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 12:16:48 -0400 (EDT)
Message-ID: <51D1AB6E.9030905@sr71.net>
Date: Mon, 01 Jul 2013 09:16:46 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] mm: madvise: MADV_POPULATE for quick pre-faulting
References: <20130627231605.8F9F12E6@viggo.jf.intel.com> <20130628054757.GA10429@gmail.com> <51CDB056.5090308@sr71.net> <51CE4451.4060708@gmail.com>
In-Reply-To: <51CE4451.4060708@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zheng Liu <gnehzuil.liu@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/28/2013 07:20 PM, Zheng Liu wrote:
>> > IOW, a process needing to do a bunch of MAP_POPULATEs isn't
>> > parallelizable, but one using this mechanism would be.
> I look at the code, and it seems that we will handle MAP_POPULATE flag
> after we release mmap_sem locking in vm_mmap_pgoff():
> 
>                 down_write(&mm->mmap_sem);
>                 ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
>                                     &populate);
>                 up_write(&mm->mmap_sem);
>                 if (populate)
>                         mm_populate(ret, populate);
> 
> Am I missing something?

I went and did my same test using mmap(MAP_POPULATE)/munmap() pair
versus using MADV_POPULATE in 160 threads in parallel.

MADV_POPULATE was about 10x faster in the threaded configuration.

With MADV_POPULATE, the biggest cost is shipping the mmap_sem cacheline
around so that we can write the reader count update in to it.  With
mmap(), there is a lot of _contention_ on that lock which is much, much
more expensive than simply bouncing a cacheline around.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
