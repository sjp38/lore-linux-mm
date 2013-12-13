Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f46.google.com (mail-qe0-f46.google.com [209.85.128.46])
	by kanga.kvack.org (Postfix) with ESMTP id 536FD6B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 18:00:07 -0500 (EST)
Received: by mail-qe0-f46.google.com with SMTP id a11so2138184qen.19
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 15:00:07 -0800 (PST)
Received: from mailrelay.anl.gov (mailrelay.anl.gov. [130.202.101.22])
        by mx.google.com with ESMTPS id l8si3804128qey.28.2013.12.13.15.00.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 15:00:06 -0800 (PST)
Date: Fri, 13 Dec 2013 17:00:04 -0600
From: Kamil Iskra <iskra@mcs.anl.gov>
Subject: Re: [PATCH] mm/memory-failure.c: send action optional signal to an
 arbitrary thread
Message-ID: <20131213230004.GD7793@mcs.anl.gov>
References: <20131212222527.GD8605@mcs.anl.gov>
 <1386964742-df8sz3d6-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386964742-df8sz3d6-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>

On Fri, Dec 13, 2013 at 14:59:02 -0500, Naoya Horiguchi wrote:

Hi Naoya,

> On Thu, Dec 12, 2013 at 04:25:27PM -0600, Kamil Iskra wrote:
> > Please find below a trivial patch that changes the sending of BUS_MCEERR_AO
> > SIGBUS signals so that they can be handled by an arbitrary thread of the
> > target process.  The current implementation makes it impossible to create a
> > separate, dedicated thread to handle such errors, as the signal is always
> > sent to the main thread.
> This can be done in application side by letting the main thread create a
> dedicated thread for error handling, or by waking up existing/sleeping one.
> It might not be optimal in overhead, but note that an action optional error
> does not require to be handled ASAP. And we need only one process to handle
> an action optional error, so no need to send SIGBUS(BUS_MCEERR_AO) for every
> processes/threads.

I'm not sure if I understand.  "letting the main thread create a dedicated
thread for error handling" is exactly what I was trying to do -- the
problem is that SIGBUS(BUS_MCEERR_AO) signals are never sent to that
thread, which is contrary to common expectations.  The signals are sent to
the main thread only, even if SIGBUS is masked there.

Just to make sure that we're on the same page, here's a testcase that
demonstrates the problem I'm trying to fix (I should've sent it the first
time; sorry for being lazy):


#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/prctl.h>
#include <unistd.h>

void sigbus_handler(int sig, siginfo_t* si, void* ucontext)
{
    printf("SIGBUS caught by thread %ld, code %d, addr %p\n",
	   (long)pthread_self(), si->si_code, si->si_addr);
}

void* sigbus_thread(void* arg)
{
    printf("sigbus thread: %ld\n", (long)pthread_self());
    for (;;)
	pause();
}

int main(void)
{
    struct sigaction sa;
    sigset_t mask;
    char* buf;
    pthread_t thread_id;

    prctl(PR_MCE_KILL, PR_MCE_KILL_SET, PR_MCE_KILL_EARLY, 0, 0);

    posix_memalign((void*)&buf, 4096, 4096);
    buf[0] = 0;
    printf("convenient address to hard offline: %p\n", buf);

    sa.sa_sigaction = sigbus_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_SIGINFO;
    sigaction(SIGBUS, &sa, NULL);

    pthread_create(&thread_id, NULL, sigbus_thread, NULL);

    sigemptyset(&mask);
    sigaddset(&mask, SIGBUS);
    pthread_sigmask(SIG_BLOCK, &mask, NULL);

    printf("main thread: %ld\n", (long)pthread_self());

    for (;;)
	pause();

    return 0;
}


This testcase uses a very common signal handling strategy in multithreaded
programs: masking signals in all threads but one, created specifically for
signal handling.  It works just fine if I send it SIGBUS from another
terminal using "kill".  It does not work if I offline the page: the signal
is routed to the main thread, where it's marked as pending; nothing gets
printed out.

As you were so kind to point out, SIGBUS(BUS_MCEERR_AO) does not need to be
handled ASAP, so why should the kernel handle it differently to other
non-critical signals?  The current behavior seems inconsistent, and there
is no convenient workaround (as a library writer, I have no control over
the actions of the main thread).

> And another concern is if this change can affect/break existing applications.
> If it can, maybe you need to add (for example) a prctl attribute to show that
> the process expects kernel to send SIGBUS(BUS_MCEERR_AO) only to the main
> thread, or to all threads belonging to the process.

I understand your concern.  However, I believe that having
SIGBUS(BUS_MCEERR_AO) behave consistently with established POSIX standards
for signal handling outhweighs the concerns over potential
incompatibilities, especially with a feature that is currently used by a
very small subset of applications.

Thus, I kindly ask you to reconsider.

Regards,

Kamil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
