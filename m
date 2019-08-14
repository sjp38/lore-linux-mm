Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C59BC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:15:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8B012083B
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:15:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tZ+HKRJp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8B012083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81CA96B000C; Wed, 14 Aug 2019 12:15:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CDA46B000D; Wed, 14 Aug 2019 12:15:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 695B06B000E; Wed, 14 Aug 2019 12:15:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0085.hostedemail.com [216.40.44.85])
	by kanga.kvack.org (Postfix) with ESMTP id 474EF6B000C
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:15:45 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id EF7EC181AC9AE
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:15:44 +0000 (UTC)
X-FDA: 75821534208.07.prose44_3221b5a66b71f
X-HE-Tag: prose44_3221b5a66b71f
X-Filterd-Recvd-Size: 4958
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:15:44 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id g8so1342801edm.6
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 09:15:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=8o9aIlCo3mpiOSnSj5arXqF2puBzCrXsQ6oC+NpAyV0=;
        b=tZ+HKRJpMp6FIVMsf7o5+PbNE/FCT6+0SQQSCPqVFcw1JwdH2wCsxVa74p7WBEgC5g
         jrVqSX3R/MWO7Tm8mrkP0X4znPQCXJ9JFxA887NEMRpu4J/KM9Tr+L1chHpnjsFShhfD
         kjqzrNxc68sHtN/8jLDDY1fyH2axmJPwxAWrFyrSfuoGL7mRWlJXFROYkaaNWvZWFGUU
         IdyQ+CskuJCoE+TM3+Af8bUT3Cv0tMVgwlsDId56+UTv9IGyeT1AlWgcdmRwFPZXs/qC
         5OJDP0G7gku518XBm35mFw6VAQojAFdgZwmVunnsc8tGwgo7C51wCDlI0JIKZH94IBar
         zRvg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:reply-to
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=8o9aIlCo3mpiOSnSj5arXqF2puBzCrXsQ6oC+NpAyV0=;
        b=dLKbKTJutseH9mDzG5JAQUsDYGT0llVpNDLNoweLR5x+KZTduJk4YnWAMiavmQ18Yp
         5r4s5qwlZBu+r9thk6sHJZw3npTGqVTWpmgkec+IL8qWr3fRop1bba4iGZnBEhSmAHx6
         cGiDa1MxNEieAcxcJTU1hKuwSDtkJWV5I/mnp883dJeRflAWaYVEOl2oU1uLkOCuHccS
         cKNEoZ82qWkG9ce0ZKrLTFskwEdyV/C27rz7ekYzhMJBXwueMoYMmWXDikEspaQbxnTQ
         jTNMqnPB4PmZI6lxqBVPA3M/Z4URk9KmelekWd8hNlY2S8lax49w2KCAOo7S0MnZmDoF
         YsdA==
X-Gm-Message-State: APjAAAUvoCVAqGsbROr+wzmPKnJIrh/b+g8RE/20X3k8IS/Qo1+mWm1h
	sqcrU6dc/aKgRh3iWdo17/k=
X-Google-Smtp-Source: APXvYqxF+Mu09EjcK1cYN7o4EzQDOnpp2ECuyGdYpYyTAKemcC9zcK2q6cKF2FOFqzmjJ8+JqHjp1A==
X-Received: by 2002:a50:b3cb:: with SMTP id t11mr374805edd.203.1565799343284;
        Wed, 14 Aug 2019 09:15:43 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id e24sm11734ejb.53.2019.08.14.09.15.41
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Aug 2019 09:15:42 -0700 (PDT)
Date: Wed, 14 Aug 2019 16:15:41 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Dan Williams <dan.j.williams@intel.com>,
	Borislav Petkov <bp@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Bjorn Helgaas <bhelgaas@google.com>, Ingo Molnar <mingo@kernel.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Nadav Amit <namit@vmware.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2 1/5] resource: Use PFN_UP / PFN_DOWN in
 walk_system_ram_range()
Message-ID: <20190814161541.ho5b6ju4t23vruff@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190814154109.3448-1-david@redhat.com>
 <20190814154109.3448-2-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814154109.3448-2-david@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 05:41:05PM +0200, David Hildenbrand wrote:
>This makes it clearer that we will never call func() with duplicate PFNs
>in case we have multiple sub-page memory resources. All unaligned parts
>of PFNs are completely discarded.
>
>Cc: Dan Williams <dan.j.williams@intel.com>
>Cc: Borislav Petkov <bp@suse.de>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Bjorn Helgaas <bhelgaas@google.com>
>Cc: Ingo Molnar <mingo@kernel.org>
>Cc: Dave Hansen <dave.hansen@linux.intel.com>
>Cc: Nadav Amit <namit@vmware.com>
>Cc: Wei Yang <richardw.yang@linux.intel.com>
>Cc: Oscar Salvador <osalvador@suse.de>
>Acked-by: Michal Hocko <mhocko@suse.com>
>Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>

>---
> kernel/resource.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/kernel/resource.c b/kernel/resource.c
>index 7ea4306503c5..88ee39fa9103 100644
>--- a/kernel/resource.c
>+++ b/kernel/resource.c
>@@ -487,8 +487,8 @@ int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
> 	while (start < end &&
> 	       !find_next_iomem_res(start, end, flags, IORES_DESC_NONE,
> 				    false, &res)) {
>-		pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
>-		end_pfn = (res.end + 1) >> PAGE_SHIFT;
>+		pfn = PFN_UP(res.start);
>+		end_pfn = PFN_DOWN(res.end + 1);
> 		if (end_pfn > pfn)
> 			ret = (*func)(pfn, end_pfn - pfn, arg);
> 		if (ret)
>-- 
>2.21.0

-- 
Wei Yang
Help you, Help me

