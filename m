Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id ACFB36B026F
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 20:41:26 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id d66so448941ioe.23
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 17:41:26 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id l20si63864ioc.203.2017.11.06.17.41.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 17:41:24 -0800 (PST)
Subject: Re: [PATCH v2 9/9] memfd-test: run fuse test on hugetlb backend
 memory
References: <20171106143944.13821-1-marcandre.lureau@redhat.com>
 <20171106143944.13821-10-marcandre.lureau@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <988f32e8-9073-0022-076b-6f86dc650a9c@oracle.com>
Date: Mon, 6 Nov 2017 17:41:16 -0800
MIME-Version: 1.0
In-Reply-To: <20171106143944.13821-10-marcandre.lureau@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com

On 11/06/2017 06:39 AM, Marc-AndrA(C) Lureau wrote:
> Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
> Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>
> ---
>  tools/testing/selftests/memfd/fuse_test.c      | 30 ++++++++++++++++++++++----
>  tools/testing/selftests/memfd/run_fuse_test.sh |  2 +-
>  tools/testing/selftests/memfd/run_tests.sh     |  1 +
>  3 files changed, 28 insertions(+), 5 deletions(-)
> 
> diff --git a/tools/testing/selftests/memfd/fuse_test.c b/tools/testing/selftests/memfd/fuse_test.c
> index 795a25ba8521..0a85b34929e1 100644
> --- a/tools/testing/selftests/memfd/fuse_test.c
> +++ b/tools/testing/selftests/memfd/fuse_test.c
> @@ -38,6 +38,8 @@
>  #define MFD_DEF_SIZE 8192
>  #define STACK_SIZE 65536
>  
> +static size_t mfd_def_size = MFD_DEF_SIZE;
> +
>  static int mfd_assert_new(const char *name, loff_t sz, unsigned int flags)
>  {
>  	int r, fd;
> @@ -123,7 +125,7 @@ static void *mfd_assert_mmap_shared(int fd)
>  	void *p;
>  
>  	p = mmap(NULL,
> -		 MFD_DEF_SIZE,
> +		 mfd_def_size,
>  		 PROT_READ | PROT_WRITE,
>  		 MAP_SHARED,
>  		 fd,
> @@ -141,7 +143,7 @@ static void *mfd_assert_mmap_private(int fd)
>  	void *p;
>  
>  	p = mmap(NULL,
> -		 MFD_DEF_SIZE,
> +		 mfd_def_size,
>  		 PROT_READ | PROT_WRITE,
>  		 MAP_PRIVATE,
>  		 fd,
> @@ -174,7 +176,7 @@ static int sealing_thread_fn(void *arg)
>  	usleep(200000);
>  
>  	/* unmount mapping before sealing to avoid i_mmap_writable failures */
> -	munmap(global_p, MFD_DEF_SIZE);
> +	munmap(global_p, mfd_def_size);
>  
>  	/* Try sealing the global file; expect EBUSY or success. Current
>  	 * kernels will never succeed, but in the future, kernels might
> @@ -224,7 +226,7 @@ static void join_sealing_thread(pid_t pid)
>  
>  int main(int argc, char **argv)
>  {
> -	static const char zero[MFD_DEF_SIZE];
> +	char *zero;
>  	int fd, mfd, r;
>  	void *p;
>  	int was_sealed;
> @@ -235,6 +237,25 @@ int main(int argc, char **argv)
>  		abort();
>  	}
>  
> +	if (argc >= 3) {
> +		if (!strcmp(argv[2], "hugetlbfs")) {
> +			unsigned long hpage_size = default_huge_page_size();
> +
> +			if (!hpage_size) {
> +				printf("Unable to determine huge page size\n");
> +				abort();
> +			}
> +
> +			hugetlbfs_test = 1;
> +			mfd_def_size = hpage_size * 2;
> +		} else {
> +			printf("Unknown option: %s\n", argv[2]);
> +			abort();
> +		}
> +	}
> +
> +	zero = calloc(sizeof(*zero), mfd_def_size);
> +
>  	/* open FUSE memfd file for GUP testing */
>  	printf("opening: %s\n", argv[1]);
>  	fd = open(argv[1], O_RDONLY | O_CLOEXEC);

When ftruncate'ing the newly created file, you need to make sure length is
a multiple of huge page size for hugetlbfs files.  So, you will want to
do something like:

--- a/tools/testing/selftests/memfd/fuse_test.c
+++ b/tools/testing/selftests/memfd/fuse_test.c
@@ -265,7 +265,7 @@ int main(int argc, char **argv)
 
        /* create new memfd-object */
        mfd = mfd_assert_new("kern_memfd_fuse",
-                            MFD_DEF_SIZE,
+                            mfd_def_size,
                             MFD_CLOEXEC | MFD_ALLOW_SEALING);
 
        /* mmap memfd-object for writing */

Leaving MFD_DEF_SIZE for the size of reads and writes should be fine.

-- 
Mike Kravetz

> @@ -303,6 +324,7 @@ int main(int argc, char **argv)
>  	close(fd);
>  
>  	printf("fuse: DONE\n");
> +	free(zero);
>  
>  	return 0;
>  }
> diff --git a/tools/testing/selftests/memfd/run_fuse_test.sh b/tools/testing/selftests/memfd/run_fuse_test.sh
> index 407df68dfe27..22e572e2d66a 100755
> --- a/tools/testing/selftests/memfd/run_fuse_test.sh
> +++ b/tools/testing/selftests/memfd/run_fuse_test.sh
> @@ -10,6 +10,6 @@ set -e
>  
>  mkdir mnt
>  ./fuse_mnt ./mnt
> -./fuse_test ./mnt/memfd
> +./fuse_test ./mnt/memfd $@
>  fusermount -u ./mnt
>  rmdir ./mnt
> diff --git a/tools/testing/selftests/memfd/run_tests.sh b/tools/testing/selftests/memfd/run_tests.sh
> index daabb350697c..c2d41ed81b24 100755
> --- a/tools/testing/selftests/memfd/run_tests.sh
> +++ b/tools/testing/selftests/memfd/run_tests.sh
> @@ -60,6 +60,7 @@ fi
>  # Run the hugetlbfs test
>  #
>  ./memfd_test hugetlbfs
> +./run_fuse_test.sh hugetlbfs
>  
>  #
>  # Give back any huge pages allocated for the test
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
