Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57C8EC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 06:06:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AADA205C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 06:06:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="s8dO8ROD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AADA205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 903D16B0005; Tue,  7 May 2019 02:06:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B3B46B0006; Tue,  7 May 2019 02:06:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77CF66B0007; Tue,  7 May 2019 02:06:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 201726B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 02:06:23 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m57so13728593edc.7
        for <linux-mm@kvack.org>; Mon, 06 May 2019 23:06:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QZm07w2nSCiVVM+WjYPWUvz7wW+nL7XT9qvn8eYdy3A=;
        b=s9jn6VSwamd8Wr2SqUHUb9TZATE6xT4SLwZle8UlE9G95tyZdKJ3fYQVAV9kaE+cRy
         XqdliA0l6dlQkWm1p9bjMsdMvo1vrawcDr+VsCWg4fAYokUkY8JtYP5woC+iuGVx5gYR
         V6nlA9eGU7QPrpqOUrqsy4rRcVvB6+Ht6xmlKTkMR5q2GubqOJLxjzw1g/LoSE5PYwfo
         d2JjQRpYkOX87M1fnLCbARqpObB2DvmIU4zs7chTK1voWcbNgrgkadl6GCXfRpl9mbfS
         EsiCiXTbgbwqzDlpxNPUCrEZ8JDSBZYbd1YQRJluxVbjuhuR7m6w6KwxyuhNkBDWTL/x
         ftxg==
X-Gm-Message-State: APjAAAXyVYbyhc3aIljG79Pwbbs897j4pn0fjjAWaJSD+YwsxVHDL1rr
	3wHvAc9v2exta31VMIGFlszf5ImbDvTfoIAwsK2iLNp3J7GzplwR9H/OcwQwDlK8E4na2vA1NEt
	ETySR9S6DnShpPLMljtqMk14s6H1t8PeBRuiRyw7MyUlUTXXseC0qU+OwxmK36y4FnA==
X-Received: by 2002:a17:906:66da:: with SMTP id k26mr7145840ejp.292.1557209182634;
        Mon, 06 May 2019 23:06:22 -0700 (PDT)
X-Received: by 2002:a17:906:66da:: with SMTP id k26mr7145776ejp.292.1557209181713;
        Mon, 06 May 2019 23:06:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557209181; cv=none;
        d=google.com; s=arc-20160816;
        b=kNnD28/tFFHuuPmy0waP9+KJqfXFMbUFYGc0Xhfvm+rAcqjrJ5z79CvKHDPAC/CP5K
         M/8q5G1vaH43taXy0j7I2LcRY+JqoB5W/EUic37OzonM8yvORayTchSI95cGBi1+UB8T
         gn0ts3CHIVDZPZDowaEzOLq5ZqIoIeyN9ZFQNbf0NWUkAZc1sI7ME8eq7g3MBZIOZkaP
         MtmfC36xgLeFjc7eSY7O+eCOtb2ZO8kMYdKGePhbwXsn33wSw3o0872bHoVDMRzqWb2n
         GO/nOfaL/IGDVucwNwW7eUlHgwkjQlrGS1u7dWsgQvYY3GTWJBgOkliPze2ufqFX2rP8
         B0kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QZm07w2nSCiVVM+WjYPWUvz7wW+nL7XT9qvn8eYdy3A=;
        b=c/W/cT2bFZ2SnL1mJczTsOMkvhuD8BU9f52xssfiIYfoYFedXqih+hi/8TSIxPk75e
         42qteBTsxwXEQWcFQAc1W+YcPB4g9MiR52SneBb0sOPARin4UhztpuiAnpCUV4Pj461L
         LJNhETDpKGKioU8Cr8XLQgRHJol7qzYn4fLgqNnS+0AOKy2aYYNuhBTa2+mgAMnZOqkl
         K8+VZYzN7yKCUJM9HFniOjf4PZDHrl+cRXq1JP6xQJuHmx5hFpL+bhL0f9TseiTxv99z
         oR50VwgNm+pzf545qYtLb0trt7JhFJzdYmSLGHvCPYQL0PDznkB3SiE9MGDpnTXbQhJL
         EYzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=s8dO8ROD;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c19sor288718ejb.39.2019.05.06.23.06.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 23:06:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=s8dO8ROD;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QZm07w2nSCiVVM+WjYPWUvz7wW+nL7XT9qvn8eYdy3A=;
        b=s8dO8RODm3uMkCQw7BIWmMyABI0C1pYr2apMhdPiSkFP6bbNhtgHKr3/jYpzpeh4JJ
         qwhI+K6TykibR4CMsBrAXVJTbJKuBZJxieq+hk0SBdOWQh30lWltBeOlxCAYN3W3G5kf
         lHJxVYgKUtWlZNbmP/kBOLWFozOI16ok5/HpgPqAspD1694ZK8lLWKY32QBFhOlFJ5Gb
         Z5Gp7Uaf0qpz+W5mdgvizxUtiDNUVZP1LP2Du8LolUcjwpIkcJe0gm2itU6o2ojjsTz/
         k52m2uroKyHEfQtmox/LagM79E84Bwt57rIT8sBl8XjO3UfftnHVGgavNSvDjJoN0lP5
         5gzA==
