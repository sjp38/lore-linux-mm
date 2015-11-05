Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id BE27982F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 13:17:28 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so70035312pac.3
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 10:17:28 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id bc7si11704690pbd.145.2015.11.05.10.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 10:17:27 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so94276179pab.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 10:17:27 -0800 (PST)
Date: Thu, 5 Nov 2015 10:17:26 -0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
Message-ID: <20151105181726.GA63566@kernel.org>
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org>
 <CALCETrUuNs=26UQtkU88cKPomx_Bik9mbgUUF9q7Nmh1pQJ4qg@mail.gmail.com>
 <56399CA5.8090101@gmail.com>
 <CALCETrU5P-mmjf+8QuS3-pm__R02j2nnRc5B1gQkeC013XWNvA@mail.gmail.com>
 <563A813B.9080903@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <563A813B.9080903@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux API <linux-api@vger.kernel.org>, Jason Evans <je@fb.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, yalin wang <yalin.wang2010@gmail.com>, Mel Gorman <mgorman@suse.de>

On Wed, Nov 04, 2015 at 05:05:47PM -0500, Daniel Micay wrote:
> > With enough pages at once, though, munmap would be fine, too.
> 
> That implies lots of page faults and zeroing though. The zeroing alone
> is a major performance issue.
> 
> There are separate issues with munmap since it ends up resulting in a
> lot more virtual memory fragmentation. It would help if the kernel used
> first-best-fit for mmap instead of the current naive algorithm (bonus:
> O(log n) worst-case, not O(n)). Since allocators like jemalloc and
> PartitionAlloc want 2M aligned spans, mixing them with other allocators
> can also accelerate the VM fragmentation caused by the dumb mmap
> algorithm (i.e. they make a 2M aligned mapping, some other mmap user
> does 4k, now there's a nearly 2M gap when the next 2M region is made and
> the kernel keeps going rather than reusing it). Anyway, that's a totally
> separate issue from this. Just felt like complaining :).
> 
> > Maybe what's really needed is a MADV_FREE variant that takes an iovec.
> > On an all-cores multithreaded mm, the TLB shootdown broadcast takes
> > thousands of cycles on each core more or less regardless of how much
> > of the TLB gets zapped.
> 
> That would work very well. The allocator ends up having a sequence of
> dirty spans that it needs to purge in one go. As long as purging is
> fairly spread out, the cost of a single TLB shootdown isn't that bad. It
> is extremely bad if it needs to do it over and over to purge a bunch of
> ranges, which can happen if the memory has ended up being very, very
> fragmentated despite the efforts to compact it (depends on what the
> application ends up doing).

I posted a patch doing exactly iovec madvise. Doesn't support MADV_FREE yet
though, but should be easy to do it.

http://marc.info/?l=linux-mm&m=144615663522661&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
