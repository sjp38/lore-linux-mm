Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A64AFC7618F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 17:58:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61E3621842
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 17:58:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="V0Z3b9Hc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61E3621842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6DEC6B0005; Fri, 26 Jul 2019 13:58:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1F6E8E0003; Fri, 26 Jul 2019 13:58:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0E0F8E0002; Fri, 26 Jul 2019 13:58:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id ADC9D6B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 13:58:28 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id j186so14369645vsc.11
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 10:58:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=yeCMaN4K2ZO7buQVH+UC6UxQHTwLlHucEGyTiE6T/j8=;
        b=nXMf9a3Zo0a2SfS8YWQsvvbS/A9ubOuJaROVcqfS+9Cp6xIAdjCsn9+j7nfwbcl7u+
         H4ndUZj7cVt3LAV8/5j5AdYoEBAA0Hra15iigX83+oQlM0jgQr+9UBiEPfg2I5g45QTZ
         ZiX1znXkmajr0oKMKKHpDDTsa8vVbPIxISikdkQTMBcpcKe1NsPD3HEC9S/gqf5Lb44l
         LszFt0tBTDpquig5HwfQTEaJ0pyGrfAHuHZlBL6TBxGHj4CAVJEqW/wvH5Csg/d2E7Tz
         bHHE9gUrFoBbNQ3/w16Uh7v0eLgclD4EB/stzqPbP6tuQnpf6uLvhE+AXYJhd1k3Wyr0
         1oPQ==
X-Gm-Message-State: APjAAAWv9qN8QhXI0gTGTyfG4Jnl2U82VcT3mJUNqEjlqXCh8r+Qn0aF
	GqTB2tvEg9sj7J9rBmdtbkOSG41O05GJKpewFzfsT7tK0w/qbK1aT8eRtwtdw5jvPuJKw7PNGAs
	c2U79cD+/X3PAOZqTVex7EMYbQy70MVQYDo2BvIyxjWXK1bln6iq2szIQm158uSiFFA==
X-Received: by 2002:a05:6102:252:: with SMTP id a18mr57989198vsq.53.1564163908345;
        Fri, 26 Jul 2019 10:58:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqza8nGr7xLDOsWjTwSZLlNWsgwFJ//nZO5rQZcKy8RNUKweQ5saAqjbZ/e7wp2lXRyCWNGX
