Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F04D76B01E5
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 13:58:45 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5EHm36W031297
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 11:48:03 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5EHwNSl068630
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 11:58:24 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5EHwEhP015979
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 11:58:14 -0600
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page
 cache control
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C1659F8.3090300@redhat.com>
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
	 <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>
	 <4C10B3AF.7020908@redhat.com> <20100610142512.GB5191@balbir.in.ibm.com>
	 <1276214852.6437.1427.camel@nimitz>
	 <20100611045600.GE5191@balbir.in.ibm.com> <4C15E3C8.20407@redhat.com>
	 <20100614084810.GT5191@balbir.in.ibm.com> <4C16233C.1040108@redhat.com>
	 <20100614125010.GU5191@balbir.in.ibm.com> <4C162846.7030303@redhat.com>
	 <1276529596.6437.7216.camel@nimitz> <4C164E63.2020204@redhat.com>
	 <1276530932.6437.7259.camel@nimitz>  <4C1659F8.3090300@redhat.com>
Content-Type: text/plain
Date: Mon, 14 Jun 2010 10:58:13 -0700
Message-Id: <1276538293.6437.7528.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: balbir@linux.vnet.ibm.com, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-14 at 19:34 +0300, Avi Kivity wrote:
> > Again, this is useless when ballooning is being used.  But, I'm thinking
> > of a more general mechanism to force the system to both have MemFree
> > _and_ be acting as if it is under memory pressure.
> >    
> 
> If there is no memory pressure on the host, there is no reason for the 
> guest to pretend it is under pressure.

I can think of quite a few places where this would be beneficial.

Ballooning is dangerous.  I've OOMed quite a few guests by
over-ballooning them.  Anything that's voluntary like this is safer than
things imposed by the host, although you do trade of effectiveness.

If all the guests do this, then it leaves that much more free memory on
the host, which can be used flexibly for extra host page cache, new
guests, etc...  A system in this state where everyone is proactively
keeping their footprints down is more likely to be able to handle load
spikes.  Reclaim is an expensive, costly activity, and this ensures that
we don't have to do that when we're busy doing other things like
handling load spikes.  This was one of the concepts behind CMM2: reduce
the overhead during peak periods.

It's also handy for planning.  Guests exhibiting this behavior will
_act_ as if they're under pressure.  That's a good thing to approximate
how a guest will act when it _is_ under pressure.

> If there is memory pressure on 
> the host, it should share the pain among its guests by applying the 
> balloon.  So I don't think voluntarily dropping cache is a good direction.

I think we're trying to consider things slightly outside of ballooning
at this point.  If ballooning was the end-all solution, I'm fairly sure
Balbir wouldn't be looking at this stuff.  Just trying to keep options
open. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
