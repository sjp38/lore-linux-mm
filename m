Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m0S7n6p9005200
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 07:49:06 GMT
Received: from py-out-1112.google.com (pyia25.prod.google.com [10.34.253.25])
	by zps19.corp.google.com with ESMTP id m0S7n4EW023495
	for <linux-mm@kvack.org>; Sun, 27 Jan 2008 23:49:05 -0800
Received: by py-out-1112.google.com with SMTP id a25so1857303pyi.13
        for <linux-mm@kvack.org>; Sun, 27 Jan 2008 23:49:04 -0800 (PST)
Message-ID: <6599ad830801272349p4b076ba5u8c491a92128fb1a9@mail.gmail.com>
Date: Sun, 27 Jan 2008 23:49:04 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] reject '\n' in a cgroup name
In-Reply-To: <20080124052049.A2A8A1E3C0D@siro.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080124052049.A2A8A1E3C0D@siro.lan>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: containers@lists.osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Looks sensible - maybe we should ban all characters not in [a-zA-Z0-9._-] ?

Paul

On Jan 23, 2008 9:20 PM, YAMAMOTO Takashi <yamamoto@valinux.co.jp> wrote:
> hi,
>
> the following patch rejects '\n' in a cgroup name.
> otherwise /proc/$$/cgroup is not parsable.
>
> example:
>         imawoto% cat /proc/$$/cgroup
>         memory:/
>         imawoto% mkdir -p "
>         memory:/foo"
>         imawoto% echo $$ >| "
>         memory:/foo/tasks"
>         imawoto% cat /proc/$$/cgroup
>         memory:/
>         memory:/foo
>         imawoto%
>
> YAMAMOTO Takashi
>
>
> Signed-off-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
> ---
>
> --- linux-2.6.24-rc8-mm1/kernel/cgroup.c.BACKUP 2008-01-23 14:43:29.000000000 +0900
> +++ linux-2.6.24-rc8-mm1/kernel/cgroup.c        2008-01-24 13:56:28.000000000 +0900
> @@ -2216,6 +2216,10 @@ static long cgroup_create(struct cgroup
>         struct cgroup_subsys *ss;
>         struct super_block *sb = root->sb;
>
> +       /* reject a newline.  otherwise /proc/$$/cgroup is not parsable. */
> +       if (strchr(dentry->d_name.name, '\n'))
> +               return -EINVAL;
> +
>         cgrp = kzalloc(sizeof(*cgrp), GFP_KERNEL);
>         if (!cgrp)
>                 return -ENOMEM;
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
