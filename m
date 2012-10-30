Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 6EB816B0088
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 16:30:14 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id c11so533553qad.14
        for <linux-mm@kvack.org>; Tue, 30 Oct 2012 13:30:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com>
References: <20121015144412.GA2173@barrios>
	<CAA25o9R53oJajrzrWcLSAXcjAd45oQ4U+gJ3Mq=bthD3HGRaFA@mail.gmail.com>
	<20121016061854.GB3934@barrios>
	<CAA25o9R5OYSMZ=Rs2qy9rPk3U9yaGLLXVB60Yncqvmf3Y_Xbvg@mail.gmail.com>
	<CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com>
	<20121022235321.GK13817@bbox>
	<alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com>
	<CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com>
	<alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com>
	<CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
	<20121030001809.GL15767@bbox>
	<CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com>
	<alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com>
	<CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com>
Date: Tue, 30 Oct 2012 13:30:13 -0700
Message-ID: <CAA25o9SE353h9xjUR0ste3af1XPuyL_hieGBUWqmt_S5hCn_9A@mail.gmail.com>
Subject: Re: zram OOM behavior
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Tue, Oct 30, 2012 at 12:12 PM, Luigi Semenzato <semenzato@google.com> wrote:

> OK, now someone is going to fix this, right? :-)

Actually, there is a very simple fix:

@@ -355,14 +364,6 @@ static struct task_struct
*select_bad_process(unsigned int *ppoints,
                        if (p == current) {
                                chosen = p;
                                *ppoints = 1000;
-                       } else if (!force_kill) {
-                               /*
-                                * If this task is not being ptraced on exit,
-                                * then wait for it to finish before killing
-                                * some other task unnecessarily.
-                                */
-                               if (!(p->group_leader->ptrace & PT_TRACE_EXIT))
-                                       return ERR_PTR(-1UL);
                        }
                }

I'd rather kill some other task unnecessarily than hang!  My load
works fine with this change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
