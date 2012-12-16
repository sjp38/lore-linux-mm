Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id B1D686B002B
	for <linux-mm@kvack.org>; Sat, 15 Dec 2012 22:04:43 -0500 (EST)
Date: Sun, 16 Dec 2012 03:04:42 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH] fadvise: perform WILLNEED readahead in a workqueue
Message-ID: <20121216030442.GA28172@dcvr.yhbt.net>
References: <20121215005448.GA7698@dcvr.yhbt.net>
 <20121216024520.GH9806@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121216024520.GH9806@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Dave Chinner <david@fromorbit.com> wrote:
> On Sat, Dec 15, 2012 at 12:54:48AM +0000, Eric Wong wrote:
> > Applications streaming large files may want to reduce disk spinups and
> > I/O latency by performing large amounts of readahead up front.
> > Applications also tend to read files soon after opening them, so waiting
> > on a slow fadvise may cause unpleasant latency when the application
> > starts reading the file.
> > 
> > As a userspace hacker, I'm sometimes tempted to create a background
> > thread in my app to run readahead().  However, I believe doing this
> > in the kernel will make life easier for other userspace hackers.
> > 
> > Since fadvise makes no guarantees about when (or even if) readahead
> > is performed, this change should not hurt existing applications.
> > 
> > "strace -T" timing on an uncached, one gigabyte file:
> > 
> >  Before: fadvise64(3, 0, 0, POSIX_FADV_WILLNEED) = 0 <2.484832>
> >   After: fadvise64(3, 0, 0, POSIX_FADV_WILLNEED) = 0 <0.000061>
> 
> You've basically asked fadvise() to readahead the entire file if it
> can. That means it is likely to issue enough readahead to fill the
> IO queue, and that's where all the latency is coming from. If all
> you are trying to do is reduce the latency of the first read, then
> only readahead the initial range that you are going to need to read...

Yes, I do want to read the whole file, eventually.  So I want to put
the file into the page cache ASAP and allow the disk to spin down.
But I also want the first read() to be fast.

> Also, Pushing readahead off to a workqueue potentially allows
> someone to DOS the system because readahead won't ever get throttled
> in the syscall context...

Yes, I'm a little worried about this, too.
Perhaps squashing something like the following will work?

diff --git a/mm/readahead.c b/mm/readahead.c
index 56a80a9..51dc58e 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -246,16 +246,18 @@ void wq_page_cache_readahead(struct address_space *mapping, struct file *filp,
 {
 	struct wq_ra_req *req;
 
+	nr_to_read = max_sane_readahead(nr_to_read);
+	if (!nr_to_read)
+		goto skip_ra;
+
 	req = kzalloc(sizeof(*req), GFP_ATOMIC);
 
 	/*
 	 * we are fire-and-forget, not having enough memory means readahead
 	 * is not worth doing anyways
 	 */
-	if (!req) {
-		fput(filp);
-		return;
-	}
+	if (!req)
+		goto skip_ra;
 
 	INIT_WORK(&req->work, wq_ra_req_fn);
 	req->mapping = mapping;
@@ -264,6 +266,9 @@ void wq_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	req->nr_to_read = nr_to_read;
 
 	queue_work(readahead_wq, &req->work);
+
+skip_ra:
+	fput(filp);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
