Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2587A6B007E
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 10:09:33 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AC28782C374
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 10:10:29 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qD3nOOBkvLnP for <linux-mm@kvack.org>;
	Wed,  9 Sep 2009 10:10:29 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E64D882C38B
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 10:10:24 -0400 (EDT)
Date: Wed, 9 Sep 2009 10:08:23 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [rfc] lru_add_drain_all() vs isolation
In-Reply-To: <20090909131945.0CF5.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0909091005010.28070@V090114053VZO-1>
References: <alpine.DEB.1.10.0909081110450.30203@V090114053VZO-1> <alpine.DEB.1.10.0909081124240.30203@V090114053VZO-1> <20090909131945.0CF5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 9 Sep 2009, KOSAKI Motohiro wrote:

> Christoph, I'd like to discuss a bit related (and almost unrelated) thing.
> I think page migration don't need lru_add_drain_all() as synchronous, because
> page migration have 10 times retry.

True this is only an optimization that increases the chance of isolation
being successful. You dont need draining at all.

> Then asynchronous lru_add_drain_all() cause
>
>   - if system isn't under heavy pressure, retry succussfull.
>   - if system is under heavy pressure or RT-thread work busy busy loop, retry failure.
>
> I don't think this is problematic bahavior. Also, mlock can use asynchrounous lru drain.
>
> What do you think?

The retries can be very fast if the migrate pages list is small. The
migrate attempts may be finished before the IPI can be processed by the
other cpus.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
