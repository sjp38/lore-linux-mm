Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id BB01C6B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 23:52:49 -0500 (EST)
Received: by mail-yk0-f169.google.com with SMTP id q9so13676504ykb.0
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 20:52:49 -0800 (PST)
Received: from mail.parisc-linux.org (palinux.external.hp.com. [192.25.206.14])
        by mx.google.com with ESMTPS id 21si3963748yhx.256.2014.01.29.20.52.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 20:52:48 -0800 (PST)
Date: Wed, 29 Jan 2014 21:52:46 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
	beyond 4096 bytes
Message-ID: <20140130045245.GH20939@parisc-linux.org>
References: <20140122151913.GY4963@suse.de> <1390410233.1198.7.camel@ret.masoncoding.com> <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com> <1390413819.1198.20.camel@ret.masoncoding.com> <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com> <20140123082734.GP13997@dastard> <1390492073.2372.118.camel@dabdike.int.hansenpartnership.com> <20140123164438.GL4963@suse.de> <1390506935.2402.8.camel@dabdike> <20140124105748.GQ4963@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140124105748.GQ4963@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, Chris Mason <clm@fb.com>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>

On Fri, Jan 24, 2014 at 10:57:48AM +0000, Mel Gorman wrote:
> So far on the table is
> 
> 1. major filesystem overhawl
> 2. major vm overhawl
> 3. use compound pages as they are today and hope it does not go
>    completely to hell, reboot when it does

Is the below paragraph an exposition of option 2, or is it an option 4,
change the VM unit of allocation?  Other than the names you're using,
this is basically what I said to Kirill in an earlier thread; either
scrap the difference between PAGE_SIZE and PAGE_CACHE_SIZE, or start
making use of it.

The fact that EVERYBODY in this thread has been using PAGE_SIZE when they
should have been using PAGE_CACHE_SIZE makes me wonder if part of the
problem is that the split in naming went the wrong way.  ie use PTE_SIZE
for 'the amount of memory pointed to by a pte_t' and use PAGE_SIZE for
'the amount of memory described by a struct page'.

(we need to remove the current users of PTE_SIZE; sparc32 and powerpc32,
but that's just a detail)

And we need to fix all the places that are currently getting the
distinction wrong.  SMOP ... ;-)  What would help is correct typing of
variables, possibly with sparse support to help us out.  Big Job.

> That's why I suggested that it may be necessary to change the basic unit of
> allocation the kernel uses to be larger than the MMU page size and restrict
> how the sub pages are used. The requirement is to preserve the property that
> "with the exception of slab reclaim that any reclaim action will result
> in K-sized allocation succeeding" where K is the largest blocksize used by
> any underlying storage device. From an FS perspective then certain things
> would look similar to what they do today. Block data would be on physically
> contiguous pages, buffer_heads would still manage the case where block_size
> <= PAGEALLOC_PAGE_SIZE (as opposed to MMU_PAGE_SIZE), particularly for
> dirty tracking and so on. The VM perspective is different because now it
> has to handle MMU_PAGE_SIZE in a very different way, page reclaim of a page
> becomes multiple unmap events and so on. There would also be anomalies such
> as mlock of a range smaller than PAGEALLOC_PAGE_SIZE becomes difficult if
> not impossible to sensibly manage because mlock of a 4K page effectively
> pins the rest and it's not obvious how we would deal with the VMAs in that
> case. It would get more than just the storage gains though. Some of the
> scalability problems that deal with massive amount of struct pages may
> magically go away if the base unit of allocation and management changes.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
