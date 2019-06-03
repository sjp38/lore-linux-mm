Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EA16C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 15:16:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B984F2779F
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 15:16:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="YXOLt6gq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B984F2779F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5318B6B000A; Mon,  3 Jun 2019 11:16:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5081C6B000D; Mon,  3 Jun 2019 11:16:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41DC06B000E; Mon,  3 Jun 2019 11:16:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7D26B000A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 11:16:46 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id l184so5111076pgd.18
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 08:16:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Ki7uylAda9xiN8zeds9nD/lyhAxSHsFTY/OHo5Iyx7w=;
        b=oqMRvc5YzNZRtyhC68uN7w7LGJPhs7WaGL5Ohavx7PBvizL+Qrp2RAeC0KFnis8lTN
         YPDTgfU2qqPaypSymwJJzhKpgXYczjzqTjmYejqiFXN2MdCQD5OA1Efo7dGJW2gDJnWR
         UiV6OBap3oTd3dTEK6sBgdIir0pZn+YAJ9akU/7nfq0RgOuWqTbvcYlEI858scOZFSKF
         U4J8nlEpqvAJ6iQ5AaCbNmQhp5fyT63/xl03ZFsgtZyr9BZIGbnagZv3khpYzZVbHm+h
         aexmDTmtd6ZHLJMoFx3ZyLQvprTwOwgV5+lj0BbByLtXKuaA4Knfj3kc1+823tlEoDK8
         PQUA==
X-Gm-Message-State: APjAAAXCkeB7nqZ1EnDZln/wiXEsZg2h1nqgtDzj+S8fzvvwdq6pamX2
	JqMKFnm/ATeWkSv4+r9UXPU+CFVJw+HSvLThIpaCZdxGhk7CdVgRghn9ETcaZ8QL5yOwklPkgGu
	XGaHd753ePkpE1795lBeEUAIF80UunTsyyWnpD5nE959faKmcTZ0pHK0cGsCh3PvnDg==
X-Received: by 2002:a17:902:b495:: with SMTP id y21mr30187054plr.243.1559575005697;
        Mon, 03 Jun 2019 08:16:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydVIe7kEiB1vFVNzuBvlk2QmbfCU5f8aoriV1Ox4ASwFwKlld6TozRUgnmGHMGtnWvnMMH
