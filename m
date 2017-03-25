Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9796B0038
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 20:30:21 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id a13so9422966ywh.14
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 17:30:21 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i74si1338384ywg.66.2017.03.24.17.30.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 17:30:19 -0700 (PDT)
Subject: Re: [PATCH] userfaultfd: selftest: combine all cases into the single
 executable
References: <1490118758-15869-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <0e8a48b5-0621-31f6-db27-ef1ece0ac514@oracle.com>
Date: Fri, 24 Mar 2017 17:30:12 -0700
MIME-Version: 1.0
In-Reply-To: <1490118758-15869-1-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 03/21/2017 10:52 AM, Mike Rapoport wrote:
> Currently, selftest for userfaultfd is compiled three times: for anonymous,
> shared and hugetlb memory. Let's combine all the cases into a single
> executable which will have a command line option for selection of the test
> type.

The changes below look good.   However, I think you forgot the HUGETLBFS
#ifndefs in faulting_process() of the non-cooperative userfaultfd tests.
As a result, we attempt to call mremap as part of the hugetlbfs test and
fail.

-- 
Mike Kravetz

> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  tools/testing/selftests/vm/Makefile      |   8 --
>  tools/testing/selftests/vm/run_vmtests   |   6 +-
>  tools/testing/selftests/vm/userfaultfd.c | 191 +++++++++++++++++--------------
>  3 files changed, 106 insertions(+), 99 deletions(-)
> 
> diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
> index 41642ba..86f1848 100644
> --- a/tools/testing/selftests/vm/Makefile
> +++ b/tools/testing/selftests/vm/Makefile
> @@ -15,8 +15,6 @@ TEST_GEN_FILES += on-fault-limit
>  TEST_GEN_FILES += thuge-gen
>  TEST_GEN_FILES += transhuge-stress
>  TEST_GEN_FILES += userfaultfd
> -TEST_GEN_FILES += userfaultfd_hugetlb
> -TEST_GEN_FILES += userfaultfd_shmem
>  TEST_GEN_FILES += mlock-random-test
>  
>  TEST_PROGS := run_vmtests
> @@ -25,12 +23,6 @@ include ../lib.mk
>  
>  $(OUTPUT)/userfaultfd: LDLIBS += -lpthread ../../../../usr/include/linux/kernel.h
>  
> -$(OUTPUT)/userfaultfd_hugetlb: userfaultfd.c ../../../../usr/include/linux/kernel.h
> -	$(CC) $(CFLAGS) -DHUGETLB_TEST -O2 -o $@ $< -lpthread
> -
> -$(OUTPUT)/userfaultfd_shmem: userfaultfd.c  ../../../../usr/include/linux/kernel.h
> -	$(CC) $(CFLAGS) -DSHMEM_TEST -O2 -o $@ $< -lpthread
> -
>  $(OUTPUT)/mlock-random-test: LDLIBS += -lcap
>  
>  ../../../../usr/include/linux/kernel.h:
> diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftests/vm/run_vmtests
> index c92f6cf..3214a64 100755
> --- a/tools/testing/selftests/vm/run_vmtests
> +++ b/tools/testing/selftests/vm/run_vmtests
> @@ -95,7 +95,7 @@ echo "      hugetlb regression testing."
>  echo "--------------------"
>  echo "running userfaultfd"
>  echo "--------------------"
> -./userfaultfd 128 32
> +./userfaultfd anon 128 32
>  if [ $? -ne 0 ]; then
>  	echo "[FAIL]"
>  	exitcode=1
> @@ -107,7 +107,7 @@ echo "----------------------------"
>  echo "running userfaultfd_hugetlb"
>  echo "----------------------------"
>  # 258MB total huge pages == 128MB src and 128MB dst
> -./userfaultfd_hugetlb 128 32 $mnt/ufd_test_file
> +./userfaultfd hugetlb 128 32 $mnt/ufd_test_file
>  if [ $? -ne 0 ]; then
>  	echo "[FAIL]"
>  	exitcode=1
> @@ -119,7 +119,7 @@ rm -f $mnt/ufd_test_file
>  echo "----------------------------"
>  echo "running userfaultfd_shmem"
>  echo "----------------------------"
> -./userfaultfd_shmem 128 32
> +./userfaultfd shmem 128 32
>  if [ $? -ne 0 ]; then
>  	echo "[FAIL]"
>  	exitcode=1
> diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
> index e9449c8..ea860d1 100644
> --- a/tools/testing/selftests/vm/userfaultfd.c
> +++ b/tools/testing/selftests/vm/userfaultfd.c
> @@ -77,10 +77,13 @@
>  #define BOUNCE_POLL		(1<<3)
>  static int bounces;
>  
> -#ifdef HUGETLB_TEST
> +#define TEST_ANON	1
> +#define TEST_HUGETLB	2
> +#define TEST_SHMEM	3
> +static int test_type;
> +
>  static int huge_fd;
>  static char *huge_fd_off0;
> -#endif
>  static unsigned long long *count_verify;
>  static int uffd, uffd_flags, finished, *pipefd;
>  static char *area_src, *area_dst;
> @@ -102,14 +105,7 @@
>  				 ~(unsigned long)(sizeof(unsigned long long) \
>  						  -  1)))
>  
> -#if !defined(HUGETLB_TEST) && !defined(SHMEM_TEST)
> -
> -/* Anonymous memory */
> -#define EXPECTED_IOCTLS		((1 << _UFFDIO_WAKE) | \
> -				 (1 << _UFFDIO_COPY) | \
> -				 (1 << _UFFDIO_ZEROPAGE))
> -
> -static int release_pages(char *rel_area)
> +static int anon_release_pages(char *rel_area)
>  {
>  	int ret = 0;
>  
> @@ -121,7 +117,7 @@ static int release_pages(char *rel_area)
>  	return ret;
>  }
>  
> -static void allocate_area(void **alloc_area)
> +static void anon_allocate_area(void **alloc_area)
>  {
>  	if (posix_memalign(alloc_area, page_size, nr_pages * page_size)) {
>  		fprintf(stderr, "out of memory\n");
> @@ -129,14 +125,9 @@ static void allocate_area(void **alloc_area)
>  	}
>  }
>  
> -#else /* HUGETLB_TEST or SHMEM_TEST */
> -
> -#define EXPECTED_IOCTLS		UFFD_API_RANGE_IOCTLS_BASIC
> -
> -#ifdef HUGETLB_TEST
>  
>  /* HugeTLB memory */
> -static int release_pages(char *rel_area)
> +static int hugetlb_release_pages(char *rel_area)
>  {
>  	int ret = 0;
>  
> @@ -152,7 +143,7 @@ static int release_pages(char *rel_area)
>  }
>  
>  
> -static void allocate_area(void **alloc_area)
> +static void hugetlb_allocate_area(void **alloc_area)
>  {
>  	*alloc_area = mmap(NULL, nr_pages * page_size, PROT_READ | PROT_WRITE,
>  				MAP_PRIVATE | MAP_HUGETLB, huge_fd,
> @@ -167,10 +158,8 @@ static void allocate_area(void **alloc_area)
>  		huge_fd_off0 = *alloc_area;
>  }
>  
> -#elif defined(SHMEM_TEST)
> -
>  /* Shared memory */
> -static int release_pages(char *rel_area)
> +static int shmem_release_pages(char *rel_area)
>  {
>  	int ret = 0;
>  
> @@ -182,7 +171,7 @@ static int release_pages(char *rel_area)
>  	return ret;
>  }
>  
> -static void allocate_area(void **alloc_area)
> +static void shmem_allocate_area(void **alloc_area)
>  {
>  	*alloc_area = mmap(NULL, nr_pages * page_size, PROT_READ | PROT_WRITE,
>  			   MAP_ANONYMOUS | MAP_SHARED, -1, 0);
> @@ -192,11 +181,35 @@ static void allocate_area(void **alloc_area)
>  	}
>  }
>  
> -#else /* SHMEM_TEST */
> -#error "Undefined test type"
> -#endif /* HUGETLB_TEST */
> -
> -#endif /* !defined(HUGETLB_TEST) && !defined(SHMEM_TEST) */
> +struct uffd_test_ops {
> +	unsigned long expected_ioctls;
> +	void (*allocate_area)(void **alloc_area);
> +	int (*release_pages)(char *rel_area);
> +};
> +
> +#define ANON_EXPECTED_IOCTLS		((1 << _UFFDIO_WAKE) | \
> +					 (1 << _UFFDIO_COPY) | \
> +					 (1 << _UFFDIO_ZEROPAGE))
> +
> +static struct uffd_test_ops anon_uffd_test_ops = {
> +	.expected_ioctls = ANON_EXPECTED_IOCTLS,
> +	.allocate_area	= anon_allocate_area,
> +	.release_pages	= anon_release_pages,
> +};
> +
> +static struct uffd_test_ops shmem_uffd_test_ops = {
> +	.expected_ioctls = UFFD_API_RANGE_IOCTLS_BASIC,
> +	.allocate_area	= shmem_allocate_area,
> +	.release_pages	= shmem_release_pages,
> +};
> +
> +static struct uffd_test_ops hugetlb_uffd_test_ops = {
> +	.expected_ioctls = UFFD_API_RANGE_IOCTLS_BASIC,
> +	.allocate_area	= hugetlb_allocate_area,
> +	.release_pages	= hugetlb_release_pages,
> +};
> +
> +static struct uffd_test_ops *uffd_test_ops;
>  
>  static int my_bcmp(char *str1, char *str2, size_t n)
>  {
> @@ -505,7 +518,7 @@ static int stress(unsigned long *userfaults)
>  	 * UFFDIO_COPY without writing zero pages into area_dst
>  	 * because the background threads already completed).
>  	 */
> -	if (release_pages(area_src))
> +	if (uffd_test_ops->release_pages(area_src))
>  		return 1;
>  
>  	for (cpu = 0; cpu < nr_cpus; cpu++) {
> @@ -610,7 +623,7 @@ static int faulting_process(void)
>  		}
>  	}
>  
> -	if (release_pages(area_dst))
> +	if (uffd_test_ops->release_pages(area_dst))
>  		return 1;
>  
>  	for (nr = 0; nr < nr_pages; nr++) {
> @@ -627,7 +640,9 @@ static int uffdio_zeropage(int ufd, unsigned long offset)
>  {
>  	struct uffdio_zeropage uffdio_zeropage;
>  	int ret;
> -	unsigned long has_zeropage = EXPECTED_IOCTLS & (1 << _UFFDIO_ZEROPAGE);
> +	unsigned long has_zeropage;
> +
> +	has_zeropage = uffd_test_ops->expected_ioctls & (1 << _UFFDIO_ZEROPAGE);
>  
>  	if (offset >= nr_pages * page_size)
>  		fprintf(stderr, "unexpected offset %lu\n",
> @@ -675,7 +690,7 @@ static int userfaultfd_zeropage_test(void)
>  	printf("testing UFFDIO_ZEROPAGE: ");
>  	fflush(stdout);
>  
> -	if (release_pages(area_dst))
> +	if (uffd_test_ops->release_pages(area_dst))
>  		return 1;
>  
>  	if (userfaultfd_open(0) < 0)
> @@ -686,7 +701,7 @@ static int userfaultfd_zeropage_test(void)
>  	if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register))
>  		fprintf(stderr, "register failure\n"), exit(1);
>  
> -	expected_ioctls = EXPECTED_IOCTLS;
> +	expected_ioctls = uffd_test_ops->expected_ioctls;
>  	if ((uffdio_register.ioctls & expected_ioctls) !=
>  	    expected_ioctls)
>  		fprintf(stderr,
> @@ -716,7 +731,7 @@ static int userfaultfd_events_test(void)
>  	printf("testing events (fork, remap, remove): ");
>  	fflush(stdout);
>  
> -	if (release_pages(area_dst))
> +	if (uffd_test_ops->release_pages(area_dst))
>  		return 1;
>  
>  	features = UFFD_FEATURE_EVENT_FORK | UFFD_FEATURE_EVENT_REMAP |
> @@ -731,7 +746,7 @@ static int userfaultfd_events_test(void)
>  	if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register))
>  		fprintf(stderr, "register failure\n"), exit(1);
>  
> -	expected_ioctls = EXPECTED_IOCTLS;
> +	expected_ioctls = uffd_test_ops->expected_ioctls;
>  	if ((uffdio_register.ioctls & expected_ioctls) !=
>  	    expected_ioctls)
>  		fprintf(stderr,
> @@ -773,10 +788,10 @@ static int userfaultfd_stress(void)
>  	int err;
>  	unsigned long userfaults[nr_cpus];
>  
> -	allocate_area((void **)&area_src);
> +	uffd_test_ops->allocate_area((void **)&area_src);
>  	if (!area_src)
>  		return 1;
> -	allocate_area((void **)&area_dst);
> +	uffd_test_ops->allocate_area((void **)&area_dst);
>  	if (!area_dst)
>  		return 1;
>  
> @@ -856,7 +871,7 @@ static int userfaultfd_stress(void)
>  			fprintf(stderr, "register failure\n");
>  			return 1;
>  		}
> -		expected_ioctls = EXPECTED_IOCTLS;
> +		expected_ioctls = uffd_test_ops->expected_ioctls;
>  		if ((uffdio_register.ioctls & expected_ioctls) !=
>  		    expected_ioctls) {
>  			fprintf(stderr,
> @@ -888,7 +903,7 @@ static int userfaultfd_stress(void)
>  		 * MADV_DONTNEED only after the UFFDIO_REGISTER, so it's
>  		 * required to MADV_DONTNEED here.
>  		 */
> -		if (release_pages(area_dst))
> +		if (uffd_test_ops->release_pages(area_dst))
>  			return 1;
>  
>  		/* bounce pass */
> @@ -934,36 +949,6 @@ static int userfaultfd_stress(void)
>  	return userfaultfd_zeropage_test() || userfaultfd_events_test();
>  }
>  
> -#ifndef HUGETLB_TEST
> -
> -int main(int argc, char **argv)
> -{
> -	if (argc < 3)
> -		fprintf(stderr, "Usage: <MiB> <bounces>\n"), exit(1);
> -	nr_cpus = sysconf(_SC_NPROCESSORS_ONLN);
> -	page_size = sysconf(_SC_PAGE_SIZE);
> -	if ((unsigned long) area_count(NULL, 0) + sizeof(unsigned long long) * 2
> -	    > page_size)
> -		fprintf(stderr, "Impossible to run this test\n"), exit(2);
> -	nr_pages_per_cpu = atol(argv[1]) * 1024*1024 / page_size /
> -		nr_cpus;
> -	if (!nr_pages_per_cpu) {
> -		fprintf(stderr, "invalid MiB\n");
> -		fprintf(stderr, "Usage: <MiB> <bounces>\n"), exit(1);
> -	}
> -	bounces = atoi(argv[2]);
> -	if (bounces <= 0) {
> -		fprintf(stderr, "invalid bounces\n");
> -		fprintf(stderr, "Usage: <MiB> <bounces>\n"), exit(1);
> -	}
> -	nr_pages = nr_pages_per_cpu * nr_cpus;
> -	printf("nr_pages: %lu, nr_pages_per_cpu: %lu\n",
> -	       nr_pages, nr_pages_per_cpu);
> -	return userfaultfd_stress();
> -}
> -
> -#else /* HUGETLB_TEST */
> -
>  /*
>   * Copied from mlock2-tests.c
>   */
> @@ -988,48 +973,78 @@ unsigned long default_huge_page_size(void)
>  	return hps;
>  }
>  
> -int main(int argc, char **argv)
> +static void set_test_type(const char *type)
>  {
> -	if (argc < 4)
> -		fprintf(stderr, "Usage: <MiB> <bounces> <hugetlbfs_file>\n"),
> -				exit(1);
> -	nr_cpus = sysconf(_SC_NPROCESSORS_ONLN);
> -	page_size = default_huge_page_size();
> +	if (!strcmp(type, "anon")) {
> +		test_type = TEST_ANON;
> +		uffd_test_ops = &anon_uffd_test_ops;
> +	} else if (!strcmp(type, "hugetlb")) {
> +		test_type = TEST_HUGETLB;
> +		uffd_test_ops = &hugetlb_uffd_test_ops;
> +	} else if (!strcmp(type, "shmem")) {
> +		test_type = TEST_SHMEM;
> +		uffd_test_ops = &shmem_uffd_test_ops;
> +	} else {
> +		fprintf(stderr, "Unknown test type: %s\n", type), exit(1);
> +	}
> +
> +	if (test_type == TEST_HUGETLB)
> +		page_size = default_huge_page_size();
> +	else
> +		page_size = sysconf(_SC_PAGE_SIZE);
> +
>  	if (!page_size)
> -		fprintf(stderr, "Unable to determine huge page size\n"),
> +		fprintf(stderr, "Unable to determine page size\n"),
>  				exit(2);
>  	if ((unsigned long) area_count(NULL, 0) + sizeof(unsigned long long) * 2
>  	    > page_size)
>  		fprintf(stderr, "Impossible to run this test\n"), exit(2);
> -	nr_pages_per_cpu = atol(argv[1]) * 1024*1024 / page_size /
> +}
> +
> +int main(int argc, char **argv)
> +{
> +	if (argc < 4)
> +		fprintf(stderr, "Usage: <test type> <MiB> <bounces> [hugetlbfs_file]\n"),
> +				exit(1);
> +
> +	set_test_type(argv[1]);
> +
> +	nr_cpus = sysconf(_SC_NPROCESSORS_ONLN);
> +	nr_pages_per_cpu = atol(argv[2]) * 1024*1024 / page_size /
>  		nr_cpus;
>  	if (!nr_pages_per_cpu) {
>  		fprintf(stderr, "invalid MiB\n");
>  		fprintf(stderr, "Usage: <MiB> <bounces>\n"), exit(1);
>  	}
> -	bounces = atoi(argv[2]);
> +
> +	bounces = atoi(argv[3]);
>  	if (bounces <= 0) {
>  		fprintf(stderr, "invalid bounces\n");
>  		fprintf(stderr, "Usage: <MiB> <bounces>\n"), exit(1);
>  	}
>  	nr_pages = nr_pages_per_cpu * nr_cpus;
> -	huge_fd = open(argv[3], O_CREAT | O_RDWR, 0755);
> -	if (huge_fd < 0) {
> -		fprintf(stderr, "Open of %s failed", argv[3]);
> -		perror("open");
> -		exit(1);
> -	}
> -	if (ftruncate(huge_fd, 0)) {
> -		fprintf(stderr, "ftruncate %s to size 0 failed", argv[3]);
> -		perror("ftruncate");
> -		exit(1);
> +
> +	if (test_type == TEST_HUGETLB) {
> +		if (argc < 5)
> +			fprintf(stderr, "Usage: hugetlb <MiB> <bounces> <hugetlbfs_file>\n"),
> +				exit(1);
> +		huge_fd = open(argv[4], O_CREAT | O_RDWR, 0755);
> +		if (huge_fd < 0) {
> +			fprintf(stderr, "Open of %s failed", argv[3]);
> +			perror("open");
> +			exit(1);
> +		}
> +		if (ftruncate(huge_fd, 0)) {
> +			fprintf(stderr, "ftruncate %s to size 0 failed", argv[3]);
> +			perror("ftruncate");
> +			exit(1);
> +		}
>  	}
>  	printf("nr_pages: %lu, nr_pages_per_cpu: %lu\n",
>  	       nr_pages, nr_pages_per_cpu);
>  	return userfaultfd_stress();
>  }
>  
> -#endif
>  #else /* __NR_userfaultfd */
>  
>  #warning "missing __NR_userfaultfd definition"
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
