Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8856C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 00:58:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EAF520820
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 00:58:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EAF520820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F7ED6B000C; Mon, 10 Jun 2019 20:58:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A7D96B000D; Mon, 10 Jun 2019 20:58:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86FCB6B0266; Mon, 10 Jun 2019 20:58:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 692816B000C
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 20:58:29 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id i133so8784931ioa.11
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 17:58:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=Nli0S1o5NmY8M2FM63gvLqbsRyjr7oT0C4h3mKwj0Lo=;
        b=OS+WrTOBTtz6JP7B5wWJ+4nMvGyrjDQxa8lALdUFtHMg+lsjgUUWD8Jbtq/R+zcQM/
         T9j2gNnt5TLyYdp6xR7U51xxphI2UTzjX759mKMlHHWcqTdjkbeZJcMlD0Ly1f6lpt8y
         pdEWlHdcwdNci8y90sNcT9Hl5mW0LJyOMk4d8Svp7c9gWnpyC3NLdcPJZ6yjtqe+cSJe
         6AILITcEzfmUMwCU7mTclBst+h9gTtEBCufEAlu9a4/3+roWKPiRP/fL6HhAJskHZ4Bg
         mRmHbKMkxtUk07VLHxfcsd5PxgovjdtucW1g/OJ3zgVmi8nHCyQpRK2DRRC8NZYeIYYb
         i/eA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAXZO5AIJzwDCxTYpHsC7MyD6e3BnTlp3W6KODX4tw17G1rqU9wi
	UIxGzEHvWTTgi+JxFGPTlgh71MbmTUQIld6jcwDRjXjmNnn9MmARZTSmVjnrkuWwcCg+gy9iN/C
	3PZbpD2UZlr4vXUP+mjcZipWoF2BVHzXe2fPjY7/d/0zZ0lUaeFfKyxp11il3o3iZcA==
X-Received: by 2002:a24:cd43:: with SMTP id l64mr16342874itg.95.1560214709189;
        Mon, 10 Jun 2019 17:58:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTJXb6InL6rAknUG2mZQT9S10C3YyE4ImjIZQm+3tqe60tda1W15LcuMKG0JVhFcyqsMr2
X-Received: by 2002:a24:cd43:: with SMTP id l64mr16342854itg.95.1560214708513;
        Mon, 10 Jun 2019 17:58:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560214708; cv=none;
        d=google.com; s=arc-20160816;
        b=t3dZQ9L/yDeKijguqSjRWekMSqt9OJv79jcW1q+h859NH1w808pdwEoxd5iGKt4R5I
         XGYX2Eb9ZO+9C8Oes+jLxdbiPr4qcPZJq5ZENc+xM4IPFIFcadUHbwzgYsDQqkcLTqgW
         wW/Yvlz8uWNtM0SiFqHCjgWoJ7AFIhAMeIrqq/sia6kV9eaIOqR//wTKXvDmPzcJ6xma
         AkeuzwcOtC/2jDynQZwKgJ2I/sKQvUfbM4hJUCC3hwwXAOJUt9M4vAFcI5ZZN5lAGycp
         irrvd6Ipk7A8fxoNnyZzYoYRWC5ingF9jVPPNCFjyTxZHjq9AlehKxgZq5jnWQhDsEeG
         rkSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=Nli0S1o5NmY8M2FM63gvLqbsRyjr7oT0C4h3mKwj0Lo=;
        b=tnMP1VJKyF5iwQoAnJvX7hoZg3w5KKSVaB59tk0F/1ynFfFyanfRRNZ3uD51bJMmxU
         AeqKsWqZ8AwMpTIG1Gvp/HbXc98b4i+3GNMCcXCLePXVEvHfsgCObrDkbNsHOQaEtM4G
         ifxQVS1zekecT0TsyMzOFjIQFbVY/tw5e/tZRhw45+9rB9mT7I1CIBdjZlxW3/cMZXcF
         NK/3YJRIWmtT0DzK95R/uQGVY3tvDzK2/d6PWNoqHpyq0cvWqxIogSIanPz9oyCezqLQ
         1yTIxcv/Enx3UXJraStULW4ub6/0LyHyRmXdF0zIcpqeP4lOVliaVLxJarL8Ei1QhMa8
         tMzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id z7si723745ite.12.2019.06.10.17.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 17:58:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x5B0wFYO024190
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 11 Jun 2019 09:58:15 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x5B0wFlq001013;
	Tue, 11 Jun 2019 09:58:15 +0900
Received: from mail03.kamome.nec.co.jp (mail03.kamome.nec.co.jp [10.25.43.7])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x5B0qXb2026225;
	Tue, 11 Jun 2019 09:58:14 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.147] [10.38.151.147]) by mail01b.kamome.nec.co.jp with ESMTP id BT-MMP-5834591; Tue, 11 Jun 2019 09:57:09 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC19GP.gisp.nec.co.jp ([10.38.151.147]) with mapi id 14.03.0319.002; Tue,
 11 Jun 2019 09:57:09 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@kernel.org>,
        "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>,
        "Chen, Jerry T" <jerry.t.chen@intel.com>,
        "Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] mm: soft-offline: return -EBUSY if
 set_hwpoison_free_buddy_page() fails
Thread-Topic: [PATCH v2 1/2] mm: soft-offline: return -EBUSY if
 set_hwpoison_free_buddy_page() fails
Thread-Index: AQHVH2UNBW9Lhf3e5UinMjf59GXrMKaVARSAgAAKeoA=
Date: Tue, 11 Jun 2019 00:57:08 +0000
Message-ID: <20190611005715.GB5187@hori.linux.bs1.fc.nec.co.jp>
References: <1560154686-18497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1560154686-18497-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <8e8e6afc-cddb-9e79-c8ae-c2814b73cbe9@oracle.com>
In-Reply-To: <8e8e6afc-cddb-9e79-c8ae-c2814b73cbe9@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.96]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <FFF5B42DBE5DA8439EBBBA26EBB51176@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 05:19:45PM -0700, Mike Kravetz wrote:
> On 6/10/19 1:18 AM, Naoya Horiguchi wrote:
> > The pass/fail of soft offline should be judged by checking whether the
> > raw error page was finally contained or not (i.e. the result of
> > set_hwpoison_free_buddy_page()), but current code do not work like that=
.
> > So this patch is suggesting to fix it.
> >=20
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Fixes: 6bc9b56433b76 ("mm: fix race on soft-offlining")
> > Cc: <stable@vger.kernel.org> # v4.19+
>=20
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

Thank you, Mike.

>=20
> To follow-up on Andrew's comment/question about user visible effects.  Wi=
thout
> this fix, there are cases where madvise(MADV_SOFT_OFFLINE) may not offlin=
e the
> original page and will not return an error.

Yes, that's right.

>  Are there any other visible
> effects?

I can't think of other ones.

- Naoya=

