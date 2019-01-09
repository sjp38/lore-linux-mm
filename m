Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6642BC43612
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:09:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24E77206BB
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:09:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24E77206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD4818E009F; Wed,  9 Jan 2019 11:09:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C830F8E0038; Wed,  9 Jan 2019 11:09:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B99BB8E009F; Wed,  9 Jan 2019 11:09:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 770858E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:09:13 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b8so5542914pfe.10
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:09:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EE/0BkdGGAB6magwhJ8ugQ7KDd8Q/T2tsYZKliX9xAg=;
        b=LZusDdsuDcoKsfQQJWALmMcTaAIy18wWFNuTSm2fLMAn7tCpQyPCmnmoI+x6EZM6vo
         JZETEQ53/HTdLyEl6/GlPLQmvbUmjwlYcIl5bPqDrr+ZfPNTAEBwIrKkc84D3QbaRX+S
         s6elROeZE1WhBlrm3S9EWxLe/iL/C21pcz1zuTI1j7TtudAlGKyhpzFeHVwo3mH38yvP
         Um1uLk33gi2zHd4+U6iZD6uAKucYhr6NdGLeqXXcMJJzNQCNOcCSrbanZlrgx9l4GMRa
         PFVdtwjSLEdsgj6D/uvLm6PuszlQ5lxXegxkgAtrq4Sa6oV0NAIneFx9KzzyCzYDuxm9
         HMZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukeSHSoOdwlVlt80sPmbeEcytToudxlXocMuMOxpqvSKlrH+qq3N
	EqARTMyCpLXtMdiBIz+5vbF0qYfivCJIiFjA1EX9SgXL8u2vsU4Acw/oRIx2AsCwWE0IDQLzxUe
	oicguCxIh2rXaFZEe8R5WV6GgM40Mzf62VwsbdbwfTWn50C1xqQyr1fKI0ysgWn+wdw==
X-Received: by 2002:a62:8893:: with SMTP id l141mr6438719pfd.1.1547050153129;
        Wed, 09 Jan 2019 08:09:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN73d41SsF3pHUIVbGvgQwRe137KVuBTrnpMvS3vnsHFWC5TWsBYnxIED/ASznRoyNILUnKi
X-Received: by 2002:a62:8893:: with SMTP id l141mr6438657pfd.1.1547050152364;
        Wed, 09 Jan 2019 08:09:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547050152; cv=none;
        d=google.com; s=arc-20160816;
        b=L8MzrNTxPNbexYYu5fJ0waMH//UoZegVSYkgvP4rbAB4ms0CceOPsp8nEHLPm9aJOe
         zafYcDz5XrJxAs6162PgUPN2sw95bdzJgzFYPEemKe0iEMOBrFcJDvAPhJf3sGk68X5J
         vA2n9KHIEzofEfsxzVPha2tlxz1JbLevTeXJ5gJwzpWjR1GYHzXw4i+GKgWTmyJIZQi7
         DCK6gNSFs88B9UKDOajsNJZ3lmn2AuWGKqHaONUYGIr+3ySBDbj12NhnOotJafCc0w6v
         77x3T2S5XN53fsXmlcrbaA+s96H7Na5lZdo7V37n/Lu7Z2pH9X0dpN4X8E4DvaQMIBPp
         9oqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=EE/0BkdGGAB6magwhJ8ugQ7KDd8Q/T2tsYZKliX9xAg=;
        b=O1/BniC/EOwtMme/7htBHeLxleEfRRj5slwtl+T8HqgnmCSPmAlg7NybgHXFFniRQQ
         r/xjCEmXQ1ZN/Lip2Z64Rha12XFbqrM+ezP4Bgn9REJW+gl6wRQDTaPlNubSuQf87oQ0
         qMdSToa03U0C6w/wk3q6zWodI8Aeo3HTqqnkoXT9T1yRGi5Q9CwCS5+lf+UkErWi0kdz
         +Z7xthFmDNSURnOuCBUStYYCKZlhgNfXsjeN19jsgaU22Cazam8JGg6fScwzMnfzABye
         RtvkEabkRzxh28xWdYBO/U+c5opQnCx1QjFFk/c51j8SoH+ydXK3Vb/ViEVFBKgDJDMt
         jtzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 101si71045016pld.22.2019.01.09.08.09.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 08:09:12 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Jan 2019 08:09:11 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,458,1539673200"; 
   d="scan'208";a="116778211"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga003.jf.intel.com with ESMTP; 09 Jan 2019 08:09:11 -0800
