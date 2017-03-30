Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A03E6B0038
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 19:04:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j70so60547805pge.11
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 16:04:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r11si3169690plj.231.2017.03.30.16.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 16:04:12 -0700 (PDT)
Date: Thu, 30 Mar 2017 16:04:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] fault-inject: support systematic fault injection
Message-Id: <20170330160411.06fb19fa0f80eafe7190d045@linux-foundation.org>
In-Reply-To: <20170328130128.101773-1-dvyukov@google.com>
References: <20170328130128.101773-1-dvyukov@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: akinobu.mita@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 28 Mar 2017 15:01:28 +0200 Dmitry Vyukov <dvyukov@google.com> wrote:

> +static ssize_t proc_fail_nth_write(struct file *file, const char __user *buf,
> +				   size_t count, loff_t *ppos)
> +{
> +	struct task_struct *task;
> +	int err, n;
> +
> +	task = get_proc_task(file_inode(file));
> +	if (!task)
> +		return -ESRCH;
> +	put_task_struct(task);
> +	if (task != current)
> +		return -EPERM;
> +	err = kstrtoint_from_user(buf, count, 10, &n);
> +	if (err)
> +		return err;
> +	if (n < 0 || n == INT_MAX)
> +		return -EINVAL;
> +	current->fail_nth = n + 1;
> +	return len;
> +}

Well that didn't go too well.

--- a/fs/proc/base.c~fault-inject-support-systematic-fault-injection-fix
+++ a/fs/proc/base.c
@@ -1377,7 +1377,7 @@ static ssize_t proc_fail_nth_write(struc
 	if (n < 0 || n == INT_MAX)
 		return -EINVAL;
 	current->fail_nth = n + 1;
-	return len;
+	return count;
 }
 
 static ssize_t proc_fail_nth_read(struct file *file, char __user *buf,

Are you sure I merged the correct version of this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
