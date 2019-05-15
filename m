Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DD4CC04AB7
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 00:49:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0222E20879
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 00:49:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RFv0sQvm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0222E20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D0036B0005; Tue, 14 May 2019 20:49:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 359546B0006; Tue, 14 May 2019 20:49:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D3516B0007; Tue, 14 May 2019 20:49:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3D306B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 20:49:27 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id r78so392822oie.8
        for <linux-mm@kvack.org>; Tue, 14 May 2019 17:49:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=/1dfnZvzmXyrAvmLqG8QuEKEEuBLjYOpAGmByOmcw20=;
        b=jJ7Rep6OmW7S0ZkOYCvqxJCaheC6EfMipnb3YkOMrap+qXRs4KTqrL4w53esLMLKvB
         P/Iu3ELrKWU7z6X/SvhGKmiWAc5Kn6sh0577tVZDnp31WGiV6fx/+998SKYUhZqtvNZR
         Qn56L/aaFONXEhktsmIgu6sSsVudyszsgq9v3VXpc410vjtitSDwOsIemUSmAszcl28q
         QcATx2sygDXx5HVfAPdVFd4mE+Bq98xG2D8FZ583FUzSKBo/xQ8I01HoeW5DhlAAxo4s
         zTvO8QPW6OmoyUQbjtq0IZiunLwrppGfl+KpCvNDK/v28fsrxHYS4Fysu+3tXgvgruKy
         22zg==
X-Gm-Message-State: APjAAAXbuFXsH8bHokLKoxAGfwp5nW4P0TOgmd6TG5ytWt/OLbZN9JOx
	BgCNKV5zeYuouCJZ2YU8UqR4zX/S8INAV+3qF381QEwx3fcEjYSIIL5RwWU0ekn3KsTaw2Xz0st
	3c6izwDfcJPMwZaQwWtz/a5vdbWyuo60VfirtJCYaWD+fs8czLkw/l2s+22BBx5H3WQ==
X-Received: by 2002:a9d:71d1:: with SMTP id z17mr18352146otj.22.1557881367574;
        Tue, 14 May 2019 17:49:27 -0700 (PDT)
