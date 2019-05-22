Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A95C5C16A69
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 06:35:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A91220644
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 06:35:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A91220644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01FD66B0007; Wed, 22 May 2019 02:35:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F143C6B0008; Wed, 22 May 2019 02:35:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E00DF6B000A; Wed, 22 May 2019 02:35:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB1F26B0007
	for <linux-mm@kvack.org>; Wed, 22 May 2019 02:35:53 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id o12so767036pll.17
        for <linux-mm@kvack.org>; Tue, 21 May 2019 23:35:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=ZbiQY2qHEoxuRaxf94iRKGcb/gAHnojso387HX4aaO0=;
        b=fMyO9am19wf4fVEo3pc1tWqAc8JZ0yNEiYt2oaw1tv0kiTc1Ql5TyyWQHv455Ey41J
         oYavyKkPnCSgeOGy0SRvsf6Ikv13cXmZlrNl3wGjQOBPw/eOdPqpvQeZqUaJScAitSZG
         mnHQi2tpQcqlVkcuXPSzaDyaBsoGkuMbdfssKIXHd949GgeRR58T5/o3jiOJX+aAiNG/
         UlmSlsRARI+u1o7FYIZbcHvj+U4fO8O7NkcDnf0zV0xjyp8/KGFwsDzAAl7ovs5kLIX3
         pa7LTScRvea/g2X15HrH/dtkg6+Cmb5tJrRQ2lvOU4mbd8B/4ZEWb8f2kqv1M3i64yD3
         m+Ig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUimplRQ3T9cb34x1o9carbZqyLK5d+IzhikPagwbV7loKa9e7l
	XlrpVDikFGUJWdJOfCB0KqKpRxvjJ/Ni/E/e+l9N0oZ+vkRbK2zzgh6cIGKVDEmK9CU18raxaTz
	dPLH3wUjppFIKNTMAx4RtmC6ixwN4XCNZxrOGrzM5H21rLaIheFy5nQOm8VEjt7I80Q==
X-Received: by 2002:a17:902:b615:: with SMTP id b21mr25330083pls.12.1558506953325;
        Tue, 21 May 2019 23:35:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxapkBwTU6k8BdLBTC5l7SzwmV1wmyECWcNXe57rV2488D0Z48kl0EsWSXhPOuviEAdAk6L
X-Received: by 2002:a17:902:b615:: with SMTP id b21mr25330048pls.12.1558506952663;
        Tue, 21 May 2019 23:35:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558506952; cv=none;
        d=google.com; s=arc-20160816;
        b=jsVfMWiZNtSZiQxCtmVpJx9ej/VO/14Q503moT8cse1Gdv7hWUPMLQkMzPovmr02bb
         B7yMVnr3TxsRZAcd0d0EU9iSBJPijoPdaF4JTQanrNaQ7EbdQDoI6hhjMl66E6D5GSbN
         LUKQ9eiQMTPPaGKlMF6rIFCFgg9K89rL/eA/UHmUiGvDjyvK6zYwGW6gNuRgxuaxtN5L
         Uyeu3rYfLUIBzdTC29v9lfR1Cm93LYN4L7bccipGiqR2l+UCFuIaTua+tDckBExpKb6+
         KrZrQLYmfxM46Tgsyqp8OKt94vdqBUXu6mFlM3c5eeV96q197XRSR0DKSPFN1rf4EJ8m
         ca0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=ZbiQY2qHEoxuRaxf94iRKGcb/gAHnojso387HX4aaO0=;
        b=cJz1kX7YF3wYlh2bxkhWfKzeRT3dc7NXSrj7L49o4Zea+u9+TPVUxZzUzRwISo7/tY
         olKmyWNoHuzl+TABuavn+uLOtDN92tIVid0pr2ylwI1CHGU8ufnJOMiTcHhFV55vYWTY
         w7odPAGUWLEmZ1NO+VzR7KTzUr9YYgV4H/B00+GHzvbBjQ5ECR3iDMEPeTUAtv/1vUPQ
         TgIb5vqD6JLnxo2zr+ZWaHxrJCMK51okfdXr5c0C7lB5noly5eSLxiZlIiB1WiheMhJH
         BtZxUjvJfNCoOttVj7HAgDoAxstG//zq8jr+ch+SCWPY/lyVe6/QWm2BGCtmsNJPZQjd
         JbCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k23si20857694pls.88.2019.05.21.23.35.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 23:35:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4M6VvuI084395
	for <linux-mm@kvack.org>; Wed, 22 May 2019 02:35:52 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sn16rr644-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 May 2019 02:35:51 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 22 May 2019 07:35:51 +0100