X-Google-Smtp-Source: APXvYqwUTax6Nbe0rTjQMRruM2k63P6Yc2eck704d/9awNC5izroT9pbEMuhoHqfwRVTcq8tjZ9+yNcKWj5nNvgcVok=
X-Received: by 2002:a17:906:1903:: with SMTP id a3mr22284151eje.37.1557209181270;
 Mon, 06 May 2019 23:06:21 -0700 (PDT)
MIME-Version: 1.0
References: <1556437474-25319-1-git-send-email-huangzhaoyang@gmail.com> <20190506145727.GA11505@cmpxchg.org>
In-Reply-To: <20190506145727.GA11505@cmpxchg.org>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Tue, 7 May 2019 14:06:09 +0800
Message-ID: <CAGWkznE0zsGLVHuCx-WGk+TOcFe6w0wJ-MXM8=cXJPZb-rQD-A@mail.gmail.com>
Subject: Re: [[repost]RFC PATCH] mm/workingset : judge file page activity via timestamp
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	David Rientjes <rientjes@google.com>, Zhaoyang Huang <zhaoyang.huang@unisoc.com>, 
	Roman Gushchin <guro@fb.com>, Jeff Layton <jlayton@redhat.com>, 
	Matthew Wilcox <mawilcox@microsoft.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 6, 2019 at 10:57 PM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> On Sun, Apr 28, 2019 at 03:44:34PM +0800, Zhaoyang Huang wrote:
> > From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> >
> > this patch introduce timestamp into workingset's entry and judge if the page is
> > active or inactive via active_file/refault_ratio instead of refault distance.
> >
> > The original thought is coming from the logs we got from trace_printk in this
> > patch, we can find about 1/5 of the file pages' refault are under the
> > scenario[1],which will be counted as inactive as they have a long refault distance
> > in between access. However, we can also know from the time information that the
> > page refault quickly as comparing to the average refault time which is calculated
> > by the number of active file and refault ratio. We want to save these kinds of
> > pages from evicted earlier as it used to be via setting it to ACTIVE instead.
> > The refault ratio is the value which can reflect lru's average file access
> > frequency in the past and provide the judge criteria for page's activation.
> >
> > The patch is tested on an android system and reduce 30% of page faults, while
> > 60% of the pages remain the original status as (refault_distance < active_file)
> > indicates. Pages status got from ftrace during the test can refer to [2].
> >
Hi Johannes,
Thank you for your feedback. I have answer previous comments many
times in different context. I don't expect you accept this patch but
want to have you pay attention to the phenomenon reported in [1],
which has a big refault distance but refaulted very quickly after
evicted. Do you think if this kind of page should be set to INACTIVE?
> > [1]
> > system_server workingset_refault: WKST_ACT[0]:rft_dis 265976, act_file 34268 rft_ratio 3047 rft_time 0 avg_rft_time 11 refault 295592 eviction 29616 secs 97 pre_secs 97
> > HwBinder:922  workingset_refault: WKST_ACT[0]:rft_dis 264478, act_file 35037 rft_ratio 3070 rft_time 2 avg_rft_time 11 refault 310078 eviction 45600 secs 101 pre_secs 99
> >
> > [2]
> > WKST_ACT[0]:   original--INACTIVE  commit--ACTIVE
> > WKST_ACT[1]:   original--ACTIVE    commit--ACTIVE
> > WKST_INACT[0]: original--INACTIVE  commit--INACTIVE
> > WKST_INACT[1]: original--ACTIVE    commit--INACTIVE
> >
> > Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
>
> Nacked-by: Johannes Weiner <hannes@cmpxchg.org>
>
> You haven't addressed any of the questions raised during previous
> submissions.

