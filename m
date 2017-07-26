Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6496B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 03:53:58 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v31so30892599wrc.7
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 00:53:57 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l72si758389wmd.131.2017.07.26.00.53.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 00:53:56 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6Q7rnoN076469
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 03:53:55 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bxj5gu8m9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 03:53:54 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 26 Jul 2017 08:53:53 +0100
Date: Wed, 26 Jul 2017 10:53:48 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RESEND PATCH 2/2] userfaultfd: selftest: Add tests for
 UFFD_FREATURE_SIGBUS
References: <1500958062-953846-1-git-send-email-prakash.sangappa@oracle.com>
 <1500958062-953846-3-git-send-email-prakash.sangappa@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500958062-953846-3-git-send-email-prakash.sangappa@oracle.com>
Message-Id: <20170726075347.GA32369@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, mike.kravetz@oracle.com

On Tue, Jul 25, 2017 at 12:47:42AM -0400, Prakash Sangappa wrote:
> Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
> ---
>  tools/testing/selftests/vm/userfaultfd.c |  121 +++++++++++++++++++++++++++++-
>  1 files changed, 118 insertions(+), 3 deletions(-)

Please describe the new test in the commit log
 
> diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
> index 1eae79a..6a43e84 100644
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
> +        if (sig == SIGBUS) {
> +                if (sigbuf)
> +                         siglongjmp(*sigbuf, 1);
> +                abort();
> +        }

Please replace spaces with tabs for the indentation in the sighndl
function.

> +}
> +
>  /*
>   * For non-cooperative userfaultfd test we fork() a process that will
>   * generate pagefaults, will mremap the area monitored by the
> @@ -585,19 +598,54 @@ static int userfaultfd_open(int features)
>   * The release of the pages currently generates event for shmem and
>   * anonymous memory (UFFD_EVENT_REMOVE), hence it is not checked
>   * for hugetlb.
> + * For signal test(UFFD_FEATURE_SIGBUS), primarily test signal
> + * delivery and ensure no userfault events are generated.

Can you add some details about the tests? E.g. what is the meaning if
signal_test=1 and signal_test=2 and what is the difference between them?

>   */

> -static int faulting_process(void)
> +static int faulting_process(int signal_test)
>  {
>  	unsigned long nr;
>  	unsigned long long count;
>  	unsigned long split_nr_pages;
> +	unsigned long lastnr;
> +	struct sigaction act;
> +	unsigned long signalled=0, sig_repeats = 0;

Spaces around that '='         ^

> 
>  	if (test_type != TEST_HUGETLB)
>  		split_nr_pages = (nr_pages + 1) / 2;
>  	else
>  		split_nr_pages = nr_pages;
> 
> +	if (signal_test) {
> +		sigbuf = &jbuf;
> +		memset (&act, 0, sizeof(act));

There should be no space between function name and open parenthesis.

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
> +					continue;

If I understand correctly, when nr == lastnr we get a repeated signal for
the same page and this is an error, right?
Why would we continue the test and won't return error immediately?

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
> @@ -607,6 +655,8 @@ static int faulting_process(void)
>  		}
>  	}
> 
> +	if (signal_test)
> +		return signalled != split_nr_pages || sig_repeats != 0;

I believe return !(signalled == split_nr_pages && sig_repeats == 0) is
clearer.
And I blank line after the return statement would be nice :)

>  	if (test_type == TEST_HUGETLB)
>  		return 0;
> 
> @@ -761,7 +811,7 @@ static int userfaultfd_events_test(void)
>  		perror("fork"), exit(1);
> 
>  	if (!pid)
> -		return faulting_process();
> +		return faulting_process(0);
> 
>  	waitpid(pid, &err, 0);
>  	if (err)
> @@ -778,6 +828,70 @@ static int userfaultfd_events_test(void)
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
> @@ -946,7 +1060,8 @@ static int userfaultfd_stress(void)
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

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
