Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AC2CF6B006A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 00:27:53 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o974RoIh001320
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Oct 2010 13:27:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C57B945DE4F
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 13:27:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D0F145DE4E
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 13:27:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 82E941DB8053
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 13:27:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C7451DB8054
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 13:27:50 +0900 (JST)
Date: Thu, 7 Oct 2010 13:22:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Restrict size of page_cgroup->flags
Message-Id: <20101007132233.f695aa2c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101007035608.GN4195@balbir.in.ibm.com>
References: <20101006142314.GG4195@balbir.in.ibm.com>
	<20101007085858.0e07de59.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007031203.GK4195@balbir.in.ibm.com>
	<20101007121816.bbd009c1.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007035608.GN4195@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, containers@lists.linux-foundation.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Oct 2010 09:26:08 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-10-07 12:18:16]:
> 
> > On Thu, 7 Oct 2010 08:42:04 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-10-07 08:58:58]:
> > > 
> > > > On Wed, 6 Oct 2010 19:53:14 +0530
> > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > 
> > > > > I propose restricting page_cgroup.flags to 16 bits. The patch for the
> > > > > same is below. Comments?
> > > > > 
> > > > > 
> > > > > Restrict the bits usage in page_cgroup.flags
> > > > > 
> > > > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > > > 
> > > > > Restricting the flags helps control growth of the flags unbound.
> > > > > Restriciting it to 16 bits gives us the possibility of merging
> > > > > cgroup id with flags (atomicity permitting) and saving a whole
> > > > > long word in page_cgroup
> > > > > 
> > > > > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > > 
> > > > Doesn't make sense until you show the usage of existing bits.
> > > 
> > > ??
> > > 
> > Limiting something for NOT EXISTING PATCH doesn't make sense, in general.
> > 
> > 
> > > > And I guess 16bit may be too large on 32bit systems.
> > > 
> > > too large on 32 bit systems? My intention is to keep the flags to 16
> > > bits and then use cgroup id for the rest and see if we can remove
> > > mem_cgroup pointer
> > > 
> > 
> > You can't use flags field to store mem_cgroup_id while we use lock bit on it.
> > We have to store something more stable...as pfn or node-id or zone-id.
> > 
> > It's very racy. 
> >
> 
> Yes, correct it is racy, there is no easy way from what I know we can write
> the upper 16 bits of the flag without affecting the lower 16 bits, if
> the 16 bits are changing. One of the techniques could be to have lock
> for the unsigned long word itself - but I don't know what performance
> overhead that would add. Having said that I would like to explore
> techniques that allow me to merge the two.
> 

to store pfn, we need to limit under 12bit.
I'll schedule my patch if dirty_ratio one goes.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
