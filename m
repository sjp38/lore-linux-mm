Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 077EA6B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 03:56:53 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAI8upTA030094
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 18 Nov 2009 17:56:51 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C889C45DE4F
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 17:56:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AA36145DE4E
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 17:56:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9666AE08002
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 17:56:50 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4920AE38003
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 17:56:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 7/7] xfs: Don't use PF_MEMALLOC
In-Reply-To: <20091117221108.GK9467@discord.disaster>
References: <20091117162235.3DEB.A69D9226@jp.fujitsu.com> <20091117221108.GK9467@discord.disaster>
Message-Id: <20091118153302.3E20.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 18 Nov 2009 17:56:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, xfs-masters@oss.sgi.com, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

> On Tue, Nov 17, 2009 at 04:23:43PM +0900, KOSAKI Motohiro wrote:
> > 
> > Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need few
> > memory, anyone must not prevent it. Otherwise the system cause
> > mysterious hang-up and/or OOM Killer invokation.
> 
> The xfsbufd is a woken run by a registered memory shaker. i.e. it
> runs when the system needs to reclaim memory. It forceN? the
> delayed write metadata buffers (of which there can be a lot) to disk
> so that they can be reclaimed on IO completion. This IO submission
> may require N?ome memory to be allocated to be able to free that
> memory.
> 
> Hence, AFAICT the use of PF_MEMALLOC is valid here.

Thanks a lot. 
I have one additional question, may I ask you?

How can we calculate maximum memory usage in xfsbufd?
I'm afraid that VM and XFS works properly but adding two makes memory exhaust.

And, I conclude XFS doesn't need sharing reservation memory with VM,
it only need non failed allocation. right? IOW I'm prefer perter's
suggestion.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
