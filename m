Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E394C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:56:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F12DC2075C
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:56:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="IA6OBonZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F12DC2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 825DD8E012E; Fri, 22 Feb 2019 13:56:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D4F08E0123; Fri, 22 Feb 2019 13:56:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69E3A8E012E; Fri, 22 Feb 2019 13:56:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1588E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 13:56:56 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id n187so2000612ybc.19
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:56:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=xkL/KUG2ty/qt3b6CfHyrEo1gt0Q/082URYwQd1dfDY=;
        b=rXR9AVYMyD87w38chuQAsl7RVUi7OUL+SxUwZImSSLOqnDVc9ucmur6HLBeLnHj/Us
         JUnFLc07ZIiXG8ABKVVqHhAx77P7DLbK02+NQqSX8QTEF8dwPBpb7YcpuVh9TnwIaM9S
         NwarxerfHWhVDIGcZKw6AJoURrv0wwGZeb0QEQU9+DEgwM9xxyIcccgeLJImzEYu4BhF
         sfOocIEQGdlRqfOaq75hQLE0x5ZoOqaJULd3wuyuq3Yx4SduRPQTgSbcOOuRVM6ayr64
         Y5GTE4D/IxL4sgJiQrsOLp8vIeKmxQqRpHwZjTcFerH/p+1Qh+3UsFYAD0E2kYk94NG1
         mmhQ==
X-Gm-Message-State: AHQUAua418E6J826M2D89WnGgZpbnNXiR6jd7veyDmdXCB2Kq3URTbFA
	aQSidQRIwRaGXeir7DpBEZpEJqyv89LkqnPn4bXSCQfKdXBgDkAog5benCPwHWUzQsr6oI0+LWT
	GclQyPlRSYCmA6CclopOBLh3qK02RiMCDpjdbl/A+3lMF277RzvxhrOauJyQGoHI18A==
X-Received: by 2002:a5b:44a:: with SMTP id s10mr4683888ybp.248.1550861815943;
        Fri, 22 Feb 2019 10:56:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYqqBgbV2V5gxkuEhk6idng7xR6aNgUlnosJVTUt8VwR5dG4NbtYVWj39a1iZb9UsUVjUUC
X-Received: by 2002:a5b:44a:: with SMTP id s10mr4683852ybp.248.1550861815091;
        Fri, 22 Feb 2019 10:56:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550861815; cv=none;
        d=google.com; s=arc-20160816;
        b=zYWwmVKnhA+Bd0lq/rsteuuLaV6f19oask3jl+lRTpknikzgyW+HjI+e+gA8xlNGH6
         MFygXT0hAuTKA3xeI9MSp0wl4zzQOpXyclRpTgYDOqdGcWrtixwdF+hyjPaRSPJw0YYA
         yYtiatlfuswdO/tiQUAXZXiqm0p+c2arTDLiuruPLdlxK+JiyO9RDZltRhHig6vzol51
         KeVigSMLxtbg19NNZzXpA9caiW3lwTx1nywsbXoYj+/WjmiHWCGRt8KXPm62e9jemF9q
         nVz64MD53g0penizVweyyOzmkVGhwq5A1MBX6aAGgnPZOmR6MhCS75gN+DTHc/rLpjo8
         CwhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=xkL/KUG2ty/qt3b6CfHyrEo1gt0Q/082URYwQd1dfDY=;
        b=i+wkOneIwyZNFYhkNJ9yhhbHHM9ZZlzQ4qMRJcLB0Rl71/pvW/pjuxYVci/m+9rQMV
         gR/gaSpiCyAAe8btV8yx3UeqFpfFWwOhZTVe0h6HYRdwONCSOMTpqfk06KIHsPFj2rtf
         FRJWYPcutvaGS6z16PTkJZdd7px0RGGZb2Fp3ilBMM8SAMS5A4spBBKm7zyGRY9495Q5
         2cE8mWeXI8qdWxJin7sQYXBJPi4koZjYx0xd1uqGez3Vvn+lNOpCqibpDvT6z+uv7mTJ
         V4E9J+UfBUInYriEhsrjrD7hmIXBs0KRZLUaRVasFov/fUINOHYWnqzse925Nz17JrnO
         iBWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=IA6OBonZ;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id c13si1258901ybl.108.2019.02.22.10.56.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 10:56:55 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=IA6OBonZ;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1MIrVEf071475;
	Fri, 22 Feb 2019 18:56:40 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=xkL/KUG2ty/qt3b6CfHyrEo1gt0Q/082URYwQd1dfDY=;
 b=IA6OBonZz6DXwAbe7D5ZQnlvUglPV/S+Wp72sxqWu/RSQWCdnVfhACLvuzwCCDMYxbY6
 iZpJugaJVyRdOMD3Qv03g2g8tMpHoAjSYUiBuezyqVUt7PSZwlg+izMSYDWIL+RcaY+M
 XwqKRFcgUvBBVylQZYCrLfq1hIQvLLu0oLh/XC8avT5VdvQZ9EGeEp2NWyw6GwHtAD5M
 nipz+C0CPsCRV8WFwVaoZyhPaYbBZSywFFIJA7/pdwzcYMQYYigkQo2jpGDjiv6dffZa
 0zI6Dwe8nFpYALMlHPtioF29rU9AshKtu7MikELFqwcmtKODW1RGwXf8IdPOd/DEvt2f Zw== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2qp81es377-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 22 Feb 2019 18:56:40 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1MIucnZ006901
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 22 Feb 2019 18:56:39 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1MIucic030285;
	Fri, 22 Feb 2019 18:56:38 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 22 Feb 2019 10:56:38 -0800
Subject: Re: [PATCH v3] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
To: Jing Xiangfeng <jingxiangfeng@huawei.com>, mhocko@kernel.org,
        akpm@linux-foundation.org
Cc: hughd@google.com, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com,
        aarcange@redhat.com, kirill.shutemov@linux.intel.com,
        linux-kernel@vger.kernel.org
References: <1550844088-67888-1-git-send-email-jingxiangfeng@huawei.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <9258d571-26d0-f9ad-a60e-0449ac8dd5f9@oracle.com>
Date: Fri, 22 Feb 2019 10:56:36 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1550844088-67888-1-git-send-email-jingxiangfeng@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9175 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902220129
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/22/19 6:01 AM, Jing Xiangfeng wrote:
Thanks, just a couple small changes.

> User can change a node specific hugetlb count. i.e.
> /sys/devices/system/node/node1/hugepages/hugepages-2048kB

Please make that,
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages

> the calculated value of count is a total number of huge pages. It could
> be overflow when a user entering a crazy high value. If so, the total
> number of huge pages could be a small value which is not user expect.
> We can simply fix it by setting count to ULONG_MAX, then it goes on. This
> may be more in line with user's intention of allocating as many huge pages
> as possible.
> 
> Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
> ---
>  mm/hugetlb.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index afef616..18fa7d7 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2423,7 +2423,10 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
>  		 * per node hstate attribute: adjust count to global,
>  		 * but restrict alloc/free to the specified node.
>  		 */
> +		unsigned long old_count = count;
>  		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];

Also, adding a comment here about checking for overflow would help people
reading the code.  Something like,

		/*
		 * If user specified count causes overflow, set to
		 * largest possible value.
		 */

-- 
Mike Kravetz

> +		if (count < old_count)
> +			count = ULONG_MAX;
>  		init_nodemask_of_node(nodes_allowed, nid);
>  	} else
>  		nodes_allowed = &node_states[N_MEMORY];
> 

