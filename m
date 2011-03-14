Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B69178D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 16:32:53 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p2EKWnOF004608
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:32:49 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by hpaq11.eem.corp.google.com with ESMTP id p2EKWVM4021849
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:32:48 -0700
Received: by pzk1 with SMTP id 1so1069609pzk.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:32:48 -0700 (PDT)
Date: Mon, 14 Mar 2011 13:32:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3 for 2.6.38] oom: oom_kill_process: don't set TIF_MEMDIE
 if !p->mm
In-Reply-To: <AANLkTi=YnG7tYCSrCPTNSQANOkD2MkP0tMjbOyZbx4NG@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1103141322390.31514@chino.kir.corp.google.com>
References: <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org> <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com>
 <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com> <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com> <20110313212726.GA24530@redhat.com> <20110314190419.GA21845@redhat.com> <20110314190446.GB21845@redhat.com>
 <AANLkTi=YnG7tYCSrCPTNSQANOkD2MkP0tMjbOyZbx4NG@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>, Frantisek Hrbata <fhrbata@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 14 Mar 2011, Linus Torvalds wrote:

> The combination of testing PF_EXITING and p->mm just doesn't seem to
> make any sense.
> 

Right, it doesn't (and I recently removed testing the combination from 
select_bad_process() in -mm).  The check for PF_EXITING in the oom killer 
is purely to avoid needlessly killing tasks when something is already 
exiting and will (hopefully) be freeing its memory soon.  If an eligible 
thread is found to be PF_EXITING, the oom killer will defer indefinitely 
unless it happens to be current.  If it happens to be current, then it is 
automatically selected so it gets access to the needed memory reserves.

We do need to ensure that behavior doesn't preempt any task from being 
killed if there's an eligible thread other than current that never 
actually detaches its ->mm (oom-skip-zombies-when-iterating-tasklist.patch 
in -mm filters all threads without an ->mm).  That can happen if 
mm->mmap_sem never gets released by a thread and that's why an earlier 
change that is already in your tree automatically gives current access to 
memory reserves immediately upon calling the oom killer if it has a 
pending SIGKILL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
