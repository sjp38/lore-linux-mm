Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08287C76196
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 08:29:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AADB82199C
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 08:29:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AADB82199C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=8bytes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 164596B0003; Mon, 22 Jul 2019 04:29:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 138EA6B0006; Mon, 22 Jul 2019 04:29:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0286E8E0001; Mon, 22 Jul 2019 04:29:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCE656B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 04:29:16 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so25870640eda.3
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 01:29:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zZz6TeDXPa+u9HvDVyHuWp6VuS0vZz3kGeur43JMqYU=;
        b=SVaLrhNkjMwbou+82KxiiSe8KFnGKZF3ymnJGjwZiegEwRrHLr10FbOaa9tHdqi33b
         A3xXiZPDKujPFPI9dDH30gx1KzdKvg2q8w0UWADLd4TTQBLXYToOGsTOOjCeKHlG/O9R
         NF20a7AB/cE3uiiimorNpkvYM7W5z6bWckT2ROOX/6T87Yy2g15knAxuPaLjSG4A+hFX
         R1O0ePRlrR/dTU+tPTMdYaLie+IfxN7e99Cqlq4NS1uWbvGeBj7J/IWUIQoX1HZGe+N9
         iqeFzN6cVpus9T+RXtCV+n34QwA7sWdrgeksuzgbwDZ0FZx9QPJxByKmimbDgc18F51d
         9G6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
X-Gm-Message-State: APjAAAUjwrKwpZqgLwgxFn/CtwGqv1XWq+In1ZP4YgTucWCIdKP65qes
	5Gdue3/L5xa/gFt4hII9Il15X9DvBzcaQDeXNeBggZ04ww4K+NHqL/jb5qh/RNHuB+1csT9px7r
	F3eHKWmtjuDsOroayHgFenRNQylc/eL3p2WY7+h6q6bp5cuDWMlanCqrfoVGijW0N7w==
X-Received: by 2002:a50:97c8:: with SMTP id f8mr58944410edb.176.1563784156369;
        Mon, 22 Jul 2019 01:29:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTR+NNAuE48tViQU5J0rh+GUvaa/Foyac7L3b5FS9lsgBTE04UmjT+JLb0BAnFuNrR364E
X-Received: by 2002:a50:97c8:: with SMTP id f8mr58944390edb.176.1563784155813;
        Mon, 22 Jul 2019 01:29:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563784155; cv=none;
        d=google.com; s=arc-20160816;
        b=lpHdg9UJmFG1yUNWKvqi8l/00Wy+J4mrMQE8LfPImGN0qRpgomEjf6VGOGqaifzDH7
         eAc0FjmiuvkcJu1SzhNUfrYm1L0ja5jpBPE6rj8kMDgPgva3kGxy4Vsa3GPFjkyyFENV
         clqjynGcG+xm8cpIMtywBPRBfAVxrZGNBSMr3xZJrL5gnNTcc+5uGLPrutHNuNN0Holf
         tGfuxEthT5ncNkHlt3qDjDYE/laxVtntWRxz4es4P5EDUexkOAUeCAUUNBxcfKqfJg5R
         x46GzzUcEP4JB/ZdSi9pUQi+9eVRLHSKDsmapchnRnDgVx22ntnDGMS8x1si7cz1n3dz
         qr5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zZz6TeDXPa+u9HvDVyHuWp6VuS0vZz3kGeur43JMqYU=;
        b=qW4sSap+gdsRneX0sI9IZm791fEQb72EjlbSwqr8yYFrmzDhYJBkL00DzAv1K2tf64
         riWDIGC6iBZZ0JCZvUydjy8bxHMNCYPS7YKQGVBngvdtSvyvb0+YyCZahHLITHQ06K9z
         tRzTO6R84D6HpsdfGszpp8jiVrF7FbtxQgBEZo0G3ji9GZXdD/HlSbsl7hTkwgLsMp23
         M89kJ6olEbe7ORVi85Ei/dShNQSBqr93JpYD9HLCbow4seGKUvaYnoPyYC3e0V4WgLk6
         sOaQt3FEJe5D3Fmy2cToCnv7gNABt40mzNowI7Ff72sxEDqr+MP9zFrdkTda2HptGB3w
         +ssg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id c5si3614264ejz.322.2019.07.22.01.29.15
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 01:29:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) client-ip=81.169.241.247;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: by theia.8bytes.org (Postfix, from userid 1000)
	id DA7572A9; Mon, 22 Jul 2019 10:29:14 +0200 (CEST)
Date: Mon, 22 Jul 2019 10:29:14 +0200
From: Joerg Roedel <joro@8bytes.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Joerg Roedel <jroedel@suse.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 3/3] mm/vmalloc: Sync unmappings in vunmap_page_range()
Message-ID: <20190722082914.GA1524@8bytes.org>
References: <20190719184652.11391-1-joro@8bytes.org>
 <20190719184652.11391-4-joro@8bytes.org>
 <20190722081115.GH19068@suse.de>
 <alpine.DEB.2.21.1907221018460.1782@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1907221018460.1782@nanos.tec.linutronix.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 10:19:32AM +0200, Thomas Gleixner wrote:
> On Mon, 22 Jul 2019, Joerg Roedel wrote:
> 
> > Srewed up the subject :(, it needs to be
> 
> Un-Srewed it :)

Thanks a lot :)

