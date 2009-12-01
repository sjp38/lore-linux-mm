Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4505F600309
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 02:36:41 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp04.au.ibm.com (8.14.3/8.13.1) with ESMTP id nB17XNnP006614
	for <linux-mm@kvack.org>; Tue, 1 Dec 2009 18:33:23 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nB17X2Qn1450232
	for <linux-mm@kvack.org>; Tue, 1 Dec 2009 18:33:02 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB17aaOT030513
	for <linux-mm@kvack.org>; Tue, 1 Dec 2009 18:36:36 +1100
Date: Tue, 1 Dec 2009 13:06:09 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: memcg: slab control
Message-ID: <20091201073609.GQ2970@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
 <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>
 <20091126085031.GG2970@balbir.in.ibm.com>
 <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com>
 <4B0E461C.50606@parallels.com>
 <20091126183335.7a18cb09.kamezawa.hiroyu@jp.fujitsu.com>
 <4B0E50B1.20602@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4B0E50B1.20602@parallels.com>
Sender: owner-linux-mm@kvack.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Suleiman Souhlal <suleiman@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Pavel Emelyanov <xemul@parallels.com> [2009-11-26 12:56:01]:

> KAMEZAWA Hiroyuki wrote:
> > On Thu, 26 Nov 2009 12:10:52 +0300
> > Pavel Emelyanov <xemul@parallels.com> wrote:
> > 
> >>>> Anyway, I agree that we need another
> >>>> slabcg, Pavel did some work in that area and posted patches, but they
> >>>> were mostly based and limited to SLUB (IIRC).
> >> I'm ready to resurrect the patches and port them for slab.
> >> But before doing it we should answer one question.
> >>
> >> Consider we have two kmalloc-s in a kernel code - one is
> >> user-space triggerable and the other one is not. From my
> >> POV we should account for the former one, but should not
> >> for the latter.
> >>
> >> If so - how should we patch the kernel to achieve that goal?
> >>
> >>> My point is that most of the kernel codes cannot work well when kmalloc(small area)
> >>> returns NULL.
> >> :) That's not so actually. As our experience shows kernel lives fine
> >> when kmalloc returns NULL (this doesn't include drivers though).
> >>
> > One issue it comes to my mind is that file system can return -EIO because
> > kmalloc() returns NULL. the kernel may work fine but terrible to users ;)
> 
> That relates to my question above - we should not account for all
> kmalloc-s. In particular - we don't account for bio-s and buffer-head-s
> since their amount is not under direct user control. Yes, you can
> request for heavy IO, but first, kernel sends your task to sleep under 
> certain conditions and second, bio-s are destroyed as soon as they are
> finished and thus bio-s and buffer-head-s cannot be used to eat all the
> kernel memory.

Just to understand the context better, is this really a problem. This
can occur when we do really run out of memory. The idea of using
slabcg + memcg together is good, except for our accounting process. I
can repost percpu counter patches that adds fuzziness along with other
tricks that Kame has to do batch accounting, that we will need to
make sure we are able to do with slab allocations as well.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
