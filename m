Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2D9D56B0062
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 21:13:17 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5H1Ddjq031037
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 17 Jun 2009 10:13:39 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 068CD45DE53
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 10:13:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 97BF745DE4F
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 10:13:38 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E0BE1DB8047
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 10:13:38 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2126F1DB8044
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 10:13:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] set the thread name
In-Reply-To: <36ca99e90906161214u6624014q3f3dc4e234bdf772@mail.gmail.com>
References: <1245177592.14543.1.camel@wall-e> <36ca99e90906161214u6624014q3f3dc4e234bdf772@mail.gmail.com>
Message-Id: <20090617100803.99C1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 17 Jun 2009 10:13:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Bert Wesarg <bert.wesarg@googlemail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Stefani Seibold <stefani@seibold.net>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org
List-ID: <linux-mm.kvack.org>

(cc to linux-api)

> Hi,
> 
> On Tue, Jun 16, 2009 at 20:39, Stefani Seibold<stefani@seibold.net> wrote:
> > Currently it is not easy to identify a thread in linux, because there is
> > no thread name like in some other OS.
> >
> > If there were are thread name then we could extend a kernel segv message
> > and the /proc/<pid>/task/<tid>/... entries by a TName value like this:
> prctl(PR_SET_NAME, ...) works perfectly here.

Oops, but man page describe another thing.

       PR_SET_NAME
              (Since Linux 2.6.9) Set the process name for the calling process
              to arg2.                    ^^^^^^^^^^^^

Should we change man page? or change implementation?

I bet many developer assume the implementation is right.


> 
> Bert
> 
> /* -*- c -*- */
> 
> #define _GNU_SOURCE
> #include <unistd.h>
> #include <stdlib.h>
> #include <stdio.h>
> #include <string.h>
> #include <stdint.h>
> #include <stdbool.h>
> #include <math.h>
> #include <pthread.h>
> #include <sys/prctl.h>
> 
> void *
> thread(void *arg)
> {
>     unsigned long i = (unsigned long)arg;
>     char comm[16];
>     snprintf(comm, sizeof comm, "task %02lu", i);
>     prctl(PR_SET_NAME, comm, 0l, 0l, 0l);
> 
>     sleep(10);
> 
>     return NULL;
> }
> 
> int
> main(int ac, char *av[])
> {
>     pthread_t thr;
>     unsigned long i, n = 10;
>     char comm[16];
> 
>     printf("%u\n", getpid());
>     sleep(5);
>     snprintf(comm, sizeof comm, "master");
>     prctl(PR_SET_NAME, comm, 0l, 0l, 0l);
>     sleep(5);
> 
>     for (i = 0; i < n; i++)
>         pthread_create(&thr, NULL, thread, (void *)i);
> 
>     pthread_join(thr, NULL);
> 
>     return 0;
> }
> 
> >
> > Greetings,
> > Stefani
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at ?http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at ?http://www.tux.org/lkml/
> >
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
