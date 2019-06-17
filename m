Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EFF5C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:27:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41B9F2054F
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:27:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jVpb4eWy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41B9F2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E40DA6B0007; Mon, 17 Jun 2019 00:27:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF1618E0003; Mon, 17 Jun 2019 00:27:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D05E18E0001; Mon, 17 Jun 2019 00:27:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B0FC06B0007
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:27:22 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id o16so8206240qtj.6
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 21:27:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Jbyq7Q2frV79XYaBb+RkixOf6rqvbIp5HPcBcMU9Ye0=;
        b=YaDaoeMrKHGKcPtaDC22BQqt6/+l9hG6d4QysNUhKdM+76IRX5q9eGaH9xYQlHJfLd
         W6/mExDobDOLbc3ZL+2Xoxi9qdL747T0W2unaJLH4yKKp8rqNiRWqsA40gOuYANFPY0r
         p5dh7UOQ43SU1jCa0xCoAbNsnjn3TJSEJqwib4S5kSOD6HS0ow2pgsGV4UaqsqK6fxMr
         oE/qr8MvhMO8WKBNBX6JyT+EzRTBdmt/LyWMoDcOO3iqm3+P9lfMKg659KtvbqqkhKEt
         7eFktr+en88zW7miBictTUlZpB1r8znc1azmGbcG8ZLnqB3IzFy0PwB2JXlHLPY9ab+y
         4KUw==
X-Gm-Message-State: APjAAAV22xOXbXPVAhRpnM2GSFqNJ38igNFALGMXB1L5T49kovv2bTRB
	ny2xYs6ZqVJwhENhtNFg4D2MyZ4LmvxbMbd6GAkY4lLffjWqdx3hhsUfP78ElBEGGQtzlRUbaeH
	d1AFl0/2+Jt5qh8762RLxLLGqryUIB8SeWGT/ovufIDIwTcVL0f8FIYk44Xk7wxb7RQ==
X-Received: by 2002:a0c:d0fc:: with SMTP id b57mr19598650qvh.78.1560745642437;
        Sun, 16 Jun 2019 21:27:22 -0700 (PDT)
X-Received: by 2002:a0c:d0fc:: with SMTP id b57mr19598626qvh.78.1560745641960;
        Sun, 16 Jun 2019 21:27:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560745641; cv=none;
        d=google.com; s=arc-20160816;
        b=XkXO0Me2yMIDEhfeAeGiZ2LS9n9KfnnRkwAowjARxo1FbJ2V0lsDtBo9KabThTxV/K
         f4nEExBaHc2+FOwMQFn0/G++HiO4pbd+w7MRfE8AlK/LOA/A5J6FHUzHWJd2Ll7i4uN3
         LMd8ZxcirQ3FJFKOkrg9wEIjW5lW4aJ3mNLvPjqJNWAwJV6DZfoVBKq5xYF4uf7eS9us
         BMR0Sd+4FqandkSjCFROoZLVmTORLdCYRFJlXvxVhRTEun7z9eu+Dlxn60824nQ3bo/H
         HrdR72p+MvtQUk/LAxIrYe+vkfoc5/yQixuhBGBIwhK1yOWxJ+twT9zAt6kDRRbVtYhe
         mXVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Jbyq7Q2frV79XYaBb+RkixOf6rqvbIp5HPcBcMU9Ye0=;
        b=nd+r6sEBsTM/+Qyu0quxL0Pj7IeG/p/PtodO1ZXCsFlnP3bWhNDjsbNo8rppeMXYRt
         4DIevMq9A5qUz3z2Hz0blRUwiMsjiLfpTgm+0EoOyv/u1+1EiifvHhQ8h/8LP8V2U73A
         ehBIH3TsPX4VIexKZZU4Ja3TUcrp/7yoJOi+kIEsEcjI0CEAEa88Eob8jwf7RfuWHh6j
         21pjKFkosvky+Ii7sPQ5og2VswjF/y89hKKVGs2EQaV/wJmKeNk25Cdpr51TAJ8jv6kV
         vNZTCXcISumHfNNcC/6Ew/JdbYcT4hukj7liwQGhbDDpaeuImNLRYOlpGZJumujMgYPJ
         Gfxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jVpb4eWy;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p26sor14529839qtc.31.2019.06.16.21.27.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Jun 2019 21:27:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jVpb4eWy;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Jbyq7Q2frV79XYaBb+RkixOf6rqvbIp5HPcBcMU9Ye0=;
        b=jVpb4eWygwk/ckbAnoKWWrEL8/9ciuMeXo+OXMQbw4lVohXTa2QFT9iPZ22RMmTuG2
         kFzfBgluct1Lij+sA5G/Cky2Psq9/psI9HP6gEWqczMKh4QYF95VTgpFZ2FL/3KNHrKX
         iE1OChVEgj5cNjyyGmbEZaUswSIhsr6p5eNjtkg99/6I+WGhkqc3TZ3hw+0+EIqnugVQ
         DDeLGCkBaKM1E7JQzDEanIRZ27cv6hKXYyOuuox8efU5S1Xny/VbQCBRk06kDC1/LcFq
         uN/eO1YaOGrb/elEj/xB4/gLbSV78HD2r14HLRGsLTWrOCnjyb/SC7Dab4+Vj2tlvbKF
         D9FQ==
