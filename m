Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id C02B16B006E
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 17:02:57 -0400 (EDT)
Received: by patj18 with SMTP id j18so95323160pat.2
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 14:02:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id kn10si4051959pbc.26.2015.04.02.14.02.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Apr 2015 14:02:56 -0700 (PDT)
Date: Thu, 2 Apr 2015 14:02:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 481/507] kernel/sys.c:1713:19: sparse: incorrect
 type in initializer (different address spaces)
Message-Id: <20150402140255.05d2bbfcbca82b3238db7912@linux-foundation.org>
In-Reply-To: <201504021041.IXmhrcFg%fengguang.wu@intel.com>
References: <201504021041.IXmhrcFg%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 2 Apr 2015 10:04:43 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   c226e49f30453de9c6d82b001a985254990b32e0
> commit: 3de343256baf44761d580e5bec367065d8f361f1 [481/507] prctl: avoid using mmap_sem for exe_file serialization
> reproduce:
>   # apt-get install sparse
>   git checkout 3de343256baf44761d580e5bec367065d8f361f1
>   make ARCH=x86_64 allmodconfig
>   make C=1 CF=-D__CHECK_ENDIAN__
> 
> 
> sparse warnings: (new ones prefixed by >>)
> 
>    kernel/sys.c:886:49: sparse: incorrect type in argument 2 (different modifiers)
>    kernel/sys.c:886:49:    expected unsigned long [nocast] [usertype] *ut
>    kernel/sys.c:886:49:    got unsigned long *<noident>
>    kernel/sys.c:886:49: sparse: implicit cast to nocast type
>    kernel/sys.c:886:59: sparse: incorrect type in argument 3 (different modifiers)
>    kernel/sys.c:886:59:    expected unsigned long [nocast] [usertype] *st
>    kernel/sys.c:886:59:    got unsigned long *<noident>
>    kernel/sys.c:886:59: sparse: implicit cast to nocast type
>
> ...
> 
>   1547		unsigned long maxrss = 0;
>   1548	
>   1549		memset((char *)r, 0, sizeof (*r));
>   1550		utime = stime = 0;
>   1551	
>   1552		if (who == RUSAGE_THREAD) {
> > 1553			task_cputime_adjusted(current, &utime, &stime);
>   1554			accumulate_thread_rusage(p, r);
>   1555			maxrss = p->signal->maxrss;
>   1556			goto out;
>   1557		}

The warnings seem bogus - everything is using cputime_t?

And I don't see how "prctl: avoid using mmap_sem for exe_file
serialization" could have caused this even if it is wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
