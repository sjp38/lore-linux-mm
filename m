Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4AA6B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 02:20:02 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id q203so24082103wmb.0
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 23:20:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b23si1998943eda.69.2017.10.08.23.20.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Oct 2017 23:20:00 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v996JRmb059772
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 02:19:59 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dfp2m7jc1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Oct 2017 02:19:58 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 9 Oct 2017 07:19:56 +0100
Date: Mon, 9 Oct 2017 09:19:50 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: RFC: spurious UFFD_EVENT_FORK with pending signals
References: <20171007151609.GH16918@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171007151609.GH16918@redhat.com>
Message-Id: <20171009061949.GA20101@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: mtk.manpages@gmail.com, linux-api@vger.kernel.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, mhocko@suse.com, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Prakash Sangappa <prakash.sangappa@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>

On Sat, Oct 07, 2017 at 05:16:09PM +0200, Andrea Arcangeli wrote:
> Hello,
> 
> I noticed that the addition of a SIGLARM to the selftest broke the
> selftest in how it handles UFFD_EVENT_FORK because of an undocumented
> UFFD_EVENT_FORK behavior. The testcase doesn't expect "spurious" fork
> events to be received.
> 
> As result two or more child uffds may be received by the monitor
> during a single fork() invocation of the parent (only the last uffd
> will be for the real child, the previous are all spurious associated
> with an mm with mm_users = 0). The monitor thread because it's a
> selftest, it expects deterministic behavior so when it receives a
> spurious uffd, it thinks it received the real uffd of the child and so
> it closes the parent uffd and just listens to such spurious uffd. But
> such spurious uffd is not the child uffd and when the parent uffd is
> closed the real child runs without userfaultfd monitoring (resulting
> in immediate corruption being detected in the child).
> 
> The source of the spurious child uffds is this check in kernel/fork.c:
> 
> 	recalc_sigpending();
> 	if (signal_pending(current)) {
> 		retval = -ERESTARTNOINTR;
> 		goto bad_fork_cancel_cgroup;
> 
> In practice this isn't a problem for CRIU or any other real non
> cooperative use case, because the parent uffd could never be closed
> (the only possible concern about this detail, would be if CRIU could
> run out of file descriptors in presence of signal flood, but even that
> would be a graceful failure with no memory corruption possible).

Indeed in CRIU we don't close the parent uffd and a couple of spurious
UFFD_EVENT_FORK won't cause a real problem. Yet, if we'll run out of file
descriptors because of signal flood during migration, even with graceful
failure we'd loose the migrated process entirely.
 
> We don't have a userfaultfd_exit hook to send a POLLHUP when the mm is
> destroyed. If we had that, the spurious uffd could be collected and
> release the file handle in the userfaultfd monitor fd space. To send
> such POLLHUP we'd need to queue all userfaultfd_ctx in a list in the
> mm_struct.
> 
> The other possible solution to the possible concern of running out of
> file descriptors in the CRIU userfaultfd monitor, is to simply prevent
> the generation of the spurious uffds and in turn removing this
> detail. That's not hard but that would move uffd structures way up
> into the callers so the UFFD_EVENT_FORK is only delivered after the
> above signal_pending check.

Currently userfault related code in fork.c neatly fits into dup_mmap() and
moving the uffd structures up into the callers would be ugly :(

However, calling dup_userfaultfd_complete() in dup_mmap() will cause
spurious UFFD_EVENT_FORK if fork() fails at any point after copy_mm().

Maybe we do need to queue all duplicated userfaultfd_ctx in the mm_struct
of the child process and call dup_userfaultfd_complete() closer to the end
of copy_process().
 
I'm going to experiment with the list of userfaultfd_ctx in mm_struct, it
seems to me that it may have additional value, e.g. to simplify
userfaultfd_event_wait_completion(). I'll need a bit of time to see if I'm
not talking complete nonsense :)

> For now I added an easy reproducer to the testcase and sigprocmask
> SIG_BLOCK/UNBLOCK around fork() to verify that such a change restores
> all "cooperative" expectations of the "non-cooperative" part of the
> testcase.
> 
> This survived fine a 12+ hour load with 4 selftests in parallel
> (shmem, hugetlb, hugetlb_shared, anon).
> 
> I found out about this detail the first time with heavy host CPU over
> commit that enlarged the guest fork runtime long enough for a SIGALARM
> to hit it and it wasn't easy to reproduce until I added the signal
> flooder to the selftest.
> 
> I'll cleanup and submit the below selftest fix shortly with a separate
> submit, but here the question is if we want to make any change to
> UFFD_EVENT_FORK for this signal issue.
> 
> If we change anything in the UFFD_EVENT_FORK processing for this, then
> the sigprocmask calls and the two #defines should be dropped from the
> selftest so the signal flooder will then validate any kernel change
> done for it.
> 
> If we change nothing then this detail should probably be documented
> just in case somebody has deterministic expectations for the
> non-cooperative features (like the selftest has).
> 
> Thanks,
> Andrea
> 
> diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
> index de2f9ec8a87f..3f7b6e91050c 100644
> --- a/tools/testing/selftests/vm/userfaultfd.c
> +++ b/tools/testing/selftests/vm/userfaultfd.c
> @@ -69,6 +69,9 @@
>  #include <setjmp.h>
>  #include <stdbool.h>
> 
> +//#define REPRODUCE_SPURIOUS_UFFD_EVENT_FORK_IN_SIG_TEST
> +//#define REPRODUCE_SPURIOUS_UFFD_EVENT_FORK_IN_EVENTS_TEST
> +
>  #ifdef __NR_userfaultfd
> 
>  static unsigned long nr_cpus, nr_pages, nr_pages_per_cpu, page_size;
> @@ -159,8 +162,7 @@ static void hugetlb_allocate_area(void **alloc_area)
>  	void *area_alias = NULL;
>  	char **alloc_area_alias;
>  	*alloc_area = mmap(NULL, nr_pages * page_size, PROT_READ | PROT_WRITE,
> -			   (map_shared ? MAP_SHARED : MAP_PRIVATE) |
> -			   MAP_HUGETLB,
> +			   (map_shared ? MAP_SHARED : MAP_PRIVATE),
>  			   huge_fd, *alloc_area == area_src ? 0 :
>  			   nr_pages * page_size);
>  	if (*alloc_area == MAP_FAILED) {
> @@ -170,7 +172,7 @@ static void hugetlb_allocate_area(void **alloc_area)
> 
>  	if (map_shared) {
>  		area_alias = mmap(NULL, nr_pages * page_size, PROT_READ | PROT_WRITE,
> -				  MAP_SHARED | MAP_HUGETLB,
> +				  MAP_SHARED,
>  				  huge_fd, *alloc_area == area_src ? 0 :
>  				  nr_pages * page_size);
>  		if (area_alias == MAP_FAILED) {
> @@ -457,8 +459,11 @@ static void *uffd_poll_thread(void *arg)
>  		ret = poll(pollfd, 2, -1);
>  		if (!ret)
>  			fprintf(stderr, "poll error %d\n", ret), exit(1);
> -		if (ret < 0)
> +		if (ret < 0) {
> +			if (errno == EINTR)
> +				continue;
>  			perror("poll"), exit(1);
> +		}
>  		if (pollfd[1].revents & POLLIN) {
>  			if (read(pollfd[1].fd, &tmp_chr, 1) != 1)
>  				fprintf(stderr, "read pipefd error\n"),
> @@ -470,8 +475,13 @@ static void *uffd_poll_thread(void *arg)
>  				pollfd[0].revents), exit(1);
>  		ret = read(uffd, &msg, sizeof(msg));
>  		if (ret < 0) {
> -			if (errno == EAGAIN)
> +			if (errno == EINTR) {
> +				fprintf(stderr, "nonblocking read -EINTR\n");
>  				continue;
> +			}
> +			if (errno == EAGAIN) {
> +				continue;
> +			}
>  			perror("nonblocking read error"), exit(1);
>  		}
>  		switch (msg.event) {
> @@ -734,14 +744,23 @@ static int faulting_process(int signal_test)
>  		count = *area_count(area_dst, nr);
>  		if (count != count_verify[nr]) {
>  			fprintf(stderr,
> -				"nr %lu memory corruption %Lu %Lu\n",
> +				"nr %lu memory corruption %Lu %Lu %d\n",
>  				nr, count,
> -				count_verify[nr]), exit(1);
> +				count_verify[nr], signal_test), exit(1);
>  		}
>  	}
> 
> -	if (signal_test)
> +	if (signal_test) {
> +		/* restore SIGBUS defaults after signal_test completed */
> +		sigbuf = NULL;
> +		memset(&act, 0, sizeof(act));
> +		act.sa_handler = SIG_DFL;
> +		if (sigaction(SIGBUS, &act, 0)) {
> +			perror("sigaction SIGBUS SIG_DFL");
> +			return 1;
> +		}
>  		return signalled != split_nr_pages;
> +	}
> 
>  	if (test_type == TEST_HUGETLB)
>  		return 0;
> @@ -920,14 +939,25 @@ static int userfaultfd_events_test(void)
>  	if (pthread_create(&uffd_mon, &attr, uffd_poll_thread, NULL))
>  		perror("uffd_poll_thread create"), exit(1);
> 
> +	/* See the comment in background_signal_flood */
> +	sigset_t set;
> +	sigemptyset(&set);
> +	sigaddset(&set, SIGUSR1);
> +	sigaddset(&set, SIGALRM);
> +#ifndef REPRODUCE_SPURIOUS_UFFD_EVENT_FORK_IN_EVENTS_TEST
> +	/* FIXME, should be pthread_sigmask */
> +	sigprocmask(SIG_BLOCK, &set, NULL);
> +#endif
>  	pid = fork();
> +	sigprocmask(SIG_UNBLOCK, &set, NULL);
>  	if (pid < 0)
>  		perror("fork"), exit(1);
> 
>  	if (!pid)
> -		return faulting_process(0);
> +		exit(faulting_process(0));
> 
> -	waitpid(pid, &err, 0);
> +	if (waitpid(pid, &err, 0) != pid)
> +		perror("waitpid"), exit(1);
>  	if (err)
>  		fprintf(stderr, "faulting process failed\n"), exit(1);
> 
> @@ -985,14 +1015,25 @@ static int userfaultfd_sig_test(void)
>  	if (pthread_create(&uffd_mon, &attr, uffd_poll_thread, NULL))
>  		perror("uffd_poll_thread create"), exit(1);
> 
> +	/* See the comment in background_signal_flood */
> +	sigset_t set;
> +	sigemptyset(&set);
> +	sigaddset(&set, SIGUSR1);
> +	sigaddset(&set, SIGALRM);
> +#ifndef REPRODUCE_SPURIOUS_UFFD_EVENT_FORK_IN_SIG_TEST
> +	/* FIXME, should be pthread_sigmask */
> +	sigprocmask(SIG_BLOCK, &set, NULL);
> +#endif
>  	pid = fork();
> +	sigprocmask(SIG_UNBLOCK, &set, NULL);
>  	if (pid < 0)
>  		perror("fork"), exit(1);
> 
>  	if (!pid)
>  		exit(faulting_process(2));
> 
> -	waitpid(pid, &err, 0);
> +	if (waitpid(pid, &err, 0) != pid)
> +		perror("waitpid"), exit(1);
>  	if (err)
>  		fprintf(stderr, "faulting process failed\n"), exit(1);
> 
> @@ -1267,14 +1308,66 @@ static void sigalrm(int sig)
>  	alarm(ALARM_INTERVAL_SECS);
>  }
> 
> +static void sigusr1(int sig)
> +{
> +	if (sig != SIGUSR1)
> +		abort();
> +}
> +
> +/*
> + * This helps reproduce the UFFD_EVENT_FORK behavior where multiple
> + * child uffds are created despite there's only one parent. That is ok
> + * as long as they're all tracked. Non cooperative users will work
> + * fine even if the mm belonging to the additional uffd are already
> + * destroyed, simply no userfault or event will happen there. To
> + * optimize those away we'd need to send the UFFD_EVENT_FORK after the
> + * signal_pending check (way up into the callers of
> + * dup_mmap()). Alternatively we'd need a reliable way to be notified
> + * with POLLHUP when the mm exits so even if spurious uffd are
> + * initially received by the monitor thread, they can be garbage
> + * collected, but that would require to queue up userfaultfd_ctx in
> + * the mm_struct. This signal flood makes sure signals are working
> + * fine at all times and the only tricky part is the UFFD_EVENT_FORK
> + * handling. If you make cooperative assumptions on non cooperative
> + * UFFD_EVENT_FORK, masking signals around fork() is necessary with
> + * the currrent API (and it will remain backwards compatible even if
> + * we lift this requirement).
> + */
> +static pid_t background_signal_flood(void)
> +{
> +	pid_t parent_pid = getpid(), pid;
> +	int n;
> +	pid = fork();
> +	if (pid < 0)
> +		perror("fork"), exit(1);
> +	if (!pid) {
> +		for (;;) {
> +			for (n = 0; n < 1000; n++) {
> +				if (kill(parent_pid, SIGUSR1))
> +					exit(0);
> +				usleep(1000);
> +			}
> +			sleep(1);
> +		}
> +	}
> +	return pid;
> +}
> +
>  int main(int argc, char **argv)
>  {
> +	pid_t signal_flooder;
> +	int ret;
>  	if (argc < 4)
>  		fprintf(stderr, "Usage: <test type> <MiB> <bounces> [hugetlbfs_file]\n"),
>  				exit(1);
> 
> +	/* FIXME: signal not to be used in multithreaded... */
>  	if (signal(SIGALRM, sigalrm) == SIG_ERR)
>  		fprintf(stderr, "failed to arm SIGALRM"), exit(1);
> +	if (signal(SIGUSR1, sigusr1) == SIG_ERR)
> +		fprintf(stderr, "failed to arm SIGUSR1"), exit(1);
> +
> +	signal_flooder = background_signal_flood();
>  	alarm(ALARM_INTERVAL_SECS);
> 
>  	set_test_type(argv[1]);
> @@ -1312,7 +1405,11 @@ int main(int argc, char **argv)
>  	}
>  	printf("nr_pages: %lu, nr_pages_per_cpu: %lu\n",
>  	       nr_pages, nr_pages_per_cpu);
> -	return userfaultfd_stress();
> +	ret = userfaultfd_stress();
> +	kill(signal_flooder, SIGTERM);
> +	if (waitpid(signal_flooder, NULL, 0) != signal_flooder)
> +		perror("waitpid"), exit(1);
> +	return ret;
>  }
> 
>  #else /* __NR_userfaultfd */
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
