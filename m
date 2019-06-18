Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97E7DC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 17:55:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 516A0205F4
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 17:55:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="duqFJcbL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 516A0205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA3226B0003; Tue, 18 Jun 2019 13:55:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B79D28E0002; Tue, 18 Jun 2019 13:55:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A41DA8E0001; Tue, 18 Jun 2019 13:55:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 84BDD6B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 13:55:46 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s9so13150784qtn.14
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 10:55:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=hRFOK+pjnetQHO1VbczYeIM67ED6Qp4/xDYjAsyHg0Y=;
        b=JqjJKisuxI4zoDDzcmT5PTRWXwSrh7/IRLf7JiKjE/FkkIZit7NF2QPCx4S2X8WaOZ
         Vt3vzxTtXfIm4loY/rsvrbwDfHoGa73595DZqUhw8Lsbee7L5GuUEjRQWWb7tqhwX1H/
         8DIKAF5xPARaHgv/GrLnb3V7dOWlML1WvWyFf65rP3QHidQD9taiTyLZY8vnAhAjD1G9
         D6rD6Wa879LsuCdY+a295yfUP90wiTTiZnCK1/gf9jR2tQIlrTRKZ4A3iwZKk8acZxCK
         0QdgxqE2aRmKB3/BnIFr3arnKp+mCarOvyHUvO0PMpUaoid/Itkj9b3Lpl0PcAINKhZn
         J2Mw==
X-Gm-Message-State: APjAAAUNOjkLfrJXqFagk/lLUfxkcCcyKbBUmapCGKoaTYgF9Wmm8u4x
	dslDC+hSaz1mIrKFvHfTFhW0yXX/6CgEezpI90NMjnEcVmE451Y8XmikFAiba64NzpXqqVQ4Mx/
	3Yb5BdX0w89/qCLGEBu0JG7JQVgCh/QW008g7k9FVXTHafAe023UORDpi5NpXqtaenQ==
X-Received: by 2002:ac8:7949:: with SMTP id r9mr69976050qtt.217.1560880546306;
        Tue, 18 Jun 2019 10:55:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdMSFKc0FG3eE5EIKFOeWk1TbRUr7BHkUvkWxHLG6wA43hw+NvQ1a5LMLuv+EDxQXFgfxj
X-Received: by 2002:ac8:7949:: with SMTP id r9mr69976015qtt.217.1560880545827;
        Tue, 18 Jun 2019 10:55:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560880545; cv=none;
        d=google.com; s=arc-20160816;
        b=NUtTjHyeyDNrxVioPrPngSeQREXHlV1H7mnJiRb+tOR4EGOvzo2+yUuPuOvCA35Rsc
         eINFU5VTXKIknMghn9ZrsAii67XttPc2593lRux52haJQSJ4Jl+B9FuCXmFFwpHOOBA9
         3rXEHP+XkvJdMshQdvr38yR/8Vydzc56Mvlvg672j3HYeYYJYzz8rrJxgOJ25VXyeXzF
         38hNORjs9EViBENj24eyV6BusrzMDQqpFXuwWU37EH8oKfQGVzf0ksh5OYg7GECmx9Ts
         3sBO1UH2ERLe2fqsOHtLPrg4W/fQyGsLvwFkLTQQ5yaYNacFn0D2GrTaosULCQMd9GBg
         rmnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=hRFOK+pjnetQHO1VbczYeIM67ED6Qp4/xDYjAsyHg0Y=;
        b=ijs5dPYxV5b9conx02epSS16xXS9G5PeRiJDes2oFutc84X6cG1SlFzYZrlloW5b/b
         T2s6J3HzoR/TQYL7PG+5dGBH4HqefUarbOsiVaWHei122FpYxsRB5fp6CmDk7oRdwTb0
         RUUjk7KBxjV07kOEkBzJnyhesltrb/HMwHbTgb1LVlvKO2yU+BXi4jGsrIrq5+/toT7d
         SPbIh/KkjGkaYw+SL91kIOPKzLgzfes7xr6jNk+4OqGzRPyjkAHKQamY8P4mgPrULtZz
         E5IRHX1tf4Dz3Ej01cqGBIreOIwcqDvnISv8OWCInrpABdN1eICYLArbnxRxUMwFI6DD
         FY7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=duqFJcbL;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id b9si10409796qvh.196.2019.06.18.10.55.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 10:55:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=duqFJcbL;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5IHrkdQ192936;
	Tue, 18 Jun 2019 17:55:33 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=hRFOK+pjnetQHO1VbczYeIM67ED6Qp4/xDYjAsyHg0Y=;
 b=duqFJcbLo0ULPOq2ei4bvjgi9cATMVZgQJD+V3y+jt4MrMtO0NaxV9tb3/6PTsmoiaiL
 JFlD9+CcThW1ctgAMj7UtErFYTYYhYG3KN6rTqpLlHxg3Rmid4wkU6YfW+7a9HBCz9aO
 yevFg+iwtdJa+B24KFPywrI6D6eopuRC2EmsPfAVKcjRX7toXFnd6pJM3ubnFiguI6s/
 PxXUgR/Y8CkEuEhhpNgYDREND86pAfsQ/FKMynBRQnB5CuOQrKTGdQHC7qoM2IfwFP0G
 JUs49S3k+Xo3jtVc7bHvUq2U5k9KUWCSfPS/Z+IUeySsGSijMWi1zbhl7orlHoKYswa7 xw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2t4rmp60gn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 18 Jun 2019 17:55:32 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5IHt79E081741;
	Tue, 18 Jun 2019 17:55:32 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2t5h5tw6d1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 18 Jun 2019 17:55:31 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5IHtTve008642;
	Tue, 18 Jun 2019 17:55:29 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 18 Jun 2019 10:55:28 -0700
