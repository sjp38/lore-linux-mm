Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8401DC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:36:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D8472086A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:36:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="v5IyrIAL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D8472086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF1A86B0006; Tue, 11 Jun 2019 15:36:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA21A6B0008; Tue, 11 Jun 2019 15:36:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6A496B000A; Tue, 11 Jun 2019 15:36:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 802876B0006
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 15:36:04 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id bc12so8335128plb.0
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 12:36:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=qLYfwfJlpK+TVRVU+iZMGBWVWAoBC/qAtoGl4xudlOE=;
        b=JPRoDaOluLxYx91V1ZBy7hJA/TDfvxkhmezRYtN5hsyzfBpXkIySNI075FML+rBBPg
         wE8Mh9gwnL+Nt0Aa1t2+6fmFiuVlbQY9CmLLouMVMATVvPm9gvczzaaIrjqbDPmtTTKX
         Q3ZeybkyLhdFBzcg8OYtBfsOKCHjkeBtZv4gfD3Bw3GdKGZ4Rz5VG7orQB9UHswHrGCc
         xEydptgZlFO0fBfSTK8lJz7HdxJvdUUTl+ASgtCVOC6qNY2BAkUn2aYdyMzIjseMEIuj
         JhSJgxd7InZbFhmuzZF2N3BR/I3S4Nmetc4bLh4aL7vgoiO7gx+0f1eN3D/eiXh+DQ6A
         PfkA==
X-Gm-Message-State: APjAAAVggJyEdat/Y7DCf6C0qwFA7LSGhPxUuqQNIkfdiS+AW4ZYlvIc
	4h0OL3ale0jyB3MPYBtUx0M0AGnUOAWnfHpInm1YwSKi/KYywjplNRqZOhR3JuOit1J8Gi9iM9M
	jg/hrHizBSGpyrNAp49J8XijoSoGID8+kp5ozN3UCe0gGG9GfNl+8KyTN1QLq81DGdg==
X-Received: by 2002:aa7:81d1:: with SMTP id c17mr83739701pfn.174.1560281764171;
        Tue, 11 Jun 2019 12:36:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMqd1c29EuO09VFgXP0O57pGCIpeTuXUHPnpW8WDG73RPIKvw3iE92bX1UoloDQT7fB321
X-Received: by 2002:aa7:81d1:: with SMTP id c17mr83739650pfn.174.1560281763531;
        Tue, 11 Jun 2019 12:36:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560281763; cv=none;
        d=google.com; s=arc-20160816;
        b=g11ZhFokneOK43+aEJuyxRy5KRgpc2rrGWKCCHmDgX1KkrzkWQyVf8oLNByuiJxCCL
         QAjjkcYgVoAhBw3oIPjiRRAOzmLQxRhTWuf546ihMmbmuy3EycUL97C5LsKB+XL3427l
         VpBL/QNdyyEuAk92Z2XOnI8TFTek/VIGkRESRgqvi7dVK95WUh3VM36IoDaAG8IS8iBY
         CH2skQhLLitFCXxViQvhPL0R9ilMnAXreFqcA6yt4eD25b9XSBUG8DPPb4UnonTWNuRA
         bm+49uEcIuUasI7he04rqBX+oGiXr5PfvU5AFDbIPF6PKBcyVCpwMhsG4neREyGsgkD4
         BmdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=qLYfwfJlpK+TVRVU+iZMGBWVWAoBC/qAtoGl4xudlOE=;
        b=MV6l7nN0TBgoaWmSwaG7P79fKwca1HZWwUxO8iuE8S/SIvLOZIv0L/eHmh7a9PuKoH
         ETZ7w3301tcpSEO7zgnKD6UP4meF0oqzp3FB+5tkhhk/J6zZbJwUsPPlVrk1ELeyjF/k
         DurK3ep7r6dAdV1Ze6IRWf/bDPZAVIRV6s31T3OhPtgOoLqTAIFilU6kwf9ZQCI5wWoP
         kUgSj68Z/z0kOGua7tXRGA+rLFDRk2PtujVln9+DKLhLqiPQ6oPjQ4KLQcyCWgi+iPXp
         y6/9YfcvOa71X71JNKvySwZIVOt2CKwM3Iah58Znsk49wCT0+8/HSATUdkSxa7Ch01t6
         TneQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=v5IyrIAL;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id a36si3150546pje.14.2019.06.11.12.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 12:36:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=v5IyrIAL;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5BJXhQl164795;
	Tue, 11 Jun 2019 19:35:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=qLYfwfJlpK+TVRVU+iZMGBWVWAoBC/qAtoGl4xudlOE=;
 b=v5IyrIAL4mNAq9s2lS0Lg8Q2mqSoIU0iM6PjVn5pKJo20zcHgj3qs2aDCqFfn+f+nP2Q
 /LeMCXu80jWxb3nuvT9fql1f+ZBHbFNZgwXc8dTrwk1tabr1T2DcWED8IvYIaBdCAG03
 2sygUeUMHGima0YdL54kdu1griOhTwKEaj457dvI4uTlnHklIBsNlaPiJRlfNX0Qo891
 88xbsZ0ZVRGt+mcXh5d1AoKVjpdT3ruVHygr317iXj+yHls0fxsl7ng7pv8N6LRQ7Ag0
 zEe0MPNue8hyBx2cwm3amTi4q+JsJMmYRRXwwqmxhTpWqxJ6ZiigoI8ds+9Tz89fbAMV jg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2t02heqfde-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 19:35:52 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5BJYsFH076809;
	Tue, 11 Jun 2019 19:35:52 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2t04hyhkfv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 19:35:52 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5BJZpEl015518;
	Tue, 11 Jun 2019 19:35:51 GMT
Received: from [10.154.187.61] (/10.154.187.61)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 11 Jun 2019 12:35:50 -0700
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
To: Christoph Hellwig <hch@lst.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
        linux-kernel@vger.kernel.org
References: <20190611144102.8848-1-hch@lst.de>
 <20190611144102.8848-10-hch@lst.de>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <3dc8c26b-97b7-aec7-4ac3-2dc3a01d63ad@oracle.com>
Date: Tue, 11 Jun 2019 13:35:48 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190611144102.8848-10-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=798
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906110125
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=844 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110125
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000018, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/11/19 8:40 AM, Christoph Hellwig wrote:
> The sparc64 code is mostly equivalent to the generic one, minus various=

> bugfixes and two arch overrides that this patch adds to pgtable.h.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/sparc/Kconfig                  |   1 +
>  arch/sparc/include/asm/pgtable_64.h |  18 ++
>  arch/sparc/mm/Makefile              |   2 +-
>  arch/sparc/mm/gup.c                 | 340 ----------------------------=

>  4 files changed, 20 insertions(+), 341 deletions(-)
>  delete mode 100644 arch/sparc/mm/gup.c
>=20

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>