X-Received: by 2002:a9d:71d1:: with SMTP id z17mr18352105otj.22.1557881366677;
        Tue, 14 May 2019 17:49:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557881366; cv=none;
        d=google.com; s=arc-20160816;
        b=PDV9isGmZOBb4MsiLzkXWrMHyxJQo+b9zn+rVCKILi4kIx4Inuim6UjuRMhDWVm6Mc
         yF/jhKHIm1xbdzLs8RiRBxZuXPxKAUB8LcNIiggcvRP2kaIMmvI6oY3vXF0yIqB8KjkT
         8SgzUf31dV2wCaZbk/Iez+edh26teYtEFRp3MQHWxuM0iu6wwiLyANaKV4nR18eaoLGV
         05/RVvtdSuwoN/ve2ZaKeVfmUEdydCXKKrc8+mGxkWdibiWPA+Q499Lv4CVXqJ0M5VrK
         m4nUBpYNdAnb/4ItN/wx/BzDeE5Wcml4AR7LnZl+9JxZGmfDm/hbKmcphpYmY9JJw7oS
         azEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=/1dfnZvzmXyrAvmLqG8QuEKEEuBLjYOpAGmByOmcw20=;
        b=zT+xvJVDLBvcxPQNUiG0aZRf9lKo5I1e1vVJJjXH7AOJkcH/j6UYM9QOqZ8mAWY1QD
         yNFNPOBT0EUBZVUVsq3dEjjJauujipbLfkeAY2o/F5fPCzF5P8xlHFD9h5Qeub7Iu8Wk
         ONhVAd4ItGo7+A33x/Lzw7qSaFomGFX1H/sEpXu7SCd1h7828tOQKdvhyEgcn4fCfbIi
         8DzRFGWzSH6DHZquPV0+vp6f5h55jV7+KF9mMqqA+puspAig0ihRf1Z+mYYPFx/i11Hs
         Pc8v9v2qYIzxOzKdYR5pPu7m+5I4mbGyJFG/HuhnerRbRH5rkKtbk5SSMTQG21QrDeqa
         v+0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RFv0sQvm;
       spf=pass (google.com: domain of nefelim4ag@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nefelim4ag@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g22sor219725otn.44.2019.05.14.17.49.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 17:49:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of nefelim4ag@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RFv0sQvm;
       spf=pass (google.com: domain of nefelim4ag@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nefelim4ag@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=/1dfnZvzmXyrAvmLqG8QuEKEEuBLjYOpAGmByOmcw20=;
        b=RFv0sQvmISAFd9Ve2FjMlX11/QOSAOV+YV9EFixhjjqagkW5Rl16XKucfQ8FEimzrw
         zWNCH83bLqJ/pEKJDdQLEIygK45lIH4oR1RpCJOyQKYEocfjkblbEkcjFckiHU43oBFo
         EMRq00C5bYAGzoV7CuJKL2kwribUEJikiHcaiO7oGamTgweIULopvfimyI6ECAj9+jij
         E/M5KYjQYi1BcFCnTNsyUTNkGFoll8OdhkkLklO0c2FANIBK+XfMozRecxy6mime+RrI
         B3ssMGSNcSWJXxJmuC+kJ18q40m3lqe24nIAuygz1JeFtXv60+dZPI1NOpbPLViGRhDA
         7/mA==
X-Google-Smtp-Source: APXvYqzk7v2yFXq2EBQuAvscQ5ewNjVlUAKstnHwHAVlx48z8B9NF1ZYHulrWQGeJcLpHj6vQIs3i5xIW3NdLJvc4I4=
X-Received: by 2002:a9d:458c:: with SMTP id x12mr3117938ote.211.1557881365991;
 Tue, 14 May 2019 17:49:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190514131654.25463-1-oleksandr@redhat.com> <20190514131654.25463-4-oleksandr@redhat.com>
 <20190514132249.h233crdsz3b7akys@atomlin.usersys.com>
In-Reply-To: <20190514132249.h233crdsz3b7akys@atomlin.usersys.com>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Wed, 15 May 2019 03:48:50 +0300
Message-ID: <CAGqmi77dtid9M8fZuWimeiWMw8r9Awu579mo8UsaVGTECwxRwA@mail.gmail.com>
Subject: Re: [PATCH RFC v2 3/4] mm/ksm: introduce force_madvise knob
To: Aaron Tomlin <atomlin@redhat.com>
Cc: Oleksandr Natalenko <oleksandr@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, 
	Kirill Tkhai <ktkhai@virtuozzo.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, 
	Matthew Wilcox <willy@infradead.org>, Pavel Tatashin <pasha.tatashin@soleen.com>, 
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

LGTM

Reviewed-by: Timofey Titovets <nefelim4ag@gmail.com>

=D0=B2=D1=82, 14 =D0=BC=D0=B0=D1=8F 2019 =D0=B3. =D0=B2 16:22, Aaron Tomlin=
 <atomlin@redhat.com>:
>
> On Tue 2019-05-14 15:16 +0200, Oleksandr Natalenko wrote:
> > Present a new sysfs knob to mark task's anonymous memory as mergeable.
> >
> > To force merging task's VMAs, its PID is echoed in a write-only file:
> >
> >    # echo PID > /sys/kernel/mm/ksm/force_madvise
> >
> > Force unmerging is done similarly, but with "minus" sign:
> >
> >    # echo -PID > /sys/kernel/mm/ksm/force_madvise
> >
> > "0" or "-0" can be used to control the current task.
> >
> > To achieve this, previously introduced ksm_enter()/ksm_leave() helpers
> > are used in the "store" handler.
> >
> > Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
> > ---
> >  mm/ksm.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 68 insertions(+)
> >
> > diff --git a/mm/ksm.c b/mm/ksm.c
> > index e9f3901168bb..22c59fb03d3a 100644
> > --- a/mm/ksm.c
> > +++ b/mm/ksm.c
> > @@ -2879,10 +2879,77 @@ static void wait_while_offlining(void)
> >
> >  #define KSM_ATTR_RO(_name) \
> >       static struct kobj_attribute _name##_attr =3D __ATTR_RO(_name)
> > +#define KSM_ATTR_WO(_name) \
> > +     static struct kobj_attribute _name##_attr =3D __ATTR_WO(_name)
> >  #define KSM_ATTR(_name) \
> >       static struct kobj_attribute _name##_attr =3D \
> >               __ATTR(_name, 0644, _name##_show, _name##_store)
> >
> > +static ssize_t force_madvise_store(struct kobject *kobj,
> > +                                  struct kobj_attribute *attr,
> > +                                  const char *buf, size_t count)
> > +{
> > +     int err;
> > +     pid_t pid;
> > +     bool merge =3D true;
> > +     struct task_struct *tsk;
> > +     struct mm_struct *mm;
> > +     struct vm_area_struct *vma;
> > +
> > +     err =3D kstrtoint(buf, 10, &pid);
> > +     if (err)
> > +             return -EINVAL;
> > +
> > +     if (pid < 0) {
> > +             pid =3D abs(pid);
> > +             merge =3D false;
> > +     }
> > +
> > +     if (!pid && *buf =3D=3D '-')
> > +             merge =3D false;
> > +
> > +     rcu_read_lock();
> > +     if (pid) {
> > +             tsk =3D find_task_by_vpid(pid);
> > +             if (!tsk) {
> > +                     err =3D -ESRCH;
> > +                     rcu_read_unlock();
> > +                     goto out;
> > +             }
> > +     } else {
> > +             tsk =3D current;
> > +     }
> > +
> > +     tsk =3D tsk->group_leader;
> > +
> > +     get_task_struct(tsk);
> > +     rcu_read_unlock();
> > +
> > +     mm =3D get_task_mm(tsk);
> > +     if (!mm) {
> > +             err =3D -EINVAL;
> > +             goto out_put_task_struct;
> > +     }
> > +     down_write(&mm->mmap_sem);
> > +     vma =3D mm->mmap;
> > +     while (vma) {
> > +             if (merge)
> > +                     ksm_enter(vma->vm_mm, vma, &vma->vm_flags);
> > +             else
> > +                     ksm_leave(vma, vma->vm_start, vma->vm_end, &vma->=
vm_flags);
> > +             vma =3D vma->vm_next;
> > +     }
> > +     up_write(&mm->mmap_sem);
> > +     mmput(mm);
> > +
> > +out_put_task_struct:
> > +     put_task_struct(tsk);
> > +
> > +out:
> > +     return err ? err : count;
> > +}
> > +KSM_ATTR_WO(force_madvise);
> > +
> >  static ssize_t sleep_millisecs_show(struct kobject *kobj,
> >                                   struct kobj_attribute *attr, char *bu=
f)
> >  {
> > @@ -3185,6 +3252,7 @@ static ssize_t full_scans_show(struct kobject *ko=
bj,
> >  KSM_ATTR_RO(full_scans);
> >
> >  static struct attribute *ksm_attrs[] =3D {
> > +     &force_madvise_attr.attr,
> >       &sleep_millisecs_attr.attr,
> >       &pages_to_scan_attr.attr,
> >       &run_attr.attr,
>
> Looks fine to me.
>
> Reviewed-by: Aaron Tomlin <atomlin@redhat.com>
>
> --
> Aaron Tomlin



--=20
Have a nice day,
Timofey.

