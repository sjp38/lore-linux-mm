Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21A86C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:56:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC8AB21881
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:56:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="tiWkZ/w9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC8AB21881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 615E78E0005; Wed, 19 Jun 2019 11:56:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C5C08E0001; Wed, 19 Jun 2019 11:56:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B5958E0005; Wed, 19 Jun 2019 11:56:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CB3A8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 11:56:23 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id p206so13478967qke.22
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 08:56:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=SoDrd9n3X32J5yU22MXe5hxvbr0oADlAzco6AaNmPlY=;
        b=YsFd3GXB3XlBzzlaaT0JcmspoEqh58tdnDOsKHnGXh9uDJwQEOhdY/MbBWWhSEur7c
         iBP1X/rO7ek0BeOas1J3BpXf70orS0vCp72AE0gkNZc788a+P5Ftc3bUOhKbx12r9+Mp
         YrZiSWBjhT/ttq5zXG/ewSHAG9U17Kvt2Gwsl0+pnb4LYH1WatRVNtaDFV2UOCwrxV6d
         lJgKVIpzHjLyWCg+wzAnl2vusdQY6KWZoSX+Qxzzx61zLil4q+9HJT4LsauGWqKeIWwU
         AIsmz8ZWvMjGtuJ3+SXWFxKTw/4P48qFS+F2lPO0bj/DlUw0WIkLw8hs92HedlYY+PCF
         /31g==
X-Gm-Message-State: APjAAAVfkhFUkAOL5GYgiypcMhk9REXxCNChOEBuXzYiiYHjybOdpTs1
	bUhSOEX/toHCSXfuy1tT17GICNzBE0CpRKHqaLBFsXpFPMuSY1liX7bL2YYY7IbijeGR4dvOVvy
	3zkhp9nw6elJwUTRt4mGrmibAXAsCfpMsA7c9IuxrD/5aJs+sctNPTwCAttBMrXcJfQ==
X-Received: by 2002:aed:3f10:: with SMTP id p16mr41890923qtf.110.1560959782933;
        Wed, 19 Jun 2019 08:56:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0tpuDBl//Z6gf1smel3aFWmMjGmM0pO3V5C57vTW+WJunJgEqRwFY/pFUvb6HGpFDmUr7
