Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2B26B0022
	for <linux-mm@kvack.org>; Fri, 20 May 2011 03:50:50 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2C8843EE0C0
	for <linux-mm@kvack.org>; Fri, 20 May 2011 16:50:45 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1413A45DE95
	for <linux-mm@kvack.org>; Fri, 20 May 2011 16:50:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E48B145DE91
	for <linux-mm@kvack.org>; Fri, 20 May 2011 16:50:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D5AD8E18003
	for <linux-mm@kvack.org>; Fri, 20 May 2011 16:50:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 94B9EE08001
	for <linux-mm@kvack.org>; Fri, 20 May 2011 16:50:44 +0900 (JST)
Date: Fri, 20 May 2011 16:43:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking
 vmlinux)
Message-Id: <20110520164354.d43be406.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTinJbYrQoye7qjPzPxP8_deCSK0g7w@mail.gmail.com>
References: <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
	<20110514165346.GV6008@one.firstfloor.org>
	<BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
	<20110514174333.GW6008@one.firstfloor.org>
	<BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
	<20110515152747.GA25905@localhost>
	<BANLkTim-AnEeL=z1sYm=iN7sMnG0+m0SHw@mail.gmail.com>
	<20110517060001.GC24069@localhost>
	<BANLkTi=TOm3aLQCD6j=4va6B+Jn2nSfwAg@mail.gmail.com>
	<BANLkTi=9W6-JXi94rZfTtTpAt3VUiY5fNw@mail.gmail.com>
	<BANLkTikHMUru=w4zzRmosrg2bDbsFWrkTQ@mail.gmail.com>
	<BANLkTima0hPrPwe_x06afAh+zTi-bOcRMg@mail.gmail.com>
	<BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
	<BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com>
	<4DD5DC06.6010204@jp.fujitsu.com>
	<BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com>
	<BANLkTins7qxWVh0bEwtk1Vx+m98N=oYVtw@mail.gmail.com>
	<20110520140856.fdf4d1c8.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinJbYrQoye7qjPzPxP8_deCSK0g7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

On Fri, 20 May 2011 14:36:13 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, May 20, 2011 at 2:08 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 20 May 2011 13:20:15 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> So I want to resolve your problem asap.
> >> We don't have see report about that. Could you do git-bisect?
> >> FYI, Recently, big change of mm is compaction,transparent huge pages.
> >> Kame, could you point out thing related to memcg if you have a mind?
> >>
> >
> > I don't doubt memcg at this stage because it never modify page->flags.
> > Consdering the case, PageActive() is set against off-LRU pages after
> > clear_active_flags() clears it.
> >
> > Hmm, I think I don't understand the lock system fully but...how do you
> > think this ?
> >
> > ==
> >
> > At splitting a hugepage, the routine marks all pmd as "splitting".
> >
> > But assume a racy case where 2 threads run into spit at the
> > same time, one thread wins compound_lock() and do split, another
> > thread should not touch splitted pages.
> 
> Sorry. Now I don't have a time to review in detail.
> When I look it roughly,  page_lock_anon_vma have to prevent it.
> But Andrea needs current this problem and he will catch something we lost. :)
> 
Hmm, maybe I miss something...need to build a test environ on my side.
But I'm not sure I can reproduce it..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