X-Received: by 2002:a05:6102:252:: with SMTP id a18mr57989169vsq.53.1564163907674;
        Fri, 26 Jul 2019 10:58:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564163907; cv=none;
        d=google.com; s=arc-20160816;
        b=cYi3qz7tQx5mpkdzjogKKNnB7vAZSJ3waqdmlgBnWpcSmGC77L+yCEebc4AwMFBwir
         /BLk416OlaranVskPchDHzcdB2r0z7h8W9pMS2cfTTVCyPBpDp9tlWzqxBh+wbAdpyuK
         rtREWwimL+UGAmIFqt48jRpHeQjBWvjimrpXK/DrTV2EKNn3C4zU0yPnZ9w7bTX0I8Y8
         yo5KeFeXArb7d9qyZCHdDtBdpyDcZ9YologSrYs8ntE3sw0mesXm6ItZrSfuNth8mIPE
         cb7dxA9/HUxo1R7xRYkpCX2wP2+zYc6twNaD2Gg0Y3pzJ8i5TIWylTUY7hks8UijzWqh
         zh7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=yeCMaN4K2ZO7buQVH+UC6UxQHTwLlHucEGyTiE6T/j8=;
        b=Gukzy/pdDchQhkostZoOTA0jr3x56rbvjWiH0k4E/8fVDloSftih1NLuKpdtcrBksU
         22mhVIYto+AGkeKChVSHq4KdyPx69ptKUV9OVAg5t3T2b0qPoDqE89GpFIqU2bYXxXdV
         pliOdJ9/zU16NzTB74CrztFjwEvToEC7yyM3DDc2ezzSoBeUx7Mng/AHjDuFJTmu/cUd
         KVqQEU2gBuSdkTjvmIxtI0ZazM9J9IrYd94qY/NUgXZ4vGgRcq7lFu2sYRx3N8FZRmZe
         ZB5rYgf19TDOW0ZrgtQYbX/HjIfdx82Mqmp6lk///ODX9/9X0vXe53u2kq2c7J/5f2tQ
         qYag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=V0Z3b9Hc;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id e188si20666972vsc.99.2019.07.26.10.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 10:58:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=V0Z3b9Hc;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6QHrRdQ070868;
	Fri, 26 Jul 2019 17:58:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=yeCMaN4K2ZO7buQVH+UC6UxQHTwLlHucEGyTiE6T/j8=;
 b=V0Z3b9HcNgBLGK896nLr2lpPLZ3t1rvtynwo15NBI8+Rb9P+k8AH9iYWd+kfaPmp8Lnd
 0a2r3afMlMyIHnVJK3DO3MwMV3zYSN7DZfOLLhSHkgIOj7F/pqIbhehWBukF5lfyQytt
 wudHYssGhgewTAGbbkiNjL3zXo5a0UeOyJKooPUuHbCTDKoqAhelFGKSn+tAQgnqbKg8
 EUHF/9KD9mK+AG+orSGaqCT1LXFUd5Hyw/zUgnC1WgHaxkUixgPrHyD9XdcmGYoDBlkt
 OqguUQqE+9zgFzfUuLOrF9LXUBib1fbRrmKsgxTHwSnkUMgb3UUbN73fX3Qu52yi7jvb pw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2tx61ccdbe-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 26 Jul 2019 17:58:13 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6QHvSiE095495;
	Fri, 26 Jul 2019 17:58:12 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2tx60ymgxp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 26 Jul 2019 17:58:12 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6QHw4SK007947;
	Fri, 26 Jul 2019 17:58:04 GMT
Received: from [10.154.133.139] (/10.154.133.139)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 26 Jul 2019 10:58:04 -0700
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
To: "Dmitry V. Levin" <ldv@altlinux.org>, Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        "David S. Miller" <davem@davemloft.net>,
        Anatoly Pugachev <matorola@gmail.com>, sparclinux@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190625143715.1689-1-hch@lst.de>
 <20190625143715.1689-10-hch@lst.de> <20190717215956.GA30369@altlinux.org>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <14242f6d-e833-c5b7-3748-458f31039b84@oracle.com>
Date: Fri, 26 Jul 2019 11:58:01 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190717215956.GA30369@altlinux.org>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9330 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907260215
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9330 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907260214
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/17/19 3:59 PM, Dmitry V. Levin wrote:
> Hi,
>=20
> On Tue, Jun 25, 2019 at 04:37:08PM +0200, Christoph Hellwig wrote:
>> The sparc64 code is mostly equivalent to the generic one, minus variou=
s
>> bugfixes and two arch overrides that this patch adds to pgtable.h.
>>
>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>> Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
>> ---
>>  arch/sparc/Kconfig                  |   1 +
>>  arch/sparc/include/asm/pgtable_64.h |  18 ++
>>  arch/sparc/mm/Makefile              |   2 +-
>>  arch/sparc/mm/gup.c                 | 340 ---------------------------=
-
>>  4 files changed, 20 insertions(+), 341 deletions(-)
>>  delete mode 100644 arch/sparc/mm/gup.c
>=20
> So this ended up as commit 7b9afb86b6328f10dc2cad9223d7def12d60e505
> (thanks to Anatoly for bisecting) and introduced a regression:=20
> futex.test from the strace test suite now causes an Oops on sparc64
> in futex syscall
>=20

I have been working on reproducing this problem but ran into a different
problem. I found 5.1 and newer kernels no longer boot on an S7 server or
in an ldom on a T7 server (kernel hangs after "crc32c_sparc64: Using
sparc64 crc32c opcode optimized CRC32C implementation" on console). A
long git bisect session between 5.0 and 5.1 pointed to commit
73a66023c937 ("sparc64: fix sparc_ipc type conversion") but that makes
no sense. I will keep working on finding root cause. I wonder if
Anatoly's git bisect result is also suspect.

--
Khalid