Message-ID: <fa89d216da811e97428ad155770bcca5eddecc37.camel@linux.intel.com>
Subject: Re: [PATCH v7] mm/page_alloc.c: memory_hotplug: free pages as
 higher order
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Arun KS <arunks@codeaurora.org>
Cc: arunks.linux@gmail.com, akpm@linux-foundation.org, mhocko@kernel.org, 
	vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, getarunks@gmail.com
Date: Wed, 09 Jan 2019 08:09:11 -0800
In-Reply-To: <fdc656df7c54819f60d9a1682c84b14f@codeaurora.org>
References: <1546578076-31716-1-git-send-email-arunks@codeaurora.org>
	 <7c81c8bc741819e87e9a2a39a8b1b6d2f8d3423a.camel@linux.intel.com>
	 <fdc656df7c54819f60d9a1682c84b14f@codeaurora.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109160911.JoKS2RXnecutMJzbly8Fld0TbBNz8_mTfmXHk7zj4B4@z>

On Wed, 2019-01-09 at 11:51 +0530, Arun KS wrote:
> On 2019-01-09 03:47, Alexander Duyck wrote:
> > On Fri, 2019-01-04 at 10:31 +0530, Arun KS wrote:
> > > When freeing pages are done with higher order, time spent on 
> > > coalescing
> > > pages by buddy allocator can be reduced.  With section size of 256MB, 
> > > hot
> > > add latency of a single section shows improvement from 50-60 ms to 
> > > less
> > > than 1 ms, hence improving the hot add latency by 60 times.  Modify
> > > external providers of online callback to align with the change.
> > > 
> > > Signed-off-by: Arun KS <arunks@codeaurora.org>
> > > Acked-by: Michal Hocko <mhocko@suse.com>
> > > Reviewed-by: Oscar Salvador <osalvador@suse.de>
> > 
> > Sorry, ended up encountering a couple more things that have me a bit
> > confused.
> > 
> > [...]
> > 
> > > diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
> > > index 5301fef..211f3fe 100644
> > > --- a/drivers/hv/hv_balloon.c
> > > +++ b/drivers/hv/hv_balloon.c
> > > @@ -771,7 +771,7 @@ static void hv_mem_hot_add(unsigned long start, 
> > > unsigned long size,
> > >  	}
> > >  }
> > > 
> > > -static void hv_online_page(struct page *pg)
> > > +static int hv_online_page(struct page *pg, unsigned int order)
> > >  {
> > >  	struct hv_hotadd_state *has;
> > >  	unsigned long flags;
> > > @@ -783,10 +783,12 @@ static void hv_online_page(struct page *pg)
> > >  		if ((pfn < has->start_pfn) || (pfn >= has->end_pfn))
> > >  			continue;
> > > 
> > > -		hv_page_online_one(has, pg);
> > > +		hv_bring_pgs_online(has, pfn, (1UL << order));
> > >  		break;
> > >  	}
> > >  	spin_unlock_irqrestore(&dm_device.ha_lock, flags);
> > > +
> > > +	return 0;
> > >  }
> > > 
> > >  static int pfn_covered(unsigned long start_pfn, unsigned long 
> > > pfn_cnt)
> > 
> > So the question I have is why was a return value added to these
> > functions? They were previously void types and now they are int. What
> > is the return value expected other than 0?
> 
> Earlier with returning a void there was now way for an arch code to 
> denying onlining of this particular page. By using an int as return 
> type, we can implement this. In one of the boards I was using, there are 
> some pages which should not be onlined because they are used for other 
> purposes(like secure trust zone or hypervisor).

So where is the code using that? I don't see any functions in the
kernel that are returning anything other than 0. Maybe you should hold
off on changing the return type and make that a separate patch to be
enabled when you add the new functions that can return non-zero values.

That way if someone wants to backport this they are just getting the
bits needed to enable the improved hot-plug times without adding the
extra overhead for changing the return type.


