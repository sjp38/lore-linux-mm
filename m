Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A897F6B0055
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 23:43:16 -0400 (EDT)
Date: Wed, 24 Jun 2009 20:44:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] Reduce the resource counter lock overhead
Message-Id: <20090624204426.3dc9e108.akpm@linux-foundation.org>
In-Reply-To: <20090625032717.GX8642@balbir.in.ibm.com>
References: <20090624170516.GT8642@balbir.in.ibm.com>
	<20090624161028.b165a61a.akpm@linux-foundation.org>
	<20090625085347.a64654a7.kamezawa.hiroyu@jp.fujitsu.com>
	<20090625032717.GX8642@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, menage@google.com, xemul@openvz.org, linux-mm@kvack.org, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jun 2009 08:57:17 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> We do a read everytime before we charge.

See, a good way to fix that is to not do it.  Instead of

	if (under_limit())
		charge_some_more(amount);
	else
		goto fail;

one can do 

	if (try_to_charge_some_more(amount) < 0)
		goto fail;

which will halve the locking frequency.  Which may not be as beneficial
as avoiding the locking altogether on the read side, dunno.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
