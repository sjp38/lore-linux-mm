Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6E95C43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 08:42:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EA1F20883
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 08:42:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jSXV4wTN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EA1F20883
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E7578E0062; Thu,  3 Jan 2019 03:42:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 196EF8E0002; Thu,  3 Jan 2019 03:42:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 087C18E0062; Thu,  3 Jan 2019 03:42:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id D13698E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 03:42:57 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id v8so37902901ioh.11
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 00:42:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0L2M2jnVYh8pe2B3P1oW9+fmz/KBQKVb4GOtnB6BJqA=;
        b=SoJHPyCBZqaZXTtYPgrK6qMbYvj1oF0A7mqKAxsln7gYNON0Oaju8tqiYdJzUge6l6
         J1LtbQS6nEvRSzqAs0QKKP2LYIdNOCCXAyocg91LT2ws+DL6p5npLwA8+KVJu+BO383A
         UxJijHbOxDIBv5Bum0ApGEOE63I3PWK2Syn0Ix7DHs/c5K/teuaWXMnEUgDUoccAi8RJ
         6LghE+g+dd8qT6sn6C9f4S9yg4OaskIyWxFnzqIbt1+C65qa+4WtkmzAcBdsdhc1BMk+
         033/yvw4scPr+cT7pIV12ATl6vfMVv8RBuz2wr/eXlRIAvG57X9QX0n+O7SAndhIZFFb
         JgcA==
X-Gm-Message-State: AJcUukfHZ23pAVMhyL7qnJQpLacUrtnlOa5ehokMBOJWpa+jp/lpl1ov
	TfTC9/4OuT0gnOni9y2eG2AxauEHuLqyT+nmbqCOFhS3e9s48jwbIElX2rmWKz59GxDnxk5sXBZ
	6MwGfL3Qe30IzTgkZOXp/Re/W4ZWItGOFyJ+PB7RL/3q3IC1cr57/zNPH+fYKiaNxkZ8DIGAf3M
	pZTIwQDVbPHNkGUH2D5xC4IhrKS31B8iG04UrYsfSzZ87CB9ECHiWdCALydOCo8mTi9lRzgeMuH
	xSjtyJ+dTaDuC6cb39ojHgCYvCNp+DHJ2p/JSTEExNLAUrleyA9Om/RuLWMp7XgQ/yYVwZFWa/3
	Do2SvWYEdn3Hk/9PvpQLvlG9fCC16BBvv+B4GwMFLRklHfW5N34fZbx0r/Fbjs11+mJbS04j8pI
	/
X-Received: by 2002:a6b:6111:: with SMTP id v17mr35223092iob.107.1546504977507;
        Thu, 03 Jan 2019 00:42:57 -0800 (PST)
X-Received: by 2002:a6b:6111:: with SMTP id v17mr35223073iob.107.1546504976807;
        Thu, 03 Jan 2019 00:42:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546504976; cv=none;
        d=google.com; s=arc-20160816;
        b=RIY4B09D3VuVHqOCQVMnPADeICmCutE8ogWrONdUGGxCIf1Ss0CyAB4gYLFlZiueCO
         O2GkIrdzwv8caNgFVIwIXsohKWjiriElJqzUgzQmLuT6UyfTwUgLq59fmWUseGaHrTHz
         p20ID9dLPQLLkWN6dGAVqdvJfwoiZTKaS7eOtgQkerVrvF31u7+yvcOwIjjHN1KPCWUm
         qRHTwRPgGNESQ2T63bzvR5Wq7rccN3i6oBAf6lALtHRwDYO4m2K9iHZw3aXd5ultpJ4u
         a3ZTdhaHECZr0Bp2HNvuoEEXazM2ctb0cGjRxVs3QQpUP8WvsLGhBIUXXp++t7qBMjvZ
         d3fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0L2M2jnVYh8pe2B3P1oW9+fmz/KBQKVb4GOtnB6BJqA=;
        b=A1hDSRUgF0OjySj/rfakfwtq7BAKJA0CbRIJ56VpKJonMt89YENHjaAxD8DxKFlGt0
         wUC5Vx/QpySFF64z3PdItWQ32MAdpPr7VK/mIzLsIzjDilhMx+lwMgpG+BOI5vofrh9Y
         Z5GEk8zqrTxo3noJWfqNs8zYWoXAnwfd1fn0w/hKvnJGSsEtv/5kAbxDmvmHetF64tx8
         8+oL7pLgS5Xo8q+aL1rPpH+6I79JBSL6o0zN2KgMHWmcR+Y1dejte8HHmUIO7y3VfUI+
         cavMtzU2dRrA+WJR8Iw/ksPe7O+xOTfBhkwQG5/gi5VO1DI9H5updHy8TOh80FZLlxcR
         Z0jw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jSXV4wTN;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s21sor7225037iol.146.2019.01.03.00.42.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 00:42:56 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jSXV4wTN;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0L2M2jnVYh8pe2B3P1oW9+fmz/KBQKVb4GOtnB6BJqA=;
        b=jSXV4wTN8Hz4KLtCGuSr62WQEFtS9/+wGjNJZiZGUOCSpjODVK089tzHLxo1RbSlJO
         Xm4XOKIdDOzP7CDXhC3rYH3qz7/JMsIM80cYHL4Z85VsyzIKn2N3NgXixzQEkSVryZFb
         hsJ3sBv+bHCsNoh1HKXvxh//prZ3wFo8SZ/aT3kUfEPmO9aqRKJNYxj03nh4lezjISbO
         M5Ql80lU8N+MgZ9wPHSBqKSTbIGHMRw6eE5vPuAYTkDexsU23GopA+upvWjGsq1rqE4R
         mHkn/DR1P3biPg35+9cVz9uAy8TfspeCYkmVLqKu/daRpiZfQwFNcw5VKpovBMGvUZOw
         FQVw==
