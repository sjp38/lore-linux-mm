Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 665ADC04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 02:01:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E5012173E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 02:01:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E5012173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B40F26B0003; Mon, 20 May 2019 22:01:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF0DF6B0005; Mon, 20 May 2019 22:01:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DFA66B0006; Mon, 20 May 2019 22:01:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6625F6B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 22:01:15 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id p124so10987695pga.6
        for <linux-mm@kvack.org>; Mon, 20 May 2019 19:01:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=ssSRIiXeKDe9YrHF0fitzIU9x5jTDXqXu6THa9Drf9Y=;
        b=IprBlqHfAEa/0YJw2MrCRu7ZibEz9IX5WEVeASP5daMThr0uQcT5vH0OXNhFsty7vL
         gu0lXOhkGokfYCvKXkpjUQl/E4exLsPr0kUMKcKiwRdELzMeW7zBNQsEbTnbbLP2wb41
         gLdv8CFk0kcckxkfHEBPAHXQNEVyGw9QrASzO1tEj/wEG6V1IW2WjNJEreAlPeDIhKWT
         k7XnbHnjsiur40GqPQek19AqfiSQxXr5SlD2ZM098H0F91/QURydu3ZsY3XBtswvIET4
         CcGwc6M0ET43jjO807SwziNc0jlbm+KcizbSpS/U13K9uclDb5TJ4JJ3XU3sq/NVUdPN
         P+NQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAXyUEp3vlQ3wzZ6r0I8aPF3F1veQft8jHI4FaOIz3r7uHr70R1J
	UnEaoQ73SCAK7LLCZ+f7e2Q7ObRA2nawrBYgr75gGOkdK6skwZT7tkhwwHNrR4tDKuTRmkijzhd
	4SxjXybNTLKuFDGEmEYrN4BpHOoaWZK5VAVuc8ev1vIRlCZfApRkJnaUglIM5Mk1lOA==
X-Received: by 2002:a17:902:7617:: with SMTP id k23mr36019882pll.175.1558404075017;
        Mon, 20 May 2019 19:01:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHVf/fWAECm03soHBeDBO8GmLLlbKcNrcd+HuuPqOgGaxQH0TkxVMrI9xpFQpBzqsix808
X-Received: by 2002:a17:902:7617:: with SMTP id k23mr36019817pll.175.1558404074365;
        Mon, 20 May 2019 19:01:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558404074; cv=none;
        d=google.com; s=arc-20160816;
        b=FYNNprVony7NHpnlsy5M0H0w5hdLb28IR8cEl19gB6FvbYcaryQ9sVe+M/tCkctEXR
         JdtIxzlL1fXanMgGypSwzpBM4eUSiRQvxggDk6KcC1wgBXJ+kXTQaUnyODljo+9j3/i3
         Vsnyikl515lkiqpb6d5dwi7uL+iK9+cKsSQPsPi3tDCcDmqY9cxTsjzpb4T74D79sKqx
         IvD3lSbAUPG+TCYPuxtKoZalK4/y980x8+FE8G0hFjkbn1oqHrK9qmLzBP7IJbCP0/ia
         JBP/qcxyMuJHh2Kg+314NEQsYbwX9nnvuNllM6R9Y0/+3HGkcNbi7TuRCV9PyUalV8nm
         Jwpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=ssSRIiXeKDe9YrHF0fitzIU9x5jTDXqXu6THa9Drf9Y=;
        b=g89ZOzyLqcF8U4j0U8glav3w2c1XCDvkhh3aySnb7HYhWihZZYFfJSMcO/4NLugEMP
         5XOOlC/gWRbPOvVfGOgwwUUKyBDUdaY4FJl8uyqpDrDZ5OOpRPgQul/41kL7qvZ0YhlJ
         1Jc3HIOsoNIJIpAv+bUOxKqqK6KNBCKv7fQYSngW5m3X9dQ/RsBSsbL6qs35Mly1XUBb
         ni9R2ow6PwoNLo1YUv5lMelWsbBKPdlRQYlcsHuV1FKS4IB/olhi+OywtL/UYcJ7mI14
         q94oSg8Y5K75kN5ueLyffrDsh7VOd3IoXMB08V1zUYgn2brNCCGuPNAODtZ+ytgt1B5/
         BIYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id a16si18848003pgv.75.2019.05.20.19.01.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 19:01:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x4L21CvV030698
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 21 May 2019 11:01:12 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x4L21CrE008501;
	Tue, 21 May 2019 11:01:12 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x4L1w6ED008163;
	Tue, 21 May 2019 11:01:12 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.150] [10.38.151.150]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-5223250; Tue, 21 May 2019 11:00:59 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC22GP.gisp.nec.co.jp ([10.38.151.150]) with mapi id 14.03.0319.002; Tue,
 21 May 2019 11:00:58 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Jane Chu <jane.chu@oracle.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Subject: Re: [PATCH v2] mm, memory-failure: clarify error message
Thread-Topic: [PATCH v2] mm, memory-failure: clarify error message
Thread-Index: AQHVD3fQwqWRF4FLCEydPsRIMf5FOKZ0PD+A
Date: Tue, 21 May 2019 02:00:57 +0000
Message-ID: <20190521020057.GA8671@hori.linux.bs1.fc.nec.co.jp>
References: <1558403523-22079-1-git-send-email-jane.chu@oracle.com>
In-Reply-To: <1558403523-22079-1-git-send-email-jane.chu@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <3E17EDE90C0E1D4DA28CCC1CA00B2217@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 07:52:03PM -0600, Jane Chu wrote:
> Some user who install SIGBUS handler that does longjmp out
> therefore keeping the process alive is confused by the error
> message
>   "[188988.765862] Memory failure: 0x1840200: Killing
>    cellsrv:33395 due to hardware memory corruption"
> Slightly modify the error message to improve clarity.
>=20
> Signed-off-by: Jane Chu <jane.chu@oracle.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks!=

