Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3BBB36B0047
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 16:39:17 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o14LdBaT028816
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 21:39:13 GMT
Received: from pxi14 (pxi14.prod.google.com [10.243.27.14])
	by kpbe14.cbf.corp.google.com with ESMTP id o14LcYEw026002
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 13:39:10 -0800
Received: by pxi14 with SMTP id 14so3294276pxi.20
        for <linux-mm@kvack.org>; Thu, 04 Feb 2010 13:39:09 -0800 (PST)
Date: Thu, 4 Feb 2010 13:39:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Improving OOM killer
In-Reply-To: <alpine.LNX.2.00.1002041044080.15395@pobox.suse.cz>
Message-ID: <alpine.DEB.2.00.1002041335140.6071@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz> <20100203170127.GH19641@balbir.in.ibm.com> <alpine.DEB.2.00.1002031021190.14088@chino.kir.corp.google.com> <201002032355.01260.l.lunak@suse.cz> <alpine.DEB.2.00.1002031600490.27918@chino.kir.corp.google.com>
 <alpine.LNX.2.00.1002041044080.15395@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jiri Kosina <jkosina@suse.cz>
Cc: Lubos Lunak <l.lunak@suse.cz>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Feb 2010, Jiri Kosina wrote:

> Why does OOM killer care about forkbombs *at all*?
> 

Because the cumulative effects of a forkbomb are detrimental to the 
system and the badness() heursitic favors large memory consumers very 
heavily.  Thus, the forkbomb is never really a strong candidate for oom 
kill since the parent may consume very little memory itself and meanwhile 
KDE or another large memory consumer will get innocently killed instead as 
a result.

> If we really want kernel to detect forkbombs (*), we'd have to establish 
> completely separate infrastructure for that (with its own knobs for tuning 
> and possibilities of disabling it completely).
> 

That's what we're trying to do, we can look at the shear number of 
children that the parent has forked and check for it to be over a certain 
"forkbombing threshold" (which, yes, can be tuned from userspace), the 
uptime of those children, their resident set size, etc., to attempt to 
find a sane heuristic that penalizes them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
