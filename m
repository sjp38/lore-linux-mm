Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 593BE6B05AD
	for <linux-mm@kvack.org>; Sun, 30 Jul 2017 03:08:01 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id q50so43055074wrb.14
        for <linux-mm@kvack.org>; Sun, 30 Jul 2017 00:08:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r132si174027wmg.0.2017.07.30.00.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Jul 2017 00:07:59 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6U73qGf107292
	for <linux-mm@kvack.org>; Sun, 30 Jul 2017 03:07:58 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c0p8d90p5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 30 Jul 2017 03:07:58 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 30 Jul 2017 08:07:56 +0100
Date: Sun, 30 Jul 2017 10:07:50 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/2] userfaultfd: selftest: Add tests for
 UFFD_FEATURE_SIGBUS feature
References: <1501208320-200277-1-git-send-email-prakash.sangappa@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1501208320-200277-1-git-send-email-prakash.sangappa@oracle.com>
Message-Id: <20170730070749.GB22926@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, mike.kravetz@oracle.com

On Thu, Jul 27, 2017 at 10:18:40PM -0400, Prakash Sangappa wrote:
> This patch adds tests for UFFD_FEATURE_SIGBUS feature. The
> tests will verify signal delivery instead of userfault events.
> Also, test use of UFFDIO_COPY to allocate memory and retry
> accessing monitored area after signal delivery.
> 
> This patch also fixes a bug in uffd_poll_thread() where 'uffd'
> is leaked.
> 
> Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
> ---
> Change log
> 
> v2:
>   - Added comments to explain the tests.
>   - Fixed test to fail immediately if signal repeats.
>   - Addressed other review comments.
> 
> v1: https://lkml.org/lkml/2017/7/26/101
> ---

Overall looks good to me, just small nitpick below.

