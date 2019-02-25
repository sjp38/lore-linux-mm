Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95B9CC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 00:45:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4991A21019
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 00:45:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="lNszA5h6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4991A21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCD0E8E0169; Sun, 24 Feb 2019 19:45:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7AD98E0167; Sun, 24 Feb 2019 19:45:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C69EE8E0169; Sun, 24 Feb 2019 19:45:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id A42818E0167
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 19:45:36 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id j10so5918463ybh.5
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 16:45:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1UyzmN6PlA6lNPpRtjTq2Mc1IMVKRlpMlMcplmQTU84=;
        b=OlOmzLzmESAX39yI8huEsnARN6LOhVMp+jmle1gSj1NNudUSHHFNTrBqVCN2lCI54i
         CulR9oQxZIoFuF+U62mNUVNOdZCa/f7yL7j5lzMhQf8CVhejLR9sOqLzB8A3FxdNFn5l
         rJ4duGw3AdzFJIRPR1z2SCeb4UhJYmOkz+QeIQdxUFqGL/tlxRkEG0Gahu/SKkkiVB0S
         FfC7Tzfgv9/GeOkFAMmUbDqrt3SmoEI7B9KCLzcpxr3D+HPygXjUkEBRow4x+JouHN3F
         N4HtEpr0H5W+SukSSYQJt5Hmkc4TctJR/KidGQT9+GhfDyT0dS8PdEw13aZFBk0O8fpm
         IyUw==
X-Gm-Message-State: AHQUAubB8LWUg2VztSMOoQSd4Ae6RYFllCqsjhHsLf6Nocs88gmkJdcI
	nzwjZr9unL4wjjTKWB/vfBZ9gjrsChVQkZ8wQg+ZCFOxAPA+Sg97CXd+/B7nOr9jieuaEL6CEmn
	qtbVWJWLueCOIltSSohJAqV9aVfXn65xV7dmvwCRB+W744viMHDMRGO+jsRtnTVod/w==
X-Received: by 2002:a25:b790:: with SMTP id n16mr6384989ybh.110.1551055536211;
        Sun, 24 Feb 2019 16:45:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbgvcAItUGLvUQZP/F9POimdzqUagMQ/KUyxD+X8zPUydtbXOFvwwNSNGreTjBRzZq5tr/j
X-Received: by 2002:a25:b790:: with SMTP id n16mr6384971ybh.110.1551055535369;
        Sun, 24 Feb 2019 16:45:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551055535; cv=none;
        d=google.com; s=arc-20160816;
        b=QNofzwjdhE6jdkelclwykXAmiZn3aXBnZvbsNl1ZXCX8uoqmhzVi+Pgjmcq2jukC/m
         Y9C721ZLqik3agO1+VWd+4DO6B3G2EeAoqadHIHZs+xqwXqG1rVVYa6NKm/09mESvrt4
         r7QQdiwg69nRBydscH6Je9vqlQCSRHuJhrEms6Hj2pu2RMnwSF5s4/RGTZBepEyyx9vP
         lUF08j3gZBvcDamDZO9zewgeyzBNoTq84o2Ex6hRiyc1FsL2I+93/pzGlAvPBPog/HBT
         ZunZj3CVJz8eRA23zpVRDjGEOqLZU+AjGZJSEpIIB/sFURbYbdz0h7aBcDDw0kwAK0OW
         9Cmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=1UyzmN6PlA6lNPpRtjTq2Mc1IMVKRlpMlMcplmQTU84=;
        b=YCklMyhC37tlkpM8tdyDpFIE4Cepz74NkGnkZbFGRc9A13jNlAsHJEt261BQsHbagR
         9Wbb7xtDsB83NmV7OVor/r2mc5M3L6yL12FUUpFOQNTAoCA42o74Dhp2a7+fg21JcsvG
         uoQk7F7m4qjavK5ZbJ37YNSt9KpieAcYgiOEmDH2j+4lHOu8COYHdM0jnHy8+pN0EfRb
         17uCy6YDNoOtE02Qp1Mss5roAXI7To0HGjyC+mjZMW8wcHMib7N7T1B9JyQ5OJSJcccw
         19LBQrP0CzSnn9U4+Skt3GgiNLdV8t8SqidBeROHo52wzkdBZRs7IDlz4iY6iFjCyBis
         m/0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lNszA5h6;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 203si3829221yby.446.2019.02.24.16.45.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Feb 2019 16:45:35 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lNszA5h6;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1P0jNAW088517;
	Mon, 25 Feb 2019 00:45:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=1UyzmN6PlA6lNPpRtjTq2Mc1IMVKRlpMlMcplmQTU84=;
 b=lNszA5h6t70w9zFrLZ3sLEbbRnCxk1LwiqFgY59aCo90OlDl/gJZUiq/TcV5oKaJBQqw
 qEPILWtWW5ci0/Than6Vi0ciSytGbO0KjVFuuWfocNIoXsAmC2Vr7AwGflMjbY904EWk
 bgeuK4lrHswY9AshAaDbNKFJCKwvor1j+G+R7JTibnHBqu7NhmGlMMc/ODw8t2vG1/F/
 bef4CrQWrw8RPhyefwSdeM0QgK4abKni8MwfzLuAf9H/zSql8D7Am+fHLzPOQTJT6IJz
 /fcXI0ml3AW0uP/6+l2f9t5+kOxLjZdFYB6QTr0pDBM3lTCegsfwVE/jfz2z9BKlKavf iw== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2qtwktu9qx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 25 Feb 2019 00:45:23 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1P0jHrw023307
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 25 Feb 2019 00:45:17 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1P0jGw7015779;
	Mon, 25 Feb 2019 00:45:16 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Sun, 24 Feb 2019 16:45:16 -0800
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
To: Jing Xiangfeng <jingxiangfeng@huawei.com>, mhocko@kernel.org
Cc: akpm@linux-foundation.org, hughd@google.com, linux-mm@kvack.org,
        n-horiguchi@ah.jp.nec.com, aarcange@redhat.com,
        kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org
References: <1550885529-125561-1-git-send-email-jingxiangfeng@huawei.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com>
Date: Sun, 24 Feb 2019 16:45:15 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1550885529-125561-1-git-send-email-jingxiangfeng@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9177 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902250004
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/22/19 5:32 PM, Jing Xiangfeng wrote:
> User can change a node specific hugetlb count. i.e.
> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
> the calculated value of count is a total number of huge pages. It could
> be overflow when a user entering a crazy high value. If so, the total
> number of huge pages could be a small value which is not user expect.
> We can simply fix it by setting count to ULONG_MAX, then it goes on. This
> may be more in line with user's intention of allocating as many huge pages
> as possible.
> 
> Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>

Thank you.

Acked-by: Mike Kravetz <mike.kravetz@oracle.com>

> ---
>  mm/hugetlb.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index afef616..6688894 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2423,7 +2423,14 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
>  		 * per node hstate attribute: adjust count to global,
>  		 * but restrict alloc/free to the specified node.
>  		 */
> +		unsigned long old_count = count;
>  		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
> +		/*
> +		 * If user specified count causes overflow, set to
> +		 * largest possible value.
> +		 */
> +		if (count < old_count)
> +			count = ULONG_MAX;
>  		init_nodemask_of_node(nodes_allowed, nid);
>  	} else
>  		nodes_allowed = &node_states[N_MEMORY];
> 

