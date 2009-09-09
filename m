Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BA7B06B007E
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 00:27:14 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n894RL38010858
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 9 Sep 2009 13:27:21 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D18745DE51
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 13:27:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3420345DE52
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 13:27:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E9F31E08005
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 13:27:19 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FE28E08010
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 13:27:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [rfc] lru_add_drain_all() vs isolation
In-Reply-To: <alpine.DEB.1.10.0909081124240.30203@V090114053VZO-1>
References: <alpine.DEB.1.10.0909081110450.30203@V090114053VZO-1> <alpine.DEB.1.10.0909081124240.30203@V090114053VZO-1>
Message-Id: <20090909131945.0CF5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  9 Sep 2009 13:27:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> The usefulness of a scheme like this requires:
> 
> 1. There are cpus that continually execute user space code
>    without system interaction.
> 
> 2. There are repeated VM activities that require page isolation /
>    migration.
> 
> The first page isolation activity will then clear the lru caches of the
> processes doing number crunching in user space (and therefore the first
> isolation will still interrupt). The second and following isolation will
> then no longer interrupt the processes.
> 
> 2. is rare. So the question is if the additional code in the LRU handling
> can be justified. If lru handling is not time sensitive then yes.

Christoph, I'd like to discuss a bit related (and almost unrelated) thing.
I think page migration don't need lru_add_drain_all() as synchronous, because
page migration have 10 times retry.

Then asynchronous lru_add_drain_all() cause

  - if system isn't under heavy pressure, retry succussfull.
  - if system is under heavy pressure or RT-thread work busy busy loop, retry failure.

I don't think this is problematic bahavior. Also, mlock can use asynchrounous lru drain.

What do you think?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