Received: from b03cxnp08025.gho.boulder.ibm.com (9.17.130.17)
	by e36.co.us.ibm.com (192.168.1.136) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 22 May 2019 07:35:48 +0100
Received: from b03ledav004.gho.boulder.ibm.com (b03ledav004.gho.boulder.ibm.com [9.17.130.235])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4M6ZlS124510908
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 22 May 2019 06:35:48 GMT
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CC79778066;
	Wed, 22 May 2019 06:35:47 +0000 (GMT)
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 92C897805C;
	Wed, 22 May 2019 06:35:46 +0000 (GMT)
Received: from [9.124.31.87] (unknown [9.124.31.87])
	by b03ledav004.gho.boulder.ibm.com (Postfix) with ESMTP;
	Wed, 22 May 2019 06:35:46 +0000 (GMT)
Subject: Re: [RFC PATCH 1/3] mm/nvdimm: Add PFN_MIN_VERSION support
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org
References: <20190522062057.26581-1-aneesh.kumar@linux.ibm.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Wed, 22 May 2019 12:05:45 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190522062057.26581-1-aneesh.kumar@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19052206-0020-0000-0000-00000EEE87E9
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011141; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01206848; UDB=6.00633758; IPR=6.00987824;
 MB=3.00026997; MTD=3.00000008; XFM=3.00000015; UTC=2019-05-22 06:35:50
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052206-0021-0000-0000-000065EBBC02
Message-Id: <27bcf0e4-ba1d-2a7e-c181-ff60a9413bce@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-22_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905220048
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/22/19 11:50 AM, Aneesh Kumar K.V wrote:
> This allows us to make changes in a backward incompatible way. I have
> kept the PFN_MIN_VERSION in this patch '0' because we are not introducing
> any incompatible changes in this patch. We also may want to backport this
> to older kernels.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>   drivers/nvdimm/pfn.h      |  9 ++++++++-
>   drivers/nvdimm/pfn_devs.c |  4 ++++
>   drivers/nvdimm/pmem.c     | 26 ++++++++++++++++++++++----
>   3 files changed, 34 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
> index dde9853453d3..1b10ae5773b6 100644
> --- a/drivers/nvdimm/pfn.h
> +++ b/drivers/nvdimm/pfn.h
> @@ -20,6 +20,12 @@
>   #define PFN_SIG_LEN 16
>   #define PFN_SIG "NVDIMM_PFN_INFO\0"
>   #define DAX_SIG "NVDIMM_DAX_INFO\0"
> +/*
> + * increment this when we are making changes such that older
> + * kernel should fail to initialize that namespace.
> + */
> +
> +#define PFN_MIN_VERSION 0
>   
>   struct nd_pfn_sb {
>   	u8 signature[PFN_SIG_LEN];
> @@ -36,7 +42,8 @@ struct nd_pfn_sb {
>   	__le32 end_trunc;
>   	/* minor-version-2 record the base alignment of the mapping */
>   	__le32 align;
> -	u8 padding[4000];
> +	__le16 min_verison;
> +	u8 padding[3998];
>   	__le64 checksum;
>   };
>   
> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> index 01f40672507f..3250de70a7b3 100644
> --- a/drivers/nvdimm/pfn_devs.c
> +++ b/drivers/nvdimm/pfn_devs.c
> @@ -439,6 +439,9 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
>   	if (nvdimm_read_bytes(ndns, SZ_4K, pfn_sb, sizeof(*pfn_sb), 0))
>   		return -ENXIO;
>   
> +	if (le16_to_cpu(pfn_sb->min_version > PFN_MIN_VERSION))
> +		return -EOPNOTSUPP;

+	if (le16_to_cpu(pfn_sb->min_version) > PFN_MIN_VERSION)
+		return -EOPNOTSUPP;



-aneesh