X-Received: by 2002:a17:902:b495:: with SMTP id y21mr30186963plr.243.1559575004801;
        Mon, 03 Jun 2019 08:16:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559575004; cv=none;
        d=google.com; s=arc-20160816;
        b=AoxAn//wonYuyUPQZ/d68iLqp00RlxTNiVMkQBYiGiTLt8r1aZ9es9WQq0/Juxaw+g
         M2MZWdXDlVZSW1jNZNWQCE2LNon+T8CJv7yKqGWl2MwU57/gH0f4mO8EcPHuTNh9wa+C
         mOY2vS8mNhjp/CG++U6az7dC/77SM5WgVGkAwMVcMOY7xL8yNbKSzJOSkSI4eT+uMs80
         0NC21DEsoGGt4FS9ruM474tNfIjWOgL0W5RknM3Rz3IZZIwQoZiJNdzzO4R1nX2aDLpL
         +ubhHdqAEVGg+FX2S8T58fJAdnjLv2M3Yi8DpYYZ5fdnlry4FeLUa1xcUa/gKp+d61q4
         Iskg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=Ki7uylAda9xiN8zeds9nD/lyhAxSHsFTY/OHo5Iyx7w=;
        b=grT0Guo46TOxkSOmr4wkt8e1pItPfgXvZcZ5wTlSyEVknAGsDaFPdb/nl37GLG1BM9
         ofL2AfF84C+mK5nrl4xVnGtJZdV1SnMAzbM+JrMOnGyhGwGpu6Nsl5cwK6QTgSEP7z9F
         +UqEj17Ndai1wg2XPehoM6qgJikXmCX932WfTIemNs/spTM+LSn9WU8hcdqQtS4vPqfX
         Uwq83FuJOCfFhHJvPA+chQr6wiLIRqymLCM5pcEP7JGDrxOjUIX/3wm6AHAKJeKgPgEl
         3+UAPU0n5/Ev/nlOpyutj/IVhneJ16QHADkpji4toIrvojfZnnOjEvYJgWrbPvUVc0yS
         nzyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=YXOLt6gq;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y1si17533150pjr.109.2019.06.03.08.16.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 08:16:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=YXOLt6gq;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x53F8i5n001438;
	Mon, 3 Jun 2019 15:16:22 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=Ki7uylAda9xiN8zeds9nD/lyhAxSHsFTY/OHo5Iyx7w=;
 b=YXOLt6gqicqliY0an8pQp23MWi+nuI/j4RGb+V08q3E7RR9WpVudFd5tNi4UxJ8lT0V9
 QD15UU8Ceho68KaL4kpbutE9o6Kpgs0IjTtiqjniDbCB+F9K1WpyqpIpqioC2rJaCtMh
 llks/iMsYyRfOQC4WnOnnxFDi27Jd2asmRi4WyP9/xsG/884I4UjKrjzqsyKfYJgHoYn
 UYnK6X7LqXJB+20nQKMluHBKTPmzH6k6zJiVxpivgk7t5UOwmzcdlX+dY8SEKUyL4P2U
 GaduDIDe9lruho7fEctWyrciD+R46VlcI1f8BJut/7IKfhaBV8i8kjHt6SyaoLqopGkK oA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2suj0q7mkh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 03 Jun 2019 15:16:22 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x53FEZCm155123;
	Mon, 3 Jun 2019 15:16:21 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2sv36s9bcr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 03 Jun 2019 15:16:21 +0000
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x53FGA4B012052;
	Mon, 3 Jun 2019 15:16:10 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 03 Jun 2019 08:16:10 -0700
Subject: Re: [PATCH 01/16] uaccess: add untagged_addr definition for other
 arches
To: Christoph Hellwig <hch@lst.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>,
        Andrey Konovalov <andreyknvl@google.com>
Cc: Nicholas Piggin <npiggin@gmail.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
        linux-kernel@vger.kernel.org,
        Catalin Marinas <catalin.marinas@arm.com>
References: <20190601074959.14036-1-hch@lst.de>
 <20190601074959.14036-2-hch@lst.de>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <431c7395-2327-2f7c-cc8f-b01412b74e10@oracle.com>
Date: Mon, 3 Jun 2019 09:16:08 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190601074959.14036-2-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9276 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=874
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906030106
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9276 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=887 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906030106
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/1/19 1:49 AM, Christoph Hellwig wrote:
> From: Andrey Konovalov <andreyknvl@google.com>
>=20
> To allow arm64 syscalls to accept tagged pointers from userspace, we mu=
st
> untag them when they are passed to the kernel. Since untagging is done =
in
> generic parts of the kernel, the untagged_addr macro needs to be define=
d
> for all architectures.
>=20
> Define it as a noop for architectures other than arm64.

Could you reword above sentence? We are already starting off with
untagged_addr() not being no-op for arm64 and sparc64. It will expand
further potentially. So something more along the lines of "Define it as
noop for architectures that do not support memory tagging". The first
paragraph in the log can also be rewritten to be not specific to arm64.

--
Khalid

>=20
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  include/linux/mm.h | 4 ++++
>  1 file changed, 4 insertions(+)
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0e8834ac32b7..949d43e9c0b6 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -99,6 +99,10 @@ extern int mmap_rnd_compat_bits __read_mostly;
>  #include <asm/pgtable.h>
>  #include <asm/processor.h>
> =20
> +#ifndef untagged_addr
> +#define untagged_addr(addr) (addr)
> +#endif
> +
>  #ifndef __pa_symbol
>  #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
>  #endif
>=20

