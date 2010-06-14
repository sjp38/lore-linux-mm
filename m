Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 836F76B0217
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 11:55:42 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5EFcfVl010713
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 11:38:41 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5EFtYZF1458376
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 11:55:34 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5EFtYYL012576
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 12:55:34 -0300
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page
 cache control
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C164E63.2020204@redhat.com>
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
	 <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>
	 <4C10B3AF.7020908@redhat.com> <20100610142512.GB5191@balbir.in.ibm.com>
	 <1276214852.6437.1427.camel@nimitz>
	 <20100611045600.GE5191@balbir.in.ibm.com> <4C15E3C8.20407@redhat.com>
	 <20100614084810.GT5191@balbir.in.ibm.com> <4C16233C.1040108@redhat.com>
	 <20100614125010.GU5191@balbir.in.ibm.com> <4C162846.7030303@redhat.com>
	 <1276529596.6437.7216.camel@nimitz>  <4C164E63.2020204@redhat.com>
Content-Type: text/plain
Date: Mon, 14 Jun 2010 08:55:32 -0700
Message-Id: <1276530932.6437.7259.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: balbir@linux.vnet.ibm.com, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-14 at 18:44 +0300, Avi Kivity wrote:
> On 06/14/2010 06:33 PM, Dave Hansen wrote:
> > At the same time, I see what you're trying to do with this.  It really
> > can be an alternative to ballooning if we do it right, since ballooning
> > would probably evict similar pages.  Although it would only work in idle
> > guests, what about a knob that the host can turn to just get the guest
> > to start running reclaim?
> 
> Isn't the knob in this proposal the balloon?  AFAICT, the idea here is 
> to change how the guest reacts to being ballooned, but the trigger 
> itself would not change.

I think the patch was made on the following assumptions:
1. Guests will keep filling their memory with relatively worthless page
   cache that they don't really need.
2. When they do this, it hurts the overall system with no real gain for
   anyone.

In the case of a ballooned guest, they _won't_ keep filling memory.  The
balloon will prevent them.  So, I guess I was just going down the path
of considering if this would be useful without ballooning in place.  To
me, it's really hard to justify _with_ ballooning in place.

> My issue is that changing the type of object being preferentially 
> reclaimed just changes the type of workload that would prematurely 
> suffer from reclaim.  In this case, workloads that use a lot of unmapped 
> pagecache would suffer.
> 
> btw, aren't /proc/sys/vm/swapiness and vfs_cache_pressure similar knobs?

Those tell you how to balance going after the different classes of
things that we can reclaim.

Again, this is useless when ballooning is being used.  But, I'm thinking
of a more general mechanism to force the system to both have MemFree
_and_ be acting as if it is under memory pressure.

Balbir, can you elaborate a bit on why you would need these patches on a
guest that is being ballooned?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
