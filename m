Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7A86B007B
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 16:11:48 -0500 (EST)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id o0TLBdeT032361
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 21:11:39 GMT
Received: from pxi31 (pxi31.prod.google.com [10.243.27.31])
	by spaceape10.eur.corp.google.com with ESMTP id o0TLBZZZ028627
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 13:11:38 -0800
Received: by pxi31 with SMTP id 31so620837pxi.6
        for <linux-mm@kvack.org>; Fri, 29 Jan 2010 13:11:37 -0800 (PST)
Date: Fri, 29 Jan 2010 13:11:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
In-Reply-To: <c6c48fdf7f746add49bb9cc058b513ae.squirrel@webmail-b.css.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1001291307460.2938@chino.kir.corp.google.com>
References: <f8c9aca9c98db8ae7df3ac2d7ac8d922.squirrel@webmail-b.css.fujitsu.com> <20100129162137.79b2a6d4@lxorguk.ukuu.org.uk> <c6c48fdf7f746add49bb9cc058b513ae.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, vedran.furac@gmail.com, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sat, 30 Jan 2010, KAMEZAWA Hiroyuki wrote:

> If so, all heuristics other than vm_size should be purged, I think.

I don't recall anybody disagreeing about removing some of the current 
heuristics, but there is value to those beyond simply total_vm: we want to 
penalize tasks that do not share any mems_allowed with the triggering 
task, for example, otherwise it can lead to needless oom killing.  Many 
people believe we should keep the slight penalty for superuser tasks over 
regular user tasks, as well.

Auditing the badness() function is a worthwhile endeavor and I think you'd 
be most successful if you tweaked the various penalties (runtime, nice, 
capabilities, etc) to reflect how much each is valued in terms of VM size, 
the baseline.  I doubt anybody would defend simply dividing by 4 or 
multiplying by 2 being scientific.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