X-Google-Smtp-Source: ALg8bN77rkgO/LeWoxShfgRtjy3AlwUM0qHXpOW0VpZiJkjl3E7GRDo6Wglv1fyIoLxGcpU4l+UThmUlGnlQE4ET3RQ=
X-Received: by 2002:a5d:8491:: with SMTP id t17mr32744583iom.11.1546504976261;
 Thu, 03 Jan 2019 00:42:56 -0800 (PST)
MIME-Version: 1.0
References: <000000000000c06550057e4cac7c@google.com> <a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz>
In-Reply-To: <a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 3 Jan 2019 09:42:45 +0100
Message-ID:
 <CACT4Y+bRvwxkdnyRosOujpf5-hkBwd2g0knyCQHob7p=0hC=Dw@mail.gmail.com>
Subject: Re: KMSAN: uninit-value in mpol_rebind_mm
To: Vlastimil Babka <vbabka@suse.cz>
Cc: syzbot <syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com>, 
	Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>, 
	David Rientjes <rientjes@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
	xieyisheng1@huawei.com, zhong jiang <zhongjiang@huawei.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103084245.d3P-kR_YJpSsKyuhXCxYVJq-PIA2j0uu4FJn-s-Hs4U@z>

On Thu, Jan 3, 2019 at 9:36 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
>
> On 12/31/18 8:51 AM, syzbot wrote:
> > Hello,
> >
> > syzbot found the following crash on:
> >
> > HEAD commit:    79fc24ff6184 kmsan: highmem: use kmsan_clear_page() in cop..
> > git tree:       kmsan
> > console output: https://syzkaller.appspot.com/x/log.txt?x=13c48b67400000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=901dd030b2cc57e7
> > dashboard link: https://syzkaller.appspot.com/bug?extid=b19c2dc2c990ea657a71
> > compiler:       clang version 8.0.0 (trunk 349734)
> >
> > Unfortunately, I don't have any reproducer for this crash yet.
> >
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com
> >
> > ==================================================================
> > BUG: KMSAN: uninit-value in mpol_rebind_policy mm/mempolicy.c:353 [inline]
> > BUG: KMSAN: uninit-value in mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
>
> The report doesn't seem to indicate where the uninit value resides in
> the mempolicy object.

Yes, it doesn't and it's not trivial to do. The tool reports uses of
unint _values_. Values don't necessary reside in memory. It can be a
register, that come from another register that was calculated as a sum
of two other values, which may come from a function argument, etc.

> I'll have to guess. mm/mempolicy.c:353 contains:
>
>         if (!mpol_store_user_nodemask(pol) &&
>             nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
>
> "mpol_store_user_nodemask(pol)" is testing pol->flags, which I couldn't
> see being uninitialized after leaving mpol_new(). So I'll guess it's
> actually about accessing pol->w.cpuset_mems_allowed on line 354.
>
> For w.cpuset_mems_allowed to be not initialized and the nodes_equal()
> reachable for a mempolicy where mpol_set_nodemask() is called in
> do_mbind(), it seems the only possibility is a MPOL_PREFERRED policy
> with empty set of nodes, i.e. MPOL_LOCAL equivalent. Let's see if the
> patch below helps. This code is a maze to me. Note the uninit access
> should be benign, rebinding this kind of policy is always a no-op.
>
> ----8<----
> From ff0ca29da6bc2572d7b267daa77ced6083e3f02d Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Thu, 3 Jan 2019 09:31:59 +0100
> Subject: [PATCH] mm, mempolicy: fix uninit memory access
>
> ---
>  mm/mempolicy.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index d4496d9d34f5..a0b7487b9112 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -350,7 +350,7 @@ static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask)
>  {
>         if (!pol)
>                 return;
> -       if (!mpol_store_user_nodemask(pol) &&
> +       if (!mpol_store_user_nodemask(pol) && !(pol->flags & MPOL_F_LOCAL) &&
>             nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
>                 return;
>
> --
> 2.19.2
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/a71997c3-e8ae-a787-d5ce-3db05768b27c%40suse.cz.
> For more options, visit https://groups.google.com/d/optout.

