Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2479C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:38:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE0E52087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:38:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE0E52087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4468F8E0006; Tue, 30 Jul 2019 02:38:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F7778E0003; Tue, 30 Jul 2019 02:38:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30D0E8E0006; Tue, 30 Jul 2019 02:38:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB1A8E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 02:38:59 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id z42so6580270uac.10
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 23:38:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=+5/+Bw2+gbX/ORKgcWpjAO5hzt1+2rpnnzlcmSklrfE=;
        b=WFx9j0tdldk4kKOz1vsW3wCgnUrX+r9RJ71PLiTlr9jwysTBNuKpPicyCzYSXE6Ged
         VS822RIpAcmRGC75z5sefOnifAh0//gu1L+1XSykfzSG9SnahFmSe3P47Vyv26Km87l8
         YYSYzG5jAtAp0wokpX9gJW5nXmhTSJmXWtscxIMuDsseo71tnTNdfR0uyjnBwKqtmXqv
         dZfdF0aWZK3MQApbeFPNAuiPOltIlhJ+ei2x9jKZm26jYDfF35O58nkh7StUqeqGLgxE
         +1OQ9V8AihXPRfl02IIgjQWQlpPZ4oZB2J6esTIPQChm63Wc5r+af6anq44MiVeFPELS
         hTrA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=liwan@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW1sWJlGjLeSKE7hzlL2RMp7JpgC0wmhsaYNWiLYlLEZT7WH3pL
	VnT0Uasf4lt82Jrn2utJVIKYn/MNWb5bvtQPV19UMdVHad3lZ6VNRCcZqwN6nFFEXUx7abZW9fu
	5fS0qmIHbaQo8wfg/LnO5AV7CgnFs2w7A7LWaARr85CveAOH9Mv7p2PtCkkEJfZSYOQ==
X-Received: by 2002:a67:e90c:: with SMTP id c12mr26567503vso.97.1564468738830;
        Mon, 29 Jul 2019 23:38:58 -0700 (PDT)
X-Received: by 2002:a67:e90c:: with SMTP id c12mr26567486vso.97.1564468738318;
        Mon, 29 Jul 2019 23:38:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564468738; cv=none;
        d=google.com; s=arc-20160816;
        b=a7Ls96ptKiJCzObfBiE9jZzKD8jxYIBukj2KzdySlYjTsPbCdSoIHFMsXS0IuRrHAi
         IGE7YIxpCGVnX460ZtFZZS1jVuOcOoUo/N2rGEKGR2poUyvWO4/1fLfvsrSTqlA5ieOD
         fCtrS+qcewPeonIKtAsfdRNC5WI/v9rV/ziI9lJIg+qTVTIgimqIR0ld7Ey8zB4tMEWo
         cl82axSUAa5UGFgcV3l9yUBZWyI80ohMZxkY4TP+Iut8TQlYS8ZgpvGmoNutMFqU0Kel
         LlbjaOma4S05jHGq0gzmHtEqSH/8ZC68raSMOcBQbz3rB+Y3VuK0FIX5FovQKlaUz+8Y
         Apow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=+5/+Bw2+gbX/ORKgcWpjAO5hzt1+2rpnnzlcmSklrfE=;
        b=FJwPkaW+9std9ZybyFIEXvGuKWyiNMndbSocW6E/4OFTLALohiat61pabZOID/k2uF
         FBgTVzCJu/dVO82h+yZGh4m9hTb8RZulvdWoTGAgT1NQ746aJyk8QwpfQ8Cc+RSPDPJY
         P4l8qbVeK4Z5A568g6GMm4UhpdfKHSKXgeflTrc5UpcQJHdohKc0U2uX1T9YSk44UtK2
         iGXo6c1QfE5DztR4MqKT+AE785/SD6Rv1E9lbVOfxvZvwXE8kG7YyxISh2nN3uxKgWg5
         bBPj6wJIaYInJNmQDyhKF1Tme0wcVHjLX4W104Xf+VXxfXDN8X09Nh+XlRrMsylyfTED
         MTeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=liwan@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o19sor32897381vsj.101.2019.07.29.23.38.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 23:38:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of liwan@redhat.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=liwan@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxTaXCo8HfKzgnLPYngAW21qtWV0zeFT3LEZ+4DgUH+NuXUKisFrHkbdsBVDEC7V+kJsHNXIpJLgbqFwt+pcjg=
X-Received: by 2002:a67:fc45:: with SMTP id p5mr10012189vsq.179.1564468738016;
 Mon, 29 Jul 2019 23:38:58 -0700 (PDT)
MIME-Version: 1.0
References: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
 <47999e20-ccbe-deda-c960-473db5b56ea0@oracle.com>
In-Reply-To: <47999e20-ccbe-deda-c960-473db5b56ea0@oracle.com>
From: Li Wang <liwang@redhat.com>
Date: Tue, 30 Jul 2019 14:38:47 +0800
Message-ID: <CAEemH2eEMS7xrYwTjK8sbNg7OvC7ogRGs24TN8xkkwV1PD4amg@mail.gmail.com>
Subject: =?UTF-8?Q?Re=3A_=5BMM_Bug=3F=5D_mmap=28=29_triggers_SIGBUS_while_doing_the?=
	=?UTF-8?Q?=E2=80=8B_=E2=80=8Bnuma=5Fmove=5Fpages=28=29_for_offlined_hugepage_in_background?=
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux-MM <linux-mm@kvack.org>, 
	LTP List <ltp@lists.linux.it>, xishi.qiuxishi@alibaba-inc.com, mhocko@kernel.org, 
	Cyril Hrubis <chrubis@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 3:01 AM Mike Kravetz <mike.kravetz@oracle.com> wrote:
...
> Something seems strange.  I can not reproduce with unmodified 5.2.3
>
> [root@f23d move_pages]# uname -r
> 5.2.3
> [root@f23d move_pages]# PATH=$PATH:$PWD ./move_pages12
> tst_test.c:1096: INFO: Timeout per run is 0h 05m 00s
> move_pages12.c:201: INFO: Free RAM 6725424 kB
> move_pages12.c:219: INFO: Increasing 2048kB hugepages pool on node 0 to 4
> move_pages12.c:229: INFO: Increasing 2048kB hugepages pool on node 1 to 4
> move_pages12.c:145: INFO: Allocating and freeing 4 hugepages on node 0
> move_pages12.c:145: INFO: Allocating and freeing 4 hugepages on node 1
> move_pages12.c:135: PASS: Bug not reproduced
>
> Summary:
> passed   1
> failed   0
> skipped  0
> warnings 0

FYI:

And, from your test log, it looks like you were running an old LTP
version, the test#2 was added in move_page12 in the latest master
branch.

So, the completely test log should be included two-part:

# ./move_pages12
tst_test.c:1100: INFO: Timeout per run is 0h 05m 00s
move_pages12.c:252: INFO: Free RAM 63759028 kB
move_pages12.c:270: INFO: Increasing 2048kB hugepages pool on node 0 to 4
move_pages12.c:280: INFO: Increasing 2048kB hugepages pool on node 1 to 6
move_pages12.c:196: INFO: Allocating and freeing 4 hugepages on node 0
move_pages12.c:196: INFO: Allocating and freeing 4 hugepages on node 1
move_pages12.c:186: PASS: Bug not reproduced
move_pages12.c:186: PASS: Bug not reproduced

Summary:
passed   2
failed   0
skipped  0
warnings 0


-- 
Regards,
Li Wang

