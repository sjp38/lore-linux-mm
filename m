Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E8DD88D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 16:40:39 -0400 (EDT)
Date: Mon, 14 Mar 2011 21:31:52 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/3 for 2.6.38] oom: oom_kill_process: don't set
	TIF_MEMDIE if !p->mm
Message-ID: <20110314203152.GA25080@redhat.com>
References: <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org> <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com> <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com> <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com> <20110313212726.GA24530@redhat.com> <20110314190419.GA21845@redhat.com> <20110314190446.GB21845@redhat.com> <AANLkTi=YnG7tYCSrCPTNSQANOkD2MkP0tMjbOyZbx4NG@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTi=YnG7tYCSrCPTNSQANOkD2MkP0tMjbOyZbx4NG@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>, David Rientjes <rientjes@google.com>, Frantisek Hrbata <fhrbata@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/14, Linus Torvalds wrote:
>
> On Mon, Mar 14, 2011 at 12:04 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> > oom_kill_process() simply sets TIF_MEMDIE and returns if PF_EXITING.
> > This is very wrong by many reasons. In particular, this thread can
> > be the dead group leader. Check p->mm != NULL.
>
> Explain more, please. Maybe I'm missing some context because I wasn't
> cc'd on the original thread, but PF_EXITING gets set by exit_signal(),
> and exit_mm() is called almost immediately afterwards which will set
> p->mm to NULL.
>
> So afaik, this will basically just remove the whole point of the code
> entirely - so why not remove it then?

I am afraid I am going to lie... But iirc I tried to remove this code
before. Can't find the previous discussion, probably I am wrong.

Anyway. I never understood why do we have this special case.

> The combination of testing PF_EXITING and p->mm just doesn't seem to
> make any sense.

To me, it doesn't make too much sense even if we do not check ->mm.

But. I _think_ the intent was to wait until this "exiting" process
does exit_mm() and frees the memory. This is like the
"the process of releasing memory " code in select_bad_process(). Once
again, this is only my speculation.

In any case, this patch doesn't pretend to be the right fix.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
