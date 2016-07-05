Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id D9B066B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 10:34:57 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id m127so137347167vkb.3
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 07:34:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n51si2468353qta.15.2016.07.05.07.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 07:34:57 -0700 (PDT)
Date: Tue, 5 Jul 2016 16:34:52 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: is pid_namespace leak in v3.10?
Message-ID: <20160705143452.GA20099@redhat.com>
References: <577B9CC5.3090404@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <577B9CC5.3090404@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: ebiederm@xmission.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/05, Xishi Qiu wrote:
>
> I find pid_namespace leak by "cat /proc/slabinfo | grep pid_namespace".
> The kernel version is RHEL 7.1 (kernel v3.10 stable).
> The following is the test case, after several times, the count of pid_namespace
> become very large, is it correct?

Apparently not,

> I also test mainline, and the count will increase too, but it seems stably later.

And I can't reproduce the problem with the latest rhel7 kernel.

And just in case, I have no idea what actually slub reports as "active_objs" but
certainly this is not the number of allocated "in use" objects, so it is fine if
this counter doesn't go to zero when your test-case exits. But it should not grow
"too much".

> BTW, this patch doesn't help.
> 24c037ebf5723d4d9ab0996433cee4f96c292a4d
> exit: pidns: alloc_pid() leaks pid_namespace if child_reaper is exiting

Sure, it can't help, your test-case doesn't fork other processes which could race
with the exiting sub-namespace init.


> int main()
> {
>         pid_t pid, child_pid;
>         int  i, status;
>         void *stack;
>
>         for (i = 0; i < 100; i++) {
>                 stack = malloc(8192);
>                 pid = clone(&test, (char *)stack + 8192, CLONE_NEWPID|SIGCHLD, 0);
>         }
>
>         sleep(5);

is this sleep() really needed to trigger the problem?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
