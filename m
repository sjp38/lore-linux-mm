Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2C4496B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 04:07:43 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id q10so8523190pdj.34
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 01:07:42 -0700 (PDT)
Message-ID: <525CF787.6050107@asianux.com>
Date: Tue, 15 Oct 2013 16:06:31 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] mm/readahead.c: need always return 0 when system call readahead()
 succeeds
References: <5212E328.40804@asianux.com> <20130820161639.69ffa65b40c5cf761bbb727c@linux-foundation.org> <521428D0.2020708@asianux.com> <20130917155644.cc988e7e929fee10e9c86d86@linux-foundation.org> <52390907.7050101@asianux.com>
In-Reply-To: <52390907.7050101@asianux.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, rientjes@google.com, sasha.levin@oracle.com, linux@rasmusvillemoes.dk, kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, lczerner@redhat.com, linux-mm@kvack.org

For system call readahead(), need always return 0 instead of bytes read
when succeed. The related commit "fee53ce mm/readahead.c: return the
value which force_page_cache_readahead() returns" causes this issue.

This bug is found by LTP readahead02 test, the related output:

  [root@gchenlinux readahead]# ./readahead02
  readahead02    0  TINFO  :  creating test file of size: 67108864
  readahead02    0  TINFO  :  read_testfile(0)
  readahead02    0  TINFO  :  read_testfile(1)
  readahead02    1  TFAIL  :  unexpected failure - returned value = 16384, expected: 0
  readahead02    2  TPASS  :  offset is still at 0 as expected
  readahead02    0  TINFO  :  read_testfile(0) took: 2292819 usec
  readahead02    0  TINFO  :  read_testfile(1) took: 3524116 usec
  readahead02    0  TINFO  :  read_testfile(0) read: 67108864 bytes
  readahead02    0  TINFO  :  read_testfile(1) read: 0 bytes
  readahead02    3  TPASS  :  readahead saved some I/O
  readahead02    0  TINFO  :  cache can hold at least: 624316 kB
  readahead02    0  TINFO  :  read_testfile(0) used cache: 65476 kB
  readahead02    0  TINFO  :  read_testfile(1) used cache: 65632 kB
  readahead02    4  TPASS  :  using cache as expected

After this fix, it can pass LTP common test by readahead01 and readahead02.

  [root@gchenlinux readahead]# ./readahead01 
  readahead01    0  TINFO  :  test_bad_fd -1
  readahead01    1  TPASS  :  expected ret success - returned value = -1
  readahead01    2  TPASS  :  expected failure: TEST_ERRNO=EBADF(9): Bad file descriptor
  readahead01    0  TINFO  :  test_bad_fd O_WRONLY
  readahead01    3  TPASS  :  expected ret success - returned value = -1
  readahead01    4  TPASS  :  expected failure: TEST_ERRNO=EBADF(9): Bad file descriptor
  readahead01    0  TINFO  :  test_invalid_fd pipe
  readahead01    5  TPASS  :  expected ret success - returned value = -1
  readahead01    6  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
  readahead01    0  TINFO  :  test_invalid_fd socket
  readahead01    7  TPASS  :  expected ret success - returned value = -1
  readahead01    8  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
  [root@gchenlinux readahead]# ./readahead02
  readahead02    0  TINFO  :  creating test file of size: 67108864
  readahead02    0  TINFO  :  read_testfile(0)
  readahead02    0  TINFO  :  read_testfile(1)
  readahead02    1  TPASS  :  expected ret success - returned value = 0
  readahead02    2  TPASS  :  offset is still at 0 as expected
  readahead02    0  TINFO  :  read_testfile(0) took: 3327468 usec
  readahead02    0  TINFO  :  read_testfile(1) took: 2802184 usec
  readahead02    0  TINFO  :  read_testfile(0) read: 67108864 bytes
  readahead02    0  TINFO  :  read_testfile(1) read: 0 bytes
  readahead02    3  TPASS  :  readahead saved some I/O
  readahead02    0  TINFO  :  cache can hold at least: 794800 kB
  readahead02    0  TINFO  :  read_testfile(0) used cache: 66704 kB
  readahead02    0  TINFO  :  read_testfile(1) used cache: 65528 kB
  readahead02    4  TPASS  :  using cache as expected


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/readahead.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index 1eee42b..83a202e 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -592,5 +592,5 @@ SYSCALL_DEFINE3(readahead, int, fd, loff_t, offset, size_t, count)
 		}
 		fdput(f);
 	}
-	return ret;
+	return ret < 0 ? ret : 0;
 }
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
