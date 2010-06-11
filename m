Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DD5316B0071
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 01:03:14 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5B51fgY010685
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 01:01:41 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5B53DM4124996
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 01:03:13 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5B53Dhx007276
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 02:03:13 -0300
Date: Fri, 11 Jun 2010 10:26:00 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
Message-ID: <20100611045600.GE5191@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
 <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>
 <4C10B3AF.7020908@redhat.com>
 <20100610142512.GB5191@balbir.in.ibm.com>
 <1276214852.6437.1427.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1276214852.6437.1427.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Avi Kivity <avi@redhat.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Dave Hansen <dave@linux.vnet.ibm.com> [2010-06-10 17:07:32]:

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
> Which page will be preferred for eviction with this patch set?
>

In this case the order is as follows

1. First we pick free pages if any
2. If we don't have free pages, we go after unmapped page cache and
slab cache
3. If that fails as well, we go after regularly memory

In the scenario that you describe, we'll not be able to easily free up
the frequently referenced page from /etc/*. The code will move on to
step 3 and do its regular reclaim. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
