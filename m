Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 820106B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 20:17:28 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8G0HOXD031708
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 16 Sep 2010 09:17:25 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8355345DE55
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 09:17:24 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 531C345DE52
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 09:17:24 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 293F01DB8043
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 09:17:24 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C89311DB803C
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 09:17:23 +0900 (JST)
Date: Thu, 16 Sep 2010 09:12:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] update /proc/sys/vm/drop_caches documentation
Message-Id: <20100916091215.ef59acd7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100915192454.GD5585@tpepper-t61p.dolavim.us>
References: <20100914234714.8AF506EA@kernel.beaverton.ibm.com>
	<20100915133303.0b232671.kamezawa.hiroyu@jp.fujitsu.com>
	<20100915192454.GD5585@tpepper-t61p.dolavim.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Tim Pepper <lnxninja@linux.vnet.ibm.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Sep 2010 12:24:55 -0700
"Tim Pepper" <lnxninja@linux.vnet.ibm.com> wrote:

> On Wed 15 Sep at 13:33:03 +0900 kamezawa.hiroyu@jp.fujitsu.com said:
> > >  
> > > diff -puN fs/drop_caches.c~update-drop_caches-documentation fs/drop_caches.c
> > > --- linux-2.6.git/fs/drop_caches.c~update-drop_caches-documentation	2010-09-14 15:44:29.000000000 -0700
> > > +++ linux-2.6.git-dave/fs/drop_caches.c	2010-09-14 15:58:31.000000000 -0700
> > > @@ -47,6 +47,8 @@ int drop_caches_sysctl_handler(ctl_table
> > >  {
> > >  	proc_dointvec_minmax(table, write, buffer, length, ppos);
> > >  	if (write) {
> > > +		WARN_ONCE(1, "kernel caches forcefully dropped, "
> > > +			     "see Documentation/sysctl/vm.txt\n");
> > 
> > Documentation updeta seems good but showing warning seems to be meddling to me.
> 
> We already have examples of things where we warn in order to turn up
> "interesting" userspace code, in the hope of starting dialog and getting
> things fixed for the future.  I don't see this so much as meddling as
> one of the fundamental aspects of open source.
> 
> drop_caches probably originally should have gone in under a CONFIG_DEBUG
> (even if all the distros would have turned it on), and had a WARN_ON
> (personally I'd argue for this compared to WARN_ONCE()), and even have
> been exposed in debugfs not procfs...but it's part of the "the interface"
> at this point.
> 
> Somebody doing debug and testing which leverages drop_caches should not
> be bothered by a WARN_ON().  Somebody using it to "fix" the kernel with
> repeated/regular calls to drop_caches should get called out for fixing
> themselves and the WARN_*()'s noting the comm could help that, unless
> somebody has a use case where repeated/regular calls to drop_caches
> is valid and not connected to buggy usage or explicit performance
> debug/testing?
> 

I hear a customer's case. His server generates 3-80000+ new dentries per day
and dentries will be piled up to 1000000+ in a month. This makes open()'s 
performance very bad because Hash-lookup will be heavy. (He has very big memory.)

What we could ask him was
  - rewrite your application. or
  - reboot once in a month (and change hash size) or
  - drop_cache once in a month

Because their servers cannot stop, he used drop_caches once in a month
while his server is idle, at night. Changing HashSize cannot be a permanent
fix because he may not stop the server for years.

For rare users who have 10000000+ of files and tons of free memory, drop_cache
can be an emergency help. 

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