Subject: Re: [PATCH v3 2/2] mm: hugetlb: soft-offline:
 dissolve_free_huge_page() return zero on !PageHuge
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@kernel.org>, xishi.qiuxishi@alibaba-inc.com,
        "Chen, Jerry T" <jerry.t.chen@intel.com>,
        "Zhuo, Qiuxu"
 <qiuxu.zhuo@intel.com>, linux-kernel@vger.kernel.org,
        Anshuman Khandual <anshuman.khandual@arm.com>
References: <1560761476-4651-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1560761476-4651-3-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <53844c4d-966e-48d3-f174-b0d3598c180c@oracle.com>
Date: Tue, 18 Jun 2019 10:55:27 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1560761476-4651-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9292 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906180143
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9292 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906180143
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/17/19 1:51 AM, Naoya Horiguchi wrote:
> madvise(MADV_SOFT_OFFLINE) often returns -EBUSY when calling soft offline
> for hugepages with overcommitting enabled. That was caused by the suboptimal
> code in current soft-offline code. See the following part:
> 
>     ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>                             MIGRATE_SYNC, MR_MEMORY_FAILURE);
>     if (ret) {
>             ...
>     } else {
>             /*
>              * We set PG_hwpoison only when the migration source hugepage
>              * was successfully dissolved, because otherwise hwpoisoned
>              * hugepage remains on free hugepage list, then userspace will
>              * find it as SIGBUS by allocation failure. That's not expected
>              * in soft-offlining.
>              */
>             ret = dissolve_free_huge_page(page);
>             if (!ret) {
>                     if (set_hwpoison_free_buddy_page(page))
>                             num_poisoned_pages_inc();
>             }
>     }
>     return ret;
> 
> Here dissolve_free_huge_page() returns -EBUSY if the migration source page
> was freed into buddy in migrate_pages(), but even in that case we actually
> has a chance that set_hwpoison_free_buddy_page() succeeds. So that means
> current code gives up offlining too early now.
> 
> dissolve_free_huge_page() checks that a given hugepage is suitable for
> dissolving, where we should return success for !PageHuge() case because
> the given hugepage is considered as already dissolved.
> 
> This change also affects other callers of dissolve_free_huge_page(),
> which are cleaned up together.
> 
> Reported-by: Chen, Jerry T <jerry.t.chen@intel.com>
> Tested-by: Chen, Jerry T <jerry.t.chen@intel.com>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

