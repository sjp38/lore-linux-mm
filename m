Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1694BC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:04:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7DC22087E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:04:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7DC22087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99C098E001F; Thu,  1 Aug 2019 11:04:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94D618E0001; Thu,  1 Aug 2019 11:04:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83C958E001F; Thu,  1 Aug 2019 11:04:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 675218E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 11:04:37 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id m25so64730699qtn.18
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 08:04:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IxLpbU0yM9DyRdS0jdHjjq6oRWrV9QDR/oP4S9YJzHs=;
        b=ZfieebCD1q8+qeAcfbTJpRgT60Q48zAC+wVhiL0w82q4LxdzbqvcUSJHdqDUPEVik8
         sbddgZB5fiwDohj1aUJEFbgm2A4MIqY1BQ+xvG+pRJcmcQVfM0dwyyp90jkahYLCIXQn
         uEwWfwyLHu3o0lvh2SUikNNSPbcxxAU9ko/pKIgrK3TE5A2kq7gyxBh48AGWJu7/PPRj
         QQIMe9UHvnHBnm7KnUFpqimqmAVUwZ+/jL449dmudXI/GodEByA5THPNrGSnAcq63i1A
         srzIJqIom6bjW61YXfewWG3mZynDkoUm40pH7iaRVGB2gc9fYnTTg8Vaejneiu+xRwVO
         XhgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWFqRmBD9QhnaNIb4McjfzjnbaFkGOYXfeyWjBUc9oemw5+obr6
	/iySfAJWKCSJ4m6LQlHpzM4qBwz8UKTEVB6oKq9uZEZ8L677lBGs6B3QWc89YRudhoZUwAr1ijr
	rHOoSqS+4PVftrFGTS+1A9RNyXXg5EMHm2Qv0KWBT/+u4uAvlH8g3cWUnayW6rJ6nFA==
X-Received: by 2002:a0c:b115:: with SMTP id q21mr93193860qvc.68.1564671877197;
        Thu, 01 Aug 2019 08:04:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuWHJ0Yk+KiJKkkBGWkp+iCkc2Nw/iELR/Lr329uwO8B4Ojj4OjYa3glDHaisIanXP+VY2
X-Received: by 2002:a0c:b115:: with SMTP id q21mr93193808qvc.68.1564671876695;
        Thu, 01 Aug 2019 08:04:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564671876; cv=none;
        d=google.com; s=arc-20160816;
        b=LlX70fE7fyz2LpSU1U3HvgRN3ph//0g7DR+KVVqvrWNW5Woe6hovW1fOL7bwN/Ql5c
         7WbQe0dPipfQt8Mtr5l89ybYDQiJQPNhSeSfrsiBQFdwtifOrnfFv1cixLbt1jDSc7Ta
         qLRboHikmvLmaPMuFesgZjjNke57TaShselJteBtuBaNhZqiyLNGjgG6VbT7964tZY5V
         FfhYqNhOwvewehv3lw0Br5YpKMUnjJMjfrXcdDPUc7a8fEkIXhZHR5SAtlSaAHi6Dhvo
         HAco/5EXmin6kCpTcMrHb7g8XEksvxNarwdsUVuxQIpDRMfhPs171QggIGQ4G3TG7MWu
         /19w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IxLpbU0yM9DyRdS0jdHjjq6oRWrV9QDR/oP4S9YJzHs=;
        b=B+n4PRBVisYywgL/MwZ1ixF2EEazxNu3ER7/y67YC1bMbwHBD0sgSL9WOvgKM0cg9f
         eO0yPODucy9dHhPFHzStMLCeZ4lH87RAi4X+//2VrCNGuO1VU4Kflp1m8gb+Qyp9HcHB
         PF6Q8qD05PHh9p6uuUD/UCLyfpUFXEeqvVLvQ/IOJojKyOGFJXb0/rNNWo0nuOrENRNl
         QGykWYXfq1BJajzNTi/3XDJfrZTlIpWW/Fx9Fr7FT1KaFMuPVdFwSV8BVKS5lK/0IWpu
         Emy+H6uTsndDc/OTehxIzh/46XvTmZ5hQ8qd0Sm/iGXRiMYu9wWPBeI3pHSULvBXXW9K
         xtgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l26si37713558qkg.62.2019.08.01.08.04.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 08:04:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D034B30A9234;
	Thu,  1 Aug 2019 15:04:35 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 0F0E51992D;
	Thu,  1 Aug 2019 15:04:33 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Thu,  1 Aug 2019 17:04:35 +0200 (CEST)
Date: Thu, 1 Aug 2019 17:04:33 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: lkml <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>,
	"srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v10 3/4] mm, thp: introduce FOLL_SPLIT_PMD
Message-ID: <20190801150432.GC31538@redhat.com>
References: <20190730052305.3672336-1-songliubraving@fb.com>
 <20190730052305.3672336-4-songliubraving@fb.com>
 <20190730161113.GC18501@redhat.com>
 <1E2B5653-BA85-4A05-9B41-57CF9E48F14A@fb.com>
 <20190731151842.GB25078@redhat.com>
 <04FB43C3-6E2B-4868-B9D5-C00342DA5C6F@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <04FB43C3-6E2B-4868-B9D5-C00342DA5C6F@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Thu, 01 Aug 2019 15:04:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/31, Song Liu wrote:
>
> > On Jul 31, 2019, at 8:18 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >
> > Now, I don't understand why do we need pmd_trans_unstable() after
> > split_huge_pmd(huge-zero-pmd), but whatever reason we have, why can't we
> > unify both cases?
> >
> > IOW, could you explain why the path below is wrong?
>
> I _think_ the following patch works (haven't fully tested yet). But I am not
> sure whether this is the best. By separating the two cases, we don't duplicate
> much code. And it is clear that the two cases are handled differently.
> Therefore, I would prefer to keep these separate for now.

I disagree. I think this separation makes the code less readable/understandable.
Exactly because it handles two cases differently and it is absolutely not clear
why.

But I can't argue, please forget.

Oleg.

