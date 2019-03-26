Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A415CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:23:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EE1020857
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:23:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EE1020857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0DED6B0007; Tue, 26 Mar 2019 05:23:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBB6B6B0008; Tue, 26 Mar 2019 05:23:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD3EC6B000A; Tue, 26 Mar 2019 05:23:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A82E36B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:23:48 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e12so7326845pgh.2
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:23:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=QBBT2o3WyNf4d245LoEFylZIG4syyjeIXuC5ym3hohs=;
        b=TgeDWAXN0t0kDnIBxsrRDCmJpoQSVuY6XeEVZ0AL06e7PwJyui/U9+VjgTylK/0B5s
         WIUpftdXxEzLEfpMIfQkjqTeM/e+IixPPtZJtwUWoStf3rt19xffI/WO4o3tbOGk9ldM
         9SAkubU0fuCiOiD7ldNBKsUo90bLyjg4sgQ0XE5vq0ScfUOPW0U13nz3Cn+LEYvMaIx7
         XCUWN5kH/uN0nMMAhqfWIw7edl3NkC/CtnoKY/4OR5nkGDxTXjRyXyc9W9QTn4HgtFmg
         2PDudNhWK5WXJU8M/ujaoLTHCJsJXD/rgr4oH35Wi2m67k9BED+2tbcOnh8vXvXZSxjL
         il0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXyZ7dUSmhDoRTnKp0SL4pC/LOTiZhXEX2SMBsLUmMTLGAj+oXr
	HW0lC4j1nm+hfTH+NhiWq63jbTlfk+6O5mX3annBvvITjakEhiKlRGKPZdppZKGjzsMUaV8VZh7
	XdHnCvNWN/m19gpeWWvevYL3KLTPS3giz3dcerUrnnMx239WaqjidhQJECLlXHlf7Mw==
X-Received: by 2002:a63:ed11:: with SMTP id d17mr27890001pgi.211.1553592228371;
        Tue, 26 Mar 2019 02:23:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWhHIC+MgSZLDKvaQMeVz0xn+5D8mp3DdY2gL56/8PksmLCxtB/CKS7lLfgJFtDA7ZKWEl
X-Received: by 2002:a63:ed11:: with SMTP id d17mr27889963pgi.211.1553592227729;
        Tue, 26 Mar 2019 02:23:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553592227; cv=none;
        d=google.com; s=arc-20160816;
        b=G4pCmty/egomBqXhAuC1nLDmUprD/fjn6TPLS6EYfMdHeUBa/uEfb0DALKcBjGUXwF
         g/1t+48wniIA3Ktv4lRY3XJxES6XV317hO6YoUCTnBSy0m31ps/nP+SIL0Pds2USYunr
         LhmWxxtRPyn4EDiL++fHjiDkHhsnUJl4mmCa+IJBhdfhYzJRmM0BTO8ogH+maRzzw+Js
         OZk/G5+INFNAoe0pEOsw8PAtFb2Kc5TPiURMFhHPJeKLpC+vZ/b+eMo9jYMsWSnCA9wY
         htYx1zxfWacd+TjYhoLO0eaMkRQ3xlvmiwV796CqV+zmcrtw82FKvfdJbJI4NcqcOfFR
         z2gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=QBBT2o3WyNf4d245LoEFylZIG4syyjeIXuC5ym3hohs=;
        b=ItAiVFLxNqcrndeZ/Jhy/EBjaOw7tuYt64otTgtDoONYSg0SDHHZgPBwMfOO7i1yVv
         h2lL514J5OXvScgj1nO4BaHBVV45hsz/XCLmBqqxxae9b3dTSmP5F4HyeUlZQb1VjGoA
         Tp9NM+rB7sHtuq64XHGB7itN7O40RNRcSF2ZozUvT+83YJaV7KKr9ux48mdI3ubWmaKc
         5tmFCRfTT9CldFi8ZqsM9rDrM0s2sc4nl0+0OeO2BOQFxYJk4Swy0zLBymNNs0/YlKGM
         RQ4ruJ4bjaYAQIdQrRnF2L0NOPJiPsdzpeiUy/adxlIbqyuNTII0//MWbWPYKRvopk+a
         +HRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u70si9744232pgd.455.2019.03.26.02.23.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 02:23:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2Q99NBw026392
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:23:47 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rffue41n3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:23:46 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Mar 2019 09:23:44 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Mar 2019 09:23:41 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2Q9NerH58196084
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 26 Mar 2019 09:23:40 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B8A9BA405B;
	Tue, 26 Mar 2019 09:23:40 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0FA7CA405C;
	Tue, 26 Mar 2019 09:23:40 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 26 Mar 2019 09:23:39 +0000 (GMT)
Date: Tue, 26 Mar 2019 11:23:38 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        akpm@linux-foundation.org, mhocko@suse.com, osalvador@suse.de,
        willy@infradead.org, william.kucharski@oracle.com
Subject: Re: [PATCH v2 2/4] mm/sparse: Optimize sparse_add_one_section()
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-3-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326090227.3059-3-bhe@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19032609-0028-0000-0000-000003585CF7
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032609-0029-0000-0000-000024171387
Message-Id: <20190326092337.GC6297@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-26_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903260069
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 05:02:25PM +0800, Baoquan He wrote:
> Reorder the allocation of usemap and memmap since usemap allocation
> is much simpler and easier. Otherwise hard work is done to make
> memmap ready, then have to rollback just because of usemap allocation
> failure.
> 
> And also check if section is present earlier. Then don't bother to
> allocate usemap and memmap if yes.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
> v1->v2:
>   Do section existence checking earlier to further optimize code.
> 
>  mm/sparse.c | 29 +++++++++++------------------
>  1 file changed, 11 insertions(+), 18 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index b2111f996aa6..f4f34d69131e 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -714,20 +714,18 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  	ret = sparse_index_init(section_nr, nid);
>  	if (ret < 0 && ret != -EEXIST)
>  		return ret;
> -	ret = 0;
> -	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
> -	if (!memmap)
> -		return -ENOMEM;
> -	usemap = __kmalloc_section_usemap();
> -	if (!usemap) {
> -		__kfree_section_memmap(memmap, altmap);
> -		return -ENOMEM;
> -	}
>  
>  	ms = __pfn_to_section(start_pfn);
> -	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
> -		ret = -EEXIST;
> -		goto out;
> +	if (ms->section_mem_map & SECTION_MARKED_PRESENT)
> +		return -EEXIST;
> +
> +	usemap = __kmalloc_section_usemap();
> +	if (!usemap)
> +		return -ENOMEM;
> +	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
> +	if (!memmap) {
> +		kfree(usemap);
> +		return  -ENOMEM;
>  	}
>  
>  	/*
> @@ -739,12 +737,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  	section_mark_present(ms);
>  	sparse_init_one_section(ms, section_nr, memmap, usemap);
>  
> -out:
> -	if (ret < 0) {
> -		kfree(usemap);
> -		__kfree_section_memmap(memmap, altmap);
> -	}
> -	return ret;
> +	return 0;
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -- 
> 2.17.2
> 

-- 
Sincerely yours,
Mike.

