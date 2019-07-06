Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,GAPPY_SUBJECT,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D584C48BDA
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 18:21:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09B102070D
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 18:21:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="UjWcfa2y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09B102070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 532F66B0003; Sat,  6 Jul 2019 14:21:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E3E08E0003; Sat,  6 Jul 2019 14:21:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 383B08E0001; Sat,  6 Jul 2019 14:21:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 10E9F6B0003
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 14:21:04 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id n19so6218911ota.14
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 11:21:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vjy9ZMLMCWdJezrwnUnOrpuuoAl0MqUTiwkUbUfsV0k=;
        b=N2/Axj9IzlAna8SNVY1EG3HhQo+y0QZD3PwpINUqZVcevd+x4nWrEIBPNtXArdOL4k
         0L40V9e7oZbu4vn0By8Mkam59M0VARyNH0M2d7YbhF5WAhQQyuSsneQlkSv763CMM2AD
         3NBbF+6KXEO4soOycGVbdeFTgVB1TWi7HhFBioYHAv05uLpykobC8kVHZcG/rECdgQKU
         lLuSj6NfBcXj5QNQGh7AJgHg5LeGyT4mDVl6SV+ctefDkBTjNhDeheS2ldaJ3x4AJXxh
         F+XTfKrzVRvpC3uUEVopnO40ICphewTCxsITAi/ee2GxgALNkdG2bjbjWTMD/s/gcihD
         THtQ==
X-Gm-Message-State: APjAAAX0Lc7BJSQ2sEGNfEgUC7ODjrLrbrrKV+BqvFoyozHWxsThjvIc
	nMzJykNIfk0Vn6RbO+lDAqUZ/TKL3tlppyd0AH2g96HUX+Sq85kM5oruwC/e5qO3T4/p4mrHAL3
	YGQfSrv9OcgPHELbQnFa4xxOcyc7zhe8kU+5RqOWsefV9Gr7ZNm7jeZvoZiq2OBr5nQ==
X-Received: by 2002:aca:f582:: with SMTP id t124mr5306218oih.71.1562437263588;
        Sat, 06 Jul 2019 11:21:03 -0700 (PDT)
X-Received: by 2002:aca:f582:: with SMTP id t124mr5306190oih.71.1562437262639;
        Sat, 06 Jul 2019 11:21:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562437262; cv=none;
        d=google.com; s=arc-20160816;
        b=hFkdCk041RKXOFo0UYc8pJMN0Juv4oiWtCchfP/crG8nbK7wTffNokp0w/il58RpW9
         WtbkF0oWmsLhwZvjIEyEsFbuN6jZewEEtt2vZaBcbijG3PdUGW4nkI0RLs9D/1M7TrWA
         UM1BM6dHrD7ZPIiZuodPEmdKx4LX+x/ul7YqDRLgGc3EAcBPR2j78Pvw+kUwAXHiLJqo
         t8htXmIQDZMMpccm30QXcWl+eI19ICugT0SNOdUe6xO2tdmK2lGauWo9cYTAXu/9R4io
         o1n9DdDiYHI7qIvatsNhAriqo+YyA2OgWpl7cn/3Xg5MDTymU/+lqe5CP6YLyqD+bS/N
         mgjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vjy9ZMLMCWdJezrwnUnOrpuuoAl0MqUTiwkUbUfsV0k=;
        b=DL2PCW8rksIPStLI7C8lb+q/Diq3kb4IO9onRsEmjmBZF0tprMH8HuaIWdWx0miquU
         wp/GmuUpJTV+gb4Gl30wuLDjclKbC0rD6tQIb03r0CEDkvdd98AZSKu0j+9aO2K//H1Q
         ZJJJBN0zxXuKNuLGT3ww3naagPrqxbRXqb8I2RhbE6t8SsTtk9tUXVzezc85BD7iUCzf
         RAEUDYtoxic/6+klqRpZIhVH3xFXPPCidXRgptlSVxdeCgTv0DTFO000KeokUW/9fipD
         EXITj5Y2gzMxVZhetbHaD1QOZpI2WZVaTLp6wJ/bd0Nr1JCkjl30ekLhRDHf7PIaY6Gj
         cimQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UjWcfa2y;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c17sor6110354otk.82.2019.07.06.11.21.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jul 2019 11:21:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UjWcfa2y;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vjy9ZMLMCWdJezrwnUnOrpuuoAl0MqUTiwkUbUfsV0k=;
        b=UjWcfa2yuiQr3pr6jvHS9G7b7/XrW6vhOl4h4FyA2pkmQyD/Ukwh09WsYtkSmGlf36
         NaUNZYVoR4bKyHeWOylNLEXv5vLpalbjvzXxCYVwPOWxoj3K9lMpnkwGWJIVWHgk/Aam
         fgp58HCVxZAA3ggPprt8eU47o+2iD3IHtRrmkvzuzEKjw9xrg42OYiz27ZrFCVg3ZiAw
         PPhz7cmQ8J6Y7yCj4QkHQyabon240CsqoSLHPPTtKWV93yHoxLdYcTf8yeghcgy4y7Y1
         B9Juh+11Z1nJ1KPi3G3ufLi7AjloCOX15qfZkMELt6FbO4ouAg7q+pMykjE4c8bjWO5z
         4bhw==
