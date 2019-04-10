Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 465F0C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 22:24:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8E272082E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 22:24:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Vz+FQpOz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8E272082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79A836B0003; Wed, 10 Apr 2019 18:24:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74C226B0005; Wed, 10 Apr 2019 18:24:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 63A396B0007; Wed, 10 Apr 2019 18:24:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 158C86B0003
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:24:17 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n11so2039903edy.5
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 15:24:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Y7nE7ZG7nELr6t53V66jtZhQYEzl5on9riW0DsXxtsU=;
        b=gNKnk8CZk3S0hn1/GzWyMZdXRaRwnuDGreZmWg9zQoARTcPVc0fH1BjkOdYdj2BZXx
         9Nto1NkKDkVcA6F+8fwr32gsb6+RmPEUyEPh3dNAz8YpmRowdBJRJU0ltBD9/7xlOPAq
         9RTPente9EFraEnmDlAWPD8LsSbEKEKzdSad+u5Wgow0uBhD2BMcdP9BMRG8GCl158iU
         qXzvD8T2+/yNV9wn6gl304tR5P6GR7SjJJ84qZK8WKcCSSnPtpj+XBQ+Hd12cq6Kpj3F
         yft+Subpxgg2Wmkszvt5vh0yq5JO1hQoU+/72i1YJHJbbUIh9lsWlaHrvsOxDJF6gcJk
         /lMQ==
X-Gm-Message-State: APjAAAWnQBGPJg38Nk4LnmTSsO5fFHV8TMtcMn+sTTHn+bl59ULLGveY
	yyWLYJrppnhblMWWjbn40VeSMIfaAriKuPUPBP5CmoSnwr5DLewSHN92j0yDBa1TdhQruKsWA26
	PZasGn2v/A8KR0iuezLynSU34DNbOxXEEc3paHrNfuYId/p3bKCELsFCIFLD0jXLZVA==
X-Received: by 2002:a17:906:81cf:: with SMTP id e15mr24463587ejx.241.1554935056430;
        Wed, 10 Apr 2019 15:24:16 -0700 (PDT)
X-Received: by 2002:a17:906:81cf:: with SMTP id e15mr24463559ejx.241.1554935055419;
        Wed, 10 Apr 2019 15:24:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554935055; cv=none;
        d=google.com; s=arc-20160816;
        b=rwd1mwbQ64UKi/1b/YxUQW3eYfsfXlbLf2j/iENtpo47+RYUtN8ItMKI/LcuDzPAWA
         Lxp85P6XSkmqM79nBeYrlc1vCPSgV49JkFzOyFjj/nllTVsMICjp6nPL4QTyWsEUBrEm
         Uuvu/bfndJiNiBZRmvr2uBWrf4BCeaxlFHrMtWoHpi6p6GCs+ijl7tnOWayEhIFMcBHq
         yK9kTqrCfvYWFkLSHQ3rXcoLge91fgVWN9o2iJ+wuW7Aw/cuKROc7GkmvaR4vNTpAgF1
         U9XQtrX4YY+2Fdz9hA1BFYXuDb5veHRCm9afjcUdNAM875TD4+MVwIoXtP95jfZF18YM
         Y2vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=Y7nE7ZG7nELr6t53V66jtZhQYEzl5on9riW0DsXxtsU=;
        b=yYw1tHHUmEUblYwqahDBHOmdJ4tWxm7f99hVosRCOKfWoS//UuJEVjY/5ueDdfkNsx
         gjZtNREydhV+66qGVALu8QbiepQ1wqxRMfCG/PmQckWexVAuKzZanFc3cwR68oSvvCjP
         GBZulHoUsTY3SvINpbKPo1bBv40jXeckeyc4BRZaPAizwvPjkqM6w+lMOYBQC4Q23SXe
         vSYTX/A+hgtWLHf/Tcq90k05fiVsaFTk1lQAR8tD6gFK4Px2voWsBeWR8qqXxX+AL6U4
         H1gE42qxrvp+Jr56Qb1mMqwDEmyWaJaePyaYbY2V0vIufjoBejwzQzOd1sb4YUaX8/AC
         sqGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Vz+FQpOz;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e2sor3880435ejt.32.2019.04.10.15.24.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Apr 2019 15:24:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Vz+FQpOz;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Y7nE7ZG7nELr6t53V66jtZhQYEzl5on9riW0DsXxtsU=;
        b=Vz+FQpOzm6oQvCsP+brtuHCQSOX5/IFmz44R5D6t8JjmNBhQLvZMg12d3Mf6jRuj2d
         XROl8WlRjkeOMYXrAvOEVCutH9U5gq6PmaEMgw9CVvrnBormAApbvWFf9PbXBdZD2Bgk
         gRwozLmSR9dFbDKzk4tLfRA6nXzZ1RPIdFwZKrLyl077JXOWvmbE02yK4z3GiSUDkjNh
         FtSJAfcl/a+EYUu/nwKCLcM7j5QfUkMSaUNeXx3FD22PDYBWTpwG2FVJzfzo0rZy7mMU
         5yfYFUy2QM6S30nBSZNlvW0ukXcXDc8ulnVSsxeCsX7UoKrbjFXO/TznvRZVaaSGwRSp
         +CfQ==
X-Google-Smtp-Source: APXvYqzSW8A0de7PCwOZbttM9WY5RHdOdZwEuTqH8Wg6cvRd7VloMyIIu7l89/NfwCmJQirAMYsnpw==
X-Received: by 2002:a17:906:7496:: with SMTP id e22mr25675653ejl.45.1554935055071;
        Wed, 10 Apr 2019 15:24:15 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id h11sm4540083eds.44.2019.04.10.15.24.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 10 Apr 2019 15:24:14 -0700 (PDT)
Date: Wed, 10 Apr 2019 22:24:13 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH] mm/memory_hotplug: Drop memory device reference after
 find_memory_block()
Message-ID: <20190410222413.4ljc2tchgkbl4lbo@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190410101455.17338-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190410101455.17338-1-david@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 12:14:55PM +0200, David Hildenbrand wrote:
>While current node handling is probably terribly broken for memory block
>devices that span several nodes (only possible when added during boot,
>and something like that should be blocked completely), properly put the
>device reference we obtained via find_memory_block() to get the nid.
>
>Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Oscar Salvador <osalvador@suse.de>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: David Hildenbrand <david@redhat.com>
>Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>Cc: Wei Yang <richard.weiyang@gmail.com>
>Cc: Qian Cai <cai@lca.pw>
>Cc: Arun KS <arunks@codeaurora.org>
>Cc: Mathieu Malaterre <malat@debian.org>
>Signed-off-by: David Hildenbrand <david@redhat.com>

You are right.

Reviewed-by: Wei Yang <richard.weiyang@gmail.com>

>---
> mm/memory_hotplug.c | 1 +
> 1 file changed, 1 insertion(+)
>
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index 5eb4a4c7c21b..328878b6799d 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -854,6 +854,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
> 	 */
> 	mem = find_memory_block(__pfn_to_section(pfn));
> 	nid = mem->nid;
>+	put_device(&mem->dev);
> 
> 	/* associate pfn range with the zone */
> 	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
>-- 
>2.20.1

-- 
Wei Yang
Help you, Help me

