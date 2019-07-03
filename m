Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B27EAC06511
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 00:59:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AA372089C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 00:59:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="pPp129mG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AA372089C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECDA76B0003; Tue,  2 Jul 2019 20:59:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E88558E0003; Tue,  2 Jul 2019 20:59:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6B958E0001; Tue,  2 Jul 2019 20:59:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id B211A6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 20:59:16 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id 77so307993ywp.14
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 17:59:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wIf3s/qpqMqc2ju4HSpCa9loV1PYd9khtmiRlahKfMw=;
        b=j9blYxYpR51mxUyMgfsY/y0XxrXWfc899wfGclil21CVJDLGbNNr/RpIBgbKcepFET
         SLNvl6olPIzSXl9LRLJGa2ZMNDkFk8sk21+IAl7TBqJh16SlYrU2bwe4TqGxpExFri/g
         tu2EhhDVijFjYBH6G3up7mmiewXa8O9XWtHuWbDW60h2+6fBGqCKiDiusT1nWUIEepyR
         VSQjT6yIsjI4RFPMW0p02+rsFj1G3y6Hmr308YiolqUa+kHzp+K7c2wYMN+/PCwVco32
         GuziNxvM17aWUxl2lD1AyYrlaTdlAcp9mFamjN9kEnLtrSDlqrhOvL0fBV7VYnO7ig2C
         4/Hw==
X-Gm-Message-State: APjAAAUSmZfLxydpzJ2JEEmHFP1uuNFu0cd8cDITXxtIVCaxkL/T0J8A
	Q/4jyzmvAYYVG+VgIls/B0WdviIO3lVKCgFp4kle1me4YmcRkH89crO5vpu6PGz+tEzC7tgowVn
	XFh/Ot49u4LaCqHOjBYUdasYeh34SDyeY7EfkvNgAIYtaff8bNrnsqXG47tD39QhvQw==
X-Received: by 2002:a25:8381:: with SMTP id t1mr6513754ybk.369.1562115556429;
        Tue, 02 Jul 2019 17:59:16 -0700 (PDT)
X-Received: by 2002:a25:8381:: with SMTP id t1mr6513736ybk.369.1562115555615;
        Tue, 02 Jul 2019 17:59:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562115555; cv=none;
        d=google.com; s=arc-20160816;
        b=iOJG4hpgGhxZKPrY/ZNttgVaPsUSp+lWt3TW0RWTMF1dzYMPdCjMOaySNJ5jWznrq7
         H0PdDFDJjoB+Y8BHtNO/5cLkqI5r2e1m0NUES19ICvnTeoWiZc/86yZqnFHVc2xwl9Gk
         TJ9KBz+RD3E+Qc+X6aVGXPtSkfd54VMqy+1vAOD5IVG7QvLkUABRxmWM/hTeiK6rv4TN
         MN+5sp+Z01Z0czD7Xg1/4QmEaYCVmvm+yZquukt/c5CGfP8OFgatSnGxGF7fAipyZ/ny
         QzZ/HZxH4NX6mM4mzi4wt09ZKeBa8vxlsup4sM7GL3HzYhUEvApnEEC0DBz6tuktHFmy
         LSiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wIf3s/qpqMqc2ju4HSpCa9loV1PYd9khtmiRlahKfMw=;
        b=DX5so9glfP2DSJLKWOMl8P1giHMbvdXT5TbkOU6wYKHWFjXiB02VgzRyVKjHsTXL6L
         jD45qp4ucwddY7y5mtrX5V0UA4iz2FzkOwrL7N2m5IvYa78Vc2aiX8cz5U8hXeFmHIa0
         yebVoza2WlPgoZQkBe+LsWSoUgtxjxPp+k0t/MSMC+pCSyO9dHOpH40v11H2hiBxhoPW
         XXeSkoSI5NQ/XZo5WQvfjXjDt3OEGoZDr+stx6wBfbgQigVmEAzOhvyeQbw0CyBn1vEh
         STLZ9wI9sfyjDBQpDaVCm97IbyZoCJhh082sVb4/OlzW87dySWn32J5c1chNmUxkGWLu
         3kzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pPp129mG;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i129sor270806ywe.204.2019.07.02.17.59.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 17:59:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pPp129mG;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wIf3s/qpqMqc2ju4HSpCa9loV1PYd9khtmiRlahKfMw=;
        b=pPp129mGMAgZmQQqFW2wfGEyipUebLHwGsceAtgrBF3rmcputVE6yLkvSQzI5+Umpe
         ozwXEefLssoK6is8zIDlkwY/8KxjUGg4mFuSKbFB26uy43eFMyRjUtyFLV2PXbRIXp4S
         nXHtGaazQ+NoOvr/kGLrfL86ynZ5+JPT39vV8UPPVwpByVSniduvE865bw+oh4sDDk8e
         jZ+tHN3OsCR6DZ27o/h80jb8FFe8FqUFoAO21NfwxBXtyuAwby9BaxyIDkmG6v6CBDrB
         xMZdvZ8g4jOQzQlCof9FvROv5TZ+hPQySu6YgAIUvgtORBagVLpLL4A6t2rIK8irYDYe
         USHg==
X-Google-Smtp-Source: APXvYqxK5DEkk2kHSda+WF/FAeUHPkw6wKzo7ZmZsBWNCRYS9CdUUUng7zhdFAAYidX2Li7ETs1OA9wyePtHHTyX7VI=
X-Received: by 2002:a81:ae5d:: with SMTP id g29mr19968749ywk.398.1562115554994;
 Tue, 02 Jul 2019 17:59:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190702233538.52793-1-henryburns@google.com>
In-Reply-To: <20190702233538.52793-1-henryburns@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 2 Jul 2019 17:59:03 -0700
Message-ID: <CALvZod7udORRrz7wzQPRa2Eya5TfrVh9kG037GKsAsSkRJPx7Q@mail.gmail.com>
Subject: Re: [PATCH v3] mm/z3fold.c: Lock z3fold page before __SetPageMovable()
To: Henry Burns <henryburns@google.com>
Cc: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Xidong Wang <wangxidong_97@163.com>, Jonathan Adams <jwadams@google.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	David Rientjes <rientjes@google.com>, stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 2, 2019 at 4:35 PM Henry Burns <henryburns@google.com> wrote:
>
> Following zsmalloc.c's example we call trylock_page() and unlock_page().
> Also make z3fold_page_migrate() assert that newpage is passed in locked,
> as per the documentation.
>
> Link: http://lkml.kernel.org/r/20190702005122.41036-1-henryburns@google.com
> Signed-off-by: Henry Burns <henryburns@google.com>
> Suggested-by: Vitaly Wool <vitalywool@gmail.com>
> Acked-by: Vitaly Wool <vitalywool@gmail.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: Vitaly Vul <vitaly.vul@sony.com>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: Xidong Wang <wangxidong_97@163.com>
> Cc: Jonathan Adams <jwadams@google.com>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

We need a "Fixes" tag.

Reviewed-by: Shakeel Butt <shakeelb@google.com>

