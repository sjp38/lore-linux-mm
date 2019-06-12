Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38DDCC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 07:25:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E09B820896
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 07:25:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E09B820896
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4002C6B0003; Wed, 12 Jun 2019 03:25:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3899B6B0005; Wed, 12 Jun 2019 03:25:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22BBF6B0006; Wed, 12 Jun 2019 03:25:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB0116B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 03:25:33 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id a17so7377434otd.19
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 00:25:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=s+wkJjMDB0ELPUytN/euhdULDcXP1uCSup15Dhr8aKY=;
        b=hj8pXRhLQTA1Gj1Szdjk2MzcRfiKM6JXVF6danPzCmT0wgiaAYZ77XrqxwtQhgLxAz
         LvPEILDuzoyG0EVYDda5Baj34PBymBsPPYh8ScuarveIaOXKhD6vvpfxXySMO5rTEAcU
         SJUBQeG43cUrym6ATUgew7zutFuKPWs3TKJo2aKUVw643FuI6wCBTYIDeZDB+R3s7VrO
         Ols2wK2tq6am6n30DMJfBtn590h2FDnUPUHu5azi/8IqX2mbSYWmu1asU1ucX20ls9H6
         SOHuXwPHSHZN8MOfowvcayPSuUGoIRW1yK6HcJzW+jOLx+03habU0KnMsUCmb0FM9eC8
         GakQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAU2iqzoSBLyCbFo9xwfFq9EFb6WyDbielIxWBVmVOK2Y8YJde4j
	2UrsWRjFVE1HeHlml6jMlFAFMgdwr8mQMy66Y/5rUBqY2JE5pb5v47GpdNW4hHkXyo0h8JufUrO
	KDrk/j57sLqAXxnY0h9+QGfYt3oGhGCuNnAH9Vq4LCgRuH+FxERiVvTawwboaJg55tw==
X-Received: by 2002:a9d:7688:: with SMTP id j8mr9013352otl.67.1560324333642;
        Wed, 12 Jun 2019 00:25:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwW8yqLnrw2YDtWx5egUI3DKn6FmYJ8pOjJz36DN8ARXQ9O79VOtEapoPsYS7F7auMCRjY1
X-Received: by 2002:a9d:7688:: with SMTP id j8mr9013311otl.67.1560324332881;
        Wed, 12 Jun 2019 00:25:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560324332; cv=none;
        d=google.com; s=arc-20160816;
        b=gZ3hXZG//Ww1Q/VW2eejq9Q+f+B4LwCQEsr/ERrHtkHeIjO1deNp6aaa4uD0+b8A/M
         p4+QCCsStgNwJGtlLbdu92MfFi97cP3pj+blCYleA8KcDdsTbzgnwQbByjiihVqVy+Fl
         /lBT8oTG6bQsAOXsVlM5c+tFk+/zw93K3RGj6rWK4ILv6E+bvkR7E8QZBMqmKziWSewt
         BT+kwpKugWKsc3GjoOHKHuySH5NF+1yis2H6XGXoK1H8g4hIj0noowGv9/ZnbUFVVbwl
         j8Q8gh3wrg2Y1tP7Nm5w3Vg7VkhZYGPiLSw8shON03wZwJj5Y8G33ct4corkBXWAmKrX
         Y3Hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=s+wkJjMDB0ELPUytN/euhdULDcXP1uCSup15Dhr8aKY=;
        b=vDIjAtr8tkXEt+4rXRJdPk38Q/NSFSV2YkkqNrGB/Q5tHROYK1f62rHS0vNa3e6AA4
         qYk06bq3beIUqGOotVeWR/TrVlykf9XbjMDt4Xx9XsZNMGufkf97SBTWHCiz/Z5QptgU
         xHCPTvn2oJFjvy8Zzo84DZ+9w9BUsg1dfS6cNNfgvW43WFsCG80W9S9cixsFDHnStUOc
         T3VXYG7/zFonZKB5b8+g6ZqYCzT1e5jcElAc9PxUcyHH3UH1yeb9mMb6QIXb09kx5xjP
         gmKTMrwtWsdDH6w7CbAMHLZNZ6z+orKYB0eLO5yeMqyToK3OidcfMT3LR818RuvdveRT
         2WDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id h12si9195642oic.64.2019.06.12.00.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 00:25:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x5C7PBVo017699
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 12 Jun 2019 16:25:11 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x5C7PBwD001465;
	Wed, 12 Jun 2019 16:25:11 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x5C7NqIT021960;
	Wed, 12 Jun 2019 16:25:11 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.147] [10.38.151.147]) by mail03.kamome.nec.co.jp with ESMTP id BT-MMP-1232875; Wed, 12 Jun 2019 15:48:25 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC19GP.gisp.nec.co.jp ([10.38.151.147]) with mapi id 14.03.0319.002; Wed,
 12 Jun 2019 15:48:24 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
CC: Mike Kravetz <mike.kravetz@oracle.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
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
Thread-Index: AQHVH2UNBW9Lhf3e5UinMjf59GXrMKaVARSAgAAKeoCAAHo+AIABejoA
Date: Wed, 12 Jun 2019 06:48:23 +0000
Message-ID: <20190612064830.GA25015@hori.linux.bs1.fc.nec.co.jp>
References: <1560154686-18497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1560154686-18497-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <8e8e6afc-cddb-9e79-c8ae-c2814b73cbe9@oracle.com>
 <20190611005715.GB5187@hori.linux.bs1.fc.nec.co.jp>
 <67bb5891-d0be-ffb8-3161-092c8167a960@arm.com>
In-Reply-To: <67bb5891-d0be-ffb8-3161-092c8167a960@arm.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <65E535AA03EEC54FB0EF6A3FD422054B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000004, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 01:44:46PM +0530, Anshuman Khandual wrote:
>=20
>=20
> On 06/11/2019 06:27 AM, Naoya Horiguchi wrote:
> > On Mon, Jun 10, 2019 at 05:19:45PM -0700, Mike Kravetz wrote:
> >> On 6/10/19 1:18 AM, Naoya Horiguchi wrote:
> >>> The pass/fail of soft offline should be judged by checking whether th=
e
> >>> raw error page was finally contained or not (i.e. the result of
> >>> set_hwpoison_free_buddy_page()), but current code do not work like th=
at.
> >>> So this patch is suggesting to fix it.
> >>>
> >>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >>> Fixes: 6bc9b56433b76 ("mm: fix race on soft-offlining")
> >>> Cc: <stable@vger.kernel.org> # v4.19+
> >>
> >> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> >=20
> > Thank you, Mike.
> >=20
> >>
> >> To follow-up on Andrew's comment/question about user visible effects. =
 Without
> >> this fix, there are cases where madvise(MADV_SOFT_OFFLINE) may not off=
line the
> >> original page and will not return an error.
> >=20
> > Yes, that's right.
>=20
> Then should this be included in the commit message as well ?

Right, I'll clarify the point in the description.

Thanks,
- Naoya=

