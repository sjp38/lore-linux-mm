Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBE6FC49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 13:40:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 764AA20678
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 13:40:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 764AA20678
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC6756B0005; Fri, 13 Sep 2019 09:40:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4FF06B0006; Fri, 13 Sep 2019 09:40:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3D946B0007; Fri, 13 Sep 2019 09:40:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0179.hostedemail.com [216.40.44.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6366B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:40:57 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 10D51181AC9BA
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 13:40:57 +0000 (UTC)
X-FDA: 75930008154.02.bun78_8174568a4106
X-HE-Tag: bun78_8174568a4106
X-Filterd-Recvd-Size: 2187
Received: from r3-11.sinamail.sina.com.cn (r3-11.sinamail.sina.com.cn [202.108.3.11])
	by imf47.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 13:40:55 +0000 (UTC)
Received: from unknown (HELO localhost.localdomain)([222.131.67.234])
	by sina.com with ESMTP
	id 5D7B9C62000035C8; Fri, 13 Sep 2019 21:40:53 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 3162149284474
From: Hillf Danton <hdanton@sina.com>
To: Thomas Hellstrom <thomas_os@shipmail.org>,
	Thomas Hellstrom <thellstrom@vmware.com>
Cc: linux-kernel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org,
	pv-drivers@vmware.com,
	linux-graphics-maintainer@vmware.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>,
	Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	jglisse@redhat.com,
	christian.koenig@amd.com,
	Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 3/7] drm/ttm: TTM fault handler helpers
Date: Fri, 13 Sep 2019 21:40:39 +0800
Message-Id: <20190913134039.3164-1-hdanton@sina.com>
In-Reply-To: <20190913093213.27254-1-thomas_os@shipmail.org>
References: <20190913093213.27254-1-thomas_os@shipmail.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 13 Sep 2019 11:32:09 +0200
>=20
>  	err =3D ttm_mem_io_lock(man, true);
> -	if (unlikely(err !=3D 0)) {
> -		ret =3D VM_FAULT_NOPAGE;
> -		goto out_unlock;
> -	}
> +	if (unlikely(err !=3D 0))
> +		return VM_FAULT_NOPAGE;
>  	err =3D ttm_mem_io_reserve_vm(bo);
> -	if (unlikely(err !=3D 0)) {
> -		ret =3D VM_FAULT_SIGBUS;
> -		goto out_io_unlock;
> -	}
> +	if (unlikely(err !=3D 0))
> +		return VM_FAULT_SIGBUS;
>=20
Hehe, no hurry.

> @@ -295,8 +307,28 @@ static vm_fault_t ttm_bo_vm_fault(struct vm_fault =
*vmf)
>  	ret =3D VM_FAULT_NOPAGE;
>  out_io_unlock:
>  	ttm_mem_io_unlock(man);
> -out_unlock:
> +	return ret;
> +}
> +EXPORT_SYMBOL(ttm_bo_vm_fault_reserved);


