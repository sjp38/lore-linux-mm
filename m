Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3ADE5C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:51:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECE8B21850
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:51:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECE8B21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B36F6B0003; Wed, 20 Mar 2019 03:51:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 739C96B0006; Wed, 20 Mar 2019 03:51:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DAC26B0007; Wed, 20 Mar 2019 03:51:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 18E266B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:51:10 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id v3so1913081pgk.9
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 00:51:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=yf2w6kFjwr1J0mQKeTr1yiLMvs2vuUd5qsCdZD+2F5Y=;
        b=F1IIOIktLiHUBghkHxK9K5yIP7tr9/rizqxZZakE9xMcCkQ/NaxdEeGleTjmoCkl6r
         gWtQtEqPCa8V4J8e+EWgNgJyF04UjAnnP0yNYDBDWWxUYPDktVp2zwDzsC09zrFRATWi
         BZHNQ2ohOPlKtU6Tb0vATYr8n+TsZAbfeiygKAs6+puZ7R7FCHJgrqeWx31HjL7K4qmB
         ozyYkIwyynPlJEpfRjkMwHdf9IC42yWkglBmaJKeLWt8KpHMmVXc19XmQi2Ulr5ODSD5
         3w2V46t5/PRVETKv5kitDFZxXJoig7icz3w6JAdSQStXfJuZOr8mtC/CgqlvHYcbmXo9
         f8Jw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWtJDRV6wpL+kOTaIYFN2q4OSAf0nO1VdOwWWUk1GqTIdRWIdRY
	9V9XSLWQVChZ6E9p7/T7qXJ03lTaVVBBTLAurjzjpj6z/cyIiJFbc+vAzuxCn76qamoAs13eK9M
	dTJnSFQZLcE1YByMtZtPEjMFocbM8YUDQgnFyANa5G3vzQKJASaDISamzYcqlXeQKvQ==
X-Received: by 2002:a17:902:8d89:: with SMTP id v9mr30541835plo.254.1553068269519;
        Wed, 20 Mar 2019 00:51:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyHQ/gid9nlSX2GRIzR0eGBqX8xUqtU/HdR7/3PRxACvd2Sd0ZyhrrYf7Q7VAPLV1qFKpH
X-Received: by 2002:a17:902:8d89:: with SMTP id v9mr30541782plo.254.1553068268719;
        Wed, 20 Mar 2019 00:51:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553068268; cv=none;
        d=google.com; s=arc-20160816;
        b=rG9ku4qiGw3VZwA0ufE3jl/pUodQgpUxG/IfTSCQf/hx94tZ2UfKjHOhzyVF7rtOh4
         KepeVjKHd2Kr26WWIfsv2szn1zqz4pjRIl4WPM7FLVW3W49B3vHiKy+AQeNguIe+/Qtn
         +7BrDVfhqRcLcjvR6+Cqleh3/E/rEYNwoxIfmkFW07m2cKv5rVZRrV0/IBEBstkxkl+7
         wYJiV0lTCAK87WEYaA0LTJTAFnNOl7ZcVvMoIbA4tZrzME44lmI+V59d4p+iMn7SOdLg
         yv4LkoE1eqoEkqD979LhBCFoVbKd1fb8ReSmJrGGOB5I0VwNED5wcbSAWkxT4blfE13k
         23FA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=yf2w6kFjwr1J0mQKeTr1yiLMvs2vuUd5qsCdZD+2F5Y=;
        b=K3CMSpwFycow1ay0s2+LAkvh7NBsNpMqM6JPzKL4xld2t12Ecy3yVTGkIG4h265vZd
         M6dw/tj2NsfAWpIxlpInk5/EX4j6BQGkaG0aj9Exa/YyHB8jtT5m5jJ9RkCpypDFSucd
         5Q9BG89FpbOS3zNS/Ad5CXBxCpXXWVMEYhvTvSugD+XNsXwm0NHuphUrZUyxwhjtXBsw
         wake10awrpWMxeRiHvL1kx5PTVhzdkcPNq0jb86ev9aJu2+tdFFOS5gbQykLq8tSpVLY
         i51WG434VxWAL4So/9vrpshXp/eMy2psMneWmWAOtYXLVc7lWZHUMwNMWyeghN50VgpQ
         LvPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b24si1093216pfd.173.2019.03.20.00.51.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 00:51:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2K7oumJ044838
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:51:08 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rbg5wuwhu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:51:07 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 20 Mar 2019 07:51:02 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 20 Mar 2019 07:50:59 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2K7p1JK7012436
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Mar 2019 07:51:01 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AEE7FA4054;
	Wed, 20 Mar 2019 07:51:01 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0BC4BA4060;
	Wed, 20 Mar 2019 07:51:01 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 20 Mar 2019 07:51:00 +0000 (GMT)
Date: Wed, 20 Mar 2019 09:50:59 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
        pasha.tatashin@oracle.com, mhocko@suse.com, rppt@linux.vnet.ibm.com,
        richard.weiyang@gmail.com, linux-mm@kvack.org
Subject: Re: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
References: <20190320073540.12866-1-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320073540.12866-1-bhe@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19032007-0012-0000-0000-000003050380
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032007-0013-0000-0000-0000213C1539
Message-Id: <20190320075058.GB13626@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-20_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903200066
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Mar 20, 2019 at 03:35:38PM +0800, Baoquan He wrote:
> The code comment above sparse_add_one_section() is obsolete and
> incorrect, clean it up and write new one.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>
> ---
>  mm/sparse.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 77a0554fa5bd..0a0f82c5d969 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -674,9 +674,12 @@ static void free_map_bootmem(struct page *memmap)
>  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
> 
>  /*
> - * returns the number of sections whose mem_maps were properly
> - * set.  If this is <=0, then that means that the passed-in
> - * map was not consumed and must be freed.
> + * sparse_add_one_section - add a memory section

Please mention that this is only intended for memory hotplug

> + * @nid:	The node to add section on
> + * @start_pfn:	start pfn of the memory range
> + * @altmap:	device page map
> + *
> + * Return 0 on success and an appropriate error code otherwise.

s/Return/Return:/ please

>   */
>  int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  				     struct vmem_altmap *altmap)
> -- 
> 2.17.2
> 

-- 
Sincerely yours,
Mike.

