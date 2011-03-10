Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9E1608D003A
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 17:49:50 -0500 (EST)
Date: Fri, 11 Mar 2011 09:49:45 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] xfs: flush vmap aliases when mapping fails
Message-ID: <20110310224945.GA15097@dastard>
References: <1299713876-7747-1-git-send-email-david@fromorbit.com>
 <20110310073751.GB25374@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110310073751.GB25374@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: xfs@oss.sgi.com, npiggin@kernel.dk, linux-mm@kvack.org

On Thu, Mar 10, 2011 at 02:37:51AM -0500, Christoph Hellwig wrote:
> On Thu, Mar 10, 2011 at 10:37:56AM +1100, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > On 32 bit systems, vmalloc space is limited and XFS can chew through
> > it quickly as the vmalloc space is lazily freed. This can result in
> > failure to map buffers, even when there is apparently large amounts
> > of vmalloc space available. Hence, if we fail to map a buffer, purge
> > the aliases that have not yet been freed to hopefuly free up enough
> > vmalloc space to allow a retry to succeed.
> 
> IMHO this should be done by vm_map_ram internally.  If we can't get the
> core code fixes we can put this in as a last resort.

OK. The patch was done as part of the triage for this bug:

https://bugzilla.kernel.org/show_bug.cgi?id=27492

where the vmalloc space on 32 bit systems is getting exhausted. I
can easily move this flush-and-retry into the vmap code.

FWIW, while the VM folk might be paying attention about vmap realted
stuff, this vmap BUG() also needs triage:

https://bugzilla.kernel.org/show_bug.cgi?id=27002

And, finally, the mm-vmap-area-cache.patch in the current mmotm also
needs to be pushed forward because we've been getting reports of
excessive CPU time being spent walking the vmap area rbtree during
vm_map_ram operations and this patch supposedly fixes that
problem....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
