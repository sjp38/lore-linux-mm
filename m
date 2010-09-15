Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 702356B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 15:24:59 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8FJHKQg027035
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:17:20 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o8FJOv2e256570
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:24:57 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8FJOvwe003228
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:24:57 -0600
From: "Tim Pepper" <lnxninja@linux.vnet.ibm.com>
Date: Wed, 15 Sep 2010 12:24:55 -0700
Subject: Re: [RFC][PATCH] update /proc/sys/vm/drop_caches documentation
Message-ID: <20100915192454.GD5585@tpepper-t61p.dolavim.us>
References: <20100914234714.8AF506EA@kernel.beaverton.ibm.com>
 <20100915133303.0b232671.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100915133303.0b232671.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lnxninja@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed 15 Sep at 13:33:03 +0900 kamezawa.hiroyu@jp.fujitsu.com said:
> >  
> > diff -puN fs/drop_caches.c~update-drop_caches-documentation fs/drop_caches.c
> > --- linux-2.6.git/fs/drop_caches.c~update-drop_caches-documentation	2010-09-14 15:44:29.000000000 -0700
> > +++ linux-2.6.git-dave/fs/drop_caches.c	2010-09-14 15:58:31.000000000 -0700
> > @@ -47,6 +47,8 @@ int drop_caches_sysctl_handler(ctl_table
> >  {
> >  	proc_dointvec_minmax(table, write, buffer, length, ppos);
> >  	if (write) {
> > +		WARN_ONCE(1, "kernel caches forcefully dropped, "
> > +			     "see Documentation/sysctl/vm.txt\n");
> 
> Documentation updeta seems good but showing warning seems to be meddling to me.

We already have examples of things where we warn in order to turn up
"interesting" userspace code, in the hope of starting dialog and getting
things fixed for the future.  I don't see this so much as meddling as
one of the fundamental aspects of open source.

drop_caches probably originally should have gone in under a CONFIG_DEBUG
(even if all the distros would have turned it on), and had a WARN_ON
(personally I'd argue for this compared to WARN_ONCE()), and even have
been exposed in debugfs not procfs...but it's part of the "the interface"
at this point.

Somebody doing debug and testing which leverages drop_caches should not
be bothered by a WARN_ON().  Somebody using it to "fix" the kernel with
repeated/regular calls to drop_caches should get called out for fixing
themselves and the WARN_*()'s noting the comm could help that, unless
somebody has a use case where repeated/regular calls to drop_caches
is valid and not connected to buggy usage or explicit performance
debug/testing?

-- 
Tim Pepper  <lnxninja@linux.vnet.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
