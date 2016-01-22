Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5B92A6B0256
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 10:32:01 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id 123so19075665wmz.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 07:32:01 -0800 (PST)
Date: Fri, 22 Jan 2016 16:31:55 +0100
From: Andres Freund <andres@anarazel.de>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160122153155.GF4961@awork2.anarazel.de>
References: <cover.1452549431.git.bcrl@kvack.org>
 <80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org>
 <20160112011128.GC6033@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160112011128.GC6033@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 2016-01-12 12:11:28 +1100, Dave Chinner wrote:
> On Mon, Jan 11, 2016 at 05:07:23PM -0500, Benjamin LaHaise wrote:
> > Enable a fully asynchronous fsync and fdatasync operations in aio using
> > the aio thread queuing mechanism.
> > 
> > Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
> > Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
> 
> Insufficient. Needs the range to be passed through and call
> vfs_fsync_range(), as I implemented here:
> 
> https://lkml.org/lkml/2015/10/28/878

FWIW, I finally started to play around with this (or more precisely
https://lkml.org/lkml/2015/10/29/517). There were some prerequisite
changes in postgres required, to actually be able to benefit, delaying
things.  First results are good, increasing OLTP throughput
considerably.

It'd also be rather helpful to be able to do
sync_file_range(SYNC_FILE_RANGE_WRITE) asynchronously, i.e. flush
without an implied barrier. Currently this blocks very frequently, even
if there's actually IO bandwidth available.

Regards,

Andres

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
