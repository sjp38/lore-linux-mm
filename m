Subject: Re: [PATCH -v6 2/2] Updating ctime and mtime for memory-mapped
	files
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20080118175450.715ded60@bree.surriel.com>
References: <12006091182260-git-send-email-salikhmetov@gmail.com>
	 <E1JFwnQ-0001FB-2c@pomaz-ex.szeredi.hu>
	 <alpine.LFD.1.00.0801181127000.2957@woody.linux-foundation.org>
	 <200801182332.02945.ioe-lkml@rameria.de>
	 <alpine.LFD.1.00.0801181439330.2957@woody.linux-foundation.org>
	 <20080118175450.715ded60@bree.surriel.com>
Content-Type: text/plain
Date: Fri, 18 Jan 2008 18:50:03 -0600
Message-Id: <1200703803.25782.45.camel@cinder.waste.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Oeser <ioe-lkml@rameria.de>, Miklos Szeredi <miklos@szeredi.hu>, peterz@infradead.org, salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-01-18 at 17:54 -0500, Rik van Riel wrote:
> On Fri, 18 Jan 2008 14:47:33 -0800 (PST)
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> >  - keep it simple. Let's face it, Linux has never ever given those 
> >    guarantees before, and it's not is if anybody has really cared. Even 
> >    now, the issue seems to be more about paper standards conformance than 
> >    anything else.
> 
> There is one issue which is way more than just standards conformance.
> 
> When a program changes file data through mmap(), at some point the
> mtime needs to be update so that backup programs know to back up the
> new version of the file.
> 
> Backup programs not seeing an updated mtime is a really big deal.

And that's fixed with the 4-line approach.

Reminds me, I've got a patch here for addressing that problem with loop mounts:

Writes to loop should update the mtime of the underlying file.

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: l/drivers/block/loop.c
===================================================================
--- l.orig/drivers/block/loop.c	2007-11-05 17:50:07.000000000 -0600
+++ l/drivers/block/loop.c	2007-11-05 19:03:51.000000000 -0600
@@ -221,6 +221,7 @@ static int do_lo_send_aops(struct loop_d
 	offset = pos & ((pgoff_t)PAGE_CACHE_SIZE - 1);
 	bv_offs = bvec->bv_offset;
 	len = bvec->bv_len;
+	file_update_time(file);
 	while (len > 0) {
 		sector_t IV;
 		unsigned size;
@@ -299,6 +300,7 @@ static int __do_lo_send_write(struct fil
 
 	set_fs(get_ds());
 	bw = file->f_op->write(file, buf, len, &pos);
+	file_update_time(file);
 	set_fs(old_fs);
 	if (likely(bw == len))
 		return 0;


-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
