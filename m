Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94AC1C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 08:38:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5361420685
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 08:38:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=pex-com.20150623.gappssmtp.com header.i=@pex-com.20150623.gappssmtp.com header.b="p6n6Vdpx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5361420685
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=pex.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E48738E0005; Wed, 20 Feb 2019 03:38:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA9C78E0002; Wed, 20 Feb 2019 03:38:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C71738E0005; Wed, 20 Feb 2019 03:38:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 696038E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 03:38:09 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id v8so1480987wmj.1
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 00:38:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=GdCtrmhlhIxIQs424Eu4PEx73+mSvtIoVuEVMF/9jls=;
        b=RS+Xb7IajDs66hX8Kt0TPsHa8xmH+BG7G+UOpXXrSb78GwrRiLJVFOz2r+Mq8PBAq/
         mnt4KAzu7aciI6UEGd5dvOU9fcnE5GGl/up78zQFw31PknFwEFE8be/Zq6O+dw/kb4jC
         jhMrqEE8ba98mVLaS/wOhG33yEqZG32WOTXmKhdD+geo6b/AUouK4W47NIlye9GIAFUx
         lvOHTpnCuqG3Oy3Dh/+CGM8y+17XTxQXCL/7r8P+zbH4+X9j7dsRteBw6Z9XuA/t6KL+
         g8QNLkw8N9jWx93FfgJYnJbmlJcXrgvhdSNFSMBJBKKSAKwOEwMl++g8/fBfYfXekwJ5
         kmzg==
X-Gm-Message-State: AHQUAuaO6JCPyzTF9RMym330dXUokVzRdKQOOZhmrn/bP1QiDCYQKWl+
	pDxss1VqtD/2dmlYgz22JE/oyn0GHY5ngOhYYmUhSd4TArQo9t9t7kGEHxecMgriEf2SXOgqKBd
	N2uCIOZqxBopy+JvqTgU5FWwraTGTpMZc0/uQJjVAbx1leTJuYzq9dfwFlI/Sf3URmHd9U1Hh2V
	MBzo9E6rKt5ykg4g10XbIwIgtLSBKYHiJ9EYaQqnBN9/CUfYrg2Q4tQs1uilNZXyHlIRQ4HlQ57
	S9hs/yy1LQgrEoCxLaWoLUy9yT9FRb2IeknO//5t3v6psok2lW0Q2/AziAo4c8Gw5TB0bfHv+jg
	AasJ5oVdCrEm/TEbQNErUykst4Toqp5qY7Bv8qYppsK16xjCepBED4amTewPn0A7MXw0qPQE4MN
	a
X-Received: by 2002:adf:ec10:: with SMTP id x16mr24011168wrn.171.1550651888833;
        Wed, 20 Feb 2019 00:38:08 -0800 (PST)
X-Received: by 2002:adf:ec10:: with SMTP id x16mr24011117wrn.171.1550651887891;
        Wed, 20 Feb 2019 00:38:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550651887; cv=none;
        d=google.com; s=arc-20160816;
        b=umXnRPM0kI4LHPf/FuAv5jp24b7YZKWljNhLLFf59TJgNGvacj5fTbPIIE1YzzfEG8
         +pWoVdX57bDIrqYNwK+1+BEmmW/1bl4AJut6gZVpAcuvgID/nqpbemnrr9v9yHENmCfJ
         eya8Iv7bwuAwKw6lhaCzZZOhGuBay0jDxABSN0PNGp3wz0VHlEV7x+2zdl6ydT2fpCDA
         pJ6q8REA3chJrg+RpNo1kFv07nd7TWW1eL2AtE/lhf841gkZZHDKcrwuhql71LkT1eOF
         lXDZxqCv8jTRZYRpSraomFe4X0pN1tw2xQSTTdOYtSerPycAUPzpz21Hrzhuo8AB/t9T
         Wu/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=GdCtrmhlhIxIQs424Eu4PEx73+mSvtIoVuEVMF/9jls=;
        b=zulTRyRL0kKIP0Bvm6MTsfJWpImbN2k6aMU7mdUK1JxNljPOHM62YAv+pE+P6UpeK1
         JLS65S6FsZO058jdP1D8H9C1btbEZyq+2CeCal7KdhzI2iDMikPpY59MkYri7JwDy43o
         KQIq2v8HYtPzX5JpDnqQHgqV9xFuvwbFdnvt+ZbGPO3YmcdWwG2E7A7xBs9Qbh6vQ5xS
         tGZ4XYdZUiCxaq4VYqyg1GvU4rsnCWAVizb+6u4npdhu1PehvdhdLFTDDvJv9oZLQwwN
         74wwNVLPOEiZ0jOrr/pLJVkfUaDPunuJnO6Qyiwfn8XzqG7YYw6zii16VYCTzyEb3v+D
         sGxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@pex-com.20150623.gappssmtp.com header.s=20150623 header.b=p6n6Vdpx;
       spf=softfail (google.com: domain of transitioning stepan@pex.com does not designate 209.85.220.65 as permitted sender) smtp.mailfrom=stepan@pex.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=pex.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor3254746wmf.22.2019.02.20.00.38.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 00:38:07 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning stepan@pex.com does not designate 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@pex-com.20150623.gappssmtp.com header.s=20150623 header.b=p6n6Vdpx;
       spf=softfail (google.com: domain of transitioning stepan@pex.com does not designate 209.85.220.65 as permitted sender) smtp.mailfrom=stepan@pex.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=pex.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=pex-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GdCtrmhlhIxIQs424Eu4PEx73+mSvtIoVuEVMF/9jls=;
        b=p6n6VdpxD1BsUNKgN6YfUqUXjeGQoxWWSO5FdKtKMdcuKRa3hnB+KVuqSb7z2qB2oe
         9jV65KRWyhAnE+sBeV8h/t7aeS95GmuSL+6Nn4wZ6svSSFm1MjvwvTKWCrYnXYhaoZdx
         crJJKh2OK0BiYAXFaf6bHaKVPd13MI+vXJ6WJKuWrn8HPDdczDloi/uSHsxorDvYySJV
         7wSJBha7OtYnm1lm9bI9JSvLv0pLvb/TY2pLuUGaQfLUBvwfEy0Y7wau5qiYu3V0Pzze
         +wzCdx7NDBDiX+ZViI76betzjq1HYE7olG+ICXMDMYcLFf9okjHfVIyGzqOodT8R2iGH
         GCUA==
