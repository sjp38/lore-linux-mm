Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 307D96B006A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 01:31:25 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o975OL2E024054
	for <linux-mm@kvack.org>; Thu, 7 Oct 2010 01:24:21 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o975VKrm351528
	for <linux-mm@kvack.org>; Thu, 7 Oct 2010 01:31:20 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o975VKr1031307
	for <linux-mm@kvack.org>; Thu, 7 Oct 2010 01:31:20 -0400
Date: Thu, 7 Oct 2010 11:01:17 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Restrict size of page_cgroup->flags
Message-ID: <20101007053117.GQ4195@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101006142314.GG4195@balbir.in.ibm.com>
 <20101007085858.0e07de59.kamezawa.hiroyu@jp.fujitsu.com>
 <20101007031203.GK4195@balbir.in.ibm.com>
 <20101007121816.bbd009c1.kamezawa.hiroyu@jp.fujitsu.com>
 <20101007035608.GN4195@balbir.in.ibm.com>
 <20101007132233.f695aa2c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101007132233.f695aa2c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, containers@lists.linux-foundation.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-10-07 13:22:33]:

> On Thu, 7 Oct 2010 09:26:08 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-10-07 12:18:16]:
> > 
> > > On Thu, 7 Oct 2010 08:42:04 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-10-07 08:58:58]:
> > > > 
> > > > > On Wed, 6 Oct 2010 19:53:14 +0530
> > > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > > 
> > > > > > I propose restricting page_cgroup.flags to 16 bits. The patch for the
> > > > > > same is below. Comments?
> > > > > > 
> > > > > > 
> > > > > > Restrict the bits usage in page_cgroup.flags
> > > > > > 
> > > > > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > > > > 
> > > > > > Restricting the flags helps control growth of the flags unbound.
> > > > > > Restriciting it to 16 bits gives us the possibility of merging
> > > > > > cgroup id with flags (atomicity permitting) and saving a whole
> > > > > > long word in page_cgroup
> > > > > > 
> > > > > > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > > > 
> > > > > Doesn't make sense until you show the usage of existing bits.
> > > > 
> > > > ??
> > > > 
> > > Limiting something for NOT EXISTING PATCH doesn't make sense, in general.
> > > 
> > > 
> > > > > And I guess 16bit may be too large on 32bit systems.
> > > > 
> > > > too large on 32 bit systems? My intention is to keep the flags to 16
> > > > bits and then use cgroup id for the rest and see if we can remove
> > > > mem_cgroup pointer
> > > > 
> > > 
> > > You can't use flags field to store mem_cgroup_id while we use lock bit on it.
> > > We have to store something more stable...as pfn or node-id or zone-id.
> > > 
> > > It's very racy. 
> > >
> > 
> > Yes, correct it is racy, there is no easy way from what I know we can write
> > the upper 16 bits of the flag without affecting the lower 16 bits, if
> > the 16 bits are changing. One of the techniques could be to have lock
> > for the unsigned long word itself - but I don't know what performance
> > overhead that would add. Having said that I would like to explore
> > techniques that allow me to merge the two.
> > 
> 
> to store pfn, we need to limit under 12bit.
> I'll schedule my patch if dirty_ratio one goes.
>

cool! We'll redo the patch then and lets make this work. We'll need to
see how many bits we need for section/node/zone to do pc_to_pfn() and
pfn_to_page().

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
