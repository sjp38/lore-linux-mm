Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B268EC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 05:30:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 774E420882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 05:30:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 774E420882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E9456B027D; Wed,  3 Apr 2019 01:30:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 095126B027E; Wed,  3 Apr 2019 01:30:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC5126B0280; Wed,  3 Apr 2019 01:30:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B0D946B027D
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 01:30:20 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x2so8397184pge.16
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 22:30:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=C+1GgyKEhcl91Oet9CB6DUILtghc7rYI2RMfm6yRXN8=;
        b=fJrp1e6q5wmgz9Zzz8WpLHLKSx3g+kYiGRWgk3K6TNaYo4mNAj0e1WJ9Cwi9PD86TD
         PRhoXyHUDTae4TPRHhgG0OXZnMJZK1Ltz5PFfZJdNlJI5/5al2FAjIU2RgGyx1/TWt08
         d8GZxYgx1D1ECyZmf5FknIKjiucUioEuWdqQFx/x82k53gIKK6PHtrWYBb45udew1u+g
         sONirRP15AWeCd8Tb1+jtYVImT4mW0qc9IaZJkZUQch7Q6xXn+v31g7cRhYt6VUlHUju
         78r01JH/BKP4iTZGcmMLmlpxK0K2s53F3hJ1wPVi/sQTK3I7UUkHoQEK7BB7Ds0y/Zl2
         zT4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAWzi7uBEION7hSgfQrqpWRgiUYGG58QeAvvwl4mpyMBltgOHYsp
	ooLQQQU9cDCZb0pzTH6aGZ4/nfXY2oR5nO4qU4gRJ2LE0SfXQoNQ4qFV2roYUV7UoO8dKUx+t/f
	KIZ42XIQR+RQXKGXrQBNp7+CEHbNhG7Fv/VqLCNfvPiv2Bi2uy8HGWF/+X3I4F1o3Nw==
X-Received: by 2002:a63:3185:: with SMTP id x127mr70619893pgx.299.1554269420141;
        Tue, 02 Apr 2019 22:30:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycZYoU4ieX1hTdu6onQK0NiJVAH+ALgEIPozwQb7SfsjZGaqhczTfYXiEdy9FjA3v3/H7I
X-Received: by 2002:a63:3185:: with SMTP id x127mr70619766pgx.299.1554269418570;
        Tue, 02 Apr 2019 22:30:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554269418; cv=none;
        d=google.com; s=arc-20160816;
        b=ZK/rNQphD71Qw0aK6jn8t2p7icLmcZUuZiyNSAuiPcnKTaHsNlewv9WmzqEjISE/I2
         hJ1toNc8aFCl/rDowmSiPOaSN6y1TUb+OJUNHJ5NgjiAZWViYJHC9ywoCsGd5CihBYR+
         tbv5gnqJKno2zl0D11wbMVrheLe6cbhnxCgVICbukpBUmj+50+aBupg9/us+uwsqULEy
         SMv1UACAgVPPMyXOoUctworBzlYlz1/hx5a5TvwpaKy7uMOYK87bPVn/n3d75FNBw8WD
         T3LV+p525JVaG7ttgaAfEjFMmfhkzta3zyh6sV4II/joh6Dtk5JdXgjeiJF9DbP8RBn9
         NaDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=C+1GgyKEhcl91Oet9CB6DUILtghc7rYI2RMfm6yRXN8=;
        b=S8b2dO9YmtZE8KaLwsllN8gQr6vE1cs/jMQjuX50pbsH2ajbYTiFIu1t5TuZTVmLmT
         TAm5ojl/t0qdQfXQ275OtBzeV1wARH6iyWUIG6gHc19kH0iHeXKY6utFqEx/NQsE7upo
         DpXywPLahMVrBZO0EtktYm2BBWwmEKDeV+A56oSdXb3ZZHzNGOLMHjWJ/oubA4Lu4dGx
         TWvko5JIGRGgA9UXgIn5bvEoFz0YJQBsfXts8N9fM14cdzEasvHZgn9JRdmQAwUApMCU
         Ei0pgGc0uvMb9SICH/W4/6m2rsZIl9I81jJyIZPJtrRm2nUeTfJnV402XbjXismqyN8q
         3USQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id p6si12757414plo.4.2019.04.02.22.30.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 22:30:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x335UEEq020015
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 3 Apr 2019 14:30:14 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x335UEsJ013917;
	Wed, 3 Apr 2019 14:30:14 +0900
Received: from mail02.kamome.nec.co.jp (mail02.kamome.nec.co.jp [10.25.43.5])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x335SdMJ023670;
	Wed, 3 Apr 2019 14:30:14 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.149] [10.38.151.149]) by mail03.kamome.nec.co.jp with ESMTP id BT-MMP-3938585; Wed, 3 Apr 2019 14:29:14 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC21GP.gisp.nec.co.jp ([10.38.151.149]) with mapi id 14.03.0319.002; Wed, 3
 Apr 2019 14:29:13 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/2] A couple hugetlbfs fixes
Thread-Topic: [PATCH v2 0/2] A couple hugetlbfs fixes
Thread-Index: AQHU6d4rcfOiD6QCGkOryDRCw26i8w==
Date: Wed, 3 Apr 2019 05:29:12 +0000
Message-ID: <20190403052913.GA10888@hori.linux.bs1.fc.nec.co.jp>
References: <20190328234704.27083-1-mike.kravetz@oracle.com>
In-Reply-To: <20190328234704.27083-1-mike.kravetz@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.148]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <77345DB63E7D154B902FE1C4B1357009@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 04:47:02PM -0700, Mike Kravetz wrote:
> I stumbled on these two hugetlbfs issues while looking at other things:
> - The 'restore reserve' functionality at page free time should not
>   be adjusting subpool counts.
> - A BUG can be triggered (not easily) due to temporarily mapping a
>   page before doing a COW.
>=20
> Both are described in detail in the commit message of the patches.
> I would appreciate comments from Davidlohr Bueso as one patch is
> directly related to code he added in commit 8382d914ebf7.
>=20
> I did not cc stable as the first problem has been around since reserves
> were added to hugetlbfs and nobody has noticed.  The second is very hard
> to hit/reproduce.
>=20
> v2 - Update definition and all callers of hugetlb_fault_mutex_hash as
>      the arguments mm and vma are no longer used or necessary.
>=20
> Mike Kravetz (2):
>   huegtlbfs: on restore reserve error path retain subpool reservation
>   hugetlb: use same fault hash key for shared and private mappings
>=20
>  fs/hugetlbfs/inode.c    |  7 ++-----
>  include/linux/hugetlb.h |  4 +---
>  mm/hugetlb.c            | 43 +++++++++++++++++++++--------------------
>  mm/userfaultfd.c        |  3 +--
>  4 files changed, 26 insertions(+), 31 deletions(-)

Both fixes look fine to me.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

