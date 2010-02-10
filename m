Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 776826B0083
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 17:38:34 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o1AMVpxA005141
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 14:31:51 -0800
Received: from pxi40 (pxi40.prod.google.com [10.243.27.40])
	by wpaz37.hot.corp.google.com with ESMTP id o1AMVVom016862
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 14:31:50 -0800
Received: by pxi40 with SMTP id 40so15644pxi.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2010 14:31:49 -0800 (PST)
Date: Wed, 10 Feb 2010 14:31:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Improving OOM killer
In-Reply-To: <20100210221847.5d7bb3cb@lxorguk.ukuu.org.uk>
Message-ID: <alpine.DEB.2.00.1002101427490.29718@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz> <4B6B4500.3010603@redhat.com> <alpine.DEB.2.00.1002041410300.16391@chino.kir.corp.google.com> <201002102154.43231.l.lunak@suse.cz> <4B7320BF.2020800@redhat.com> <20100210221847.5d7bb3cb@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@redhat.com>, Lubos Lunak <l.lunak@suse.cz>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Feb 2010, Alan Cox wrote:

> One of the problems with picking on tasks that fork a lot is that
> describes apache perfectly. So a high loaded apache will get shot over a
> rapid memory eating cgi script.
> 

With my rewrite, the oom killer would not select apache but rather the 
child with a seperate address space that is consuming the most amount of 
allowed memory and only when a configurable number of such children (1000 
by default) have not had any runtime.  My heuristic is only meant to 
slightly penalize such tasks so that they can be distinguished from oom 
kill from other parents with comparable memory usage.  Enforcing a strict 
forkbomb policy is out of the scope of the oom killer, though, so no 
attempt was made.

> Any heuristic is going to be iffy - but that isn't IMHO a good one to
> work from. If anything "who allocated lots of RAM recently" may be a
> better guide but we don't keep stats for that.
> 

That's what my heuristic basically does, if a parent is identified as a 
forkbomb, then it is only penalized by averaging the memory consumption of 
those children and then multiplying it by the same number of times the 
configurable forkbomb threshold was reached.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
