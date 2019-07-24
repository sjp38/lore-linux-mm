Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E3AEC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:24:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B88332190F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:24:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="4rBK7kYk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B88332190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 516FE8E0005; Wed, 24 Jul 2019 14:24:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C7746B000E; Wed, 24 Jul 2019 14:24:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B4CF8E0005; Wed, 24 Jul 2019 14:24:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 14AD26B000D
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:24:25 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id x140so12816534vsc.0
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:24:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=F3bCNko/rlePxa3FH2qI7hAkpjKGdcXc+ZaXjXWxwWs=;
        b=ZviBljyabemuteXl0B62KTDdmHzhooZU1ECAWOsP0NWguRAIj4uUV1dv75z59xkSux
         AF6I099QQ8g3wt42tsE2uH3jhzKgD8uuHvmvFbD9SORDPl9gxbmcDb1cTTpQT+7oHfyI
         10NokOxgKWNzuBMdrAs6JzkVuqGYyP5dDvxyY9eGUce0bp1Xkr9t8iRULCBcvuA8OL5l
         Z2WrP7JMnpKI4a06gbSm+N3JfGgW2aKSVj+Jrq1dEBmj+3nPh7q32nTyChQi8Tum/PZf
         cBY7ztU6Zw5gDjJZQlKkHSVLQbCns+uizvPj77t2+ZZTLbumu3EfPppkZdntyXXlDgu3
         3ZHQ==
X-Gm-Message-State: APjAAAXaznTuR5e23De/DeQk9/e/UsM4pKsSDozuqCAjofgV4c8c/f8w
	ivFZ1+m5otZVmA6O8WZmvRqW0jtwI20QT7ZVSO7DOeii5w8kGQ0KY4K6fG0FqYeStNXv+mZm4c0
	x94+EAa/sQ9nOd/AJjifY11dn7WXdZ/cx3dZYTi4sDoivQ3qy3sgex2RAAhAqdIA5Dg==
X-Received: by 2002:a67:2e97:: with SMTP id u145mr52992412vsu.193.1563992664713;
        Wed, 24 Jul 2019 11:24:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwty0BdaCfU4h2n8WCgzdDx1VrZJiYSykqWW8IX64NJBiIeOIqd3bDkSDipPWSLhVDLe9jr
