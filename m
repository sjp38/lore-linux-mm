Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AC2386B0071
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 21:59:02 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5B1x0uB004413
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 11 Jun 2010 10:59:00 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D23CD45DE60
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 10:58:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B2F3245DE4D
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 10:58:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9883B1DB8041
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 10:58:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 42FA31DB803E
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 10:58:59 +0900 (JST)
Date: Fri, 11 Jun 2010 10:54:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page
 cache control
Message-Id: <20100611105441.ee657515.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1276214852.6437.1427.camel@nimitz>
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
	<20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>
	<4C10B3AF.7020908@redhat.com>
	<20100610142512.GB5191@balbir.in.ibm.com>
	<1276214852.6437.1427.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: balbir@linux.vnet.ibm.com, Avi Kivity <avi@redhat.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jun 2010 17:07:32 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Thu, 2010-06-10 at 19:55 +0530, Balbir Singh wrote:
> > > I'm not sure victimizing unmapped cache pages is a good idea.
> > > Shouldn't page selection use the LRU for recency information instead
> > > of the cost of guest reclaim?  Dropping a frequently used unmapped
> > > cache page can be more expensive than dropping an unused text page
> > > that was loaded as part of some executable's initialization and
> > > forgotten.
> > 
> > We victimize the unmapped cache only if it is unused (in LRU order).
> > We don't force the issue too much. We also have free slab cache to go
> > after.
> 
> Just to be clear, let's say we have a mapped page (say of /sbin/init)
> that's been unreferenced since _just_ after the system booted.  We also
> have an unmapped page cache page of a file often used at runtime, say
> one from /etc/resolv.conf or /etc/passwd.
> 

Hmm. I'm not fan of estimating working set size by calculation
based on some numbers without considering history or feedback.

Can't we use some kind of feedback algorithm as hi-low-watermark, random walk
or GA (or somehing more smart) to detect the size ?

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
