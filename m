Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id B04F98E0001
	for <linux-mm@kvack.org>; Sat, 29 Sep 2018 06:28:26 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id j12-v6so4398649ota.3
        for <linux-mm@kvack.org>; Sat, 29 Sep 2018 03:28:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c51-v6si3703321otj.113.2018.09.29.03.28.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Sep 2018 03:28:25 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8TAOgUG132462
	for <linux-mm@kvack.org>; Sat, 29 Sep 2018 06:28:24 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mt5xy2gju-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 29 Sep 2018 06:28:24 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sat, 29 Sep 2018 11:28:21 +0100
Date: Sat, 29 Sep 2018 13:28:12 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] userfaultfd: selftest: cleanup help messages
References: <20180929084311.15600-1-peterx@redhat.com>
 <20180929084311.15600-2-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180929084311.15600-2-peterx@redhat.com>
Message-Id: <20180929102811.GA6429@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, Shuah Khan <shuah@kernel.org>, Jerome Glisse <jglisse@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kselftest@vger.kernel.org, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Sep 29, 2018 at 04:43:09PM +0800, Peter Xu wrote:
> Firstly, the help in the comment region is obsolete, now we support
> three parameters.  Since at it, change it and move it into the help
> message of the program.
> 
> Also, the help messages dumped here and there is obsolete too.  Use a
> single usage() helper.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Small comment below, otherwise

Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

> ---
>  tools/testing/selftests/vm/userfaultfd.c | 44 ++++++++++++++----------
>  1 file changed, 26 insertions(+), 18 deletions(-)
> 
> diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
> index 7b8171e3128a..2a84adaf8cf8 100644
> --- a/tools/testing/selftests/vm/userfaultfd.c
> +++ b/tools/testing/selftests/vm/userfaultfd.c
> @@ -34,18 +34,6 @@
>   * per-CPU threads 1 by triggering userfaults inside
>   * pthread_mutex_lock will also verify the atomicity of the memory
>   * transfer (UFFDIO_COPY).
> - *
> - * The program takes two parameters: the amounts of physical memory in
> - * megabytes (MiB) of the area and the number of bounces to execute.
> - *
> - * # 100MiB 99999 bounces
> - * ./userfaultfd 100 99999
> - *
> - * # 1GiB 99 bounces
> - * ./userfaultfd 1000 99
> - *
> - * # 10MiB-~6GiB 999 bounces, continue forever unless an error triggers
> - * while ./userfaultfd $[RANDOM % 6000 + 10] 999; do true; done
>   */
> 
>  #define _GNU_SOURCE
> @@ -115,6 +103,28 @@ pthread_attr_t attr;
>  				 ~(unsigned long)(sizeof(unsigned long long) \
>  						  -  1)))
> 
> +const char *examples =
> +    "# 100MiB 99999 bounces\n"
> +    "./userfaultfd anon 100 99999\n"
> +    "\n"
> +    "# 1GiB 99 bounces\n"
> +    "./userfaultfd anon 1000 99\n"
> +    "\n"
> +    "# 10MiB-~6GiB 999 bounces, continue forever unless an error triggers\n"
> +    "while ./userfaultfd anon $[RANDOM % 6000 + 10] 999; do true; done\n"
> +    "\n";

While at it, can you please update the examples to include other test
types?

> +
> +static void usage(void)
> +{
> +	fprintf(stderr, "\nUsage: ./userfaultfd <test type> <MiB> <bounces> "
> +		"[hugetlbfs_file]\n\n");
> +	fprintf(stderr, "Supported <test type>: anon, hugetlb, "
> +		"hugetlb_shared, shmem\n\n");
> +	fprintf(stderr, "Examples:\n\n");
> +	fprintf(stderr, examples);
> +	exit(1);
> +}
> +
>  static int anon_release_pages(char *rel_area)
>  {
>  	int ret = 0;
> @@ -1272,8 +1282,7 @@ static void sigalrm(int sig)
>  int main(int argc, char **argv)
>  {
>  	if (argc < 4)
> -		fprintf(stderr, "Usage: <test type> <MiB> <bounces> [hugetlbfs_file]\n"),
> -				exit(1);
> +		usage();
> 
>  	if (signal(SIGALRM, sigalrm) == SIG_ERR)
>  		fprintf(stderr, "failed to arm SIGALRM"), exit(1);
> @@ -1286,20 +1295,19 @@ int main(int argc, char **argv)
>  		nr_cpus;
>  	if (!nr_pages_per_cpu) {
>  		fprintf(stderr, "invalid MiB\n");
> -		fprintf(stderr, "Usage: <MiB> <bounces>\n"), exit(1);
> +		usage();
>  	}
> 
>  	bounces = atoi(argv[3]);
>  	if (bounces <= 0) {
>  		fprintf(stderr, "invalid bounces\n");
> -		fprintf(stderr, "Usage: <MiB> <bounces>\n"), exit(1);
> +		usage();
>  	}
>  	nr_pages = nr_pages_per_cpu * nr_cpus;
> 
>  	if (test_type == TEST_HUGETLB) {
>  		if (argc < 5)
> -			fprintf(stderr, "Usage: hugetlb <MiB> <bounces> <hugetlbfs_file>\n"),
> -				exit(1);
> +			usage();
>  		huge_fd = open(argv[4], O_CREAT | O_RDWR, 0755);
>  		if (huge_fd < 0) {
>  			fprintf(stderr, "Open of %s failed", argv[3]);
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.
