Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id EB3966B0062
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 00:38:50 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so1069017dad.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 21:38:50 -0700 (PDT)
Date: Wed, 31 Oct 2012 21:38:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: zram OOM behavior
In-Reply-To: <20121101021145.GF26256@bbox>
Message-ID: <alpine.DEB.2.00.1210312136370.17607@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com> <CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com> <alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com> <CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
 <20121030001809.GL15767@bbox> <CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com> <alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com> <CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com> <20121031005738.GM15767@bbox>
 <alpine.DEB.2.00.1210311151341.8809@chino.kir.corp.google.com> <20121101021145.GF26256@bbox>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Thu, 1 Nov 2012, Minchan Kim wrote:

> If mutiple threads are page faulting and try to allocate memory, then they
> should go to oom path and they will reach following code.
> 
>         if (task->flags & PF_EXITING) {
>                if (task == current)
>                         return OOM_SCAN_SELECT;
> 

No, OOM_SCAN_SELECT does not return immediately and kill that process; it 
only prefers to kill that process first iff the oom killer isn't deferred 
because it finds TIF_MEMDIE threads or other PF_EXITING threads other than 
current.  So if multiple processes are in the exit path with PF_EXITING 
and require additional memory then the oom killed may defer without 
killing anything.  That's what I suspect is happening in this case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
