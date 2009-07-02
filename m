Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 837046B004D
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 02:41:47 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n626iFBJ031150
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 2 Jul 2009 15:44:15 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F404545DE61
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 15:44:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BCB8645DE4F
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 15:44:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BBE11DB8041
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 15:44:14 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F383AE08003
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 15:44:13 +0900 (JST)
Date: Thu, 2 Jul 2009 15:42:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] ZERO PAGE again
Message-Id: <20090702154234.d7ee06a4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4A4B8486.3020307@redhat.com>
References: <20090701185759.18634360.kamezawa.hiroyu@jp.fujitsu.com>
	<4A4B8486.3020307@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Wed, 01 Jul 2009 18:45:10 +0300
Avi Kivity <avi@redhat.com> wrote:

> On 07/01/2009 12:57 PM, KAMEZAWA Hiroyuki wrote:
> > ZERO PAGE was removed in 2.6.24 (=>  http://lkml.org/lkml/2007/10/9/112)
> > and I had no objections.
> >
> > In these days, at user support jobs, I noticed a few of customers
> > are making use of ZERO_PAGE intentionally...brutal mmap and scan, etc. They are
> > using RHEL4-5(before 2.6.18) then they don't notice that ZERO_PAGE
> > is gone, yet.
> > yes, I can say  "ZERO PAGE is gone" to them in next generation distro.
> >
> > Recently, a question comes to lkml (http://lkml.org/lkml/2009/6/4/383
> >
> > Maybe there are some users of ZERO_PAGE other than my customers.
> > So, can't we use ZERO_PAGE again ?
> >
> > IIUC, the problem of ZERO_PAGE was
> >    - reference count cache ping-pong
> >    - complicated handling.
> >    - the behavior page-fault-twice can make applications slow.
> >
> > This patch is a trial to de-refcounted ZERO_PAGE.
> > Any comments are welcome. I'm sorry for digging grave...
> >    
> 
> kvm could use this.  There's a fairly involved scenario where the lack 
> of zero page hits us:
> 
> - a guest is started
> - either it doesn't touch all of its memory, or it balloons some of its 
> memory away, so its resident set size is smaller than the total amount 
> of memory it has
> - the guest is live migrated to another host; this involves reading all 
> of the guest memory
> 
> If we don't have zero page, all of the not-present pages are faulted in 
> and the resident set size increases; this increases memory pressure, 
> which is what we're trying to avoid (one of the reasons to live migrate 
> is to free memory).
> 

Thank you. I'll make this patch cleaner and fix my English, then post again.
maybe in the next week.

A case I met was the application level migration. An application save its
sparse table by scan-and-dump. To know "all memory contents are zero",
it had to read memory, at least.

Regards,
-Kame




> -- 
> error compiling committee.c: too many arguments to function
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
