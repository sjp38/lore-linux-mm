Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1956B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 10:57:53 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u3so174536007pgn.12
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 07:57:53 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id o3si17762134pld.201.2017.04.04.07.57.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 07:57:51 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id g2so37693676pge.2
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 07:57:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170328130128.101773-1-dvyukov@google.com>
References: <20170328130128.101773-1-dvyukov@google.com>
From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Tue, 4 Apr 2017 23:57:31 +0900
Message-ID: <CAC5umyggX4OLBSG5z0gLZ3Tc0=ev_DrcgbRbKnw9i=uzXTSsUg@mail.gmail.com>
Subject: Re: [PATCH v2] fault-inject: support systematic fault injection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

2017-03-28 22:01 GMT+09:00 Dmitry Vyukov <dvyukov@google.com>:
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 6e8655845830..66001172249b 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -1353,6 +1353,53 @@ static const struct file_operations proc_fault_inject_operations = {
>         .write          = proc_fault_inject_write,
>         .llseek         = generic_file_llseek,
>  };
> +
> +static ssize_t proc_fail_nth_write(struct file *file, const char __user *buf,
> +                                  size_t count, loff_t *ppos)
> +{
> +       struct task_struct *task;
> +       int err, n;
> +
> +       task = get_proc_task(file_inode(file));
> +       if (!task)
> +               return -ESRCH;
> +       put_task_struct(task);
> +       if (task != current)
> +               return -EPERM;
> +       err = kstrtoint_from_user(buf, count, 10, &n);
> +       if (err)
> +               return err;
> +       if (n < 0 || n == INT_MAX)
> +               return -EINVAL;
> +       current->fail_nth = n + 1;
> +       return len;
> +}
> +
> +static ssize_t proc_fail_nth_read(struct file *file, char __user *buf,
> +                                 size_t count, loff_t *ppos)
> +{
> +       struct task_struct *task;
> +       int err;
> +
> +       task = get_proc_task(file_inode(file));
> +       if (!task)
> +               return -ESRCH;
> +       put_task_struct(task);
> +       if (task != current)
> +               return -EPERM;
> +       if (count < 1)
> +               return -EINVAL;
> +       err = put_user((char)(current->fail_nth ? 'N' : 'Y'), buf);
> +       if (err)
> +               return err;
> +       current->fail_nth = 0;
> +       return 1;
> +}
> +
> +static const struct file_operations proc_fail_nth_operations = {
> +       .read           = proc_fail_nth_read,
> +       .write          = proc_fail_nth_write,
> +};
>  #endif
>
>
> @@ -3296,6 +3343,11 @@ static const struct pid_entry tid_base_stuff[] = {
>  #endif
>  #ifdef CONFIG_FAULT_INJECTION
>         REG("make-it-fail", S_IRUGO|S_IWUSR, proc_fault_inject_operations),
> +       /*
> +        * Operations on the file check that the task is current,
> +        * so we create it with 0666 to support testing under unprivileged user.
> +        */
> +       REG("fail-nth", 0666, proc_fail_nth_operations),
>  #endif

This file is owned by the currnet user.  So we can create it with 0644
and just allow unprivileged user to write it.  And it enables to remove
the check that the task is current or not in read/write operations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
