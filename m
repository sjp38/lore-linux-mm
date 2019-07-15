Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C0FCC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 16:03:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C90D205ED
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 16:03:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C90D205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDD0A6B000E; Mon, 15 Jul 2019 12:03:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D667A6B0269; Mon, 15 Jul 2019 12:03:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE0C36B026A; Mon, 15 Jul 2019 12:03:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 83C836B000E
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 12:03:58 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id q9so10709317pgv.17
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 09:03:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=X3I3dDc3cEh78hdm7SsNO+BCi73EeEwlNjb1R3B9Tdo=;
        b=AQ2P1aMN4i8eLxMLNM6dFV26nQWIjbJG6sD9xtdO66DlOd5qOoKDSF1NwzcId2hgiM
         CKtyZSbBGKTnwEwY9WVyE5NSv59A5Rq6n52Bors/i0KpjwjtgaajqtXmldE+4X2m6onv
         YLDGbssviR53z0lU7ZEGhiEi1rvfwfPbDFE11n++UqyOKpshLcH6kNsf7X26lF+7lM6+
         kdi8SmbAZbG1puAI4A/T5r8RoWVoGOrQ9SsFk+6gFGHdNeLsaXN29cfLQQ4Mul/KWkhD
         offTAkMQ7G7OkVcQGB7/odRvf3J6nsFF/0VBAcLmkYvapLR4vi3JhhCfbiC9+fUbJCt/
         3TsA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVYzkJ8e+00o0orIQMli97RGZwBVns5/VE9MPGzM3Uhgmj44xH9
	l66jWiIilROfmzKWbLCIgNRzXB/jGJsILTDzXHX41q096cm8gswF0EtBMM8wjyuB0OUWVP3zYGq
	DdjW4R3cvc/fE4U6aHxwDefmGt8Ws03pFaafee9dGyrPJvhZGI9MzHEGd3Em2hK6xuQ==
X-Received: by 2002:a63:8f16:: with SMTP id n22mr21665672pgd.306.1563206638131;
        Mon, 15 Jul 2019 09:03:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3BWtHeOGfwAPEKkiUgVQJupCmzRMy9X3ZTpDoDAtTVrH/6cQmxP1shJaFFqdywYRxzVF4
X-Received: by 2002:a63:8f16:: with SMTP id n22mr21665602pgd.306.1563206637260;
        Mon, 15 Jul 2019 09:03:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563206637; cv=none;
        d=google.com; s=arc-20160816;
        b=pVT4ZkL0bgTQzCHmibVPqPq3kEo3bkGY/xgeZ5a83NL4EQ+x9ByGlBVl4Xlu50cGK3
         gLffsL+X71qPHW3tuCuP2cbX/V6NigPRoOfuCtRXPDX9pUJu57h2c6BnMOTtBvN2kEDZ
         KvjQGhwyJ9bbdPiPuew2P5zGqnhcYbYXgUpjqr4o9e05R/1f+r5D6hR9f/Lf3hc0vGAd
         Y046CbkENCR0uvvUe2vJ6Vd+o0R6rq75I1lozRh6n3zyEhKQlkCXHacqAq9pMb2QSdmQ
         GcbWq5hOhBUvd2wTfEXT6aOjnUTbjxAmzLIQ70RHeQSePuDe3zCnDFuVTt9DAQ2RmSH6
         sQQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=X3I3dDc3cEh78hdm7SsNO+BCi73EeEwlNjb1R3B9Tdo=;
        b=C9Y+AFymvueXA0q5MzWDHITsINKjdOsVAOs3frP07stX7bD65iRMwAmWKJ4v80xJaO
         d/FOIPhCmIzO3GII2DOaUx+QY4jVtPhNHOCfvB8KIioIhMjgN7oMgrtqcuKtk9bZn60X
         B9yBA0BVzkUqKzLDEYo1fWHYaasF0oNv9HOIX2PtbqxSTg7UkzjUIdxptAUmw54ivLk7
         OkXvNUqwdkzQZ7EAM8mS4NdascwA1Jp6Hs4ZXBBAEZiR7hNQG/z4zbUhIJFJKgbflHTJ
         hPXy7lIPcnZzKe8dHokfVWPOnAjOaTaMuoR2MuQHdUi76jjvUNyGPzSYqLmBMOyOD9td
         ghiw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u9si15816261pjn.86.2019.07.15.09.03.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 09:03:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6FG33BR104272
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 12:03:56 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2trtag96de-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 12:03:56 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 15 Jul 2019 17:03:10 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 15 Jul 2019 17:03:06 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6FG35a753346516
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 15 Jul 2019 16:03:05 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 431014C040;
	Mon, 15 Jul 2019 16:03:05 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5CE744C05A;
	Mon, 15 Jul 2019 16:03:00 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.70.182])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 15 Jul 2019 16:03:00 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, david@redhat.com, pasha.tatashin@soleen.com,
        mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH 1/2] mm,sparse: Fix deactivate_section for early sections
In-Reply-To: <20190715081549.32577-2-osalvador@suse.de>
References: <20190715081549.32577-1-osalvador@suse.de> <20190715081549.32577-2-osalvador@suse.de>
Date: Mon, 15 Jul 2019 21:32:57 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19071516-4275-0000-0000-0000034D2E82
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19071516-4276-0000-0000-0000385D3E1F
Message-Id: <87wogje15a.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-15_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907150187
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Oscar Salvador <osalvador@suse.de> writes:

> deactivate_section checks whether a section is early or not
> in order to either call free_map_bootmem() or depopulate_section_memmap().
> Being the former for sections added at boot time, and the latter for
> sections hotplugged.
>
> The problem is that we zero section_mem_map, so the last early_section()
> will always report false and the section will not be removed.
>
> Fix this checking whether a section is early or not at function
> entry.
>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

> Fixes: mmotm ("mm/sparsemem: Support sub-section hotplug")
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  mm/sparse.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 3267c4001c6d..1e224149aab6 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -738,6 +738,7 @@ static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
>  	DECLARE_BITMAP(map, SUBSECTIONS_PER_SECTION) = { 0 };
>  	DECLARE_BITMAP(tmp, SUBSECTIONS_PER_SECTION) = { 0 };
>  	struct mem_section *ms = __pfn_to_section(pfn);
> +	bool section_is_early = early_section(ms);
>  	struct page *memmap = NULL;
>  	unsigned long *subsection_map = ms->usage
>  		? &ms->usage->subsection_map[0] : NULL;
> @@ -772,7 +773,7 @@ static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
>  	if (bitmap_empty(subsection_map, SUBSECTIONS_PER_SECTION)) {
>  		unsigned long section_nr = pfn_to_section_nr(pfn);
>  
> -		if (!early_section(ms)) {
> +		if (!section_is_early) {
>  			kfree(ms->usage);
>  			ms->usage = NULL;
>  		}
> @@ -780,7 +781,7 @@ static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
>  		ms->section_mem_map = sparse_encode_mem_map(NULL, section_nr);
>  	}
>  
> -	if (early_section(ms) && memmap)
> +	if (section_is_early && memmap)
>  		free_map_bootmem(memmap);
>  	else
>  		depopulate_section_memmap(pfn, nr_pages, altmap);
> -- 
> 2.12.3

