Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 426C0C10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:47:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 589842173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:47:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 589842173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D28B18E0003; Tue, 26 Feb 2019 07:47:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDADD8E0001; Tue, 26 Feb 2019 07:47:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA2068E0003; Tue, 26 Feb 2019 07:47:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8858E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:47:00 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id u13so9337027qkj.13
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 04:47:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=EYDFzwVVpIhBF/t8LaEP40NzQqmr2aprZ+ivgpqWGEg=;
        b=s5TXhiFCKCP9YAM1K1SrZdRrAEqRjYYLhhodtWF/x5Q4JaCK973cBMm5swMmY4LKkV
         YcaEkyhcsnoRPDtVXbjkRTlnoht5I34cszg2NnJrT6QQ+G9EgPm4fvejjsiVSvwTYFFJ
         GjEMGOyFLk0WK95raxQnMD7NvEAggizE2wylfKZoYA8uzisnb7zo8S4s+xKKU5I1k3f6
         fHcfqz2TXMZzJwVgJtl+8uXsY736FRgiqqaE5ZtgcCJpY6vSrOCUCIJtWxW1NrRPCcC1
         0f5rm0+B0ho8/KkUeCd9CCiBAKe/1PDSnzSVgBi4uRNebUWECjiAXv5RWFMbEl0bHzXx
         0aHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAua45CRyqx03n8Wn4QC0aAtAVoMy+XXQ/VHlOSczRBBCBRTu6j0L
	VOT5wDY+Dtar63aOXfjriyTXhKY5LAujw1llGcC5eIJ3b0g9DMVJ2QIHJGGvon/X4SH/x1HKxUR
	tvayFPbpy4G0lNZ7lFXBNoQTvXmhwxla1Kb48j5SAuqsF//yYIBSFtxIWxSHlLVwvYQ==
X-Received: by 2002:a37:4a83:: with SMTP id x125mr16656623qka.30.1551185220291;
        Tue, 26 Feb 2019 04:47:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYMyrNppIVqr0eCAW6HVgdW9evcljrxk7u6qnk9C5umcRvOskkURXjGebG9Srq7Q/G5MqN1
X-Received: by 2002:a37:4a83:: with SMTP id x125mr16656586qka.30.1551185219406;
        Tue, 26 Feb 2019 04:46:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551185219; cv=none;
        d=google.com; s=arc-20160816;
        b=SJdBLvuaj1KxtgjsMNmMapGq4aqD6QWZ+m53+92CxxhkYQrDvyPQMYoU95lkvpyIn5
         jSTYDk63SGNWyYgUOW0G5N4CAAG9R/bspKgcqJldoV9tS6mGDXBfBm7hGixVNgiAOeRz
         fZxbIK2hhu5Vs1A87XamHB6iCW1p1poAdmAZbe4sxsEgArbvtWB/6AVasCE5I+q4mT5I
         7Y3/qp/q4izqF6iZ87CY6lduXMDGze1Ggc/Mf+OoVoV4Rcj8F/8HjcjF9yVFKqgyBpDr
         iU2VolqJsOrqQ/ZWROiiFiDNXxFYq6/upVlvKqZ98h00hr7wz+05ti47gljQa2asgqfW
         uqjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=EYDFzwVVpIhBF/t8LaEP40NzQqmr2aprZ+ivgpqWGEg=;
        b=odcrVevp+Gw8hJ9zEe4S4iriGUJUoqmSPnvynjs3728wvmqBiHUCK8SFaCsqpucJGZ
         lC8c0dhuac5ghyqSjelWueAed3E3TWeQtRwfiE1pnqXcQ5wjUx8MAotHuBjLf4skKVGZ
         PzIpc4Pt3zkPSfjwf01K6KRFI5bctrtFud7LEyAhTSFAqQs4yybdpH4b10S7oF1xTb4O
         e2eNPZr22MwW7NeqX4p0WtRLMYBRLrnYgn2e1LEg8ATDG81mvFqaOwIZk791R6SKhV6a
         k691a5hS42DI0TToyRKbwy0fKXI8TtZBXQ2PWb0KQrX5CIvHB8yMRGK2XgWyWQgHmAUg
         ZmLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r4si1280437qvr.3.2019.02.26.04.46.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 04:46:59 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1QCjI1V004979
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:46:58 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qw4116d18-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:46:58 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Feb 2019 12:46:56 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Feb 2019 12:46:53 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1QCkq1N52559976
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 26 Feb 2019 12:46:52 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 339AEAE045;
	Tue, 26 Feb 2019 12:46:52 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 64DE2AE051;
	Tue, 26 Feb 2019 12:46:51 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 26 Feb 2019 12:46:51 +0000 (GMT)
