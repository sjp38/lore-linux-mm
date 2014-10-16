Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id AD6DA6B0074
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 03:22:53 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id y10so294826pdj.23
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 00:22:53 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id fx15si319067pdb.251.2014.10.17.00.22.52
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 00:22:52 -0700 (PDT)
Date: Thu, 16 Oct 2014 18:33:31 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 07/21] dax,ext2: Replace XIP read and write with DAX
 I/O
Message-ID: <20141016223331.GA11169@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-8-git-send-email-matthew.r.wilcox@intel.com>
 <20141016095027.GE19075@thinkos.etherlink>
 <20141016195112.GE11522@wil.cx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141016195112.GE11522@wil.cx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 16, 2014 at 03:51:12PM -0400, Matthew Wilcox wrote:
> On Thu, Oct 16, 2014 at 11:50:27AM +0200, Mathieu Desnoyers wrote:
> > > +			if (rw == WRITE) {
> > > +				if (!buffer_mapped(bh)) {
> > > +					retval = -EIO;
> > > +					/* FIXME: fall back to buffered I/O */
> > 
> > Fallback on buffered I/O would void guarantee about having data stored
> > into persistent memory after write returns. Not sure we actually want
> > that.
> 
> Yeah, I think that comment is just stale.  I can't see a way in which
> buffered I/O would succeed after DAX I/O falis.

On further consideration, I think the whole thing is just foolish.
I don't see how get_block(create == 1) can return success *and* a buffer
that is !mapped.

So I did this nice simplification:

-                       if (rw == WRITE) {
-                               if (!buffer_mapped(bh)) {
-                                       retval = -EIO;
-                                       /* FIXME: fall back to buffered I/O */
-                                       break;
-                               }
-                               hole = false;
-                       } else {
-                               hole = !buffer_written(bh);
-                       }
+                       hole = (rw != WRITE) && !buffer_written(bh);

(compile-tested only; I'm going to run all the changes through xfstests
next week when I'm back home before sending out a v12).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