X-Google-Smtp-Source: APXvYqz98YOorzFY4+k5v0LreYOOqec8w5b+vRF+LffTx/HLtStoJ/Aj3kJlMhu0loBjNZ2ykOkSKJhYWsW+jV1pTwE=
X-Received: by 2002:aed:3b66:: with SMTP id q35mr93395728qte.118.1560745641667;
 Sun, 16 Jun 2019 21:27:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190613175747.1964753-1-songliubraving@fb.com>
In-Reply-To: <20190613175747.1964753-1-songliubraving@fb.com>
From: Song Liu <liu.song.a23@gmail.com>
Date: Sun, 16 Jun 2019 21:27:10 -0700
Message-ID: <CAPhsuW6PEwRnw=z57LPLtsvZPVCcnZR69uhs5FRVczM2OZSeXA@mail.gmail.com>
Subject: Re: [PATCH v4 0/5] THP aware uprobe
To: Song Liu <songliubraving@fb.com>
Cc: open list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Oleg Nesterov <oleg@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, mhiramat@kernel.org, 
	matthew.wilcox@oracle.com, kirill.shutemov@linux.intel.com, 
	Kernel Team <kernel-team@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 10:58 AM Song Liu <songliubraving@fb.com> wrote:
>
> This set makes uprobe aware of THPs.
>
> Currently, when uprobe is attached to text on THP, the page is split by
> FOLL_SPLIT. As a result, uprobe eliminates the performance benefit of THP.
>
> This set makes uprobe THP-aware. Instead of FOLL_SPLIT, we introduces
> FOLL_SPLIT_PMD, which only split PMD for uprobe. After all uprobes within
> the THP are removed, the PTEs are regrouped into huge PMD.
>
> Note that, with uprobes attached, the process runs with PTEs for the huge
> page. The performance benefit of THP is recovered _after_ all uprobes on
> the huge page are detached.
>
> This set (plus a few THP patches) is also available at
>
>    https://github.com/liu-song-6/linux/tree/uprobe-thp
>
> Changes since v3:
> 1. Simplify FOLL_SPLIT_PMD case in follow_pmd_mask(), (Kirill A. Shutemov)
> 2. Fix try_collapse_huge_pmd() to match change in follow_pmd_mask().
>
> Changes since v2:
> 1. For FOLL_SPLIT_PMD, populated the page table in follow_pmd_mask().
> 2. Simplify logic in uprobe_write_opcode. (Oleg Nesterov)
> 3. Fix page refcount handling with FOLL_SPLIT_PMD.
> 4. Much more testing, together with THP on ext4 and btrfs (sending in
>    separate set).
> 5. Rebased up on Linus's tree:
>    commit 35110e38e6c5 ("Merge tag 'media/v5.2-2' of git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/linux-media")
>
> Changes since v1:
> 1. introduces FOLL_SPLIT_PMD, instead of modifying split_huge_pmd*();
> 2. reuse pages_identical() from ksm.c;
> 3. rewrite most of try_collapse_huge_pmd().
>

Hi Kirill and Oleg,

Does this version look good to you? If so, could you please reply with
your Acked-by and/or Reviewed-by?

Thanks,
Song

