Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0624A6B004A
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 04:03:27 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o9Q83Jwj006535
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 01:03:23 -0700
Received: from pvb32 (pvb32.prod.google.com [10.241.209.96])
	by wpaz1.hot.corp.google.com with ESMTP id o9Q83Hii012142
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 01:03:17 -0700
Received: by pvb32 with SMTP id 32so802310pvb.33
        for <linux-mm@kvack.org>; Tue, 26 Oct 2010 01:03:17 -0700 (PDT)
Date: Tue, 26 Oct 2010 01:03:12 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: understand KSM
In-Reply-To: <1877317998.247611287997865214.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Message-ID: <alpine.LSU.2.00.1010260045120.2939@sister.anvils>
References: <1877317998.247611287997865214.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: caiqian@redhat.com
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Oct 2010, caiqian@redhat.com wrote:

> Hi everyone, while developing some tests for KSM in LTP

Thank you!

> - http://marc.info/?l=ltp-list&m=128754077917739&w=2 , noticed that pages_shared, pages_sharing and pages_unshared have different values than the expected values in the tests after read the doc. I am not sure if I misunderstood those values or there were bugs somewhere.

You were expecting KSM to share pages between processes, but you were
not expecting it to share pages within a process, which it does also.

To check the exact numbers, it would be easier if you use page-aligned
mmap() rather than byte-aligned malloc() for your MADV_MERGEABLE buffers:
some numbers are a little "off" because of part-pages at start and end.

> 
> There are 3 programs (A, B ,C) to allocate 128M memory each using KSM.
> 
> A has memory content equal 'c'.
> B has memory content equal 'a'.
> C has memory content equal 'a'.
> 
> Then (using the latest mmotm tree),
> pages_shared = 2
> pages_sharing = 98292
> pages_unshared = 0

So, after KSM has done its best, it all reduces to 1 page full of 'a's
and another 1 page full of 'c's.

> 
> Later,
> A has memory content = 'c'
> B has memory content = 'b'
> C has memory content = 'a'.
> 
> Then,
> pages_shared = 4
> pages_sharing = 98282
> pages_unshared = 0

pages_shared 3 would be the obvious: I expect the extra 1 is an artifact
of part-pages at start and end of your buffers, a page shared there too.

> 
> Finally,
> A has memory content = 'd'
> B has memory content = 'd'
> C has memory content = 'd'
> 
> Then,
> pages_shared = 0
> pages_sharing = 0
> pages_unshared = 0

The children appear to exit(1) as soon as they have filled
their buffers with 'd's, so there's nothing left to share.

Hugh

> 
> The following was the failed LTP output,
> 
> # ./ksm01 
> ksm01       0  TINFO  :  KSM merging...
> ksm01       0  TINFO  :  child 0 allocates 128 MB filled with 'c'.
> ksm01       0  TINFO  :  child 1 allocates 128 MB filled with 'a'.
> ksm01       0  TINFO  :  child 2 allocates 128 MB filled with 'a'.
> ksm01       0  TINFO  :  check!
> ksm01       0  TINFO  :  run is 1.
> ksm01       0  TINFO  :  pages_shared is 2.
> ksm01       1  TFAIL  :  pages_shared is not 32768.
> ksm01       0  TINFO  :  pages_sharing is 98292.
> ksm01       2  TFAIL  :  pages_sharing is not 32768.
> ksm01       0  TINFO  :  pages_unshared is 0.
> ksm01       3  TFAIL  :  pages_unshared is not 32768.
> ksm01       0  TINFO  :  child 1 continues...
> ksm01       0  TINFO  :  child 1 changes memory content to 'b'.
> ksm01       0  TINFO  :  check!
> ksm01       0  TINFO  :  run is 1.
> ksm01       0  TINFO  :  pages_shared is 4.
> ksm01       4  TFAIL  :  pages_shared is not 0.
> ksm01       0  TINFO  :  pages_sharing is 98282.
> ksm01       5  TFAIL  :  pages_sharing is not 0.
> ksm01       0  TINFO  :  pages_unshared is 0.
> ksm01       6  TFAIL  :  pages_unshared is not 98304.
> ksm01       0  TINFO  :  child 0 continues...
> ksm01       0  TINFO  :  child 0 changes memory content to 'd'.
> ksm01       0  TINFO  :  child 1 continues...
> ksm01       0  TINFO  :  child 1 changes memory content to 'd'
> ksm01       0  TINFO  :  child 2 continues...
> ksm01       0  TINFO  :  child 2 changes memory content to 'd'
> ksm01       0  TINFO  :  check!
> ksm01       0  TINFO  :  run is 1.
> ksm01       0  TINFO  :  pages_shared is 0.
> ksm01       7  TFAIL  :  pages_shared is not 32768.
> ksm01       0  TINFO  :  pages_sharing is 0.
> ksm01       8  TFAIL  :  pages_sharing is not 65536.
> ksm01       0  TINFO  :  pages_unshared is 0.
> ksm01       0  TINFO  :  KSM unmerging...
> ksm01       0  TINFO  :  check!
> ksm01       0  TINFO  :  run is 2.
> ksm01       0  TINFO  :  pages_shared is 0.
> ksm01       0  TINFO  :  pages_sharing is 0.
> ksm01       0  TINFO  :  pages_unshared is 0.
> ksm01       0  TINFO  :  stop KSM.
> ksm01       0  TINFO  :  check!
> ksm01       0  TINFO  :  run is 0.
> ksm01       0  TINFO  :  pages_shared is 0.
> ksm01       0  TINFO  :  pages_sharing is 0.
> ksm01       0  TINFO  :  pages_unshared is 0.
> ksm01       9  TFAIL  :  ksmtest() failed with 1.
> 
> CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
