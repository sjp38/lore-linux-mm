Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 54AA76B0070
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 18:38:13 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id t2so699477qcq.14
        for <linux-mm@kvack.org>; Tue, 30 Oct 2012 15:38:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA25o9SE353h9xjUR0ste3af1XPuyL_hieGBUWqmt_S5hCn_9A@mail.gmail.com>
References: <20121015144412.GA2173@barrios> <CAA25o9R53oJajrzrWcLSAXcjAd45oQ4U+gJ3Mq=bthD3HGRaFA@mail.gmail.com>
 <20121016061854.GB3934@barrios> <CAA25o9R5OYSMZ=Rs2qy9rPk3U9yaGLLXVB60Yncqvmf3Y_Xbvg@mail.gmail.com>
 <CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com>
 <20121022235321.GK13817@bbox> <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com>
 <CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com>
 <alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com>
 <CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
 <20121030001809.GL15767@bbox> <CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com>
 <alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com>
 <CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com> <CAA25o9SE353h9xjUR0ste3af1XPuyL_hieGBUWqmt_S5hCn_9A@mail.gmail.com>
From: Sonny Rao <sonnyrao@google.com>
Date: Tue, 30 Oct 2012 15:37:51 -0700
Message-ID: <CAPz6YkUC3p0h0N+gqFctiLXmsPBAbC8P35DmNQXPSU_117Jk4A@mail.gmail.com>
Subject: Re: zram OOM behavior
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, Oct 30, 2012 at 1:30 PM, Luigi Semenzato <semenzato@google.com> wrote:
>
> On Tue, Oct 30, 2012 at 12:12 PM, Luigi Semenzato <semenzato@google.com> wrote:
>
> > OK, now someone is going to fix this, right? :-)
>
> Actually, there is a very simple fix:
>
> @@ -355,14 +364,6 @@ static struct task_struct
> *select_bad_process(unsigned int *ppoints,
>                         if (p == current) {
>                                 chosen = p;
>                                 *ppoints = 1000;
> -                       } else if (!force_kill) {
> -                               /*
> -                                * If this task is not being ptraced on exit,
> -                                * then wait for it to finish before killing
> -                                * some other task unnecessarily.
> -                                */
> -                               if (!(p->group_leader->ptrace & PT_TRACE_EXIT))
> -                                       return ERR_PTR(-1UL);
>                         }
>                 }
>
> I'd rather kill some other task unnecessarily than hang!  My load
> works fine with this change.

It also appears that we didn't kill any unnecessary tasks either.

It's just a deadlock
exiting process A encounters a page fault and has to allocate some
memory and goes to sleep
process B which is running the OOM Killer blocks on exiting process
and process A blocks forever on memory while process B blocks on A,
and therefore no memory is released

IMO, the fact that we don't do this when the process is being ptraced
also seems to justify that it's a valid thing to do in all cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
