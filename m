Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD95AC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 23:03:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94D10208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 23:03:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Hgx4J6Xn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94D10208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FC9D6B0008; Fri,  9 Aug 2019 19:03:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2ACA06B000A; Fri,  9 Aug 2019 19:03:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19C446B000C; Fri,  9 Aug 2019 19:03:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C3B4F6B0008
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 19:03:52 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b14so47230777wrn.8
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 16:03:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AA45q6IMPxeio0FSS0wDQ5w5I6FSh5bk8IxEXeZUP0E=;
        b=oDByPPnn53C5KMFgVxxrCIBB8NPuuo+M6VnqtAI5YNeMTc7bWCu8ecXNoWtgoQzFbb
         38ybAyTAIbSmwXZxpQW+ha+7a2OjxiH0d1kJM9J7yB0/IJ4OspLw5j2RCvTPrY2sWO9+
         kJ5iuKYlkRr1wZgbkfBSfwe+qmLnsedSC31Y/TIDETarqBUUKLJEHWtsLzJ71t0HMXTN
         8LtQekVjHDDrVX53yFZgpHItcs64EbhQ/9N6YSBdXQCGY/sD6HDgGIPmWXY+42ZG7hV+
         kqH9K3LDA6CBOuKIMGo8sBfbi+vD4iYvqH0I8QQ8WWlAd4s37S6/aoR0osqSjWos8EBb
         fbFw==
X-Gm-Message-State: APjAAAW6gX4bdbnxAt+0YMLQub4WeqAc/mRfIVTzVOGJGsZLR61Dz3g4
	VMtXidjXSq39Q5hh5SLhtZMtgOxFOjMDOdeUGjvzk7pzvDHcjXf/ddIZSTDky637ma3M6LqdNUf
	gBqN5lpWLmFiYIPQcrFbcv0k6W/QHRcrB0BZ8luRXWJlsc4ED2iYcWrqA93w3zUsjWw==
X-Received: by 2002:adf:dc51:: with SMTP id m17mr27587667wrj.256.1565391832364;
        Fri, 09 Aug 2019 16:03:52 -0700 (PDT)
X-Received: by 2002:adf:dc51:: with SMTP id m17mr27587616wrj.256.1565391831471;
        Fri, 09 Aug 2019 16:03:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391831; cv=none;
        d=google.com; s=arc-20160816;
        b=O6VU7VrwdekjZnPZitDwS5Q6oO+aSjCo/41sp6cecwOeDHGI/+2hxH/npmJuuB9S3q
         M4qvSwi486gOV4Jr1H1NbPs9VygaydH9dHdjAi1izCoJsCQBLNdKw2SFSAaUGzv0o65b
         3r0jifhe18e/A+82Ng1s+CHHsN8txLK0eV7cgqluO2cv63RGqEGgM14Q3HtWvE7mL/Um
         W2bVL9ZjqkfHXw4Nm0bWDh2Q+4TiyH5VtJA1IS52dTASajkE13vT0ugflBhslfdCF+6T
         QLNZuLcpkDj5mL3e4fhOuBSGwqF9I2Sr1JeUNsJ8PzHtedbJU3+Ih+jn6QvvbZe8shfN
         fvAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AA45q6IMPxeio0FSS0wDQ5w5I6FSh5bk8IxEXeZUP0E=;
        b=sKRHJ/ql9KfV6D3MBtIfV/njiL+A7lhXwYwvAkY8EVtb06cd+WzFvY43yFvElCYyND
         560ih+KkRBIregBgn7pHPgWaS5I3Dod1K6sZxFmMkw+Ofj+i8s1wx/cG/LCRQ5BQ2Jq3
         emfbh42k16wQWe8o9IRooOY2W8dwIzdCQ9gA6/dueBIgOU0n6/k/vUq6Q4hZKLqn2Jn2
         1+GEffNvlid9wLJCZv8oPCW0teEKkffp0SA5qGTnvQmUxy7TTicH/qeeq78jZ4QfxZvv
         Qv8yjyb4IrbuWxFEMLb7uxSuPCgY2ubg1IenkbquUE35Br69k6vZqgchZlQBtkOqxkhU
         5HXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Hgx4J6Xn;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a8sor4522334wrn.19.2019.08.09.16.03.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 16:03:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Hgx4J6Xn;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AA45q6IMPxeio0FSS0wDQ5w5I6FSh5bk8IxEXeZUP0E=;
        b=Hgx4J6XnzbPi/G6IzDkRvXBDXp3Xw1iLGFI/8Hl4XZuiFH/pUvEk+HOHKKjP76/hQX
         mWBD6zQ+rQEL/nOuq0/6OmDbIxxGtFO6mY0LVFTTsqFrIlaZRSb6M8aKKowHzhH3DQTm
         2V+ddlS0fA173GTaNiMA1v1CE+VrS8SelYzm2zJvLS4DQ8ADl33KFGIwXY+3yOoWJZOf
         43vCBcpxoWOuxjX+XDan+MgqKv25HMcRzB9Sdy38s8MR02Rff0hzlNnG2pYSL2LO5aSF
         Ub94moH3Leka0deP3ghd/pfu+DURzPTrsZXYAaf5nPRADSxRxH4ONydFG4lxIGtrLsfa
         iSyA==
