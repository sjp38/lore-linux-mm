Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 353916B0031
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 05:50:59 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id x13so5790866wgg.3
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 02:50:58 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pl10si5843195wic.8.2014.01.30.02.50.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 02:50:57 -0800 (PST)
Date: Thu, 30 Jan 2014 10:50:52 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Message-ID: <20140130105052.GP6732@suse.de>
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
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140130045245.GH20939@parisc-linux.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, Chris Mason <clm@fb.com>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>

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
> change the VM unit of allocation?

Changing the VM unit of allocation is a major VM overhawl

> Other than the names you're using,
> this is basically what I said to Kirill in an earlier thread; either
> scrap the difference between PAGE_SIZE and PAGE_CACHE_SIZE, or start
> making use of it.
> 

No. The PAGE_CACHE_SIZE would depend on the underlying address space and
vary. The large block patchset would have to have done this but I did not
go back and review the patches due to lack of time. With that it starts
hitting into fragmentation problems that have to be addressed somehow and
cannot just be waved away.

> The fact that EVERYBODY in this thread has been using PAGE_SIZE when they
> should have been using PAGE_CACHE_SIZE makes me wonder if part of the
> problem is that the split in naming went the wrong way.  ie use PTE_SIZE
> for 'the amount of memory pointed to by a pte_t' and use PAGE_SIZE for
> 'the amount of memory described by a struct page'.
> 
> (we need to remove the current users of PTE_SIZE; sparc32 and powerpc32,
> but that's just a detail)
> 
> And we need to fix all the places that are currently getting the
> distinction wrong.  SMOP ... ;-)  What would help is correct typing of
> variables, possibly with sparse support to help us out.  Big Job.
> 

That's taking the approach of the large block patchset (as I understand
it, not reviewed, not working on this etc) without dealing with potential
fragmentation problems. Of course they could be remapped virtually if
necessary but that will be very constrained on 32-bit, the final transfer
to hardware will require scatter/gather and there is a setup/teardown
cost with virtual mappings such as faulting (setup) and IPIs to flush TLBs
(teardown) that would add overhead.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
