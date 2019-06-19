Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95F13C43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 20:05:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3ED3420673
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 20:05:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="JfZGTb/9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3ED3420673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE57E6B0003; Wed, 19 Jun 2019 16:05:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D96258E0003; Wed, 19 Jun 2019 16:05:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C10DD8E0001; Wed, 19 Jun 2019 16:05:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BDAC6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 16:05:43 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id v67so566199yba.11
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 13:05:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=T5/3kAdAeR6zFBROUWJvfOGR6wpTe6uJBD03+FJjR7Q=;
        b=ZAnw90fULfsOCIylL4aqZbzcJH0eKjIVpMVZAasm9cDUVSWxuelaNpY9Zam/Ys+Yfs
         gRG2xb4AhmuOwktYfPjnNYuTR2GKpsS+5SHJUFYFEfqQ6Awx7jgcPsx4Ni8CpH2dLh6C
         8LsNqKdsha9NOFQkHiGyVaA9Zbo0hdbaCJCI3zgKw59NuuVJY3U1W0F0tFmdBDsSz9Ge
         Xpvo2f7aUnd4RCa9ckM4okAKU8JwKgYyAHpZnETnzDQGgEAymtDwoqsdkKio85eTHArW
         ys2zJKkHaTsEGgqfW4JmZHKZLZ4Eubn+4BRAp3hou1wCe2lQ+Oi7jle7nl1GDwvuN/RY
         sAnw==
X-Gm-Message-State: APjAAAVbGpQJdbGPBF4r2rMrivahnraj3bkMEDOB6sbsdi+H/Xc86lgd
	YJcBFxWefv+MrrMNpApWRGD+mOwmTR6CF2+qkZtzHS5OtiyhTKkVTBWfOKsG8Ih7Rgni3BP53lt
	iqFpiTk/KDL4u7hBQDDUX09LfHbeLHNLr1s0XVUlp3eJ23Z4tOxU+VrELPUvMk80d3A==
X-Received: by 2002:a81:3c47:: with SMTP id j68mr29566699ywa.293.1560974743312;
        Wed, 19 Jun 2019 13:05:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNLW9yjpVDp3fd1xPFj913bZ424V/gf7F1Jv60PLZZjwJhvls5wCikL/E5z6ePdO71gpuR
X-Received: by 2002:a81:3c47:: with SMTP id j68mr29566667ywa.293.1560974742710;
        Wed, 19 Jun 2019 13:05:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560974742; cv=none;
        d=google.com; s=arc-20160816;
        b=pJFc3+NdX45QMIuXcpMjrfJE0iQ891n/ap/cYp1wpUXSD/p72g1cNR+KKS/GPTXu7s
         JIiVN20w+24MhqMdF5EMefLOKJYyEKEzfPLfRxBsBstFsthKAGNvDGDw61k4mCeHEBRn
         hE0hf6nduSOS08YiAjfeTuQ7OXo9taU7zGwRBwknWNMXE76HxPNvmHM7GimdJPL0VSzW
         Fle1GfWey/NikDe6lB6My/wdOD1o4MguIyETVFU3XTfb8RI+/FqW33kPjbGHKLvZzT/H
         1+Sg2ikzppLvRl6fzXyCsdUpVaaK6NnCpZWtLVTV/ULn/e5hQ916LV8CUjJ7iUy54NdC
         Qsww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=T5/3kAdAeR6zFBROUWJvfOGR6wpTe6uJBD03+FJjR7Q=;
        b=PzbWXXX+zI8oNEXDLRfYvuftoGU4HZwS4A84AAirP7DVVfhzEFU2LLSetDzUlJ8xel
         5nn25gmNeVYSVgali7djjzU4a1EUcsH0TH5W2eQdfHRtDdXygKIUDKXnQbiRNdUPWU/g
         FA2ggT4Xf7gdSSvod/iRrCiP0I9jBVJ5zJnm0uc1EQnTHgy14KMS0JT3fvbYL3z+Ncst
         2zhziPbpKPfSJKW2s//0dpX0jypPJ0xPfky7/YyiuKYbpyqSJjkOcdYI8kU2nvWBpHlG
         5w2dqaB0b1cfwRRb+2yRFiZY/AXh6JSGI92VaEp2yaO10+nXwV90Bg5BOiN/X2tLy4OB
         n1aw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="JfZGTb/9";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id n6si2476888ywl.441.2019.06.19.13.05.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 13:05:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="JfZGTb/9";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5JK3j9u107770;
	Wed, 19 Jun 2019 20:05:27 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=T5/3kAdAeR6zFBROUWJvfOGR6wpTe6uJBD03+FJjR7Q=;
 b=JfZGTb/9vsPuTMYS8TLwO4D8maqLtaN37PWBviJWNWHwVHs6MQchbjnbIgEyT7QH5fPr
 RQaEqPDd4BLrljBr3UdRftu3+JLtrIljjKd9fnV8AG4CN4o7VCmxFBu3Cl8nvesNwCWz
 WIX9fL7RM27yvN1yXBV2ffc84cSXssCtprnFBx9JT9Dxvzwcw9BbBpKWzQE6w959cX3m
 0wLk2hF0v2PhKsE/QLpTHqn5AFlUdUziXjHErCwZzqKM7mXOXE9LWChgFdAX1ktGhG2H
 kWc5j8nTubxy0mEzTZ/LFPGY/UPGDf6lLKUj2qzGz2XAU0UI7iXrVbiRGgfjIjj0yqPG dg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2t7809dft1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 19 Jun 2019 20:05:27 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5JK5FSV002705;
	Wed, 19 Jun 2019 20:05:26 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2t7rdwu63d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 19 Jun 2019 20:05:26 +0000
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5JK5NFI017703;
	Wed, 19 Jun 2019 20:05:23 GMT
