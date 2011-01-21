Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 907768D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 02:19:26 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp03.au.ibm.com (8.14.4/8.13.1) with ESMTP id p0L7EoIO016898
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 18:14:50 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0L7JFtC2236418
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 18:19:15 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0L7JEvV021968
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 18:19:14 +1100
Date: Fri, 21 Jan 2011 12:49:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [REPOST] [PATCH 1/3] Move zone_reclaim() outside of
 CONFIG_NUMA (v3)
Message-ID: <20110121071911.GJ2897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110120123039.30481.81151.stgit@localhost6.localdomain6>
 <20110120123608.30481.63446.stgit@localhost6.localdomain6>
 <alpine.DEB.2.00.1101200847350.10695@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1101200847350.10695@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <cl@linux.com> [2011-01-20 08:49:27]:

> On Thu, 20 Jan 2011, Balbir Singh wrote:
> 
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -253,11 +253,11 @@ extern int vm_swappiness;
> >  extern int remove_mapping(struct address_space *mapping, struct page *page);
> >  extern long vm_total_pages;
> >
> > +extern int sysctl_min_unmapped_ratio;
> > +extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
> >  #ifdef CONFIG_NUMA
> >  extern int zone_reclaim_mode;
> > -extern int sysctl_min_unmapped_ratio;
> >  extern int sysctl_min_slab_ratio;
> > -extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
> >  #else
> >  #define zone_reclaim_mode 0
> 
> So the end result of this patch is that zone reclaim is compiled
> into vmscan.o even on !NUMA configurations but since zone_reclaim_mode ==
> 0 noone can ever call that code?
>

The third patch, fixes this with the introduction of a config
(cut-copy-paste below). If someone were to bisect to this point, what
you say is correct.

+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) ||
defined(CONFIG_NUMA)
 extern int sysctl_min_unmapped_ratio;
 extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
-#ifdef CONFIG_NUMA
-extern int zone_reclaim_mode;
-extern int sysctl_min_slab_ratio;
 #else
-#define zone_reclaim_mode 0
 static inline int zone_reclaim(struct zone *z, gfp_t mask, unsigned
int order)
 {
        return 0;
 }
 #endif

Thanks for the review! 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
