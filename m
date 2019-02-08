Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAA16C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 10:04:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 918F42080A
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 10:04:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 918F42080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 290748E0088; Fri,  8 Feb 2019 05:04:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23CE48E0002; Fri,  8 Feb 2019 05:04:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 106428E0088; Fri,  8 Feb 2019 05:04:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D65918E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 05:04:11 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k37so2920868qtb.20
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 02:04:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=utW2vT3KaOmdeS27LLnNSqfihtVuCTya6Q/qp+pT83M=;
        b=EO2ZRoZShBJ0+Ay5DB+Imvzt4vwHZVHW0DIgay6j1YKuEvu9j1KB/2Qk/ayTk6Ejmi
         yyuWNBJN6NtxHAMDqrYVdYEbxrba47yD63n7Ak/wAqCT6Up0L0QPa9kpeMa2sJf8gAjU
         uuo93esjcK5ORdpHaFtpImca7VuQSvqkrnpaWj/sljS4fhI2M9IY6Ctnh3C7rROsmQ1v
         Bza/RVYHikW9L0ZhkPLJulzGakrstlyfjVQJX7SV8rgfRQZM9wAp8w0u5IjQfS5x3X/y
         EdwK5LBZcH9sDaNPCy41rtsVwKdXwAQKrdnjg4OqwsShyQEj4MMwEVgV/33vZSGDoUie
         KJnA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZ7YRwGFNM4wszFdp18PSSqgruZwbpFuMyQ8ICGoP3+EFxdSUoa
	rNHnb01hdeVeUedaBx94ItIilQdr6zv4bGOeE9pFLtoOpC5qTMyD+CaZews9qfgJ9mmBOSYF98e
	Fs1Ko7ag0HMkAtZzNsXx0hHTg07MXZov4gMpsv7Q3GbMzqIYC2itdtBzk9eI1uafhnQ==
X-Received: by 2002:ae9:f218:: with SMTP id m24mr6551652qkg.136.1549620251572;
        Fri, 08 Feb 2019 02:04:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZDMqtysVw8oK0jAxNu/slrncGvVFSlh1tNGEjry0XKzKnono5psF1HTbuiRgU30p4llvqW
X-Received: by 2002:ae9:f218:: with SMTP id m24mr6551611qkg.136.1549620250784;
        Fri, 08 Feb 2019 02:04:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549620250; cv=none;
        d=google.com; s=arc-20160816;
        b=ozIXGcPPpLqhQRMpT7+9woyBNfz4AGttkMMXOdBxhK1VxZ69869clI+VN2M7umA6cm
         ln+41U0CfXkTlcn8SlqY/Hq24LKqAZMdBsd2D9/w7BSExEy3MHygjJ7XcHyXMeMBr2MN
         mCuxpFbUZ1dgX4W96KXqyWB4D2rLMewnxkTaIxLOwKDO+1TjH3xJSzE1gqAxCbZxRxIT
         0+kvAhM6KfhdTgGnzJCH4LAXqFuyc2lXHTj7ec6m6A658vVsGkrcRraqHlgDDJkwHia+
         o5Kab/kUlls8z0qAOrXR6cwXDsTbyyzAtg9WobFtl7hJn1FwiamM2Xlb+F2GOBnncQ4j
         i/pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=utW2vT3KaOmdeS27LLnNSqfihtVuCTya6Q/qp+pT83M=;
        b=jIotkc3StMgdSCsHIJAEacpfWYp6K8GnVQbxH2d67/fS/rcHisM8ON2sO4y9QhutO7
         cdxGFOx3gfbVHQIO8Ie8JMNJJGJlZ6gx69QiYRb+hwipG7VbNkqyEZ8hOPlYOGiU+4Hq
         EZhhlC4zjHR1O7cTkNt2WYGPYkQlJkQgZEEEG3m1YTUJ38igaoU1GzszMb9aF0LU2jy9
         oUFM+8DF97nL9WdTkosF5yO6eYBYEqCooWGNBcJcmETpnB06xiXwM90BmPnAqBIgXVp1
         20cfZsKlcx3yIQcD7oIk91j0OQ/9iQ0zK83616lVNR0NDnV9J5/2+/YjBeeBAT5D/xDT
         QmxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i37si57142qvd.196.2019.02.08.02.04.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 02:04:10 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x189wa7r019322
	for <linux-mm@kvack.org>; Fri, 8 Feb 2019 05:04:10 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qh4mh0078-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 08 Feb 2019 05:04:09 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Fri, 8 Feb 2019 10:04:08 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 8 Feb 2019 10:04:04 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x18A44L361604062
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 8 Feb 2019 10:04:04 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F0F64A405D;
	Fri,  8 Feb 2019 10:04:03 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5F448A4055;
	Fri,  8 Feb 2019 10:04:03 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.183])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Fri,  8 Feb 2019 10:04:03 +0000 (GMT)
