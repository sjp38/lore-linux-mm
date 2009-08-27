Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 55E216B004F
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 20:20:39 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7R0KiZp001536
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 27 Aug 2009 09:20:44 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E49D445DE57
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 09:20:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 66C2645DE60
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 09:20:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C48781DB803F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 09:20:42 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F7EDE08013
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 09:20:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] mm: remove unnecessary loop inside shrink_inactive_list()
In-Reply-To: <20090821112228.GA6457@localhost>
References: <2f11576a0908210409p3f1551a4i194887abbad94e9b@mail.gmail.com> <20090821112228.GA6457@localhost>
Message-Id: <20090827091834.397F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 27 Aug 2009 09:20:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

> On Fri, Aug 21, 2009 at 07:09:17PM +0800, KOSAKI Motohiro wrote:
> > 2009/8/20 Wu Fengguang <fengguang.wu@intel.com>:
> > > shrink_inactive_list() won't be called to scan too much pages
> > > (unless in hibernation code which is fine) or too few pages (ie.
> > > batching is taken care of by the callers). A So we can just remove the
> > > big loop and isolate the exact number of pages requested.
> > >
> > > Just a RFC, and a scratch patch to show the basic idea.
> > > Please kindly NAK quick if you don't like it ;)
> > 
> > Hm, I think this patch taks only cleanups. right?
> > if so, I don't find any objection reason.
> 
> Mostly cleanups, but one behavior change here: 
> 
> > > - A  A  A  A  A  A  A  nr_taken = sc->isolate_pages(sc->swap_cluster_max,
> > > + A  A  A  A  A  A  A  nr_taken = sc->isolate_pages(nr_to_scan,
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  &page_list, &nr_scan, sc->order, mode,
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A zone, sc->mem_cgroup, 0, file);
> 
> The new behavior is to scan exactly the number of pages that
> shrink_zone() or other callers tell it. It won't try to "round it up"
> to 32 pages. This new behavior is in line with shrink_active_list()'s
> current status as well as shrink_zone()'s expectation.
> 
> shrink_zone() may still submit scan requests for <32 pages, which is
> suboptimal. I'll try to eliminate that totally with more patches.

Your explanation seems makes sense.
I'll wait your next spin :)





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
