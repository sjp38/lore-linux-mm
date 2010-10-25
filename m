Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9FC5D8D0001
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 05:11:06 -0400 (EDT)
Received: from mail06.corp.redhat.com (zmail06.collab.prod.int.phx2.redhat.com [10.5.5.45])
	by mx4-phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o9P9B5Sc025629
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 05:11:05 -0400
Date: Mon, 25 Oct 2010 05:11:05 -0400 (EDT)
From: caiqian@redhat.com
Message-ID: <1877317998.247611287997865214.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <356409918.247361287997619777.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: understand KSM
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi everyone, while developing some tests for KSM in LTP - http://marc.info/?l=ltp-list&m=128754077917739&w=2 , noticed that pages_shared, pages_sharing and pages_unshared have different values than the expected values in the tests after read the doc. I am not sure if I misunderstood those values or there were bugs somewhere.

There are 3 programs (A, B ,C) to allocate 128M memory each using KSM.

A has memory content equal 'c'.
B has memory content equal 'a'.
C has memory content equal 'a'.

Then (using the latest mmotm tree),
pages_shared = 2
pages_sharing = 98292
pages_unshared = 0

Later,
A has memory content = 'c'
B has memory content = 'b'
C has memory content = 'a'.

Then,
pages_shared = 4
pages_sharing = 98282
pages_unshared = 0

Finally,
A has memory content = 'd'
B has memory content = 'd'
C has memory content = 'd'

Then,
pages_shared = 0
pages_sharing = 0
pages_unshared = 0

The following was the failed LTP output,

# ./ksm01 
ksm01       0  TINFO  :  KSM merging...
ksm01       0  TINFO  :  child 0 allocates 128 MB filled with 'c'.
ksm01       0  TINFO  :  child 1 allocates 128 MB filled with 'a'.
ksm01       0  TINFO  :  child 2 allocates 128 MB filled with 'a'.
ksm01       0  TINFO  :  check!
ksm01       0  TINFO  :  run is 1.
ksm01       0  TINFO  :  pages_shared is 2.
ksm01       1  TFAIL  :  pages_shared is not 32768.
ksm01       0  TINFO  :  pages_sharing is 98292.
ksm01       2  TFAIL  :  pages_sharing is not 32768.
ksm01       0  TINFO  :  pages_unshared is 0.
ksm01       3  TFAIL  :  pages_unshared is not 32768.
ksm01       0  TINFO  :  child 1 continues...
ksm01       0  TINFO  :  child 1 changes memory content to 'b'.
ksm01       0  TINFO  :  check!
ksm01       0  TINFO  :  run is 1.
ksm01       0  TINFO  :  pages_shared is 4.
ksm01       4  TFAIL  :  pages_shared is not 0.
ksm01       0  TINFO  :  pages_sharing is 98282.
ksm01       5  TFAIL  :  pages_sharing is not 0.
ksm01       0  TINFO  :  pages_unshared is 0.
ksm01       6  TFAIL  :  pages_unshared is not 98304.
ksm01       0  TINFO  :  child 0 continues...
ksm01       0  TINFO  :  child 0 changes memory content to 'd'.
ksm01       0  TINFO  :  child 1 continues...
ksm01       0  TINFO  :  child 1 changes memory content to 'd'
ksm01       0  TINFO  :  child 2 continues...
ksm01       0  TINFO  :  child 2 changes memory content to 'd'
ksm01       0  TINFO  :  check!
ksm01       0  TINFO  :  run is 1.
ksm01       0  TINFO  :  pages_shared is 0.
ksm01       7  TFAIL  :  pages_shared is not 32768.
ksm01       0  TINFO  :  pages_sharing is 0.
ksm01       8  TFAIL  :  pages_sharing is not 65536.
ksm01       0  TINFO  :  pages_unshared is 0.
ksm01       0  TINFO  :  KSM unmerging...
ksm01       0  TINFO  :  check!
ksm01       0  TINFO  :  run is 2.
ksm01       0  TINFO  :  pages_shared is 0.
ksm01       0  TINFO  :  pages_sharing is 0.
ksm01       0  TINFO  :  pages_unshared is 0.
ksm01       0  TINFO  :  stop KSM.
ksm01       0  TINFO  :  check!
ksm01       0  TINFO  :  run is 0.
ksm01       0  TINFO  :  pages_shared is 0.
ksm01       0  TINFO  :  pages_sharing is 0.
ksm01       0  TINFO  :  pages_unshared is 0.
ksm01       9  TFAIL  :  ksmtest() failed with 1.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
