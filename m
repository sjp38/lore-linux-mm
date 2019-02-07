Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 996EAC282C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:57:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52C042175B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:57:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52C042175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B12E48E0042; Thu,  7 Feb 2019 10:57:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A98328E0002; Thu,  7 Feb 2019 10:57:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9148B8E0042; Thu,  7 Feb 2019 10:57:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4B05D8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 10:57:19 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id e89so187854pfb.17
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 07:57:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=CmCtoBkBCzvg1xjMdtTGtAInUWo0XqKmbWRHvqbc+oo=;
        b=pVqj65qMseQcaSYIPC1cLthpWRSn7NlJsmoDRLoxAN9FeD+zvUhbaOJqdwJ6D7Z0nU
         XyhT0DVcPdUxNsYDqo+dtbGUsTFjddV6o3aEWjLTEllggb6JqwmAEnQFwNVhjGqA+PTI
         STpuFdZZNA8dJkWaD+C9KtFgC7BcgdR9D1Yu5sDyvtUf+/dCZLmQb0uMy8h0rN+ZU2ys
         BDU2PtGfSrRBApOgBWR/nGYCoThZOhrGkRL/iktV+gHHRrb+UtUyECEvRgNJmeDFtMiC
         z/sOPWlbmPLAoDVk8uHwiaas9JOmGOXBukE3wBg+Uf/aaNk0TCnU04fLGDXfNqK4Ckhy
         M1Uw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZ5GY/E04/eNrETOpvZsfs/aM5Odnm+atAe+aWU38DKo4lNm1we
	ajNBvb6ZtNJS1sjQaxu/Qgem6u943EecK4O8W0CwoUr+Nzd99tvy6oKVLx3TsHvkBRwFf3heQLD
	EGD3SqVCCYaMenwi1KDiwoMptyB1KoRPaKtCLsdKayk1FkGYvs8OUsw7OuV6caCQsJg==
X-Received: by 2002:a17:902:820f:: with SMTP id x15mr16614783pln.224.1549555038934;
        Thu, 07 Feb 2019 07:57:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYyMyKQwvNr77SDbZSQECtUzN1Mnxyr5z5gUFMy1F9bPhhg4reI8Al7OIazYupOeJAaUqJj
X-Received: by 2002:a17:902:820f:: with SMTP id x15mr16614726pln.224.1549555038156;
        Thu, 07 Feb 2019 07:57:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549555038; cv=none;
        d=google.com; s=arc-20160816;
        b=KkDLSHazYvUJbpvkvUV+Jxctsv34O3u1qJamfAeO87zJYNKjsA+vorlyqUp3DqmwW2
         uELyDUKuVDKxAMU5V3LUNkosLe/kSPqBzVROxTfUR2LIgK5BNzTR5ydL1EtUtH1+RXQS
         95hlyeKvWmqIZ1hGw3lyRP6J6jApe8cyY35HmgfKyNJplMKwZfVGFR9ktgYdGbbq0y29
         eotsClhLhsIKoIXcUVd1aY77/Y/+sEUne+usiO7BYhYq2Lg45wa4chW2hqjC7N+f7ywy
         opNPTbGPl2wWuZJl3w5psLNZnaJhMmRa64RL5ItZpDVCsilVCd/gSymKi5n8ACqD0atz
         aJYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=CmCtoBkBCzvg1xjMdtTGtAInUWo0XqKmbWRHvqbc+oo=;
        b=Isdouk+9hMXyolvdaYpRUdRygaUfDFLVealzoj1zeWXrIH+OuZOSC1KGnMa/UzHoQq
         jti8LBoM7xKtcWOm2PfRJlfve1b50jAtQ5hmIX8yfw+J6Ds8BQIyQWEBNGuCRcsLSfI1
         GSmoCdUNXDLI6k+Y+B5y5eiJNXTx0ezMOjzmbAWgitEHBj7fZzoEn9s4P9OdyZ8ttLLk
         u1NYiFJfQYvCzDoHAR/0c8xHt0AK847gTKMq5XhQcEXmNDJ9o+0rBTUeDEJ3R9JwUqle
         F43TrqT2S2/aqJFLHcX2Gl89n78Zmic2Ehj+kZa+8Dx7UsV6UfzPWy5YBeS8geQZ8npv
         aA2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i5si9586892pgg.279.2019.02.07.07.57.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 07:57:18 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x17FsIOp112747
	for <linux-mm@kvack.org>; Thu, 7 Feb 2019 10:57:17 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qgq8m1vjk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 07 Feb 2019 10:57:17 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 7 Feb 2019 15:57:14 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 7 Feb 2019 15:57:05 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x17Fv4Jg58785802
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 7 Feb 2019 15:57:04 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 826AD4C044;
	Thu,  7 Feb 2019 15:57:04 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1C3454C040;
	Thu,  7 Feb 2019 15:57:02 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu,  7 Feb 2019 15:57:02 +0000 (GMT)
