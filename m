Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 85CE56B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 18:58:11 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so745414pdj.6
        for <linux-mm@kvack.org>; Tue, 20 May 2014 15:58:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id fw4si3694222pbb.63.2014.05.20.15.58.10
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 15:58:10 -0700 (PDT)
Date: Tue, 20 May 2014 15:58:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Sync only the requested range in msync
Message-Id: <20140520155809.2ff4a91b7767379db66db1b1@linux-foundation.org>
In-Reply-To: <x49y4y54xgq.fsf@segfault.boston.devel.redhat.com>
References: <1395961361-21307-1-git-send-email-matthew.r.wilcox@intel.com>
	<20140423141115.GA31375@infradead.org>
	<20140512163948.0b365598e1e4d0b06dea3bc6@linux-foundation.org>
	<x49y4y54xgq.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com

On Tue, 13 May 2014 09:31:01 -0400 Jeff Moyer <jmoyer@redhat.com> wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > On Wed, 23 Apr 2014 07:11:15 -0700 Christoph Hellwig <hch@infradead.org> wrote:
> >
> >> On Thu, Mar 27, 2014 at 07:02:41PM -0400, Matthew Wilcox wrote:
> >> > [untested.  posted because it keeps coming up at lsfmm/collab]
> >> > 
> >> > msync() currently syncs more than POSIX requires or BSD or Solaris
> >> > implement.  It is supposed to be equivalent to fdatasync(), not fsync(),
> >> > and it is only supposed to sync the portion of the file that overlaps
> >> > the range passed to msync.
> >> > 
> >> > If the VMA is non-linear, fall back to syncing the entire file, but we
> >> > still optimise to only fdatasync() the entire file, not the full fsync().
> >> > 
> >> > Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> >> 
> >> Looks good,
> >> 
> >> Reviewed-by: Christoph Hellwig <hch@lst.de>
> >
> > I worry that if there are people who are relying on the current
> > behaviour (knowingly or not!) then this patch will put their data at
> > risk and nobody will ever know.  Until that data gets lost, that is.
> > At some level of cautiousness, this is one of those things we can never
> > fix.
> >
> > I suppose we could add an msync2() syscall with the new behaviour so
> > people can migrate over.  That would be very cheap to do.
> >
> > It's hard to know what's the right thing to do here.
> 
> FWIW, I think we should apply the patch.  Anyone using the API properly
> will not get the desired result, and it could have a negative impact on
> performance.  The man page is very explicit on what you should expect,
> here.  Anyone relying on undocumented behavior gets to keep both pieces
> when it breaks.  That said, I do understand your viewpoint, Andrew,
> especially since it's so hard to get people to sync their data at all,
> much less correctly.
> 
> Acked-by: Jeff Moyer <jmoyer@redhat.com>
> 

Sigh, OK, scary.  And I don't see a sane way in which we can do
WARN_ON_ONCE("hey dummy this doesn't do what you think it does").

Matthew, I checked the arith carefully and it looks OK, but would be
more comfortable if you could find a way of testing it please?  Try
this dirty trick:


	if (!strcmp(current->comm, "my-test-app")) {
		char buf[100];

		sprintf(buf, "kernel: %llu->%llu\n", fstart, fend);
		sys_write(1, buf, strlen(buf));
	}

so your debug info nicely appears on my-test-app's (fflushed) stdout ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
