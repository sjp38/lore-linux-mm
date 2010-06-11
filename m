Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9CE066B01AC
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 01:10:20 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5B5AIdu017471
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 11 Jun 2010 14:10:18 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C7E045DE50
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 14:10:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9322445DE55
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 14:10:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2ACE71DB8042
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 14:10:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A53711DB8045
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 14:10:16 +0900 (JST)
Date: Fri, 11 Jun 2010 14:05:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page
 cache control
Message-Id: <20100611140553.956f31ab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100611044632.GD5191@balbir.in.ibm.com>
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
	<20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>
	<4C10B3AF.7020908@redhat.com>
	<20100610142512.GB5191@balbir.in.ibm.com>
	<1276214852.6437.1427.camel@nimitz>
	<20100611105441.ee657515.kamezawa.hiroyu@jp.fujitsu.com>
	<20100611044632.GD5191@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Avi Kivity <avi@redhat.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jun 2010 10:16:32 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-11 10:54:41]:
> 
> > On Thu, 10 Jun 2010 17:07:32 -0700
> > Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> > 
> > > On Thu, 2010-06-10 at 19:55 +0530, Balbir Singh wrote:
> > > > > I'm not sure victimizing unmapped cache pages is a good idea.
> > > > > Shouldn't page selection use the LRU for recency information instead
> > > > > of the cost of guest reclaim?  Dropping a frequently used unmapped
> > > > > cache page can be more expensive than dropping an unused text page
> > > > > that was loaded as part of some executable's initialization and
> > > > > forgotten.
> > > > 
> > > > We victimize the unmapped cache only if it is unused (in LRU order).
> > > > We don't force the issue too much. We also have free slab cache to go
> > > > after.
> > > 
> > > Just to be clear, let's say we have a mapped page (say of /sbin/init)
> > > that's been unreferenced since _just_ after the system booted.  We also
> > > have an unmapped page cache page of a file often used at runtime, say
> > > one from /etc/resolv.conf or /etc/passwd.
> > > 
> > 
> > Hmm. I'm not fan of estimating working set size by calculation
> > based on some numbers without considering history or feedback.
> > 
> > Can't we use some kind of feedback algorithm as hi-low-watermark, random walk
> > or GA (or somehing more smart) to detect the size ?
> >
> 
> Could you please clarify at what level you are suggesting size
> detection? I assume it is outside the OS, right? 
> 
"OS" includes kernel and system programs ;)

I can think of both way in kernel and in user approarh and they should be
complement to each other.

An example of kernel-based approach is.
 1. add a shrinker callback(A) for balloon-driver-for-guest as guest kswapd.
 2. add a shrinker callback(B) for balloon-driver-for-host as host kswapd.
(I guess current balloon driver is only for host. Please imagine.)

(A) increases free memory in Guest.
(B) increases free memory in Host.

This is an example of feedback based memory resizing between host and guest.

I think (B) is necessary at least before considering complecated things.

To implement something clever,  (A) and (B) should take into account that
how frequently memory reclaim in guest (which requires some I/O) happens.

If doing outside kernel, I think using memcg is better than depends on
balloon driver. But co-operative balloon and memcg may show us something
good.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