X-Google-Smtp-Source: APXvYqxNIFUtq0mvXkjapWy5+xX1d0Xp8TP4K9kMBJ6lZAuc7uPuLpfox+P3pZ3dVwbona9mq6bzyo+H3lZPiB9qFJI=
X-Received: by 2002:adf:ce88:: with SMTP id r8mr28161681wrn.42.1565391830743;
 Fri, 09 Aug 2019 16:03:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190808190300.GA9067@cmpxchg.org>
In-Reply-To: <20190808190300.GA9067@cmpxchg.org>
From: Suren Baghdasaryan <surenb@google.com>
Date: Fri, 9 Aug 2019 16:03:39 -0700
Message-ID: <CAJuCfpFQdCmhdCQQGxmWuwjYRdMCL8-xtkuUiqYE03ut+uvW6g@mail.gmail.com>
Subject: Re: [PATCH RESEND] block: annotate refault stalls from IO submission
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jens Axboe <axboe@kernel.dk>, Dave Chinner <david@fromorbit.com>, 
	Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, 
	linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 8, 2019 at 12:03 PM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> psi tracks the time tasks wait for refaulting pages to become
> uptodate, but it does not track the time spent submitting the IO. The
> submission part can be significant if backing storage is contended or
> when cgroup throttling (io.latency) is in effect - a lot of time is
> spent in submit_bio(). In that case, we underreport memory pressure.
>
> Annotate submit_bio() to account submission time as memory stall when
> the bio is reading userspace workingset pages.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  block/bio.c               |  3 +++
>  block/blk-core.c          | 23 ++++++++++++++++++++++-
>  include/linux/blk_types.h |  1 +
>  3 files changed, 26 insertions(+), 1 deletion(-)
>
> diff --git a/block/bio.c b/block/bio.c
> index 299a0e7651ec..4196865dd300 100644
> --- a/block/bio.c
> +++ b/block/bio.c
> @@ -806,6 +806,9 @@ void __bio_add_page(struct bio *bio, struct page *page,
>
>         bio->bi_iter.bi_size += len;
>         bio->bi_vcnt++;
> +
> +       if (!bio_flagged(bio, BIO_WORKINGSET) && unlikely(PageWorkingset(page)))
> +               bio_set_flag(bio, BIO_WORKINGSET);
>  }
>  EXPORT_SYMBOL_GPL(__bio_add_page);
>
> diff --git a/block/blk-core.c b/block/blk-core.c
> index d0cc6e14d2f0..1b1705b7dde7 100644
> --- a/block/blk-core.c
> +++ b/block/blk-core.c
> @@ -36,6 +36,7 @@
>  #include <linux/blk-cgroup.h>
>  #include <linux/debugfs.h>
>  #include <linux/bpf.h>
> +#include <linux/psi.h>
>
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/block.h>
> @@ -1128,6 +1129,10 @@ EXPORT_SYMBOL_GPL(direct_make_request);
>   */
>  blk_qc_t submit_bio(struct bio *bio)
>  {
> +       bool workingset_read = false;
> +       unsigned long pflags;
> +       blk_qc_t ret;
> +
>         if (blkcg_punt_bio_submit(bio))
>                 return BLK_QC_T_NONE;
>
> @@ -1146,6 +1151,8 @@ blk_qc_t submit_bio(struct bio *bio)
>                 if (op_is_write(bio_op(bio))) {
>                         count_vm_events(PGPGOUT, count);
>                 } else {
> +                       if (bio_flagged(bio, BIO_WORKINGSET))
> +                               workingset_read = true;
>                         task_io_account_read(bio->bi_iter.bi_size);
>                         count_vm_events(PGPGIN, count);
>                 }
> @@ -1160,7 +1167,21 @@ blk_qc_t submit_bio(struct bio *bio)
>                 }
>         }
>
> -       return generic_make_request(bio);
> +       /*
> +        * If we're reading data that is part of the userspace
> +        * workingset, count submission time as memory stall. When the
> +        * device is congested, or the submitting cgroup IO-throttled,
> +        * submission can be a significant part of overall IO time.
> +        */
> +       if (workingset_read)
> +               psi_memstall_enter(&pflags);
> +
> +       ret = generic_make_request(bio);
> +
> +       if (workingset_read)
> +               psi_memstall_leave(&pflags);
> +
> +       return ret;
>  }
>  EXPORT_SYMBOL(submit_bio);
>
> diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
> index 1b1fa1557e68..a9dadfc16a92 100644
> --- a/include/linux/blk_types.h
> +++ b/include/linux/blk_types.h
> @@ -209,6 +209,7 @@ enum {
>         BIO_BOUNCED,            /* bio is a bounce bio */
>         BIO_USER_MAPPED,        /* contains user pages */
>         BIO_NULL_MAPPED,        /* contains invalid user pages */
> +       BIO_WORKINGSET,         /* contains userspace workingset pages */
>         BIO_QUIET,              /* Make BIO Quiet */
>         BIO_CHAIN,              /* chained bio, ->bi_remaining in effect */
>         BIO_REFFED,             /* bio has elevated ->bi_cnt */
> --
> 2.22.0
>

The change contributes to the amount of recorded stall while running
memory stress test with and without the patch. Did not notice any
performance regressions so far. Thanks!

Tested-by: Suren Baghdasaryan <surenb@google.com>