X-Google-Smtp-Source: APXvYqzj5WEE2VrNr3N+Gwhig3lJufmMH6pDUKtfm7kJ7qx1O0a+Ca76u4RhV3hyGQEys/0AWVBDs6sVNq/tKZ0qalw=
X-Received: by 2002:a9d:5a91:: with SMTP id w17mr4400771oth.32.1562437262037;
 Sat, 06 Jul 2019 11:21:02 -0700 (PDT)
MIME-Version: 1.0
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com> <1562410493-8661-12-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1562410493-8661-12-git-send-email-s.mesoraca16@gmail.com>
From: Jann Horn <jannh@google.com>
Date: Sat, 6 Jul 2019 20:20:35 +0200
Message-ID: <CAG48ez0uFX4AniOk1W0Vs6j=7Q5QfSFQTrBBzC2qL2bpWn_yCg@mail.gmail.com>
Subject: Re: [PATCH v5 11/12] S.A.R.A.: /proc/*/mem write limitation
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Cc: kernel list <linux-kernel@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, 
	Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, 
	James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>, 
	PaX Team <pageexec@freemail.hu>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 6, 2019 at 12:55 PM Salvatore Mesoraca
<s.mesoraca16@gmail.com> wrote:
> Prevent a task from opening, in "write" mode, any /proc/*/mem
> file that operates on the task's mm.
> A process could use it to overwrite read-only memory, bypassing
> S.A.R.A. restrictions.
[...]
> +static void sara_task_to_inode(struct task_struct *t, struct inode *i)
> +{
> +       get_sara_inode_task(i) = t;

This looks bogus. Nothing is actually holding a reference to `t` here, right?

> +}
> +
>  static struct security_hook_list data_hooks[] __lsm_ro_after_init = {
>         LSM_HOOK_INIT(cred_prepare, sara_cred_prepare),
>         LSM_HOOK_INIT(cred_transfer, sara_cred_transfer),
>         LSM_HOOK_INIT(shm_alloc_security, sara_shm_alloc_security),
> +       LSM_HOOK_INIT(task_to_inode, sara_task_to_inode),
>  };
[...]
> +static int sara_file_open(struct file *file)
> +{
> +       struct task_struct *t;
> +       struct mm_struct *mm;
> +       u16 sara_wxp_flags = get_current_sara_wxp_flags();
> +
> +       /*
> +        * Prevent write access to /proc/.../mem
> +        * if it operates on the mm_struct of the
> +        * current process: it could be used to
> +        * bypass W^X.
> +        */
> +
> +       if (!sara_enabled ||
> +           !wxprot_enabled ||
> +           !(sara_wxp_flags & SARA_WXP_WXORX) ||
> +           !(file->f_mode & FMODE_WRITE))
> +               return 0;
> +
> +       t = get_sara_inode_task(file_inode(file));
> +       if (unlikely(t != NULL &&
> +                    strcmp(file->f_path.dentry->d_name.name,
> +                           "mem") == 0)) {

This should probably at least have a READ_ONCE() somewhere in case the
file concurrently gets renamed?

> +               get_task_struct(t);
> +               mm = get_task_mm(t);
> +               put_task_struct(t);

Getting and dropping a reference to the task_struct here is completely
useless. Either you have a reference, in which case you don't need to
take another one, or you don't have a reference, in which case you
also can't take one.

> +               if (unlikely(mm == current->mm))
> +                       sara_warn_or_goto(error,
> +                                         "write access to /proc/*/mem");

Why is the current process so special that it must be protected more
than other processes? Is the idea here to rely on other protections to
protect all other tasks? This should probably come with a comment that
explains this choice.

> +               mmput(mm);
> +       }
> +       return 0;
> +error:
> +       mmput(mm);
> +       return -EACCES;
> +}

