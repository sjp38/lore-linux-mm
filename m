Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4E64D6B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 19:22:55 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p9BNMjwi009708
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 16:22:45 -0700
Received: from vcbfk1 (vcbfk1.prod.google.com [10.220.204.1])
	by wpaz9.hot.corp.google.com with ESMTP id p9BNKSMZ027835
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 16:22:45 -0700
Received: by vcbfk1 with SMTP id fk1so227315vcb.6
        for <linux-mm@kvack.org>; Tue, 11 Oct 2011 16:22:45 -0700 (PDT)
Date: Tue, 11 Oct 2011 16:22:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com>
Message-ID: <alpine.DEB.2.00.1110111612120.5236@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com> <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com> <20111010153723.6397924f.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>, Con Kolivas <kernel@kolivas.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Tue, 11 Oct 2011, Satoru Moriya wrote:

> Actually page allocator decreases min watermark to 3/4 * min watermark
> for rt-task. But in our case some applications create a lot of
> processes and if all of them are rt-task, the amount of watermark
> bonus(1/4 * min watermark) is not enough.
> 

Right, if you can exhaust (1/4 * min_wmark) of memory quickly enough, 
you'll still have latency issues.

> If we can tune the amount of bonus, it may be fine. But that is
> almost all same as extra free kbytes.
> 

I don't know if your test case is the only thing that Rik is looking at, 
but if so, then that statement makes me believe that this patch is 
definitely in the wrong direction, so NACK on it until additional 
information is presented.  The reasoning is simple: if tuning the bonus 
given to rt-tasks in the page allocator itself would fix the issue, then 
we can certainly add logic specifically for rt-tasks that can reclaim more 
aggressively without needing any tunable from userspace (and _certainly_ 
not a global tunable that affects every application!).

> > Does there exist anything like a test case which demonstrates the need 
> > for this feature?
> 
> Unfortunately I don't have a real test case but just simple one.
> And in my simple test case, I can avoid direct reclaim if we set
> workload as rt-task.
> 
> The simple test case I used is following:
> http://marc.info/?l=linux-mm&m=131605773321672&w=2
> 

I tried proposing one of Con's patches from his BFS scheduler ("mm: adjust 
kswapd nice level for high priority page") about 1 1/2 years ago that I 
recall and believe may significantly help your test case.  The thread is 
at http://marc.info/?t=126743860700002.  (There's a lot of interesting 
things in Con's patchset that can be pulled into the VM, this isn't the 
only one.)

The patch wasn't merged back then because we wanted a test case that was 
specifically fixed by this issue, and it may be that we have just found 
one.  If you could try it out without any extra_free_kbytes, I think we 
may be able to help your situation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
