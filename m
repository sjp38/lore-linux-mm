Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 311489000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 16:33:35 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p8RKXVSs026790
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 13:33:31 -0700
Received: from gyg13 (gyg13.prod.google.com [10.243.50.141])
	by wpaz13.hot.corp.google.com with ESMTP id p8RKXR6T007027
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 13:33:30 -0700
Received: by gyg13 with SMTP id 13so6423621gyg.8
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 13:33:27 -0700 (PDT)
Date: Tue, 27 Sep 2011 13:33:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm: restrict access to /proc/meminfo
In-Reply-To: <alpine.DEB.2.00.1109271459180.13797@router.home>
Message-ID: <alpine.DEB.2.00.1109271328151.24402@chino.kir.corp.google.com>
References: <20110927175453.GA3393@albatros> <20110927175642.GA3432@albatros> <20110927193810.GA5416@albatros> <alpine.DEB.2.00.1109271459180.13797@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Vasiliy Kulikov <segoon@openwall.com>, kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Valdis.Kletnieks@vt.edu, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, 27 Sep 2011, Christoph Lameter wrote:

> Viewing free memory is usually necessary to check on reclaim activities
> (things otherwise operating normally). "free" memory (in the sense of the
> memory that an application can still allocate) is not really displayed by
> free. Wish we had a new free that avoids all the misinterpretations.
> 
> Meminfo is also requires by vmstat.
> 

Even with the patch, you could still get all this information by summing 
up the per-node meminfo in /sys/devices/system/node/nodeX/meminfo.  
Non-root users certainly need to be able to use things like numactl and be 
able to specify their own mempolicies for NUMA machines, so limiting basic 
memory state information isn't going to work.

I'd much rather just convert everything to use MB rather than KB so you 
can't determine things at a page level.  I think that gets us much closer 
to what the patch is intending to restrict.  But I also expect some 
breakage from things that just expect meminfo to be in KB units without 
parsing what the kernel is exporting.

> If we want to go down this route then we need some sort of diagnostic
> group that a user must be part of in order to allow viewing of basic
> memory statistics.
> 

It'll turn into another one of our infinite number of capabilities.  Does 
anything actually care about statistics at KB granularity these days?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
