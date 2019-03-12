Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E722C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 13:59:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CC9D2087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 13:59:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="WMOwULbJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CC9D2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9818C8E0003; Tue, 12 Mar 2019 09:59:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 907378E0002; Tue, 12 Mar 2019 09:59:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D06A8E0003; Tue, 12 Mar 2019 09:59:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4988E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:59:00 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id q184so2282479itd.6
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 06:59:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=4ZMOItDFTh1XM3CjXjtxCCu74z5TNsFK2Hx8PSjO5W0=;
        b=nMzV+vnMT87phRUETwd/mcYJeNJCbpcePJ8EOskxo1VCHfn0h/WnTmtN/qqBiOCj4J
         rfzszFGPWXisvMgVo+iaM24bipF+xSS3mXOE5a8Ff1i+NtwBUHheTCYREXptOchE7dgs
         ihxCHLzmADKfw+GRKkpX3pJKBeZFPl/iD4sqts6fU6iktQi9HHNcjjiDtb9/zfKCx+wE
         hkoZXulCk65k5B6vCdwcZ8eWiAH4LoB560ac+Fp26bEALALiDE6flIv+0ZXAQ7wgpKlz
         f3CmzLjffVU6dExFDdd4U4Sl6r6qOzk+Mc5MBLju4Bd/JzLrNmBKNYkv7FYuoBJQfVEB
         RFLw==
X-Gm-Message-State: APjAAAUtJynxiZyBumIU6Xj6A8pqe7ui/WBSpINQZCs124EA/HIRkJKf
	SDtLAVp9Y1aEJ3oh0cf3BmJCUAiAmY904Uyqf2hCf39f62mQdh4n4lnfjTB7OClQ7MrxeEeBj9/
	g7e4tl8+TUQc9Ivp4JGSogCkU46gVqylZuges0zsgQxEc6HKaIwow7nC7Xk73g9k90w==
X-Received: by 2002:a5e:aa03:: with SMTP id s3mr444999ioe.279.1552399140062;
        Tue, 12 Mar 2019 06:59:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKdTO7CHjyrK4PyCKtmNxQ+rv4dxiKd0bJIqL+Kt0Lchyu/1zRPXfl0ARTEMsgNyPe0odo
X-Received: by 2002:a5e:aa03:: with SMTP id s3mr444954ioe.279.1552399138941;
        Tue, 12 Mar 2019 06:58:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552399138; cv=none;
        d=google.com; s=arc-20160816;
        b=tNFHVuQzEqijuostZivmzfUu3dwwwJE8n93FBR1vjvfAW6E6omueflWYiftKikBme+
         tRmU597lugkj533VG7kRYb/NiLOTRMwhuMlA95t0gO9cSPOOxOculXP3oDIrhy6ykjPr
         dCCm9WBNLT9tGonmOAQNffo93AHfY12tToqhAkfAFywCMBqDem5it5KBVYy/HzrjRfai
         Bu0SJxW9IwfHmMN69RBvNt9RJaWEBlOIcelZtgp816QAvhe2itFgMlwRr8C9+qzXI1sv
         dmawvMqcbaM7UDe00mct0SosjkgMsUsjP1R3hToNKfVcrk3fu0OFONotYjg+cNNZYdli
         NxjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=4ZMOItDFTh1XM3CjXjtxCCu74z5TNsFK2Hx8PSjO5W0=;
        b=SJbapRWhOaXYvbN+OY9rJwuF5PpKWrYy1QlDC6IsykT/JKswoXh8VGCyP3Lt2SqbA5
         d+pS9crc9lypCBpYxYPn2i+8h5pwOZmJT1k7wIr2e/4eO3Z5UtF5Jt8gNxTxenIdzc+J
         Xn4+GnuRJgKh7rPp1HEjAkXLvWhDwTzdNQZRCThUJVbRE6xV+iu6XAw/dUcivOvfBdUB
         HAjJ9T7aYZm7+7IC0hYehNXS8RhFavJCgWhHi1d0aeaBrn4onAdVl/FFSg4JGx0neUPy
         PYalo1H/249oo40hqh8HVhayxgVbNZYR69AahNSXWHV4sSf1ducCAUmAPQGmahSXG43b
         9tsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WMOwULbJ;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id m197si1347529itb.30.2019.03.12.06.58.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 06:58:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WMOwULbJ;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2CDvUmC124541;
	Tue, 12 Mar 2019 13:58:56 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=4ZMOItDFTh1XM3CjXjtxCCu74z5TNsFK2Hx8PSjO5W0=;
 b=WMOwULbJ5OAaymHHf1NW2GtgBx4yNyJCUcPDMGKc7W7xcQ6lTU4jCjzV1RqZUfolZWOJ
 zxOWNVYcwgaOrvq6f0VXQdrwckLdOEl1W6gpGZGpL0Jthh2oIQxKUr/t+8d6B56QszWz
 vIfr1m4lUUyOjU0KrQ7qtrmW9nUOsTIWs4M3qQswori95BRSHtgx9Pzl/4Z2Ey3MNQ9v
 nQUp03TMuPu2QGEcj7+HwdkMqLQ+Zppg3RiV5dmvATZiN3YMeryt7HvBL4urGtycUu3d
 VHWYGEIGFAPx2L3T6HQdRV2QZ12NDEGVbuvM428cP5n0ss5ypMRWhB9G70XGSGg9MoPZ Gg== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2r44wu4sgf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Mar 2019 13:58:56 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x2CDwtSQ010468
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Mar 2019 13:58:55 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2CDwrSe025273;
	Tue, 12 Mar 2019 13:58:53 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 12 Mar 2019 06:58:53 -0700
Subject: Re: [PATCH] mm: remove unused variable
To: Bartosz Golaszewski <brgl@bgdev.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Anthony Yznaga <anthony.yznaga@oracle.com>,
        "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
        =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Bartosz Golaszewski <bgolaszewski@baylibre.com>
References: <20190312132852.20115-1-brgl@bgdev.pl>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <c86234af-a83a-712a-8dc8-0ec2a5dad103@oracle.com>
Date: Tue, 12 Mar 2019 07:58:51 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190312132852.20115-1-brgl@bgdev.pl>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9192 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903120099
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/12/19 7:28 AM, Bartosz Golaszewski wrote:
> From: Bartosz Golaszewski <bgolaszewski@baylibre.com>
>=20
> The mm variable is set but unused. Remove it.

It is used. Look further down for calls to set_pte_at().

--
Khalid

>=20
> Signed-off-by: Bartosz Golaszewski <bgolaszewski@baylibre.com>
> ---
>  mm/mprotect.c | 1 -
>  1 file changed, 1 deletion(-)
>=20
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 028c724dcb1a..130dac3ad04f 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -39,7 +39,6 @@ static unsigned long change_pte_range(struct vm_area_=
struct *vma, pmd_t *pmd,
>  		unsigned long addr, unsigned long end, pgprot_t newprot,
>  		int dirty_accountable, int prot_numa)
>  {
> -	struct mm_struct *mm =3D vma->vm_mm;
>  	pte_t *pte, oldpte;
>  	spinlock_t *ptl;
>  	unsigned long pages =3D 0;
>=20


