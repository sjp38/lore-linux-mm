Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1FC4C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:53:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86DDF229F3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:53:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="TNR0nbQw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86DDF229F3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 208236B000C; Thu, 25 Jul 2019 13:53:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 191058E0003; Thu, 25 Jul 2019 13:53:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 009DD8E0002; Thu, 25 Jul 2019 13:53:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id D26D76B000C
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:53:51 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id u84so55842051iod.1
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:53:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=DskHihDhKZA/Fq49qJO0doPSez/fz+BiwP1T46flO+o=;
        b=UmudtYbd6GRb6io8uQS/OmzP7i6ptjTe63GZWrK6LCrPHjLoOqiGMIDrdol2adpxsZ
         +JSFcySrLQDpI0RufpFGwRYnSA1FffS5ZY3cUIEJyl3lsCVsyVEA7bXzqAvOwNJfLrwR
         HLlqOc6KIbIuANtXZ4ZfL6HWbpohm7/5+zd05jaBhPUh4dk8Gbbl9WaWhzsVPXq5NB3r
         qvd2ACQ0tGY2oSL9mkXmDRhCaJfzkWf/n+GRiFNife4K9FJB5JA0zApVy1EVRIMIJOUg
         QZos2tu4fKBLtFEvPiN9wOyysFcUJ+oDOmUYr0GcaU5N6IdjRvYq1YBlwHIlBNmaDEw8
         qgPA==
X-Gm-Message-State: APjAAAVJWhxmGoROeci8fvzzfnexXsrUyOmfiRxrU+daOv/kTGpyr7ef
	NLvKkr65Tmy3nld6ZzcdGZr93z00VYarxQpuo3CK6pcCMKXYPunrRajFuo+zN/447FAiI45SVoY
	pbShwrzANkcR01N8pB2x3Gj5lEtiTpadTzul/7zblq6TI5D6ekhowxf6FsPAVVPNStg==
X-Received: by 2002:a5d:8404:: with SMTP id i4mr13213410ion.146.1564077231527;
        Thu, 25 Jul 2019 10:53:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHeUzNE0yIJ4Ls/YjDv5C7toGD9oLjjtcDF7CbgoPwXllaOdaoiBo8lUki9a93TZGXJ08J
X-Received: by 2002:a5d:8404:: with SMTP id i4mr13213347ion.146.1564077230759;
        Thu, 25 Jul 2019 10:53:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564077230; cv=none;
        d=google.com; s=arc-20160816;
        b=RTKnqYgzykpWKiN5WMBvfHsFRfohrY+xr/bRGF5YbbzwQ3IdA1JzNuUNAPqYVqpMoa
         fjNp/r5MsRtpBkx6QfrKP8vhf45IigK4mxqHr4FybVOKe4uvsa8ZrFdwG4AtT8U42etQ
         wtZyzhzrPLghF0AomD8HyU50CcvCI7IK1+jSteRMQUcjATW7YfQ3N7uaqOQCCWRKQC5h
         d5CZr31CGCOdHNAyxDLWw+P/Bwtm/yQr0+pALIh0g6rICUk/Py40N6JtVMiM/4gXIEL5
         gmh7TxPkV5V4bp0I5Gp1aCXSl9w0YDZyJqxV5x26QgughtxiE9Bh50r38L7RRwKqKC9I
         /BeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=DskHihDhKZA/Fq49qJO0doPSez/fz+BiwP1T46flO+o=;
        b=nrK5OQSBicHhEpMcmCONEd4E3DLLv9NcER/FvKbdkaB/tKhh9XVw2lBHORUt5oBlK9
         jMak8deqzWaCDwkyNA4+jYD9u/cX+QnXhc3TiWRxd9akQ9E/2d56vwCVJA4f7BrWESIS
         RnnSJYL2BQPzk4KiB7UlHf4NaJ+ZZdi7mDx+Gxk7ZSciHfnLacSROYrgtXc042JzYz6H
         55NI03X4IAZ2u8vvbK997I30OA9655mbgheeO3fUR41fj7sEeSxkufXJMJvd6KRFjF+W
         eAuXe1EwwRC1g5GN39r+81SZYFN2rSv2BRvAI0XuwAA4hIvZuGyH5lLFXGMytTD97p+4
         qcLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=TNR0nbQw;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t8si89754119jan.0.2019.07.25.10.53.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 10:53:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=TNR0nbQw;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6PHnKbJ049589;
	Thu, 25 Jul 2019 17:53:49 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=DskHihDhKZA/Fq49qJO0doPSez/fz+BiwP1T46flO+o=;
 b=TNR0nbQwsPhmhhzkN0XUOm5DyKGABJasfZRd7Z3WKP6L/vhGuqsUMHlInDffuEh7W28Z
 KIDc+dm+C3T+9II5FiOqa3IwgwVXtha/9m8rsk/+yatq4RDhFIZ4RJ7DdD5zmfDpvEx6
 mjK126Mt2HCph8FaAipzai7ur36yOS7bBasUUtAhNgnS2R1lCSd1V1AYvEBt9JisQYPg
 7CZK3qM2LbHPH7ILg4tMxPgmeAzoyJVR3vUqGC7jPc/OR5SM/siA1YRGejnRuUFkeJV5
 EzkFQ86fGGOcZ4fO1wBBbmb83ipXRzZIWN9TueKgFQ5C6D+M554PToE4ThICS1Pp42jW jg== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2tx61c5n0c-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Jul 2019 17:53:49 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6PHrOv6172739;
	Thu, 25 Jul 2019 17:53:48 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2tx60yf6jr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Jul 2019 17:53:48 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6PHrl8Q017808;
	Thu, 25 Jul 2019 17:53:48 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 25 Jul 2019 10:53:47 -0700
