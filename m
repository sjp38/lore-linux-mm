Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id EDEDA6B0170
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 18:46:44 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p9EMkeKg014218
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 15:46:40 -0700
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by wpaz13.hot.corp.google.com with ESMTP id p9EMY1sU001523
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 15:46:38 -0700
Received: by pzk5 with SMTP id 5so9169058pzk.9
        for <linux-mm@kvack.org>; Fri, 14 Oct 2011 15:46:38 -0700 (PDT)
Date: Fri, 14 Oct 2011 15:46:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB4F747AC@USINDEVS02.corp.hds.com>
Message-ID: <alpine.DEB.2.00.1110141536520.21305@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com> <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com> <20111010153723.6397924f.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com> <20111011125419.2702b5dc.akpm@linux-foundation.org> <65795E11DBF1E645A09CEC7EAEE94B9CB516CBFE@USINDEVS02.corp.hds.com> <20111011135445.f580749b.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516D055@USINDEVS02.corp.hds.com> <alpine.DEB.2.00.1110121537380.16286@chino.kir.corp.google.com> <65795E11DBF1E645A09CEC7EAEE94B9CB516D0EA@USINDEVS02.corp.hds.com> <alpine.DEB.2.00.1110121654120.30123@chino.kir.corp.google.com>
 <20111013143501.a59efa5c.kamezawa.hiroyu@jp.fujitsu.com>,<alpine.DEB.2.00.1110131351270.24853@chino.kir.corp.google.com> <65795E11DBF1E645A09CEC7EAEE94B9CB4F747AC@USINDEVS02.corp.hds.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Fri, 14 Oct 2011, Satoru Moriya wrote:

> > Satoru was specifically talking about the VM using free memory for 
> > pagecache,
> 
> Yes, because we can't stop increasing pagecache and it 
> occupies RAM where some people want to keep free for bursty
> memory requirement. Usually it works fine but sometimes like
> my test case doesn't work well.
> 
> > so doing echo echo 1 > /proc/sys/vm/drop_caches can mitigate 
> > that almost immediately.  
> 
> I know it and some admins use that kind of tuning. But is it
> proper way? Should we exec the script like above periodically?
> I believe that we should use it for debug only.
> 

Agreed, this was in response to the suggestion for adding a mem_shrink() 
syscall, which would require the same periodic calls or knowledge of the 
application prior to the bursty memory allocations.  I bring up 
drop_caches just to illustrate that it is effectively the same thing for 
the entire address space when pressured by pagecache.  So I don't think 
that syscall would actually help for your scenario.

> > If there were a change to increase the space significantly between the 
> > high and min watermark when min_free_kbytes changes, that would fix the 
> > problem. 
> 
> Right. But min_free_kbytes changes both thresholds, foregroud reclaim
> and background reclaim. I'd like to configure them separately like
> dirty_bytes and dirty_background_bytes for flexibility.
> 

The point I'm trying to make is that if kswapd can be made aware that it 
was kicked by a rt_task() in the page allocator, the same criteria we use 
for ALLOC_HARDER today, or a rt_task() subsequently enters the page 
allocator slowpath while kswapd is running, then not only can we increase 
the scheduling priority of kswapd but it is also possible to reclaim above 
the high watermark for an extra bonus.  I believe we can find a sane 
middle ground that requires no userspace tunable where a _single_ realtime 
application cannot allocate memory faster than kswapd with very high 
priority and reclaiming above the high watermark, whether that's a factor 
of 1.25 or not.

> > The problem is two-fold: that comes at a penalty for systems 
> > or workloads that don't need to reclaim the additional memory, and it's 
> > not clear how much space should exist between those watermarks.
> 
> The required size depends on a system architacture such as kernel,
> applications, storage etc. and so admin who care the whole system
> should configure it based on tests by his own risk.
> 

Doing that comes at a penalty for other workloads that are running on the 
same system, which is the problem with a global tunable that doesn't 
discriminate on an allocator's priority (the min -> high watermarks for 
reclaim do well except for rt-threads, as evidenced by this thread).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
