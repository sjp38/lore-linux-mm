Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEE46C76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:43:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F4D521849
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:43:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F4D521849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 398406B000A; Thu, 18 Jul 2019 16:43:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34A278E0003; Thu, 18 Jul 2019 16:43:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25EDD8E0001; Thu, 18 Jul 2019 16:43:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 036836B000A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 16:43:10 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id l9so25439081qtu.12
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:43:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=9eblpP3JyzQ/q2PT74U6nG0AEs1Cq9zUs8kBlURUKNg=;
        b=MxRkbfLaVLqCoxcm86mcQxNASYpKp8L9GzRIU68QcNVm0i12KjncQdOy+Ehc55wssX
         dAIACDjGbOh2ZuoiGJT0Mv57D2mG9CXRyHMK8vmLewHbMKq0MtF6W5JYZG7p9oRMaMkg
         FciXzc0G2xn0VrCQrKpmgUKsEQDZ+mxFETckpTmrPKyNHmyMnQHSLlhBgxURYMM9TdzE
         /M11QNmJdeO174VY81/0g5ZYiSWWCXWjZ3Jwh8A2cW1mSA3hIb+uWk5bLsDlBGh8Nuqb
         EE+hMsEhhxeuiPhfod3xqyUjZB2ZX8dIrmc/yL11BDtq5Uuyzl6ttE/QcfT3mn0pPos8
         RusQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXx+bCnhYdsttO21IFgX8EBAg3QloXKAhZvVhvvgLDpDOdjUmOh
	VMAoElyB2o+3HWbr0N7q9OwT246A6Qm55CpVgjek/+8zAQrnmOQjGzLdStpE/JT2ZX1w1mC5UKf
	+3RPxxvEQyLsRiVl6X65330DQ2X+0YRP+UQZtKQ0yEHENWa1vb2VXrlyKfh7+wf+ezw==
X-Received: by 2002:ad4:4423:: with SMTP id e3mr21384126qvt.145.1563482589773;
        Thu, 18 Jul 2019 13:43:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/HrcCLhDXoy5uNr7Tr89ukFh8b8tADZfh0DKx8wIwHe5ibz0SeehBrtIurlTc6p2BYkQp
X-Received: by 2002:ad4:4423:: with SMTP id e3mr21384115qvt.145.1563482589293;
        Thu, 18 Jul 2019 13:43:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563482589; cv=none;
        d=google.com; s=arc-20160816;
        b=cvuCjg30BqDF9pF+cg33as0y3gc6vZ4RrihrEpZ+WxCTCVJR8HKkXgbkDEyeF3Qj8f
         HMLlKcc145OXfBkzyOQvmx0Ak8dD4QaLrxD31loVDVt/KrcPKuffoZ5lL3Gknscuf3CH
         eXpsj6uwzl8VUcTxt/eAbZ+9v+A/a3M+YenHvVlPW6WPPfcBbQA8doKXaXl9QeqmXLwa
         66hvv8oau1vQeEfjtlNSER/vTPeOnMbs3YAIkHm5cSp2+aQ37TDLAhlyfiLFYA0g9MkV
         HakNbBdMw6TwUoLCVngAVzYxgVgey+aXpne2tc9wsQEEZ/CYoZh4LCanYuoQCiKUDq0l
         ASXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=9eblpP3JyzQ/q2PT74U6nG0AEs1Cq9zUs8kBlURUKNg=;
        b=yYjg0wc0jyvtbEvV3iKfVJroHrH71Lji4L9sLR23FXDSc5GLnMzMIjMHE+CPDJqnu4
         vnzWFnzEhyi0P4JWrWIG0cv7RBfpw1BReW7DEQdIH1YSiIhgRLThQDKsAnsB+xMReHs6
         Vl6LfnKcxFDvL7RWR8NhNLkkM0Lj4s0/U68tVLiorAWat5GT3lKQuz3zhtCV/BgvLQSq
         ictOaMmXpELDlB0qEllYDLZnRldH6Bp06kQhW7yRYPK9NeQIbBJ06IR10JgoYaHluVPo
         35jZJSDy3hBU65lsx69/UgqMI8NS1FNan8Rsh184/rTCWJgMEdfkPmK9Zee0Ji9ZGFBc
         Lukw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a13si19347895qvh.92.2019.07.18.13.43.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 13:43:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 71EB881F0C;
	Thu, 18 Jul 2019 20:43:08 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id C0FFA607B0;
	Thu, 18 Jul 2019 20:42:51 +0000 (UTC)
Date: Thu, 18 Jul 2019 16:42:50 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Wang <wei.w.wang@intel.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	xdeguillard@vmware.com, namit@vmware.com, pagupta@redhat.com,
	riel@surriel.com, dave.hansen@intel.com, david@redhat.com,
	konrad.wilk@oracle.com, yang.zhang.wz@gmail.com, nitesh@redhat.com,
	lcapitulino@redhat.com, aarcange@redhat.com, pbonzini@redhat.com,
	alexander.h.duyck@linux.intel.com, dan.j.williams@intel.com
Subject: Re: [PATCH v2] mm/balloon_compaction: avoid duplicate page removal
Message-ID: <20190718164152-mutt-send-email-mst@kernel.org>
References: <1563442040-13510-1-git-send-email-wei.w.wang@intel.com>
 <20190718082535-mutt-send-email-mst@kernel.org>
 <20190718133626.e30bec8fc506689b3daf48ee@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190718133626.e30bec8fc506689b3daf48ee@linux-foundation.org>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 18 Jul 2019 20:43:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 01:36:26PM -0700, Andrew Morton wrote:
> On Thu, 18 Jul 2019 08:26:11 -0400 "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > On Thu, Jul 18, 2019 at 05:27:20PM +0800, Wei Wang wrote:
> > > Fixes: 418a3ab1e778 (mm/balloon_compaction: List interfaces)
> > > 
> > > A #GP is reported in the guest when requesting balloon inflation via
> > > virtio-balloon. The reason is that the virtio-balloon driver has
> > > removed the page from its internal page list (via balloon_page_pop),
> > > but balloon_page_enqueue_one also calls "list_del"  to do the removal.
> > > This is necessary when it's used from balloon_page_enqueue_list, but
> > > not from balloon_page_enqueue_one.
> > > 
> > > So remove the list_del balloon_page_enqueue_one, and update some
> > > comments as a reminder.
> > > 
> > > Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> > 
> > 
> > ok I posted v3 with typo fixes. 1/2 is this patch with comment changes. Pls take a look.
> 
> I really have no idea what you're talking about here :(.  Some other
> discussion and patch thread, I suppose.
> 
> You're OK with this patch?

Not exactly. I will send v5 soon, you will be CC'd.

> Should this patch have cc:stable?

Yes. Sorry.