X-Google-Smtp-Source: AHgI3IZWkPd6B6tcJ6NHpInQGdrnshQUdcrkkgsRYAyHaxaPT5jfQnG8TweEs6j/CRqoE7A4qo/8Srmj7/jqH9S6vE4=
X-Received: by 2002:a1c:1b4e:: with SMTP id b75mr6049089wmb.88.1550651887345;
 Wed, 20 Feb 2019 00:38:07 -0800 (PST)
MIME-Version: 1.0
References: <20190220032245.2413-1-stepan@pex.com> <20190220064939.GT4525@dhcp22.suse.cz>
In-Reply-To: <20190220064939.GT4525@dhcp22.suse.cz>
From: "Bujnak, Stepan" <stepan@pex.com>
Date: Wed, 20 Feb 2019 09:37:56 +0100
Message-ID: <CAFZe2nQW3mUGgSVndzmPirz7BkVUCEyjt=hgxqFn=bntrCsC8A@mail.gmail.com>
Subject: Re: [PATCH] mm/oom: added option 'oom_dump_task_cmdline'
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, mcgrof@kernel.org, 
	hannes@cmpxchg.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 7:49 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 20-02-19 04:22:45, Stepan Bujnak wrote:
> > When oom_dump_tasks is enabled, this option will try to display task
> > cmdline instead of the command name in the system-wide task dump.
> >
> > This is useful in some cases e.g. on postgres server. If OOM killer is
> > invoked it will show a bunch of tasks called 'postgres'. With this
> > option enabled it will show additional information like the database
> > user, database name and what it is currently doing.
> >
> > Other example is python. Instead of just 'python' it will also show the
> > script name currently being executed.
>
> The size of OOM report output is quite large already and this will just
> add much more for some workloads and printing from this context is quite
> a problem already.
>

The option defaults to false so most workloads wouldn't be affected.
As an alternative the cmdline line can only be printed for the
victim task in the OOM summary.

> > Signed-off-by: Stepan Bujnak <stepan@pex.com>
> > ---
> >  Documentation/sysctl/vm.txt | 10 ++++++++++
> >  include/linux/oom.h         |  1 +
> >  kernel/sysctl.c             |  7 +++++++
> >  mm/oom_kill.c               | 20 ++++++++++++++++++--
> >  4 files changed, 36 insertions(+), 2 deletions(-)
> >
> [...]
> > @@ -404,9 +406,18 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
> >       pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
> >       rcu_read_lock();
> >       for_each_process(p) {
> > +             char *name, *cmd = NULL;
> > +
> >               if (oom_unkillable_task(p, memcg, nodemask))
> >                       continue;
> >
> > +             /*
> > +              * This needs to be done before calling find_lock_task_mm()
> > +              * since both grab a task lock which would result in deadlock.
> > +              */
> > +             if (sysctl_oom_dump_task_cmdline)
> > +                     cmd = kstrdup_quotable_cmdline(p, GFP_KERNEL);
> > +
> >               task = find_lock_task_mm(p);
> >               if (!task) {
> >                       /*
> You are trying to allocate from the OOM context. That is a big no no.
> Not to mention that this is deadlock prone because get_cmdline needs
> mmap_sem and the allocating context migh hold the lock already. So the
> patch is simply wrong.
>

Thanks for the notes. I understand how allocating from OOM context
is a problem. However I still believe that this would be helpful
for debugging OOM kills since task->comm is often not descriptive
enough. Would it help if instead of calling kstrdup_quotable_cmdline()
which allocates the buffer on heap I called get_cmdline() directly
passing it stack-allocated buffer of certain size e.g. 256?

> --
> Michal Hocko
> SUSE Labs

