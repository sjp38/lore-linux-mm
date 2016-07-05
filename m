Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0C7C7828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 07:41:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a69so443112668pfa.1
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 04:41:12 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id o129si3823328pfb.247.2016.07.05.04.41.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Jul 2016 04:41:11 -0700 (PDT)
Message-ID: <577B9CC5.3090404@huawei.com>
Date: Tue, 5 Jul 2016 19:40:53 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: is pid_namespace leak in v3.10?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com, ebiederm@xmission.com
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

I find pid_namespace leak by "cat /proc/slabinfo | grep pid_namespace".
The kernel version is RHEL 7.1 (kernel v3.10 stable).
The following is the test case, after several times, the count of pid_namespace
become very large, is it correct?

I also test mainline, and the count will increase too, but it seems stably later.

BTW, this patch doesn't help.
24c037ebf5723d4d9ab0996433cee4f96c292a4d
exit: pidns: alloc_pid() leaks pid_namespace if child_reaper is exiting

Thanks,
Xishi Qiu


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <signal.h>

#ifndef CLONE_NEWPID
#define CLONE_NEWPID            0x20000000
#endif

void test(void)
{
        printf("clone child\n");
        exit(0);
}

int main()
{
        pid_t pid, child_pid;
        int  i, status;
        void *stack;

        for (i = 0; i < 100; i++) {
                stack = malloc(8192);
                pid = clone(&test, (char *)stack + 8192, CLONE_NEWPID|SIGCHLD, 0);
        }

        sleep(5);

        return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
