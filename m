Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0746B0031
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 01:01:39 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id y10so2614544pdj.18
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 22:01:38 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:7])
        by mx.google.com with ESMTP id ek3si5056652pbd.325.2014.01.29.22.01.37
        for <linux-mm@kvack.org>;
        Wed, 29 Jan 2014 22:01:38 -0800 (PST)
Date: Thu, 30 Jan 2014 17:01:03 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Message-ID: <20140130060103.GF13997@dastard>
References: <1390410233.1198.7.camel@ret.masoncoding.com>
 <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>
 <1390413819.1198.20.camel@ret.masoncoding.com>
 <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com>
 <20140123082734.GP13997@dastard>
 <1390492073.2372.118.camel@dabdike.int.hansenpartnership.com>
 <20140123164438.GL4963@suse.de>
 <1390506935.2402.8.camel@dabdike>
 <20140124105748.GQ4963@suse.de>
 <20140130045245.GH20939@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140130045245.GH20939@parisc-linux.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Mel Gorman <mgorman@suse.de>, James Bottomley <James.Bottomley@HansenPartnership.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, Chris Mason <clm@fb.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>

On Wed, Jan 29, 2014 at 09:52:46PM -0700, Matthew Wilcox wrote:
> On Fri, Jan 24, 2014 at 10:57:48AM +0000, Mel Gorman wrote:
> > So far on the table is
> > 
> > 1. major filesystem overhawl
> > 2. major vm overhawl
> > 3. use compound pages as they are today and hope it does not go
> >    completely to hell, reboot when it does
> 
> Is the below paragraph an exposition of option 2, or is it an option 4,
> change the VM unit of allocation?  Other than the names you're using,
> this is basically what I said to Kirill in an earlier thread; either
> scrap the difference between PAGE_SIZE and PAGE_CACHE_SIZE, or start
> making use of it.

Christoph Lamater's compound page patch set scrapped PAGE_CACHE_SIZE
and made it a variable that was set on the struct address_space when
it was instantiated by the filesystem. In effect, it allowed
filesystems to specify the unit of page cache allocation on a
per-inode basis.

> The fact that EVERYBODY in this thread has been using PAGE_SIZE when they
> should have been using PAGE_CACHE_SIZE makes me wonder if part of the
> problem is that the split in naming went the wrong way.  ie use PTE_SIZE
> for 'the amount of memory pointed to by a pte_t' and use PAGE_SIZE for
> 'the amount of memory described by a struct page'.

PAGE_CACHE_SIZE was never distributed sufficiently to be used, and
if you #define it to something other than PAGE_SIZE stuff will
simply break.

> (we need to remove the current users of PTE_SIZE; sparc32 and powerpc32,
> but that's just a detail)
> 
> And we need to fix all the places that are currently getting the
> distinction wrong.  SMOP ... ;-)  What would help is correct typing of
> variables, possibly with sparse support to help us out.  Big Job.

Yes, that's what the Christoph's patchset did.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
