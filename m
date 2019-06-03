Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6701C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:05:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A125274BA
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:05:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="jX8igtAt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A125274BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BCB26B028A; Mon,  3 Jun 2019 13:05:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26D436B028C; Mon,  3 Jun 2019 13:05:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10EBF6B028D; Mon,  3 Jun 2019 13:05:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id E42836B028A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:05:09 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id s2so13568573itl.7
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:05:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=OfBlugxBOMTUJDS5Fta0E067EXIuFHrIc+KiOftycQo=;
        b=lEgmCv+413LFAMC+khcu0QbNYfoSAuwOm3GmeZGerfOt+OQBkmS8VUvthuebUVUWva
         zqYmYwltWoPfJreoDdTcEdpq/3ey07qGIov+cWurVu72t2XcXIPvQCs/SXgc9AhI1R6+
         TExaA+Wp52RgGNNtHIrsE7u5WuUROC4IiVT8TlM2labytrlSFiecZl2e5orTv2PJdgNx
         4PLVhE6mEooKuwpBHCT8pCMwwSDlDk0NeQHynMMTMT3ZFY+BkNdQix9qh5g1ofr6rsw6
         Eo14KS/xl24iWUBfu2YtTqhW0ZvbFcWs4PnaqkcyCKl4IcniMBMd73m/0gZW3UTiBDof
         hLVQ==
X-Gm-Message-State: APjAAAUZhbdVhccgVmrcEO6uuwbDS5jetvWrWcRjuvCIMyqo5MoM9POs
	PlHsYnC0yME2JE8ZrkNr/Dx53SJr5djTv4xIgUs3VE0bAAuIKNxxyo1qdkzbAnjtvV+PeYSFm/E
	NbGn9Lpmy5UU/rdHsiX/CdijdXUVgSLHHNPTWqMPbfB7YeFas3I5NbaI9dtK5MWEN1g==
X-Received: by 2002:a5d:8b52:: with SMTP id c18mr6174526iot.89.1559581509672;
        Mon, 03 Jun 2019 10:05:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymTbuvdOcAKLfwzC4HMwGWQwEPwYlLmi1sK8kktX52EOeBUZkjVa5TltkHd3TA/L/GuG+V
