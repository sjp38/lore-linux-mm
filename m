Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59FADC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:54:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25BB621855
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:54:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25BB621855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B3E48E0003; Mon, 17 Jun 2019 02:54:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 964C38E0001; Mon, 17 Jun 2019 02:54:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82D728E0003; Mon, 17 Jun 2019 02:54:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E2048E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:54:12 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g9so7117074pgd.17
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 23:54:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=YvmswtQ24ZW+HPbnzj6bpTo8+v2gOCrHe4cI3T/Ysfg=;
        b=TIn+4nWwHOKAvIKgSb58Nj1m8RFAdR7fJ3j66lAblDeOQYsR7h5VgUz6eZX1rkX1CL
         j+O6HyxnP9XuanigjkhAfEdbbwdbI6fYw+eVEjbt2EwDtmltSN7P/sbDRlbzjJ1k2Shw
         1CcfFho76djNbUfNZVXn4TLSbKfHObmc4XJTq3pS52UVQT+aqA1mMhALT963YsfuY47e
         X/stNEPg36jJP9vLDtwF161D1/d60QBIT8t3RLLNa0KVEy/LJNJmnLkdQFn6Wup3FHfr
         5nS2OawwhNmAWXLr9BNIHqEiwUQCUrS6aJs7VWni9LTlCSVLt18MVUhYMp7pQxlQFDwW
         RiEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAU+idicfbYuyxZkxoUGhkzH37dCVXsphc0pI48EzMG052p1Ihcz
	G+CPk/BlCy2gpbs0ZydFRPoL+tsDCIIgcIvyXl4O/+45Y9eQYvQTf3Kww4tyoqXf4hrKbZw366H
	iS2Udp2OTSVl+8bTYnRUiwCZeL5q49LTJbwPpupzC6A2/PxYknbO7x4lad+esp9IzBA==
X-Received: by 2002:a63:8841:: with SMTP id l62mr46274884pgd.246.1560754451894;
        Sun, 16 Jun 2019 23:54:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGRWn0atDQ6Ve1cFrgU7y974uMdovXuapshRLWfXUIvMcazANrdlyXwGGgp35hghQXx69Y
X-Received: by 2002:a63:8841:: with SMTP id l62mr46274854pgd.246.1560754451304;
        Sun, 16 Jun 2019 23:54:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560754451; cv=none;
        d=google.com; s=arc-20160816;
        b=xa3+pdFtwVbHrnLbqNGnvFGhucXbcwbdjo7FMijf1IqHSY2e3xcOPc39VgZJRXqL6l
         /Vzmkey6sIc5ivliInTY8+Q8L5Qxo6LUgB/4ySkiR8Xv8VAGq62b6YJ94bPhsy6OidQR
         xpEWlCCvLUBGXSifQbStr+fK71pwX/85Re8KowAemGEBfL3obkRQzFsTKAIXO6KJx51E
         9Tq1lDIqmEWEJWSO9S9eaZvgJ2JHBj8h2VHNNUjluFdSxN5bdwB1Lx9xKMAG3munZLTs
         h21/l3JRRdMwReTFP6jjbB4XqNR0VhaMTa5440Epz1/jbxuipVYMJt7BojpJSeza+1pm
         H4Dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=YvmswtQ24ZW+HPbnzj6bpTo8+v2gOCrHe4cI3T/Ysfg=;
        b=A5ShX5uSERUyekdydiy6CdV0l5nxvg4goAm3ufpwio+w2p1gBqybCAiJuvJdKg0F2w
         d8MpsdhZyB4Z3Nh5HBsvOZ5yoyD0L0HVZ/vDFJr0VL2Peghurmw5q6wNn7nCmujbbsjV
         sI+Z6mDArFNBVV92tm64K0hk4d96xUWAz8qwyIJqCwNLA5OT0jvCT4/IWZcu4BbG/QkV
         Iha+/+h10+nFp/gTqeQbc4xz+AyuVC1BKeGC9uwrJPIG5d+xN5bgaDl6D5rVDITV574n
         e71FG3zSa8vLBWSsplplMbTxdAiq+6HR00uiYbrSKcRbyYqvvOxRs8ATiNM1efG5Nx+I
         X6Iw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f16si9837314pjg.50.2019.06.16.23.54.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 23:54:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5H6qbx9004980
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:54:10 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t64b33qw8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:54:10 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 17 Jun 2019 07:54:08 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 17 Jun 2019 07:54:02 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5H6s1U951839090
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 17 Jun 2019 06:54:01 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3762AAE05D;
	Mon, 17 Jun 2019 06:54:01 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9FEDBAE051;
	Mon, 17 Jun 2019 06:53:59 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.53])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 17 Jun 2019 06:53:59 +0000 (GMT)
Date: Mon, 17 Jun 2019 09:53:57 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: "Alastair D'Silva" <alastair@au1.ibm.com>
Cc: alastair@d-silva.org, Andrew Morton <akpm@linux-foundation.org>,
        David Hildenbrand <david@redhat.com>,
        Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Wei Yang <richard.weiyang@gmail.com>, Juergen Gross <jgross@suse.com>,
        Qian Cai <cai@lca.pw>, Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
        Jiri Kosina <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>,
        Mukesh Ojha <mojha@codeaurora.org>, Arun KS <arunks@codeaurora.org>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Baoquan He <bhe@redhat.com>,
        Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 4/5] mm/hotplug: Avoid RCU stalls when removing large
 amounts of memory
References: <20190617043635.13201-1-alastair@au1.ibm.com>
 <20190617043635.13201-5-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617043635.13201-5-alastair@au1.ibm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19061706-0012-0000-0000-00000329BB60
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061706-0013-0000-0000-00002162D170
Message-Id: <20190617065357.GD16810@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-17_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906170064
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 02:36:30PM +1000, Alastair D'Silva wrote:
> From: Alastair D'Silva <alastair@d-silva.org>
> 
> When removing sufficiently large amounts of memory, we trigger RCU stall
> detection. By periodically calling cond_resched(), we avoid bogus stall
> warnings.
> 
> Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
> ---
>  mm/memory_hotplug.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e096c987d261..382b3a0c9333 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -578,6 +578,9 @@ void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
>  		__remove_section(zone, __pfn_to_section(pfn), map_offset,
>  				 altmap);
>  		map_offset = 0;
> +
> +		if (!(i & 0x0FFF))

No magic numbers please. And a comment would be appreciated.

> +			cond_resched();
>  	}
> 
>  	set_zone_contiguous(zone);
> -- 
> 2.21.0
> 

-- 
Sincerely yours,
Mike.