Date: Fri, 8 Feb 2019 12:04:01 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
        Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] memblock: remove memblock_{set,clear}_region_flags
References: <1549455025-17706-1-git-send-email-rppt@linux.ibm.com>
 <1549455025-17706-2-git-send-email-rppt@linux.ibm.com>
 <CAFqt6zbvYKQS0NO3x9d45ubwf_MdEf67x1=xUHLb+ippCFmeQg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zbvYKQS0NO3x9d45ubwf_MdEf67x1=xUHLb+ippCFmeQg@mail.gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19020810-0008-0000-0000-000002BE009E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020810-0009-0000-0000-0000222A0E13
Message-Id: <20190208100401.GB11096@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-08_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902080072
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 10:02:24PM +0530, Souptick Joarder wrote:
> On Wed, Feb 6, 2019 at 6:01 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> >
> > The memblock API provides dedicated helpers to set or clear a flag on a
> > memory region, e.g. memblock_{mark,clear}_hotplug().
> >
> > The memblock_{set,clear}_region_flags() functions are used only by the
> > memblock internal function that adjusts the region flags.
> > Drop these functions and use open-coded implementation instead.
> >
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> > ---
> >  include/linux/memblock.h | 12 ------------
> >  mm/memblock.c            |  9 ++++++---
> >  2 files changed, 6 insertions(+), 15 deletions(-)
> >
> > diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> > index 71c9e32..32a9a6b 100644
> > --- a/include/linux/memblock.h
> > +++ b/include/linux/memblock.h
> > @@ -317,18 +317,6 @@ void __next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
> >         for_each_mem_range_rev(i, &memblock.memory, &memblock.reserved, \
> >                                nid, flags, p_start, p_end, p_nid)
> >
> > -static inline void memblock_set_region_flags(struct memblock_region *r,
> > -                                            enum memblock_flags flags)
> > -{
> > -       r->flags |= flags;
> > -}
> > -
> > -static inline void memblock_clear_region_flags(struct memblock_region *r,
> > -                                              enum memblock_flags flags)
> > -{
> > -       r->flags &= ~flags;
> > -}
> > -
> >  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> >  int memblock_set_node(phys_addr_t base, phys_addr_t size,
> >                       struct memblock_type *type, int nid);
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index 0151a5b..af5fe8e 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -851,11 +851,14 @@ static int __init_memblock memblock_setclr_flag(phys_addr_t base,
> >         if (ret)
> >                 return ret;
> >
> > -       for (i = start_rgn; i < end_rgn; i++)
> > +       for (i = start_rgn; i < end_rgn; i++) {
> > +               struct memblock_region *r = &type->regions[i];
> 
> Is it fine if we drop this memblock_region *r altogether ?

I prefer using a local variable to

	type->regions[i].flags
 
> > +
> >                 if (set)
> > -                       memblock_set_region_flags(&type->regions[i], flag);
> > +                       r->flags |= flag;
> >                 else
> > -                       memblock_clear_region_flags(&type->regions[i], flag);
> > +                       r->flags &= ~flag;
> > +       }
> >
> >         memblock_merge_regions(type);
> >         return 0;
> > --
> > 2.7.4
> >
> 

-- 
Sincerely yours,
Mike.

