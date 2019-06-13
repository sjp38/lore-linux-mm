Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41739C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:32:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC3C821537
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:32:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mh0Rc495"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC3C821537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F17C8E0001; Thu, 13 Jun 2019 16:32:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A2636B000C; Thu, 13 Jun 2019 16:32:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B6DC8E0001; Thu, 13 Jun 2019 16:32:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 14E2A6B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:32:44 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id x22so85869vsj.1
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:32:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XnwdqEB/zxSUoi8AX3TTUKJIQzqvpn/EDnWBDbRAeC0=;
        b=e9adcK5/bJ1Efv9aMgwbmthfqKhyWxe7XpxxfW8dWEXPcwi5d6vhkVxf9BpoODnCP3
         muSloVlqni/MLnDJG/Mr6LJerBN94c2updGRju11WmYG3bQ2QDVsI7N9DtUgcY7TPtWc
         FltsRBO/AoXKSP+HM3IETjObH2THrbdk7lkBcqM65uxmBl3FVgcgd5bM+I/aav+xPI8q
         FHXZJyIpJ8idnSNuJ5VsdueiP/RpLANUbr0zROfooH7H2Uup7tVedNAYSG5ucW+ih/UR
         eoGbU99LJi/BcTbVETUzWmTrc6e44bu953GSU7ayrW4YTBtirShRpq+LtDdE6zQlXycr
         ho8w==
X-Gm-Message-State: APjAAAUp4EJT648+fHfMnKV8ySLgBvXa0K17ytSn+jT7WVmpPMf/IPTh
	EOoOXPY2WGN4DFPrRBaNGAH1L2Oc8zo6dpsDTXNKrXi1vEyDc+Guh88H/HUAQXfMSsoAvbgiIBw
	olOVy5NpTgYZmqm7oPOFCLvNjTR7nfShjmKxxWS2af51sUiuOyIHtzrzO9VmQjiG+0g==
X-Received: by 2002:a67:7fd8:: with SMTP id a207mr27154946vsd.85.1560457963752;
        Thu, 13 Jun 2019 13:32:43 -0700 (PDT)
