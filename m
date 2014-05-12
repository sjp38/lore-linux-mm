Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 40D956B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 19:39:51 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so9378817pad.16
        for <linux-mm@kvack.org>; Mon, 12 May 2014 16:39:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id jw2si371663pbc.458.2014.05.12.16.39.50
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 16:39:50 -0700 (PDT)
Date: Mon, 12 May 2014 16:39:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Sync only the requested range in msync
Message-Id: <20140512163948.0b365598e1e4d0b06dea3bc6@linux-foundation.org>
In-Reply-To: <20140423141115.GA31375@infradead.org>
References: <1395961361-21307-1-git-send-email-matthew.r.wilcox@intel.com>
	<20140423141115.GA31375@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com

On Wed, 23 Apr 2014 07:11:15 -0700 Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Mar 27, 2014 at 07:02:41PM -0400, Matthew Wilcox wrote:
> > [untested.  posted because it keeps coming up at lsfmm/collab]
> > 
> > msync() currently syncs more than POSIX requires or BSD or Solaris
> > implement.  It is supposed to be equivalent to fdatasync(), not fsync(),
> > and it is only supposed to sync the portion of the file that overlaps
> > the range passed to msync.
> > 
> > If the VMA is non-linear, fall back to syncing the entire file, but we
> > still optimise to only fdatasync() the entire file, not the full fsync().
> > 
> > Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> 
> Looks good,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

I worry that if there are people who are relying on the current
behaviour (knowingly or not!) then this patch will put their data at
risk and nobody will ever know.  Until that data gets lost, that is.
At some level of cautiousness, this is one of those things we can never
fix.

I suppose we could add an msync2() syscall with the new behaviour so
people can migrate over.  That would be very cheap to do.

It's hard to know what's the right thing to do here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
