Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D04276B004D
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 19:28:58 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 476A082C5E2
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 19:51:17 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bYngExsIYL2q for <linux-mm@kvack.org>;
	Tue,  7 Jul 2009 19:51:17 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0B26F82C5E6
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 19:51:11 -0400 (EDT)
Date: Tue, 7 Jul 2009 19:32:41 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
In-Reply-To: <4A5384A4.7060108@redhat.com>
Message-ID: <alpine.DEB.1.10.0907071931160.17422@gentwo.org>
References: <20090707090120.1e71a060.minchan.kim@barrios-desktop> <20090707090509.0C60.A69D9226@jp.fujitsu.com> <20090707101855.0C63.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907071248560.5124@gentwo.org> <4A5384A4.7060108@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Jul 2009, Rik van Riel wrote:

> Christoph Lameter wrote:
> > On Tue, 7 Jul 2009, KOSAKI Motohiro wrote:
> >
> > > +++ b/include/linux/mmzone.h
> > > @@ -100,6 +100,8 @@ enum zone_stat_item {
> > >  	NR_BOUNCE,
> > >  	NR_VMSCAN_WRITE,
> > >  	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
> > > +	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
> > > +	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
> >
> > LRU counters are rarer in use then the counters used for dirty pages etc.
> >
> > Could you move the counters for reclaim into a separate cacheline?
>
> I don't get the point of that - these counters are
> per-cpu anyway, so why would they need to be in a
> separate cacheline?

Because there are so many counters now that they spread multiple
cachelines. PCP data is very performance sensitive. Putting them in a
separate cacheline so that the most important counters are in the
first one will reduce the cache footprint of many core VM functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
