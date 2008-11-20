Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id mAK1NX82032054
	for <linux-mm@kvack.org>; Wed, 19 Nov 2008 17:23:33 -0800
Received: from rv-out-0506.google.com (rvbk40.prod.google.com [10.140.87.40])
	by zps18.corp.google.com with ESMTP id mAK1NFY5005326
	for <linux-mm@kvack.org>; Wed, 19 Nov 2008 17:23:32 -0800
Received: by rv-out-0506.google.com with SMTP id k40so207397rvb.17
        for <linux-mm@kvack.org>; Wed, 19 Nov 2008 17:23:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0811200110180.19216@blonde.site>
References: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
	 <Pine.LNX.4.64.0811200110180.19216@blonde.site>
Date: Wed, 19 Nov 2008 17:23:31 -0800
Message-ID: <6599ad830811191723v3c346a17kf5ae5494987373c1@mail.gmail.com>
Subject: Re: [PATCH 1/7] mm: remove cgroup_mm_owner_callbacks
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 19, 2008 at 5:11 PM, Hugh Dickins <hugh@veritas.com> wrote:
>
>  assign_new_owner:
>        BUG_ON(c == p);
>        get_task_struct(c);
> -       read_unlock(&tasklist_lock);
> -       down_write(&mm->mmap_sem);
>        /*
>         * The task_lock protects c->mm from changing.
>         * We always want mm->owner->mm == mm
>         */
>        task_lock(c);
> +       /*
> +        * Delay read_unlock() till we have the task_lock()
> +        * to ensure that c does not slip away underneath us
> +        */
> +       read_unlock(&tasklist_lock);

How can c slip away when we've done get_task_struct(c) earlier?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
