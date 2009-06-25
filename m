Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 82E796B007E
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 00:39:28 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5P4efXx012651
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 25 Jun 2009 13:40:41 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B7EB845DE4F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 13:40:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9818845DD72
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 13:40:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8564EE08002
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 13:40:41 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 42A621DB8037
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 13:40:41 +0900 (JST)
Date: Thu, 25 Jun 2009 13:39:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Reduce the resource counter lock overhead
Message-Id: <20090625133908.6ae3dd40.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090624204426.3dc9e108.akpm@linux-foundation.org>
References: <20090624170516.GT8642@balbir.in.ibm.com>
	<20090624161028.b165a61a.akpm@linux-foundation.org>
	<20090625085347.a64654a7.kamezawa.hiroyu@jp.fujitsu.com>
	<20090625032717.GX8642@balbir.in.ibm.com>
	<20090624204426.3dc9e108.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, menage@google.com, xemul@openvz.org, linux-mm@kvack.org, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jun 2009 20:44:26 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 25 Jun 2009 08:57:17 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > We do a read everytime before we charge.
> 
> See, a good way to fix that is to not do it.  Instead of
> 
> 	if (under_limit())
> 		charge_some_more(amount);
> 	else
> 		goto fail;
> 
> one can do 
> 
> 	if (try_to_charge_some_more(amount) < 0)
> 		goto fail;
> 
> which will halve the locking frequency.  Which may not be as beneficial
> as avoiding the locking altogether on the read side, dunno.
> 
I don't think we do read-before-write ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
