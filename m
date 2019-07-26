Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5BFCC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:44:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEA392166E
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:44:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEA392166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 537526B0005; Fri, 26 Jul 2019 04:44:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C1558E0003; Fri, 26 Jul 2019 04:44:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AF2B8E0002; Fri, 26 Jul 2019 04:44:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 196986B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 04:44:28 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id m198so44506292qke.22
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 01:44:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=m5jDVP9T1V4F89n5NEhGPcz/v3vUHdPn/V/7rFludbA=;
        b=NBFI+EH4AVlNIEX9W0tr63IbUngamhXW4xFZkh+U10qdGpdzyewAN3CU56XsROES/a
         9f3EjgvQtAVel2tUNQZrsX6vTZ0p6vNUt+SKe2hypeNdmDbtWjNXsIkJm81Jz7LsSgX8
         JF7nIcLt9Qmr4qUH3Wkkr0egMflZtyBleuXAqziBASGz0f0mHA7zpJHKkZRtltT/V86w
         2Pl9d82sGoGEySYOzDLaiWqIJkwFXt/9TG5Ek1tV8QceEdIIV3ruwnppvA2iNMvsKsYx
         5vcTW+WBAxlCa55O/pK1pyVcBHgvUyKttYQfD1JmM2ZSml14DE6IgOv/jBU5zlDr4PnK
         3J7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWKKDypaT5akMl5WPm4Y2bXeGLkHUiZhzN8GTM4FtwtqHBjd8Ld
	SBlULW+ZpDHqo8+1pBVwhGMGGYqxQCVmleMyUVmWYf0TTI6YsXkniahk8BIyauJ85GgCy/FDtfm
	FIUOepdZ32yLvteDGV+17XbOnxMbvzZH2R1tGWCZBrgt5nLpz0uYKyKKqf0kHGOsi/Q==
X-Received: by 2002:a0c:86e8:: with SMTP id 37mr68559233qvg.77.1564130667902;
        Fri, 26 Jul 2019 01:44:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGN0sVbDhBom0VjYRsBlk0bISIM4TDz1Ey00craW8lPwmm8+d57r76stge1OB67ffh30mF
X-Received: by 2002:a0c:86e8:: with SMTP id 37mr68559212qvg.77.1564130667468;
        Fri, 26 Jul 2019 01:44:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564130667; cv=none;
        d=google.com; s=arc-20160816;
        b=p4sXAMpxCpdTFWQ6JpQP2YsNJr3cpE4t2YPYvBg/YiIvSyLyUpU0H6qR2KYA80gfIM
         yrRTyAo20uL9nn8u1JtLv9TA/xHCMBrriSDyEi6Pct2zbv+2zqZI2XlpQGqX77p/se5o
         LcNBZZHaOyQmXjpAbJDAxRHqhrnynkqIgKt4Z6f9HprSqyU9KInUG8XDNMlPmG/p5xaW
         oTDQdU2qk0MiEc9qQq/x2jbPZHbgRLFxjQsUfIL5PabTv1o2/PrER4GcsXq0kcRiXzcB
         EDbcXyRJEgpopZq0jY42xgEsGVwlh9v82HOjes/ylFp4X4LXyn7HzaPTZMQa2xzp3jim
         hTjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=m5jDVP9T1V4F89n5NEhGPcz/v3vUHdPn/V/7rFludbA=;
        b=CyFJ/fcOYNz4wDsHelY3PJzilMlrIFi48Uqix/8HA/TiRt7BJS0T1YPZPbjcbX2kBg
         piONyt4bdjLYMgRqK5FQhXDc0hJ/w17Chu2XiLayxFmf4+BlJS4V/PD/uKMX5l/AP/Ye
         noIUChmUNyLhjwiCOaHfmzHDnL4qZKNAdE4s2FpX0YX4Pw5GK0K+eOHtVXrknZ/zPVK6
         vuQXmSvfR8l8MELD4FGj8IftqTRVESq8TjIwda970R8cYnlHDFNpzaOQkg+GX9Rdezyf
         JES9WjmwRyD4gl1Qiy4Bp/oqaCZTncbvER9MkXnlHXnyS0caerzvar8FAMtAvAlKXlG8
         5GVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p14si2572288qkm.135.2019.07.26.01.44.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 01:44:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9136830A6960;
	Fri, 26 Jul 2019 08:44:26 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 856EC101E241;
	Fri, 26 Jul 2019 08:44:24 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Fri, 26 Jul 2019 10:44:26 +0200 (CEST)
Date: Fri, 26 Jul 2019 10:44:23 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"rostedt@goodmis.org" <rostedt@goodmis.org>,
	Kernel Team <Kernel-team@fb.com>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>
Subject: Re: [PATCH v8 2/4] uprobe: use original page when all uprobes are
 removed
Message-ID: <20190726084423.GA16112@redhat.com>
References: <20190724083600.832091-1-songliubraving@fb.com>
 <20190724083600.832091-3-songliubraving@fb.com>
 <20190724113711.GE21599@redhat.com>
 <BCE000B2-3F72-4148-A75C-738274917282@fb.com>
 <20190725081414.GB4707@redhat.com>
 <A0D24D6F-B649-4B4B-8C33-70B7DCB0D814@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <A0D24D6F-B649-4B4B-8C33-70B7DCB0D814@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Fri, 26 Jul 2019 08:44:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/25, Song Liu wrote:
>
> I guess I know the case now. We can probably avoid this with an simp=10le=
=20
> check for old_page =3D=3D new_page?

better yet, I think we can check PageAnon(old_page) and avoid the unnecessa=
ry
__replace_page() in this case. See the patch below.

Anyway, why __replace_page() needs to lock both pages? This doesn't look ni=
ce
even if it were correct. I think it can do lock_page(old_page) later.

Oleg.


--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -488,6 +488,10 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, s=
truct mm_struct *mm,
 		ref_ctr_updated =3D 1;
 	}
=20
+	ret =3D 0;
+	if (!is_register && !PageAnon(old_page))
+		goto put_old;
+
 	ret =3D anon_vma_prepare(vma);
 	if (ret)
 		goto put_old;

