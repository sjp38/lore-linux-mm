Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60F09C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:57:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D0D62146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:57:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D0D62146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C69446B0006; Wed, 20 Mar 2019 03:57:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3D8D6B0007; Wed, 20 Mar 2019 03:57:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2DDE6B0008; Wed, 20 Mar 2019 03:57:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2956B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:57:01 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id p127so1901200pga.20
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 00:57:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=TSu//6i+HT3W1SaVXmcGjSdGj5ZslETnp7PAL37lvY0=;
        b=qDCN4JT14QTeuw/4bA0GBQQgUjdBJlBWJ196N+dL+ScEqFdyprgXSPOcUbSG8Oty1B
         iWOLdXLdCFAILA/8DMktLwy0HOxpcWVD0KqkHXePveP/6Ang2grXk4pEoI7lNcdNh5zf
         s83ZQMgaFdpGzEmocyJGr2rjjz4tE3/hd175Mu5dRiaXhtjYBH65BU+E0z8KuG7KKwIa
         Q1XFgKrKayhUm6Wm+EgCwzwQbI6py18a2rRuByTQMK3fTDsOGfZ9/VgHQcMtpN5FCbrc
         oejR7inwSzOMFwIesQ08DbgmWKd3qXUtgREbKLKrqUMDk8gD5VykN4UYo9QwjiCZRSmQ
         i3qA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWCqtFBjL40JzSpzxcN7Ge9LBxDuJ5IRNvVXHHNcCfialVcQ6wU
	AsvT8j3w5AzmY9xO34kTMXcjqBFoYJOK/rEOF1FzxMIke9/oU2glA6R5bhmEl3mDAWeKk6S9paK
	9lzuCOGrNmQB1Vk1XlhBoPWFmJqp8IyEI4+ZhIDfB8SwhU8sCzYgo5HTpc5ftTzTD/Q==
X-Received: by 2002:a63:1d20:: with SMTP id d32mr940312pgd.49.1553068620996;
        Wed, 20 Mar 2019 00:57:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRlU7/0yUTYRnjRcF3athI2MCxcd03B+GWJXEtdt/jdk98YPxJ+8NgD5s1n6WcGg3ldy4Q
X-Received: by 2002:a63:1d20:: with SMTP id d32mr940277pgd.49.1553068620211;
        Wed, 20 Mar 2019 00:57:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553068620; cv=none;
        d=google.com; s=arc-20160816;
        b=As16BQ8IOqiAo9T6Dh/yYI8rFvx3yMkJUserdhK9BDyLpM3CRmfCJ5dBFPDoJR2IzN
         B/ulgzg10T4j8L7hnIPkkfjc+kWPL8HV0aNCDrFpm7zxwLKL/uB9CVCkjD8M7xDnCh4a
         RYlh73ongt8rsXCPXKm3A/2axKiL+ruff/Mfc1D/VIlwNnHLpcYND47x0rCh95G1GpLP
         8KaJRdgkVMD37QEuo5OLBsfX1XvGGP5P4ITnorcPnxHW3i130V/ETXOkCAtBh/YVK0+o
         0LC7RXOZRcjT8PpcnLfVz/2D+eLgep7uMn9wTYDyFPPXnOykiP3ubvo4pOe8pN919CP9
         hW9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=TSu//6i+HT3W1SaVXmcGjSdGj5ZslETnp7PAL37lvY0=;
        b=mkiYIw3SbfZ9gT+NGXmeOgzfTA3DnBRlELVgNupY8Dbgpl/gcHVOe2TScAo8V5ASio
         /J8g/Ks995CWdf5lR2FWkm5FUrTsgngdEerV6lzYSh+OBdSIrWmvE036Kk5WFQD0XLzR
         M7iNYxwYyI42GZBV0h0QTHfUtkO8FAELdy3T3VmlE+N2fi8LZPPJtOdHv8duhXNQDDow
         PGgYhBObwC5AHd8lik47rwSIKUwZmooSWW16YfVUldjLZj5QzyuNXWJkfJ2XRC85pxz2
         2QYEQ/11Lze7wXOKqLMmZp1ooAoVaiY6dirDMFRSeinr7+wGoEoB3CPSref11OS+7yMR
         wA2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d19si1115492pgk.115.2019.03.20.00.57.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 00:57:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2K7rlpW098525
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:56:59 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rbentfwf9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:56:59 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 20 Mar 2019 07:56:51 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 20 Mar 2019 07:56:48 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2K7uqJg61276284
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Mar 2019 07:56:53 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BB97BA4057;
	Wed, 20 Mar 2019 07:56:52 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1790EA4051;
	Wed, 20 Mar 2019 07:56:52 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 20 Mar 2019 07:56:51 +0000 (GMT)
Date: Wed, 20 Mar 2019 09:56:50 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
        pasha.tatashin@oracle.com, mhocko@suse.com, rppt@linux.vnet.ibm.com,
        richard.weiyang@gmail.com, linux-mm@kvack.org
Subject: Re: [PATCH 2/3] mm/sparse: Optimize sparse_add_one_section()
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320073540.12866-2-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320073540.12866-2-bhe@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19032007-4275-0000-0000-0000031D2343
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032007-4276-0000-0000-0000382BA629
Message-Id: <20190320075649.GC13626@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-20_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903200067
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:35:39PM +0800, Baoquan He wrote:
> Reorder the allocation of usemap and memmap since usemap allocation
> is much smaller and simpler. Otherwise hard work is done to make
> memmap ready, then have to rollback just because of usemap allocation
> failure.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>
> ---
>  mm/sparse.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 0a0f82c5d969..054b99f74181 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -697,16 +697,17 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  	ret = sparse_index_init(section_nr, nid);
>  	if (ret < 0 && ret != -EEXIST)
>  		return ret;
> -	ret = 0;
> -	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
> -	if (!memmap)
> -		return -ENOMEM;
> +
>  	usemap = __kmalloc_section_usemap();
> -	if (!usemap) {
> -		__kfree_section_memmap(memmap, altmap);
> +	if (!usemap)
> +		return -ENOMEM;
> +	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
> +	if (!memmap) {
> +		kfree(usemap);

If you are anyway changing this why not to switch to goto's for error
handling?

>  		return -ENOMEM;
>  	}
> 
> +	ret = 0;
>  	ms = __pfn_to_section(start_pfn);
>  	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
>  		ret = -EEXIST;
> -- 
> 2.17.2
> 

-- 
Sincerely yours,
Mike.

