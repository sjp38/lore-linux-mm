Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id E25DB6B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 23:54:43 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id cm18so64160qab.18
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 20:54:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v4si16355960qeb.26.2013.12.17.20.54.42
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 20:54:42 -0800 (PST)
Date: Tue, 17 Dec 2013 23:54:26 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1387342466-7cf57hks-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20131213230004.GD7793@mcs.anl.gov>
References: <20131212222527.GD8605@mcs.anl.gov>
 <1386964742-df8sz3d6-mutt-n-horiguchi@ah.jp.nec.com>
 <20131213230004.GD7793@mcs.anl.gov>
Subject: Re: [PATCH] mm/memory-failure.c: send action optional signal to an
 arbitrary thread
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamil Iskra <iskra@mcs.anl.gov>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>

Kamil,

# Sorry for late response.

On Fri, Dec 13, 2013 at 05:00:04PM -0600, Kamil Iskra wrote:
> On Fri, Dec 13, 2013 at 14:59:02 -0500, Naoya Horiguchi wrote:
> 
> Hi Naoya,
> 
> > On Thu, Dec 12, 2013 at 04:25:27PM -0600, Kamil Iskra wrote:
> > > Please find below a trivial patch that changes the sending of BUS_MCEERR_AO
> > > SIGBUS signals so that they can be handled by an arbitrary thread of the
> > > target process.  The current implementation makes it impossible to create a
> > > separate, dedicated thread to handle such errors, as the signal is always
> > > sent to the main thread.
> > This can be done in application side by letting the main thread create a
> > dedicated thread for error handling, or by waking up existing/sleeping one.
> > It might not be optimal in overhead, but note that an action optional error
> > does not require to be handled ASAP. And we need only one process to handle
> > an action optional error, so no need to send SIGBUS(BUS_MCEERR_AO) for every
> > processes/threads.
> 
> I'm not sure if I understand.  "letting the main thread create a dedicated
> thread for error handling" is exactly what I was trying to do -- the
> problem is that SIGBUS(BUS_MCEERR_AO) signals are never sent to that
> thread, which is contrary to common expectations.  The signals are sent to
> the main thread only, even if SIGBUS is masked there.

I think that what your patch suggests is that "letting the dedicated thread
get SIGBUS(BUS_MCEERR_AO) directly (not via the main thread) from kernel."
It's a bit different from what I meant in the previous email.

> Just to make sure that we're on the same page, here's a testcase that
> demonstrates the problem I'm trying to fix (I should've sent it the first
> time; sorry for being lazy):

Thanks. And I see your problem.

> 
> #include <pthread.h>
> #include <signal.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <sys/prctl.h>
> #include <unistd.h>
> 
> void sigbus_handler(int sig, siginfo_t* si, void* ucontext)
> {
>     printf("SIGBUS caught by thread %ld, code %d, addr %p\n",
> 	   (long)pthread_self(), si->si_code, si->si_addr);
> }
> 
> void* sigbus_thread(void* arg)
> {
>     printf("sigbus thread: %ld\n", (long)pthread_self());
>     for (;;)
> 	pause();
> }
> 
> int main(void)
> {
>     struct sigaction sa;
>     sigset_t mask;
>     char* buf;
>     pthread_t thread_id;
> 
>     prctl(PR_MCE_KILL, PR_MCE_KILL_SET, PR_MCE_KILL_EARLY, 0, 0);
> 
>     posix_memalign((void*)&buf, 4096, 4096);
>     buf[0] = 0;
>     printf("convenient address to hard offline: %p\n", buf);
> 
>     sa.sa_sigaction = sigbus_handler;
>     sigemptyset(&sa.sa_mask);
>     sa.sa_flags = SA_SIGINFO;
>     sigaction(SIGBUS, &sa, NULL);
> 
>     pthread_create(&thread_id, NULL, sigbus_thread, NULL);
> 
>     sigemptyset(&mask);
>     sigaddset(&mask, SIGBUS);
>     pthread_sigmask(SIG_BLOCK, &mask, NULL);
> 
>     printf("main thread: %ld\n", (long)pthread_self());
> 
>     for (;;)
> 	pause();
> 
>     return 0;
> }
> 
> 
> This testcase uses a very common signal handling strategy in multithreaded
> programs: masking signals in all threads but one, created specifically for
> signal handling.  It works just fine if I send it SIGBUS from another
> terminal using "kill".  It does not work if I offline the page: the signal
> is routed to the main thread, where it's marked as pending; nothing gets
> printed out.
> 
> As you were so kind to point out, SIGBUS(BUS_MCEERR_AO) does not need to be
> handled ASAP, so why should the kernel handle it differently to other
> non-critical signals?  The current behavior seems inconsistent, and there
> is no convenient workaround (as a library writer, I have no control over
> the actions of the main thread).

I'm not sure if current implementation is intentional or not,
but I understand about the inconsistency.

> > And another concern is if this change can affect/break existing applications.
> > If it can, maybe you need to add (for example) a prctl attribute to show that
> > the process expects kernel to send SIGBUS(BUS_MCEERR_AO) only to the main
> > thread, or to all threads belonging to the process.
> 
> I understand your concern.  However, I believe that having
> SIGBUS(BUS_MCEERR_AO) behave consistently with established POSIX standards
> for signal handling outhweighs the concerns over potential
> incompatibilities, especially with a feature that is currently used by a
> very small subset of applications.

OK, and in this case the effect on existing multi-threaded applications seems
to be small (just small degradation of availability, but no kernel panic nor
data lost,) so I think it's acceptable.

I want to agree with your patch, so could you repost the patch with patch
description?  git-format-patch will help you.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