Subject: Re: [PATCH] mm/hugetlb.c: check the failure case for find_vma
To: Navid Emamdoost <navid.emamdoost@gmail.com>, emamd001@umn.edu
Cc: kjlu@umn.edu, smccaman@umn.edu, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
References: <20190725013944.20661-1-navid.emamdoost@gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <44c005c2-2b4f-d1da-0437-fe4c90f883ae@oracle.com>
Date: Thu, 25 Jul 2019 10:53:46 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190725013944.20661-1-navid.emamdoost@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9329 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=910
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907250211
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9329 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=937 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907250210
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/24/19 6:39 PM, Navid Emamdoost wrote:
> find_vma may fail and return NULL. The null check is added.
> 
> Signed-off-by: Navid Emamdoost <navid.emamdoost@gmail.com>
> ---
>  mm/hugetlb.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ede7e7f5d1ab..9c5e8b7a6476 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4743,6 +4743,9 @@ void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
>  pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  {
>  	struct vm_area_struct *vma = find_vma(mm, addr);
> +	if (!vma)
> +		return (pte_t *)pmd_alloc(mm, pud, addr);
> +

Hello Navid,

You should not mix declarations and code like this.  I am surprised that your
compiler did not issue a warning such as:

mm/hugetlb.c: In function ‘huge_pmd_share’:
mm/hugetlb.c:4815:2: warning: ISO C90 forbids mixed declarations and code [-Wdeclaration-after-statement]
  struct address_space *mapping = vma->vm_file->f_mapping;
  ^~~~~~

While it is true that the routine find_vma can return NULL.  I do not
believe it is possible here within the context of huge_pmd_share.  Why?

huge_pmd_share is called from huge_pte_alloc to allocate a page table
entry for a huge page.  So, the calling code is attempting to populate
page tables.  There are three callers of huge_pte_alloc: hugetlb_fault,
copy_hugetlb_page_range and __mcopy_atomic_hugetlb.  In each of these
routines (or their callers) it has been verified that address is within
a vma.  In addition, mmap_sem is held so that vmas can not change.
Therefore, there should be no way for find_vma to return NULL here.

Please let me know if there is something I have overlooked.  Otherwise,
there is no need for such a modification.
-- 
Mike Kravetz

>  	struct address_space *mapping = vma->vm_file->f_mapping;
>  	pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
>  			vma->vm_pgoff;
> 