X-Received: by 2002:a67:2e97:: with SMTP id u145mr52992382vsu.193.1563992664179;
        Wed, 24 Jul 2019 11:24:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563992664; cv=none;
        d=google.com; s=arc-20160816;
        b=dGlr4H9386nCxVsiJc0NiZMmYgoixmgnk0mYZacqsbPiprbD+axPei7kN48PF8x0fU
         S6x6nuQeeKcIhcKQDa+wEBDmiD62wwJGXGTGpkxNwVOIBZydw5T08Sv2DzUL+phdP+Wn
         F1/PxB7QowXx1jRQ40MJjlNRCiJng0ITf3lyx6KpMn27UZK5yU+kp15zmxQ5j+vejwq+
         NleFqZSSmoC2pns2DGCNWop0ka3Rn02TsrNnHnCJ7iaIKf/eiV/RVzrZI40wEkEC22OH
         4h0aSrSyBRKwoWRHkD7aQJYIptT8zCzgdm86pcv7jOOt0AIl1OJR0KnCfuIoKaJRwD55
         Tdnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=F3bCNko/rlePxa3FH2qI7hAkpjKGdcXc+ZaXjXWxwWs=;
        b=LSPqJZqZ+fOmPJURddNPTN7ipiMOCfwxVeyu3oVewDBCu/lQtAvFO4R5Qqb16qZ1Bg
         R+Mf+42qfk6GaJ/qaLDztcmA97Gs+h4WrjLkmz5xCTDKtI5Xm8LDxFKwjiwUdLOM9fbm
         SOowWoJ9y92a4THGXAhI1qVG4ipQnjT7vhM6jer/lXS8GYTM4G2OaUHtMQ0so2FVRgKi
         x/umIw9e+gZfkOUctYPKknMe7w8lfvvZ2xQTtU3gUCWh8DVF41ZM0aIH2m189m/aMqRp
         PnIehvzqE5iRUDcWw7ztYHtciX6Rav7g9abqIJS1CXyN7NjbyPm8PbfCuGRirWAJ9DiK
         yk8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=4rBK7kYk;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u17si9129700vsq.379.2019.07.24.11.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 11:24:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=4rBK7kYk;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6OIOEQ6084431;
	Wed, 24 Jul 2019 18:24:14 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=F3bCNko/rlePxa3FH2qI7hAkpjKGdcXc+ZaXjXWxwWs=;
 b=4rBK7kYk81nIlg+q6ud+iGNCmIEvwySL4JpAGr5Kd6GCcPqEvkp4UpknCHXhCMv5AxV1
 WDbzijod6es/JLIdMfu3FRoHeey8drmLBnc5H0V6B1zkrwOstFmIiTpJvQJbkGRXXMZp
 f9k2X5Dt/UbqAJioyixCLfmGHYkgrbe+vUpD9UenMNBsWxSCI+9qT9ooULHlPjhe5dqw
 1K4qYCmcwCiWImUe6iMzGzBg17g6cWqiGTAZWUaa4xI9++WKZKyYKBlMFvVEM267mh3I
 DkvAS1OuOu0LVNuArAHvmbYFKpbWI+urqDSZiKXMVeccExMcOY/IsJ8qw9LiMBgJMqX4 AA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2tx61by5eg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Jul 2019 18:24:14 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6OICkCE099366;
	Wed, 24 Jul 2019 18:24:14 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2tx60xvpar-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Jul 2019 18:24:14 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6OIOBW1013593;
	Wed, 24 Jul 2019 18:24:11 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 24 Jul 2019 11:24:11 -0700
Subject: Re: [PATCH] mm/rmap.c: remove set but not used variable 'cstart'
To: YueHaibing <yuehaibing@huawei.com>, akpm@linux-foundation.org,
        jglisse@redhat.com, kirill.shutemov@linux.intel.com,
        rcampbell@nvidia.com, ktkhai@virtuozzo.com, colin.king@canonical.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190724141453.38536-1-yuehaibing@huawei.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <10d2821c-cc56-961b-8f43-ae9097ed0621@oracle.com>
Date: Wed, 24 Jul 2019 11:24:10 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190724141453.38536-1-yuehaibing@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907240195
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907240196
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/24/19 7:14 AM, YueHaibing wrote:
> Fixes gcc '-Wunused-but-set-variable' warning:
> 
> mm/rmap.c: In function page_mkclean_one:
> mm/rmap.c:906:17: warning: variable cstart set but not used [-Wunused-but-set-variable]
> 
> It is not used any more since
> commit cdb07bdea28e ("mm/rmap.c: remove redundant variable cend")

It appears Commit 0f10851ea475 ("mm/mmu_notifier: avoid double notification
when it is useless") is what removed the use of cstart and cend.  And, they
should have been removed then.

> Reported-by: Hulk Robot <hulkci@huawei.com>
> Signed-off-by: YueHaibing <yuehaibing@huawei.com>

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

> ---
>  mm/rmap.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index ec1af8b..40e4def 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -903,10 +903,9 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>  	mmu_notifier_invalidate_range_start(&range);
>  
>  	while (page_vma_mapped_walk(&pvmw)) {
> -		unsigned long cstart;
>  		int ret = 0;
>  
> -		cstart = address = pvmw.address;
> +		address = pvmw.address;
>  		if (pvmw.pte) {
>  			pte_t entry;
>  			pte_t *pte = pvmw.pte;
> @@ -933,7 +932,6 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>  			entry = pmd_wrprotect(entry);
>  			entry = pmd_mkclean(entry);
>  			set_pmd_at(vma->vm_mm, address, pmd, entry);
> -			cstart &= PMD_MASK;
>  			ret = 1;
>  #else
>  			/* unexpected pmd-mapped page? */
> 