X-Received: by 2002:a67:7fd8:: with SMTP id a207mr27154874vsd.85.1560457963037;
        Thu, 13 Jun 2019 13:32:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560457963; cv=none;
        d=google.com; s=arc-20160816;
        b=wRa+RlikDbPElWKrzlmplfvs7pkhWvV6BmkggAmCsq7BOUp7Gm7Zpy8tCTeHC02u6H
         tvSWTIkiJo27+/pcaa5YwS1b4jMVOA1BXrXCMyDUiMDdHI9f9Su3x5WjtTrbByEh4Yg8
         FHXpuLLJ2cgS8dZ/Ssd7yCfQd6cidQQcfdCo01JMwCY8p1yT246epDEY5L2FKafB3G44
         sPVd5cr7owCTKUDz/2XJoE7aBMkoGPrCgpmMFtIcwEYDLaTbHvkY55JmzvXuKVNpGGMc
         ZE/yUBU7znIcbAPdgs+uOx4guGAGvipEMxG8LdBCbcWrLynYgiEOMhEXQl2g9TLAyTdx
         mH5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XnwdqEB/zxSUoi8AX3TTUKJIQzqvpn/EDnWBDbRAeC0=;
        b=M5pvb8YjBWxp6jUtnDIYZvG6gD1Rf1W6xE9caXooYyIm1MiFAv7KROSOQAL9MaE9cs
         oXll8Mnj3tm0l1Pr0iTrOHOblXlTamwcEzM9Z0g6T+4BUS80o1V+gZm/KhkhGF+KaOuR
         MqVJTvi88k2qCkNl7DKJzaEEb2OpLj6Vofzod4Xjg/CkdpUPyVwxBzTjW1fO5TV0nsbF
         VId5hHuDOSrvRE/LU1Ra2kG2QOCxHDsc/NjQQeAeahjht6UFHO9ILm0ce9YhaoZAoOgS
         98k5IDzPsH/Nx4AdQqJ226dpvZbYtsfYlHTsprwAKmpMRG2YCU2yO2Ryyut0J9IgPm/k
         oVTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mh0Rc495;
       spf=pass (google.com: domain of avagin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=avagin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h29sor343202uab.62.2019.06.13.13.32.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 13:32:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of avagin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mh0Rc495;
       spf=pass (google.com: domain of avagin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=avagin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XnwdqEB/zxSUoi8AX3TTUKJIQzqvpn/EDnWBDbRAeC0=;
        b=mh0Rc495xOBUVTnnEmr4AY5NBwVSaqzX7zqV6Dc0pZhAdBBMh97ij8pz/2/iyufp6F
         ooJ45PQgHYRytRZez//z7awy8/LfcteuyU4iQPzoIaxepq7w2liWukbsUhe7AVsGV2m4
         cGRVK2X2wHvYVrnO3N3b1vRlOqgAy1SA4v+7JmfMJIywOp9HK3ygvJWCv7tbo6q745j4
         w7aNSUQU4VPwQ+rzdjFOPSxICgPxP25z9gSYvI9Fr4DHolTZx7l7s1QyHkMnZG2KUxWG
         2/hwjxPew43xbKjCW3en5tfPSloSM/x9hxBFVQ0j+Y7gNVoK1FrgVaKF+OIkIdmaZH4p
         Ua2A==
X-Google-Smtp-Source: APXvYqwYSC5celn0/YY56qS1Ya7QSTRLAhhjVJF5SlLdd0JuZboIS3qB8YqgOjoOCvVdt0mtU6tXdL4lZWb7/Se6XdM=
X-Received: by 2002:ab0:6619:: with SMTP id r25mr3232042uam.33.1560457962568;
 Thu, 13 Jun 2019 13:32:42 -0700 (PDT)
MIME-Version: 1.0
References: <156007465229.3335.10259979070641486905.stgit@buzz>
 <156007493995.3335.9595044802115356911.stgit@buzz> <20190612231426.GA3639@gmail.com>
 <f15478b5-098f-e1be-0928-62f46cff77e7@yandex-team.ru>
In-Reply-To: <f15478b5-098f-e1be-0928-62f46cff77e7@yandex-team.ru>
From: Andrei Vagin <avagin@gmail.com>
Date: Thu, 13 Jun 2019 13:32:31 -0700
Message-ID: <CANaxB-xUADVJx7HL6uHNRLDLNC19urcp-NY6RnyrckuH2neaAw@mail.gmail.com>
Subject: Re: [PATCH v2 5/6] proc: use down_read_killable mmap_sem for /proc/pid/map_files
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, 
	Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, 
	Cyrill Gorcunov <gorcunov@gmail.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, 
	=?UTF-8?Q?Michal_Koutn=C3=BD?= <mkoutny@suse.com>, 
	Al Viro <viro@zeniv.linux.org.uk>, Roman Gushchin <guro@fb.com>, Dmitry Safonov <dima@arista.com>, 
	Mike Rapoport <rppt@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 1:15 AM Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
>
> On 13.06.2019 2:14, Andrei Vagin wrote:
> > On Sun, Jun 09, 2019 at 01:09:00PM +0300, Konstantin Khlebnikov wrote:
> >> Do not stuck forever if something wrong.
> >> Killable lock allows to cleanup stuck tasks and simplifies investigation.
> >
> > This patch breaks the CRIU project, because stat() returns EINTR instead
> > of ENOENT:
> >
> > [root@fc24 criu]# stat /proc/self/map_files/0-0
> > stat: cannot stat '/proc/self/map_files/0-0': Interrupted system call
>
> Good catch.
>
> It seems CRIU tests has good coverage for darkest corners of kernel API.
> Kernel CI projects should use it. I suppose you know how to promote this. =)

I remember Mike was trying to add the CRIU test suite into kernel-ci,
but it looks like this ended up with nothing.

The good thing here is that we have our own kernel-ci:
https://travis-ci.org/avagin/linux/builds

Travis-CI doesn't allow to replace the kernel, so we use CRIU to
dump/restore a ssh session and travis doesn't notice when we kexec a
new kernel.

>
> >
> > Here is one inline comment with the fix for this issue.
> >
> >>
> >> It seems ->d_revalidate() could return any error (except ECHILD) to
> >> abort validation and pass error as result of lookup sequence.
> >>
> >> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> >> Reviewed-by: Roman Gushchin <guro@fb.com>
> >> Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>
> >> Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> >
> > It was nice to see all four of you in one place :).
> >
> >> Acked-by: Michal Hocko <mhocko@suse.com>
> >> ---
> >>   fs/proc/base.c |   27 +++++++++++++++++++++------
> >>   1 file changed, 21 insertions(+), 6 deletions(-)
> >>
> >> diff --git a/fs/proc/base.c b/fs/proc/base.c
> >> index 9c8ca6cd3ce4..515ab29c2adf 100644
> >> --- a/fs/proc/base.c
> >> +++ b/fs/proc/base.c
> >> @@ -1962,9 +1962,12 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
> >>              goto out;
> >>
> >>      if (!dname_to_vma_addr(dentry, &vm_start, &vm_end)) {
> >> -            down_read(&mm->mmap_sem);
> >> -            exact_vma_exists = !!find_exact_vma(mm, vm_start, vm_end);
> >> -            up_read(&mm->mmap_sem);
> >> +            status = down_read_killable(&mm->mmap_sem);
> >> +            if (!status) {
> >> +                    exact_vma_exists = !!find_exact_vma(mm, vm_start,
> >> +                                                        vm_end);
> >> +                    up_read(&mm->mmap_sem);
> >> +            }
> >>      }
> >>
> >>      mmput(mm);
> >> @@ -2010,8 +2013,11 @@ static int map_files_get_link(struct dentry *dentry, struct path *path)
> >>      if (rc)
> >>              goto out_mmput;
> >>
> >> +    rc = down_read_killable(&mm->mmap_sem);
> >> +    if (rc)
> >> +            goto out_mmput;
> >> +
> >>      rc = -ENOENT;
> >> -    down_read(&mm->mmap_sem);
> >>      vma = find_exact_vma(mm, vm_start, vm_end);
> >>      if (vma && vma->vm_file) {
> >>              *path = vma->vm_file->f_path;
> >> @@ -2107,7 +2113,10 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
> >>      if (!mm)
> >>              goto out_put_task;
> >>
> >> -    down_read(&mm->mmap_sem);
> >> +    result = ERR_PTR(-EINTR);
> >> +    if (down_read_killable(&mm->mmap_sem))
> >> +            goto out_put_mm;
> >> +
> >
> >       result = ERR_PTR(-ENOENT);
> >
> >>      vma = find_exact_vma(mm, vm_start, vm_end);
> >>      if (!vma)
> >>              goto out_no_vma;
> >> @@ -2118,6 +2127,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
> >>
> >>   out_no_vma:
> >>      up_read(&mm->mmap_sem);
> >> +out_put_mm:
> >>      mmput(mm);
> >>   out_put_task:
> >>      put_task_struct(task);
> >> @@ -2160,7 +2170,12 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
> >>      mm = get_task_mm(task);
> >>      if (!mm)
> >>              goto out_put_task;
> >> -    down_read(&mm->mmap_sem);
> >> +
> >> +    ret = down_read_killable(&mm->mmap_sem);
> >> +    if (ret) {
> >> +            mmput(mm);
> >> +            goto out_put_task;
> >> +    }
> >>
> >>      nr_files = 0;
> >>