>  tools/testing/selftests/vm/userfaultfd.c |  127 +++++++++++++++++++++++++++++-
>  1 files changed, 124 insertions(+), 3 deletions(-)
> 
> diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
> index 1eae79a..3976d7a 100644
> --- a/tools/testing/selftests/vm/userfaultfd.c
> +++ b/tools/testing/selftests/vm/userfaultfd.c
> @@ -66,6 +66,7 @@
>  #include <sys/wait.h>
>  #include <pthread.h>
>  #include <linux/userfaultfd.h>
> +#include <setjmp.h>
> 
>  #ifdef __NR_userfaultfd
> 
> @@ -408,6 +409,7 @@ static int copy_page(int ufd, unsigned long offset)
>  				userfaults++;
>  			break;
>  		case UFFD_EVENT_FORK:
> +			close(uffd);
>  			uffd = msg.arg.fork.ufd;
>  			pollfd[0].fd = uffd;
>  			break;
> @@ -572,6 +574,17 @@ static int userfaultfd_open(int features)
>  	return 0;
>  }
> 
> +sigjmp_buf jbuf, *sigbuf;
> +
> +static void sighndl(int sig, siginfo_t *siginfo, void *ptr)
> +{
> +	if (sig == SIGBUS) {
> +		if (sigbuf)
> +			siglongjmp(*sigbuf, 1);
> +		abort();
> +	}
> +}
> +
>  /*
>   * For non-cooperative userfaultfd test we fork() a process that will
>   * generate pagefaults, will mremap the area monitored by the
> @@ -585,19 +598,59 @@ static int userfaultfd_open(int features)
>   * The release of the pages currently generates event for shmem and
>   * anonymous memory (UFFD_EVENT_REMOVE), hence it is not checked
>   * for hugetlb.
> + * For signal test(UFFD_FEATURE_SIGBUS), signal_test = 1, we register
> + * monitored area, generate pagefaults and test that signal is delivered.
> + * Use UFFDIO_COPY to allocate missing page and retry. For signal_test = 2
> + * test robustness use case - we release monitored area, fork a process
> + * that will generate pagefaults and verify signal is generated.
> + * This also tests UFFD_FEATURE_EVENT_FORK event along with the signal
> + * feature. Using monitor thread, verify no userfault events are generated.
>   */
> -static int faulting_process(void)
> +static int faulting_process(int signal_test)
>  {
>  	unsigned long nr;
>  	unsigned long long count;
>  	unsigned long split_nr_pages;
> +	unsigned long lastnr;
> +	struct sigaction act;
> +	unsigned long signalled = 0, sig_repeats = 0;
> 
>  	if (test_type != TEST_HUGETLB)
>  		split_nr_pages = (nr_pages + 1) / 2;
>  	else
>  		split_nr_pages = nr_pages;
> 
> +	if (signal_test) {
> +		sigbuf = &jbuf;
> +		memset(&act, 0, sizeof(act));
> +		act.sa_sigaction = sighndl;
> +		act.sa_flags = SA_SIGINFO;
> +		if (sigaction(SIGBUS, &act, 0)) {
> +			perror("sigaction");
> +			return 1;
> +		}
> +		lastnr = (unsigned long)-1;
> +	}
> +
>  	for (nr = 0; nr < split_nr_pages; nr++) {
> +		if (signal_test) {
> +			if (sigsetjmp(*sigbuf, 1) != 0) {
> +				if (nr == lastnr) {
> +					sig_repeats++;

You can simply 'return 1' here, then sig_repeats variable can be dropped
and the return statement for signal_test can be simplified.

> +					break;
> +				}
> +
> +				lastnr = nr;
> +				if (signal_test == 1) {
> +					if (copy_page(uffd, nr * page_size))
> +						signalled++;
> +				} else {
> +					signalled++;
> +					continue;
> +				}
> +			}
> +		}
> +
>  		count = *area_count(area_dst, nr);
>  		if (count != count_verify[nr]) {
>  			fprintf(stderr,
> @@ -607,6 +660,9 @@ static int faulting_process(void)
>  		}
>  	}
> 
> +	if (signal_test)
> +		return !(signalled == split_nr_pages && sig_repeats == 0);
> +
>  	if (test_type == TEST_HUGETLB)
>  		return 0;
> 
> @@ -761,7 +817,7 @@ static int userfaultfd_events_test(void)
>  		perror("fork"), exit(1);
> 
>  	if (!pid)
> -		return faulting_process();
> +		return faulting_process(0);
> 
>  	waitpid(pid, &err, 0);
>  	if (err)
> @@ -778,6 +834,70 @@ static int userfaultfd_events_test(void)
>  	return userfaults != nr_pages;
>  }
> 
> +static int userfaultfd_sig_test(void)
> +{
> +	struct uffdio_register uffdio_register;
> +	unsigned long expected_ioctls;
> +	unsigned long userfaults;
> +	pthread_t uffd_mon;
> +	int err, features;
> +	pid_t pid;
> +	char c;
> +
> +	printf("testing signal delivery: ");
> +	fflush(stdout);
> +
> +	if (uffd_test_ops->release_pages(area_dst))
> +		return 1;
> +
> +	features = UFFD_FEATURE_EVENT_FORK|UFFD_FEATURE_SIGBUS;
> +	if (userfaultfd_open(features) < 0)
> +		return 1;
> +	fcntl(uffd, F_SETFL, uffd_flags | O_NONBLOCK);
> +
> +	uffdio_register.range.start = (unsigned long) area_dst;
> +	uffdio_register.range.len = nr_pages * page_size;
> +	uffdio_register.mode = UFFDIO_REGISTER_MODE_MISSING;
> +	if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register))
> +		fprintf(stderr, "register failure\n"), exit(1);
> +
> +	expected_ioctls = uffd_test_ops->expected_ioctls;
> +	if ((uffdio_register.ioctls & expected_ioctls) !=
> +	    expected_ioctls)
> +		fprintf(stderr,
> +			"unexpected missing ioctl for anon memory\n"),
> +			exit(1);
> +
> +	if (faulting_process(1))
> +		fprintf(stderr, "faulting process failed\n"), exit(1);
> +
> +	if (uffd_test_ops->release_pages(area_dst))
> +		return 1;
> +
> +	if (pthread_create(&uffd_mon, &attr, uffd_poll_thread, NULL))
> +		perror("uffd_poll_thread create"), exit(1);
> +
> +	pid = fork();
> +	if (pid < 0)
> +		perror("fork"), exit(1);
> +
> +	if (!pid)
> +		exit(faulting_process(2));
> +
> +	waitpid(pid, &err, 0);
> +	if (err)
> +		fprintf(stderr, "faulting process failed\n"), exit(1);
> +
> +	if (write(pipefd[1], &c, sizeof(c)) != sizeof(c))
> +		perror("pipe write"), exit(1);
> +	if (pthread_join(uffd_mon, (void **)&userfaults))
> +		return 1;
> +
> +	printf("done\n");
> +	printf(" Signal test userfaults: %ld\n", userfaults);
> +	close(uffd);
> +	return userfaults != 0;
> +}
>  static int userfaultfd_stress(void)
>  {
>  	void *area;
> @@ -946,7 +1066,8 @@ static int userfaultfd_stress(void)
>  		return err;
> 
>  	close(uffd);
> -	return userfaultfd_zeropage_test() || userfaultfd_events_test();
> +	return userfaultfd_zeropage_test() || userfaultfd_sig_test()
> +		|| userfaultfd_events_test();
>  }
> 
>  /*
> -- 
> 1.7.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
