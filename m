Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 271648D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 15:02:06 -0400 (EDT)
Date: Tue, 15 Mar 2011 19:53:16 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/3 for 2.6.38] oom: oom_kill_process: don't set
	TIF_MEMDIE if !p->mm
Message-ID: <20110315185316.GA21640@redhat.com>
References: <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org> <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com> <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com> <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com> <20110313212726.GA24530@redhat.com> <20110314190419.GA21845@redhat.com> <20110314190446.GB21845@redhat.com> <alpine.DEB.2.00.1103141314190.31514@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1103141314190.31514@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>, Frantisek Hrbata <fhrbata@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/14, David Rientjes wrote:
>
> On Mon, 14 Mar 2011, Oleg Nesterov wrote:
>
> > oom_kill_process() simply sets TIF_MEMDIE and returns if PF_EXITING.
> > This is very wrong by many reasons. In particular, this thread can
> > be the dead group leader. Check p->mm != NULL.
> >
>
> This is true only for the oom_kill_allocating_task sysctl where it is
> required in all cases to kill current; current won't be triggering the oom
> killer if it's dead.
>
> oom_kill_process() is called with the thread selected by
> select_bad_process() and that function will not return any thread if any
> eligible task is found to be PF_EXITING and is not current, or any
> eligible task is found to have TIF_MEMDIE.
>
> In other words, for this conditional to be true in oom_kill_process(),
> then p must be current and so it cannot be the dead group leader as
> specified in your changelog unless PF_EXITING gets set between
> select_bad_process() and the oom_kill_process() call: we don't care about
> that since it's in the exit path and we therefore want to give it access
> to memory reserves to quickly exit anyway and the check for PF_EXITING in
> select_bad_process() prevents any infinite loop of that task getting
> constantly reselected if it's dead.

Confused. I sent the test-case. OK, may be you meant the code in -mm,
but I meant the current code.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
