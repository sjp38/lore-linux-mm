Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id A35E96B027B
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 19:36:50 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5209791pbb.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 16:36:50 -0700 (PDT)
Date: Fri, 22 Jun 2012 16:36:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: replace some information in tasklist dump
In-Reply-To: <CAHGf_=q=6uWb4wpZxnZNGY=VohoaWrDJtiQk0Rn59unNSMTnyQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1206221634230.18408@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206221444370.23486@chino.kir.corp.google.com> <CAHGf_=p4SS7qA_eRpBF0PawyUa8DpYncL0LS-=B4tHFaDUKV-w@mail.gmail.com> <alpine.DEB.2.00.1206221609220.15114@chino.kir.corp.google.com>
 <CAHGf_=q=6uWb4wpZxnZNGY=VohoaWrDJtiQk0Rn59unNSMTnyQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-1764458780-1340408209=:18408"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-1764458780-1340408209=:18408
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 22 Jun 2012, KOSAKI Motohiro wrote:

> >> > -               pr_info("[%5d] %5d %5d %8lu %8lu %3u     %3d         %5d %s\n",
> >> > +               pr_info("[%5d] %5d %5d %8lu %8lu %7lu %8lu         %5d %s\n",
> >> >                        task->pid, from_kuid(&init_user_ns, task_uid(task)),
> >> >                        task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
> >> > -                       task_cpu(task), task->signal->oom_adj,
> >> > +                       task->mm->nr_ptes,
> >>
> >> nr_ptes should be folded into rss. it's "resident".
> >> btw, /proc rss info should be fixed too.
> >
> > If we can fold rss into get_mm_rss() and every caller is ok with that,
> > then we can remove showing it here and adding it explicitly in
> > oom_badness().
> 
> No worth to make fragile ABI. Do you have any benefit?
> 

Yes, because this is exactly where we would discover something like a 
mm->nr_ptes accounting issue since it would result in an oom kill and we'd 
notice the mismatch between nr_ptes and rss in the tasklist dump.

I also don't think anybody is parsing this tasklist dump or I wouldn't be 
changing it here.
--397155492-1764458780-1340408209=:18408--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
