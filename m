Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 142FF8D0001
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 22:24:00 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oAQ3753V001255
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 22:07:05 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id EDED14DE803D
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 22:22:30 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAQ3NvIC348662
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 22:23:57 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAQ3NvdM013263
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 01:23:57 -0200
Date: Fri, 26 Nov 2010 08:53:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] [BUG] memcg: fix false positive VM_BUG on non-SMP
Message-ID: <20101126032355.GG3298@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1290520130-9990-1-git-send-email-kirill@shutemov.name>
 <20101123121606.c07197e5.akpm@linux-foundation.org>
 <20101123210255.GA22484@cmpxchg.org>
 <20101123142247.e8566e3e.akpm@linux-foundation.org>
 <20101123225244.GB22484@cmpxchg.org>
 <20101124092337.b9fe888f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101124092337.b9fe888f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutsemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-11-24 09:23:37]:

> On Tue, 23 Nov 2010 23:52:44 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Tue, Nov 23, 2010 at 02:22:47PM -0800, Andrew Morton wrote:
> > > On Tue, 23 Nov 2010 22:02:55 +0100
> > > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > 
> > > > On Tue, Nov 23, 2010 at 12:16:06PM -0800, Andrew Morton wrote:
> > > > > On Tue, 23 Nov 2010 15:48:50 +0200
> > > > > "Kirill A. Shutsemov" <kirill@shutemov.name> wrote:
> > > > > 
> > > > > > ------------[ cut here ]------------
> > > > > > kernel BUG at mm/memcontrol.c:2155!
> > > > > 
> > > > > This bug has been there for a year, from which I conclude people don't
> > > > > run memcg on uniprocessor machines a lot.
> > > > > 
> > > > > Which is a bit sad, really.  Small machines need resource control too,
> > > > > perhaps more than large ones..
> > > > 
> > > > Admittedly, this patch is compile-tested on UP only, but it should be
> > > > obvious enough.
> > > > 
> > > > ---
> > > > From: Johannes Weiner <hannes@cmpxchg.org>
> > > > Subject: [patch] memcg: fix page cgroup lock assert on UP
> > > > 
> > > > Page cgroup locking primitives use the bit spinlock API functions,
> > > > which do nothing on UP.
> > > > 
> > > > Thus, checking the lock state can not be done by looking at the bit
> > > > directly, but one has to go through the bit spinlock API as well.
> > > > 
> > > > This fixes a guaranteed UP bug, where asserting the page cgroup lock
> > > > bit as a sanity check crashes the kernel.
> > > > 
> > > 
> > > hm, your patch is the same as Kirill's, except you named it
> > > page_is_cgroup_locked() rather than is_page_cgroup_locked().  I guess
> > > page_is_cgroup_locked() is a bit better.
> > 
> > I had not sorted by threads and somehow assumed this was another
> > forward from you of a bugzilla report or something.  I didn't see
> > Kirill's patch until now.  Sorry!
> > 
> > Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>
>

Great catch! Thanks

 
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
