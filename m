Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5F16B6B0035
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 07:56:01 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mx11so335702bkb.2
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 04:56:00 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id ar3si10153499bkc.223.2014.01.23.04.55.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 04:55:59 -0800 (PST)
Date: Thu, 23 Jan 2014 07:55:50 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Message-ID: <20140123125550.GB6853@thunk.org>
References: <1390410233.1198.7.camel@ret.masoncoding.com>
 <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>
 <1390413819.1198.20.camel@ret.masoncoding.com>
 <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com>
 <52E00B28.3060609@redhat.com>
 <1390415703.2372.62.camel@dabdike.int.hansenpartnership.com>
 <52E0106B.5010604@redhat.com>
 <1390419019.2372.89.camel@dabdike.int.hansenpartnership.com>
 <20140122115002.bb5d01dee836b567a7aad157@linux-foundation.org>
 <20140123083558.GQ13997@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140123083558.GQ13997@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chris Mason <clm@fb.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, Ric Wheeler <rwheeler@redhat.com>

On Thu, Jan 23, 2014 at 07:35:58PM +1100, Dave Chinner wrote:
> > 
> > I expect it would be relatively simple to get large blocksizes working
> > on powerpc with 64k PAGE_SIZE.  So before diving in and doing huge
> > amounts of work, perhaps someone can do a proof-of-concept on powerpc
> > (or ia64) with 64k blocksize.
> 
> Reality check: 64k block sizes on 64k page Linux machines has been
> used in production on XFS for at least 10 years. It's exactly the
> same case as 4k block size on 4k page size - one page, one buffer
> head, one filesystem block.

This is true for ext4 as well.  Block size == page size support is
pretty easy; the hard part is when block size > page size, due to
assumptions in the VM layer that requires that FS system needs to do a
lot of extra work to fudge around.  So the real problem comes with
trying to support 64k block sizes on a 4k page architecture, and can
we do it in a way where every single file system doesn't have to do
their own specific hacks to work around assumptions made in the VM
layer.

Some of the problems include handling the case where you get someone
dirties a single block in a sparse page, and the FS needs to manually
fault in the other 56k pages around that single page.  Or the VM not
understanding that page eviction needs to be done in chunks of 64k so
we don't have part of the block evicted but not all of it, etc.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