X-Received: by 2002:a5d:8b52:: with SMTP id c18mr6174474iot.89.1559581509018;
        Mon, 03 Jun 2019 10:05:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559581509; cv=none;
        d=google.com; s=arc-20160816;
        b=y+GaWRvw50xv5BxenIvLNo4Q2uSsaDcdKmGo/968/SVT6IA918I+QZRMVsg1xJZQJt
         /kJC3Wsq1/IPRAW7ykBhBBX4jSxq9mgGLm3B3PdNmi7nc+EASD9ogeio4jw+hZVdM73X
         cBpjtsr/Nsfc9+Zl7kQeCd/F1/r6GK9SRPdRbARZV2ch7tTWlQSGxvKianveXItFtykk
         ImsLoCUQOV5J4/LypkVFlLfiIRY16iU+8rE5OorHzUJBCckSIAMWh2NHkjWiXvvImq1T
         D/yXyEaqgLtLokUuqFTIu3XlByN6ceJZkOLAwSfEWi82YK60jSazDfhR538sVScHzzzq
         FoBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=OfBlugxBOMTUJDS5Fta0E067EXIuFHrIc+KiOftycQo=;
        b=eP193MHSiEvs4xFpi76Gr0UL7n/ItS/p191qKRueEouIzW043lGx3swyTCAhr10a0y
         /jUfr6m61YbAQvJidjoPtaLIom/xsVqDzNjOhHXKgJPRr6fnj3eSW4l91aglM3J7koYT
         qwLD4m6UK6TGCFw5x1kRIs9sb+SUHRAtv5hMyALl6kQ0d1Jpn3j5C9JrmyjyRsCukHhS
         tJoVF2yqbYEoul3ToMDUeJK5R0o5jcOOzWwdVBr1RM9Rf9aRB4dC7bhouNaq9HUp7Swj
         CvOPZ/vtyUEgJwyBOuyMBpJo0cCauSPEWBj7OTDDMVgsLyaTObHWvzUSOUvJPwQFlrpn
         AZUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=jX8igtAt;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id d71si9650534jab.10.2019.06.03.10.05.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 10:05:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=jX8igtAt;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x53H3xSn100496;
	Mon, 3 Jun 2019 17:04:43 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=OfBlugxBOMTUJDS5Fta0E067EXIuFHrIc+KiOftycQo=;
 b=jX8igtAtwdGWEcSQ15NbliZz+NGIxv22eo7wYyRnuuYQ7I4J/bIEqkjIMzg4nRkoaTHN
 Izj1eZ3FVe1MPbsF1dYsa+JsLP+4qEQVawH6/fkC1cv94PTeQa/skgeNAkL7L8E1wd20
 4RGoi2Jt3aFi4/U0wmvd4vrnsadD0wKIeZChrG/bw4MRrCFb484s4PEYw6yASdqlW7XP
 gY1T8XQl48DrdBh2Zl0WHDVvzFQRmVP7va2HFIKL3rd5QdAY2VUdmHvX1AdMNXXvrYIN
 hq/n16LS6BO3VJFXQsI955s6dUO0v4GGeGgILk3iJmQi8y78QUC3NMgSdO1Vb3Lpd7Pa rg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2suj0q87ph-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 03 Jun 2019 17:04:43 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x53H25KX001162;
	Mon, 3 Jun 2019 17:02:42 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2supp77nea-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 03 Jun 2019 17:02:42 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x53H2beP015785;
	Mon, 3 Jun 2019 17:02:37 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 03 Jun 2019 10:02:37 -0700
Subject: Re: [PATCH v16 01/16] uaccess: add untagged_addr definition for other
 arches
To: Andrey Konovalov <andreyknvl@google.com>,
        linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
        dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
        linux-media@vger.kernel.org, kvm@vger.kernel.org,
        linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>,
        Vincenzo Frascino <vincenzo.frascino@arm.com>,
        Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>,
        Felix Kuehling <Felix.Kuehling@amd.com>,
        Alexander Deucher <Alexander.Deucher@amd.com>,
        Christian Koenig <Christian.Koenig@amd.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Jens Wiklander <jens.wiklander@linaro.org>,
        Alex Williamson <alex.williamson@redhat.com>,
        Leon Romanovsky <leon@kernel.org>,
        Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
        Dave Martin <Dave.Martin@arm.com>, enh <enh@google.com>,
        Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>,
        Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
        Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>,
        Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
        Jacob Bramley <Jacob.Bramley@arm.com>,
        Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
        Robin Murphy <robin.murphy@arm.com>,
        Kevin Brodsky <kevin.brodsky@arm.com>,
        Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1559580831.git.andreyknvl@google.com>
 <097bc300a5c6554ca6fd1886421bb2e0adb03420.1559580831.git.andreyknvl@google.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <8ff5b0ff-849a-1e0b-18da-ccb5be85dd2b@oracle.com>
Date: Mon, 3 Jun 2019 11:02:33 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <097bc300a5c6554ca6fd1886421bb2e0adb03420.1559580831.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9277 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906030117
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9277 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906030118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/3/19 10:55 AM, Andrey Konovalov wrote:
> To allow arm64 syscalls to accept tagged pointers from userspace, we mu=
st
> untag them when they are passed to the kernel. Since untagging is done =
in
> generic parts of the kernel, the untagged_addr macro needs to be define=
d
> for all architectures.
>=20
> Define it as a noop for architectures other than arm64.
>=20
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
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

Andrey,

This patch has now become part of the other patch series Chris Hellwig
has sent out -
<https://lore.kernel.org/lkml/20190601074959.14036-1-hch@lst.de/>. Can
you coordinate with that patch series?

--
Khalid

