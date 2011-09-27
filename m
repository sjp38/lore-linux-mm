Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A24A49000C4
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 14:27:30 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p8RIRRpb032312
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 11:27:27 -0700
Received: from yxk30 (yxk30.prod.google.com [10.190.3.158])
	by hpaq1.eem.corp.google.com with ESMTP id p8RIPthB004707
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 11:27:26 -0700
Received: by yxk30 with SMTP id 30so6592430yxk.12
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 11:27:26 -0700 (PDT)
Date: Tue, 27 Sep 2011 11:27:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm: restrict access to /proc/meminfo
In-Reply-To: <20110927175642.GA3432@albatros>
Message-ID: <alpine.DEB.2.00.1109271122480.17876@chino.kir.corp.google.com>
References: <20110927175453.GA3393@albatros> <20110927175642.GA3432@albatros>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: kernel-hardening@lists.openwall.com, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Valdis.Kletnieks@vt.edu, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, 27 Sep 2011, Vasiliy Kulikov wrote:

> /proc/meminfo stores information related to memory pages usage, which
> may be used to monitor the number of objects in specific caches (and/or
> the changes of these numbers).  This might reveal private information
> similar to /proc/slabinfo infoleaks.  To remove the infoleak, just
> restrict meminfo to root.  If it is used by unprivileged daemons,
> meminfo permissions can be altered the same way as slabinfo:
> 
>     groupadd meminfo
>     usermod -a -G meminfo $MONITOR_USER
>     chmod g+r /proc/meminfo
>     chgrp meminfo /proc/meminfo
> 

I guess the side-effect of this is that users without root will no longer 
report VM issues where "there's tons of freeable memory but my task got 
killed", "there's swap available but is unutilized in lowmem situations", 
etc. :)

Seriously, though, can't we just change the granularity of /proc/meminfo 
to be MB instead of KB or at least provide a separate file that is 
readable that does that?  I can understand not exporting information on a 
page-level granularity but not giving users a way to determine the amount 
of free memory is a little extreme.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
