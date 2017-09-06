Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2253A6B04E2
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 22:15:09 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a2so10231733pfj.2
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 19:15:09 -0700 (PDT)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id m25si307265pfe.214.2017.09.05.19.15.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Sep 2017 19:15:08 -0700 (PDT)
Message-ID: <59AF5A20.2000101@huawei.com>
Date: Wed, 6 Sep 2017 10:14:56 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] a question about stack size form /proc/pid/task/child pid/limits
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, zhong jiang <zhongjiang@huawei.com>

Hi, I find if I use a defined stack size to create a child thread,
then the max stack size from /proc/pid/task/child pid/limits still
shows "Max stack size            8388608", it doesn't update to
the user defined size, is it a problem?

Here is the test code:
		...
                pthread_attr_t attr;
                ret = pthread_attr_init(&attr);
                if (ret)
                        printf("error\n");
                ret = pthread_attr_setstacksize(&attr, 83886080);
                if (ret)
                        printf("error\n");
                ret = pthread_create(&id_1[i], &attr, (void  *)thread_alloc, NULL);
		...

I use strace to track the app, it shows glibc will call mmap to
alloc the child thread stack. So should gilbc call setrlimit to
update the stack limit too?

And glibc will only insert a guard at the start of the stack vma,
so the stack vma maybe merged to another vma at the end, right?

...
mmap(NULL, 83890176, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS|MAP_STACK, -1, 0) = 0x7fca1d6a6000
mprotect(0x7fca1d6a6000, 4096, PROT_NONE) = 0
clone(child_stack=0x7fca226a5fb0, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0x7fca226a69d0, tls=0x7fca226a6700, child_tidptr=0x7fca226a69d0) = 21043
...

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
