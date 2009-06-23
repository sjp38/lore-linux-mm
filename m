Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 03C6F6B004F
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 20:07:56 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5N088DW007346
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 23 Jun 2009 09:08:08 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 077E445DD7D
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 09:08:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BD93B45DD7E
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 09:08:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A0B901DB8040
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 09:08:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 591C01DB8038
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 09:08:04 +0900 (JST)
Date: Tue, 23 Jun 2009 09:06:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Performance degradation seen after using one list for hot/cold
 pages.
Message-Id: <20090623090630.f06b7b17.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090622165236.GE3981@csn.ul.ie>
References: <20626261.51271245670323628.JavaMail.weblogic@epml20>
	<20090622165236.GE3981@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: NARAYANAN GOPALAKRISHNAN <narayanan.g@samsung.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Jun 2009 17:52:36 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Mon, Jun 22, 2009 at 11:32:03AM +0000, NARAYANAN GOPALAKRISHNAN wrote:
> > Hi,
> > 
> > We are running on VFAT.
> > We are using iozone performance benchmarking tool (http://www.iozone.org/src/current/iozone3_326.tar) for testing.
> > 
> > The parameters are 
> > /iozone -A -s10M -e -U /tmp -f /tmp/iozone_file
> > 
> > Our block driver requires requests to be merged to get the best performance.
> > This was not happening due to non-contiguous pages in all kernels >= 2.6.25.
> > 
> 
> Ok, by the looks of things, all the aio_read() requests are due to readahead
> as opposed to explicit AIO  requests from userspace. In this case, nothing
> springs to mind that would avoid excessive requests for cold pages.
> 
> It looks like the simpliest solution is to go with the patch I posted.
> Does anyone see a better alternative that doesn't branch in rmqueue_bulk()
> or add back the hot/cold PCP lists?
> 
No objection.  But 2 questions...

> -        list_add(&page->lru, list);
> +        if (likely(cold == 0))
> +            list_add(&page->lru, list);
> +        else
> +            list_add_tail(&page->lru, list);
>          set_page_private(page, migratetype);
>          list = &page->lru;
>      }

1. if (likely(coild == 0))
	"likely" is necessary ?

2. Why moving pointer "list" rather than following ?

	if (cold)
		list_add(&page->lru, list);
	else
		list_add_tail(&page->lru, list);


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
