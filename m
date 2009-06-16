Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4C1B96B0055
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 15:14:03 -0400 (EDT)
Received: by bwz21 with SMTP id 21so5583448bwz.38
        for <linux-mm@kvack.org>; Tue, 16 Jun 2009 12:14:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1245177592.14543.1.camel@wall-e>
References: <1245177592.14543.1.camel@wall-e>
Date: Tue, 16 Jun 2009 21:14:26 +0200
Message-ID: <36ca99e90906161214u6624014q3f3dc4e234bdf772@mail.gmail.com>
Subject: Re: [RFC] set the thread name
From: Bert Wesarg <bert.wesarg@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Stefani Seibold <stefani@seibold.net>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jun 16, 2009 at 20:39, Stefani Seibold<stefani@seibold.net> wrote:
> Currently it is not easy to identify a thread in linux, because there is
> no thread name like in some other OS.
>
> If there were are thread name then we could extend a kernel segv message
> and the /proc/<pid>/task/<tid>/... entries by a TName value like this:
prctl(PR_SET_NAME, ...) works perfectly here.

Bert

/* -*- c -*- */

#define _GNU_SOURCE
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <pthread.h>
#include <sys/prctl.h>

void *
thread(void *arg)
{
    unsigned long i =3D (unsigned long)arg;
    char comm[16];
    snprintf(comm, sizeof comm, "task %02lu", i);
    prctl(PR_SET_NAME, comm, 0l, 0l, 0l);

    sleep(10);

    return NULL;
}

int
main(int ac, char *av[])
{
    pthread_t thr;
    unsigned long i, n =3D 10;
    char comm[16];

    printf("%u\n", getpid());
    sleep(5);
    snprintf(comm, sizeof comm, "master");
    prctl(PR_SET_NAME, comm, 0l, 0l, 0l);
    sleep(5);

    for (i =3D 0; i < n; i++)
        pthread_create(&thr, NULL, thread, (void *)i);

    pthread_join(thr, NULL);

    return 0;
}

>
> Greetings,
> Stefani
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