X-Received: by 2002:aed:3f10:: with SMTP id p16mr41890860qtf.110.1560959782180;
        Wed, 19 Jun 2019 08:56:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560959782; cv=none;
        d=google.com; s=arc-20160816;
        b=I18Cj1mPoe/cPfUSXE8dT7YfIghTTXDzQMKJxMdA8JlZiGx3/poiWs9oLDXmpGCzHS
         GLaxoGHDv3UnbzQphM2rBiomRjxBcg6ZATz6lDDQMtHr+Lze9i5esT1chig2mijmFjfx
         SF1JtHD6d6bBVcutTDFkQf1BmqlUZbFrOkmxEQPTgPljXUy9siJVUYT+tybnAQJh+J4W
         YwHFvld15r0xVtXFyzDQ105vPB89f4T/8ZQh9hXiheIlw5tYS0RtjmjibCAdm6LJM89U
         lMrTaCZ3UdVslq5lH84fVxYW8sRqz/aAGq4m66HsHmgAyE48nEcJXVyyIcTKbgKqz/Jz
         qdmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=SoDrd9n3X32J5yU22MXe5hxvbr0oADlAzco6AaNmPlY=;
        b=c7KbhRVTS2tjZ8pLJuqX9rvlrnbJdmsyAnlN8uvXiFUV3hj0z09NcsFdJXvI0bfTDL
         09dKvhSoyeK5nn5aUDCDJxtzPg67QTmfdSeGhrrl6Ug/g3Pqdpv24oKNg7kGJyeNTX/q
         x2/bF7gYKkgPHjQnIstl2/uyGjbs8vsa3aaEfe4voA25f2BwmAQgjwSK/T6kxDjjRDBU
         jLQxgSezovu1JK/lTZsxYNRWRzut9u/tekp9Fmu0+AtzzvX3//Rcti9uAlmUzr2P8HRH
         7WNN5K6ljXK0v5YxUIFr1mkMdR6yy+zMhTtHNk2vUmgKx3xGjsbyjGF1jwj+hywtU1le
         r6HA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="tiWkZ/w9";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y126si12993984qkc.160.2019.06.19.08.56.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 08:56:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="tiWkZ/w9";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5JFrt88113520;
	Wed, 19 Jun 2019 15:56:00 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=SoDrd9n3X32J5yU22MXe5hxvbr0oADlAzco6AaNmPlY=;
 b=tiWkZ/w95Jnc750JE7NdIbSVLAxuNCJanB6vqjZPJ1aa3V8V1zz7hD/Mpir7yCJj4IkD
 UQZJ4T89Du+KDCmcxRn0ky0McpX+U/kGRnqOQRs9Q9lPNTQrXSPaHIcnrAd14qwTT+Ls
 CGw1pVAKq/48OOP4FVYkyfrOoPEKCzD3TVQpqowv9EXgafE2X+GyV2ycT9MSpTab4s91
 k+axl+0IYieWJcr4RyrP9FuovImoVA8NHW3+4dnQhyAVZXUqxpDMsH20ju5Zy1ck0hGd
 PWwheucUcbKKfNgIakqhbBRgWYJkSnvYDhZj4P1QxV3xVq7enCqaFO9qReDYFpCFmV9e cg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2t7809cba1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 19 Jun 2019 15:56:00 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5JFsVbp049987;
	Wed, 19 Jun 2019 15:55:59 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2t77ynx8s0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 19 Jun 2019 15:55:59 +0000
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5JFtpTh010454;
	Wed, 19 Jun 2019 15:55:51 GMT
Received: from [10.65.164.174] (/10.65.164.174)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 19 Jun 2019 08:55:51 -0700
Subject: Re: [PATCH v17 04/15] mm, arm64: untag user pointers passed to memory
 syscalls
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
References: <cover.1560339705.git.andreyknvl@google.com>
 <f9b50767d639b7116aa986dc67f158131b8d4169.1560339705.git.andreyknvl@google.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <a5e0e465-89d5-91d0-c6a4-39674269bbf2@oracle.com>
Date: Wed, 19 Jun 2019 09:55:45 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <f9b50767d639b7116aa986dc67f158131b8d4169.1560339705.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9293 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906190128
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9293 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906190128
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
> This patch allows tagged pointers to be passed to the following memory
> syscalls: get_mempolicy, madvise, mbind, mincore, mlock, mlock2, mprote=
ct,
> mremap, msync, munlock, move_pages.
>=20
> The mmap and mremap syscalls do not currently accept tagged addresses.
> Architectures may interpret the tag as a background colour for the
> corresponding vma.
>=20
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>


