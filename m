Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 18D5F6B004D
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 17:20:00 -0500 (EST)
Date: Sat, 10 Dec 2011 09:19:56 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: XFS causing stack overflow
Message-ID: <20111209221956.GE14273@dastard>
References: <CAAnfqPAm559m-Bv8LkHARm7iBW5Kfs7NmjTFidmg-idhcOq4sQ@mail.gmail.com>
 <20111209115513.GA19994@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111209115513.GA19994@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Ryan C. England" <ryan.england@corvidtec.com>, linux-mm@kvack.org, xfs@oss.sgi.com

On Fri, Dec 09, 2011 at 06:55:13AM -0500, Christoph Hellwig wrote:
> On Thu, Dec 08, 2011 at 01:03:51PM -0500, Ryan C. England wrote:
> > I am looking for assistance on XFS which is why I have joined this mailing
> > list.  I'm receiving a stack overflow on our file server.  The server is
> > running Scientific Linux 6.1 with the following kernel,
> > 2.6.32-131.21.1.el6.x86_64.
> > 
> > This is causing random reboots which is more annoying than anything.  I
> > found a couple of links in the archives but wasn't quite sure how to apply
> > this patch.  I can provide whatever information necessary in order for
> > assistance in troubleshooting.
> 
> It's really mostly an issue with the VM page reclaim and writeback
> code.  The kernel still has the old balance dirty pages code which calls
> into writeback code from the stack of the write system call, which
> already comes from NFSD with massive amounts of stack used.  Then
> the writeback code calls into XFS to write data out, then you get the
> full XFS btree code, which then ends up in kmalloc and memory reclaim.

You forgot about interrupt stacking - that trace shows the system
took an interrupt at the point of highest stack usage in the
writeback call chain.... :/

> You probably have only a third of the stack actually used by XFS, the
> rest is from NFSD/writeback code and page reclaim.  I don't think any
> of this is easily fixable in a 2.6.32 codebase.  Current mainline 3.2-rc
> now has the I/O-less balance dirty pages which will basically split the
> stack footprint in half, but it's an invasive change to the writeback
> code that isn't easily backportable.

It also doesn't solve the problem, because we can get pretty much
the same stack from the COMMIT operation starting writeback....

The backport of the patches that separate the allocation onto a
separte workqueue are not straight forward because all the workqueue
code is different. I'll go back and update the TOT patch to make
this separation first before backporting...

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
