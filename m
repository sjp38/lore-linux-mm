Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 897A46B0023
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 17:51:06 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p9PLp3K2029405
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 14:51:03 -0700
Received: from vws18 (vws18.prod.google.com [10.241.21.146])
	by wpaz24.hot.corp.google.com with ESMTP id p9PLoIHu002754
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 14:51:02 -0700
Received: by vws18 with SMTP id 18so1435411vws.9
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 14:51:00 -0700 (PDT)
Date: Tue, 25 Oct 2011 14:50:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB4F747B3@USINDEVS02.corp.hds.com>
Message-ID: <alpine.DEB.2.00.1110251446340.26017@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com> <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com> <20111010153723.6397924f.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com> <20111011125419.2702b5dc.akpm@linux-foundation.org> <65795E11DBF1E645A09CEC7EAEE94B9CB516CBFE@USINDEVS02.corp.hds.com> <20111011135445.f580749b.akpm@linux-foundation.org> <4E95917D.3080507@redhat.com>
 <20111012122018.690bdf28.akpm@linux-foundation.org>,<4E95F167.5050709@redhat.com> <65795E11DBF1E645A09CEC7EAEE94B9CB4F747B1@USINDEVS02.corp.hds.com>,<alpine.DEB.2.00.1110231419070.17218@chino.kir.corp.google.com>
 <65795E11DBF1E645A09CEC7EAEE94B9CB4F747B3@USINDEVS02.corp.hds.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, "hughd@google.com" <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Mon, 24 Oct 2011, Satoru Moriya wrote:

> >> We do.
> >> Basically we need this kind of feature for almost all our latency
> >> sensitive applications to avoid latency issue in memory allocation.
> >>
> > 
> > These are all realtime?
> 
> Do you mean that these are all realtime process?
> 
> If so, answer is depending on the situation. In the some situations,
> we can set these applications as rt-task. But the other situation,
> e.g. using some middlewares, package softwares etc, we can't set them
> as rt-task because they are not built for running as rt-task. And also
> it is difficult to rebuilt them for working as rt-task because they
> usually have huge code base.
> 

If this problem affects processes that aren't realtime, then your only 
option is to increase /proc/sys/vm/min_free_kbytes.  It's unreasonable to 
believe that the VM should be able to reclaim in the background at the 
same rate that an application is allocating huge amounts of memory without 
allowing there to be a buffer.  Adding another tunable isn't going to 
address that situation better than min_free_kbytes.

> As I reported another mail, changing kswapd priority does not mitigate
> even my simple testcase very much. Of course, reclaiming above the high
> wmark may solve the issue on some workloads but if an application can
> allocate memory more than high wmark - min wmark which is extended and
> fast enough, latency issue will happen.
> Unless this latency concern is fixed, customers doesn't use vanilla
> kernel.
> 

And you have yet to provide an expression that shows what a sane setting 
for this tunable will be.  In fact, it seems like you're just doing trial 
and error and finding where it works pretty well for a certain VM 
implementation in a certain kernel.  That's simply not a maintainable 
userspace interface!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