Received: from [10.65.164.174] (/10.65.164.174)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 19 Jun 2019 13:05:23 -0700
Subject: Re: [PATCH v17 12/15] media/v4l2-core, arm64: untag user pointers in
 videobuf_dma_contig_user_get
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
        Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
        Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
References: <cover.1560339705.git.andreyknvl@google.com>
 <7fbcdbe16a2bd99e92eb4541248469738d89a122.1560339705.git.andreyknvl@google.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <5ea75db0-20e9-7423-8670-967eedd56440@oracle.com>
Date: Wed, 19 Jun 2019 14:05:20 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <7fbcdbe16a2bd99e92eb4541248469738d89a122.1560339705.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9293 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906190165
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9293 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906190165
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/12/19 5:43 AM, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow=
 to
> pass tagged user pointers (with the top byte set to something else othe=
r
> than 0x00) as syscall arguments.
>=20
> videobuf_dma_contig_user_get() uses provided user pointers for vma
> lookups, which can only by done with untagged pointers.
>=20
> Untag the pointers in this function.
>=20
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Acked-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---

Patch looks good, but commit log should be updated to not be specific to
arm64.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>



>  drivers/media/v4l2-core/videobuf-dma-contig.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> exact_copy_from_user
> diff --git a/drivers/media/v4l2-core/videobuf-dma-contig.c b/drivers/me=
dia/v4l2-core/videobuf-dma-contig.c
> index e1bf50df4c70..8a1ddd146b17 100644
> --- a/drivers/media/v4l2-core/videobuf-dma-contig.c
> +++ b/drivers/media/v4l2-core/videobuf-dma-contig.c
> @@ -160,6 +160,7 @@ static void videobuf_dma_contig_user_put(struct vid=
eobuf_dma_contig_memory *mem)
>  static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_mem=
ory *mem,
>  					struct videobuf_buffer *vb)
>  {
> +	unsigned long untagged_baddr =3D untagged_addr(vb->baddr);
>  	struct mm_struct *mm =3D current->mm;
>  	struct vm_area_struct *vma;
>  	unsigned long prev_pfn, this_pfn;
> @@ -167,22 +168,22 @@ static int videobuf_dma_contig_user_get(struct vi=
deobuf_dma_contig_memory *mem,
>  	unsigned int offset;
>  	int ret;
> =20
> -	offset =3D vb->baddr & ~PAGE_MASK;
> +	offset =3D untagged_baddr & ~PAGE_MASK;
>  	mem->size =3D PAGE_ALIGN(vb->size + offset);
>  	ret =3D -EINVAL;
> =20
>  	down_read(&mm->mmap_sem);
> =20
> -	vma =3D find_vma(mm, vb->baddr);
> +	vma =3D find_vma(mm, untagged_baddr);
>  	if (!vma)
>  		goto out_up;
> =20
> -	if ((vb->baddr + mem->size) > vma->vm_end)
> +	if ((untagged_baddr + mem->size) > vma->vm_end)
>  		goto out_up;
> =20
>  	pages_done =3D 0;
>  	prev_pfn =3D 0; /* kill warning */
> -	user_address =3D vb->baddr;
> +	user_address =3D untagged_baddr;
> =20
>  	while (pages_done < (mem->size >> PAGE_SHIFT)) {
>  		ret =3D follow_pfn(vma, user_address, &this_pfn);
>=20


