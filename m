Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC8B6B0271
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 20:47:30 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id f199so8641335qke.20
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 17:47:30 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f21si84176qka.383.2017.11.06.17.47.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 17:47:29 -0800 (PST)
Subject: Re: [PATCH v2 0/9] memfd: add sealing to hugetlb-backed memory
References: <20171106143944.13821-1-marcandre.lureau@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <feeb8164-134f-5efa-018c-b80ca8e26414@oracle.com>
Date: Mon, 6 Nov 2017 17:47:21 -0800
MIME-Version: 1.0
In-Reply-To: <20171106143944.13821-1-marcandre.lureau@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com, David Herrmann <dh.herrmann@gmail.com>

On 11/06/2017 06:39 AM, Marc-AndrA(C) Lureau wrote:
> Hi,
> 
> Recently, Mike Kravetz added hugetlbfs support to memfd. However, he
> didn't add sealing support. One of the reasons to use memfd is to have
> shared memory sealing when doing IPC or sharing memory with another
> process with some extra safety. qemu uses shared memory & hugetables
> with vhost-user (used by dpdk), so it is reasonable to use memfd
> now instead for convenience and security reasons.

Thanks for doing this.

I will create a patch to restructure the code such that memfd_create (and
file sealing) is split out and will depend on CONFIG_TMPFS -or-
CONFIG_HUGETLBFS.  I think this can wait to go in until after this patch
series.  Unless, someone prefers that it go in first?

-- 
Mike Kravetz


> 
> Thanks!
> 
> v1->v2: after Mike review,
> - add "memfd-hugetlb:" prefix in memfd-test
> - run fuse test on hugetlb backend memory
> - rename function memfd_file_get_seals() -> memfd_file_seals_ptr()
> - update commit messages
> - added reviewed-by tags
> 
> RFC->v1:
> - split rfc patch, after early review feedback
> - added patch for memfd-test changes
> - fix build with hugetlbfs disabled
> - small code and commit messages improvements
> 
> Marc-AndrA(C) Lureau (9):
>   shmem: unexport shmem_add_seals()/shmem_get_seals()
>   shmem: rename functions that are memfd-related
>   hugetlb: expose hugetlbfs_inode_info in header
>   hugetlbfs: implement memfd sealing
>   shmem: add sealing support to hugetlb-backed memfd
>   memfd-tests: test hugetlbfs sealing
>   memfd-test: add 'memfd-hugetlb:' prefix when testing hugetlbfs
>   memfd-test: move common code to a shared unit
>   memfd-test: run fuse test on hugetlb backend memory
> 
>  fs/fcntl.c                                     |   2 +-
>  fs/hugetlbfs/inode.c                           |  39 +++--
>  include/linux/hugetlb.h                        |  11 ++
>  include/linux/shmem_fs.h                       |   6 +-
>  mm/shmem.c                                     |  59 ++++---
>  tools/testing/selftests/memfd/Makefile         |   5 +
>  tools/testing/selftests/memfd/common.c         |  45 ++++++
>  tools/testing/selftests/memfd/common.h         |   9 ++
>  tools/testing/selftests/memfd/fuse_test.c      |  36 +++--
>  tools/testing/selftests/memfd/memfd_test.c     | 212 ++++---------------------
>  tools/testing/selftests/memfd/run_fuse_test.sh |   2 +-
>  tools/testing/selftests/memfd/run_tests.sh     |   1 +
>  12 files changed, 195 insertions(+), 232 deletions(-)
>  create mode 100644 tools/testing/selftests/memfd/common.c
>  create mode 100644 tools/testing/selftests/memfd/common.h
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