>  mm/madvise.c   | 2 ++
>  mm/mempolicy.c | 3 +++
>  mm/migrate.c   | 2 +-
>  mm/mincore.c   | 2 ++
>  mm/mlock.c     | 4 ++++
>  mm/mprotect.c  | 2 ++
>  mm/mremap.c    | 7 +++++++
>  mm/msync.c     | 2 ++
>  8 files changed, 23 insertions(+), 1 deletion(-)
>=20
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 628022e674a7..39b82f8a698f 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -810,6 +810,8 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size=
_t, len_in, int, behavior)
>  	size_t len;
>  	struct blk_plug plug;
> =20
> +	start =3D untagged_addr(start);
> +
>  	if (!madvise_behavior_valid(behavior))
>  		return error;
> =20
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 01600d80ae01..78e0a88b2680 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1360,6 +1360,7 @@ static long kernel_mbind(unsigned long start, uns=
igned long len,
>  	int err;
>  	unsigned short mode_flags;
> =20
> +	start =3D untagged_addr(start);
>  	mode_flags =3D mode & MPOL_MODE_FLAGS;
>  	mode &=3D ~MPOL_MODE_FLAGS;
>  	if (mode >=3D MPOL_MAX)
> @@ -1517,6 +1518,8 @@ static int kernel_get_mempolicy(int __user *polic=
y,
>  	int uninitialized_var(pval);
>  	nodemask_t nodes;
> =20
> +	addr =3D untagged_addr(addr);
> +
>  	if (nmask !=3D NULL && maxnode < nr_node_ids)
>  		return -EINVAL;
> =20
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f2ecc2855a12..d22c45cf36b2 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1616,7 +1616,7 @@ static int do_pages_move(struct mm_struct *mm, no=
demask_t task_nodes,
>  			goto out_flush;
>  		if (get_user(node, nodes + i))
>  			goto out_flush;
> -		addr =3D (unsigned long)p;
> +		addr =3D (unsigned long)untagged_addr(p);
> =20
>  		err =3D -ENODEV;
>  		if (node < 0 || node >=3D MAX_NUMNODES)
> diff --git a/mm/mincore.c b/mm/mincore.c
> index c3f058bd0faf..64c322ed845c 100644
> --- a/mm/mincore.c
> +++ b/mm/mincore.c
> @@ -249,6 +249,8 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size=
_t, len,
>  	unsigned long pages;
>  	unsigned char *tmp;
> =20
> +	start =3D untagged_addr(start);
> +
>  	/* Check the start address: needs to be page-aligned.. */
>  	if (start & ~PAGE_MASK)
>  		return -EINVAL;
> diff --git a/mm/mlock.c b/mm/mlock.c
> index 080f3b36415b..e82609eaa428 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -674,6 +674,8 @@ static __must_check int do_mlock(unsigned long star=
t, size_t len, vm_flags_t fla
>  	unsigned long lock_limit;
>  	int error =3D -ENOMEM;
> =20
> +	start =3D untagged_addr(start);
> +
>  	if (!can_do_mlock())
>  		return -EPERM;
> =20
> @@ -735,6 +737,8 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size=
_t, len)
>  {
>  	int ret;
> =20
> +	start =3D untagged_addr(start);
> +
>  	len =3D PAGE_ALIGN(len + (offset_in_page(start)));
>  	start &=3D PAGE_MASK;
> =20
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index bf38dfbbb4b4..19f981b733bc 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -465,6 +465,8 @@ static int do_mprotect_pkey(unsigned long start, si=
ze_t len,
>  	const bool rier =3D (current->personality & READ_IMPLIES_EXEC) &&
>  				(prot & PROT_READ);
> =20
> +	start =3D untagged_addr(start);
> +
>  	prot &=3D ~(PROT_GROWSDOWN|PROT_GROWSUP);
>  	if (grows =3D=3D (PROT_GROWSDOWN|PROT_GROWSUP)) /* can't be both */
>  		return -EINVAL;
> diff --git a/mm/mremap.c b/mm/mremap.c
> index fc241d23cd97..64c9a3b8be0a 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -606,6 +606,13 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsig=
ned long, old_len,
>  	LIST_HEAD(uf_unmap_early);
>  	LIST_HEAD(uf_unmap);
> =20
> +	/*
> +	 * Architectures may interpret the tag passed to mmap as a background=

> +	 * colour for the corresponding vma. For mremap we don't allow tagged=

> +	 * new_addr to preserve similar behaviour to mmap.
> +	 */
> +	addr =3D untagged_addr(addr);
> +
>  	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
>  		return ret;
> =20
> diff --git a/mm/msync.c b/mm/msync.c
> index ef30a429623a..c3bd3e75f687 100644
> --- a/mm/msync.c
> +++ b/mm/msync.c
> @@ -37,6 +37,8 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, =
len, int, flags)
>  	int unmapped_error =3D 0;
>  	int error =3D -EINVAL;
> =20
> +	start =3D untagged_addr(start);
> +
>  	if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
>  		goto out;
>  	if (offset_in_page(start))
>=20