Date: Tue, 26 Feb 2019 14:46:49 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Sasha Levin <sashal@kernel.org>
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
        Michal Hocko <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org
Subject: Re: [PATCH AUTOSEL 4.20 66/72] mm, memory_hotplug:
 is_mem_section_removable do not pass the end of a zone
References: <20190223210422.199966-1-sashal@kernel.org>
 <20190223210422.199966-66-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190223210422.199966-66-sashal@kernel.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022612-0016-0000-0000-0000025B1407
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022612-0017-0000-0000-000032B57643
Message-Id: <20190226124649.GH11981@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-26_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1031 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902260094
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 23, 2019 at 04:04:16PM -0500, Sasha Levin wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> [ Upstream commit efad4e475c312456edb3c789d0996d12ed744c13 ]
 
There is a fix for this fix [1].

It's  commit 891cb2a72d821f930a39d5900cb7a3aa752c1d5b ("mm, memory_hotplug:
fix off-by-one in is_pageblock_removable") in mainline.
    
[1] https://lore.kernel.org/lkml/20190218181544.14616-1-mhocko@kernel.org/


> Patch series "mm, memory_hotplug: fix uninitialized pages fallouts", v2.
> 
> Mikhail Zaslonko has posted fixes for the two bugs quite some time ago
> [1].  I have pushed back on those fixes because I believed that it is
> much better to plug the problem at the initialization time rather than
> play whack-a-mole all over the hotplug code and find all the places
> which expect the full memory section to be initialized.
> 
> We have ended up with commit 2830bf6f05fb ("mm, memory_hotplug:
> initialize struct pages for the full memory section") merged and cause a
> regression [2][3].  The reason is that there might be memory layouts
> when two NUMA nodes share the same memory section so the merged fix is
> simply incorrect.
> 
> In order to plug this hole we really have to be zone range aware in
> those handlers.  I have split up the original patch into two.  One is
> unchanged (patch 2) and I took a different approach for `removable'
> crash.
> 
> [1] http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com
> [2] https://bugzilla.redhat.com/show_bug.cgi?id=1666948
> [3] http://lkml.kernel.org/r/20190125163938.GA20411@dhcp22.suse.cz
> 
> This patch (of 2):
> 
> Mikhail has reported the following VM_BUG_ON triggered when reading sysfs
> removable state of a memory block:
> 
>  page:000003d08300c000 is uninitialized and poisoned
>  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
>  Call Trace:
>    is_mem_section_removable+0xb4/0x190
>    show_mem_removable+0x9a/0xd8
>    dev_attr_show+0x34/0x70
>    sysfs_kf_seq_show+0xc8/0x148
>    seq_read+0x204/0x480
>    __vfs_read+0x32/0x178
>    vfs_read+0x82/0x138
>    ksys_read+0x5a/0xb0
>    system_call+0xdc/0x2d8
>  Last Breaking-Event-Address:
>    is_mem_section_removable+0xb4/0x190
>  Kernel panic - not syncing: Fatal exception: panic_on_oops
> 
> The reason is that the memory block spans the zone boundary and we are
> stumbling over an unitialized struct page.  Fix this by enforcing zone
> range in is_mem_section_removable so that we never run away from a zone.
> 
> Link: http://lkml.kernel.org/r/20190128144506.15603-2-mhocko@kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Reported-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
> Debugged-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
> Tested-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Sasha Levin <sashal@kernel.org>
> ---
>  mm/memory_hotplug.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 21d94b5677e81..5ce0d929ff482 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1234,7 +1234,8 @@ static bool is_pageblock_removable_nolock(struct page *page)
>  bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
>  {
>  	struct page *page = pfn_to_page(start_pfn);
> -	struct page *end_page = page + nr_pages;
> +	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
> +	struct page *end_page = pfn_to_page(end_pfn);
> 
>  	/* Check the starting page of each pageblock within the range */
>  	for (; page < end_page; page = next_active_pageblock(page)) {
> -- 
> 2.19.1
> 

-- 
Sincerely yours,
Mike.

