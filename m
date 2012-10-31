Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 56D616B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 00:46:07 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so762708pbb.14
        for <linux-mm@kvack.org>; Tue, 30 Oct 2012 21:46:05 -0700 (PDT)
Date: Tue, 30 Oct 2012 21:46:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: zram OOM behavior
In-Reply-To: <CAA25o9SE353h9xjUR0ste3af1XPuyL_hieGBUWqmt_S5hCn_9A@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1210302142510.26588@chino.kir.corp.google.com>
References: <20121015144412.GA2173@barrios> <CAA25o9R53oJajrzrWcLSAXcjAd45oQ4U+gJ3Mq=bthD3HGRaFA@mail.gmail.com> <20121016061854.GB3934@barrios> <CAA25o9R5OYSMZ=Rs2qy9rPk3U9yaGLLXVB60Yncqvmf3Y_Xbvg@mail.gmail.com> <CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com>
 <20121022235321.GK13817@bbox> <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com> <CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com> <alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com>
 <CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com> <20121030001809.GL15767@bbox> <CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com> <alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com>
 <CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com> <CAA25o9SE353h9xjUR0ste3af1XPuyL_hieGBUWqmt_S5hCn_9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Tue, 30 Oct 2012, Luigi Semenzato wrote:

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
> 

That's not an acceptable "fix" at all, it will lead to unnecessarily 
killing processes when others are in the exit path, i.e. every oom kill 
would kill two or three or more processes instead of just one.

Could you please try this on 3.6 since all the code you're quoting is from 
old kernels?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