Date: Thu, 7 Feb 2019 17:57:00 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz,
        Rik van Riel <riel@surriel.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com,
        Peter Zijlstra <peterz@infradead.org>,
        Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com,
        iamjoonsoo.kim@lge.com, treding@nvidia.com,
        Kees Cook <keescook@chromium.org>,
        Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de,
        hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie,
        oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com,
        Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org,
        Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org,
        Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org,
        linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org,
        linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org,
        iommu@lists.linux-foundation.org, linux-media@vger.kernel.org
Subject: Re: [PATCHv2 1/9] mm: Introduce new vm_insert_range and
 vm_insert_range_buggy API
References: <20190131030812.GA2174@jordon-HP-15-Notebook-PC>
 <20190131083842.GE28876@rapoport-lnx>
 <CAFqt6za9xA_8OKiaaHXcO9go+RtPdjLY5Bz_fgQL+DZbermNhA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6za9xA_8OKiaaHXcO9go+RtPdjLY5Bz_fgQL+DZbermNhA@mail.gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19020715-4275-0000-0000-0000030CB409
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020715-4276-0000-0000-0000381ABD69
Message-Id: <20190207155700.GA8040@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-07_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=772 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902070121
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Souptick,

On Thu, Feb 07, 2019 at 09:19:47PM +0530, Souptick Joarder wrote:
> Hi Mike,
> 
> Just thought to take opinion for documentation before placing it in v3.
> Does it looks fine ?
 
Overall looks good to me. Several minor points below.

> +/**
> + * __vm_insert_range - insert range of kernel pages into user vma
> + * @vma: user vma to map to
> + * @pages: pointer to array of source kernel pages
> + * @num: number of pages in page array
> + * @offset: user's requested vm_pgoff
> + *
> + * This allow drivers to insert range of kernel pages into a user vma.

          allows
> + *
> + * Return: 0 on success and error code otherwise.
> + */
> +static int __vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num, unsigned long offset)
> 
> 
> +/**
> + * vm_insert_range - insert range of kernel pages starts with non zero offset
> + * @vma: user vma to map to
> + * @pages: pointer to array of source kernel pages
> + * @num: number of pages in page array
> + *
> + * Maps an object consisting of `num' `pages', catering for the user's
                                   @num pages
> + * requested vm_pgoff
> + *
> + * If we fail to insert any page into the vma, the function will return
> + * immediately leaving any previously inserted pages present.  Callers
> + * from the mmap handler may immediately return the error as their caller
> + * will destroy the vma, removing any successfully inserted pages. Other
> + * callers should make their own arrangements for calling unmap_region().
> + *
> + * Context: Process context. Called by mmap handlers.
> + * Return: 0 on success and error code otherwise.
> + */
> +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num)
> 
> 
> +/**
> + * vm_insert_range_buggy - insert range of kernel pages starts with zero offset
> + * @vma: user vma to map to
> + * @pages: pointer to array of source kernel pages
> + * @num: number of pages in page array
> + *
> + * Similar to vm_insert_range(), except that it explicitly sets @vm_pgoff to

                                                                  the offset

> + * 0. This function is intended for the drivers that did not consider
> + * @vm_pgoff.
> + *
> + * Context: Process context. Called by mmap handlers.
> + * Return: 0 on success and error code otherwise.
> + */
> +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num)
> 

-- 
Sincerely yours,
Mike.

