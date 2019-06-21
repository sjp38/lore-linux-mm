Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFEFDC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:44:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 906D0208C3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:44:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="B//niuCs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 906D0208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27BAB8E0003; Fri, 21 Jun 2019 08:44:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22B8D8E0002; Fri, 21 Jun 2019 08:44:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F3A28E0003; Fri, 21 Jun 2019 08:44:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B322C8E0002
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:44:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o13so9087023edt.4
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 05:44:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=OqVBZEPWFSP/e9s0tB0Ipt3Dw5LvuQwd4dI9ko39cRU=;
        b=bbaFOVwA9Njp/kWqQoFKOIBNlqQ5PHtdVqjLe886tRr/jIrqIe89ZzvfHp7wRh75O4
         WCHOPAKzGF+MJ/rdcDuyoPkU0WJGfb22y8Z4iiwGiI/YR7is0DMTeTgP7Lcr46Kr4gra
         usiqigoT1+dqsFZXX/BK/eV0Oq9ctW2Ggu7mRW371NrAYS0I/Gnj+MiosTXVFsXK+3eg
         rSJjjrPoIIJ9y6RIRQsG93JOvtdcXO93cluLvWP/Y6yd25yqZY/jbCd4YrWjRpqmRG4q
         DmfqHjYmAmmaGqH2cT+ESYVdgvsizSUqZjdSrzgo6cpMD3oQSDlS8yaAmq46cbxQjdOT
         oVJg==
X-Gm-Message-State: APjAAAXHPdYJwxlccdLOl2yfKKW6IadFnM1yggUMWQg1fV4pQ0UVdGUJ
	IRrdppxkozwoVZekHRtgE0UOHTT56oENMQT1X23Rlq1b3D1H1f9HjUe+Vfe1zl0h/NdrgZKiWRa
	UgeOw1j2wpo0cZq/rjpRq1qPiK+wKnMGOXPq/O+Tpzj6sAsEfpDP8ZPhpgtmlmDnieA==
X-Received: by 2002:a17:907:20db:: with SMTP id qq27mr96184115ejb.30.1561121043283;
        Fri, 21 Jun 2019 05:44:03 -0700 (PDT)
X-Received: by 2002:a17:907:20db:: with SMTP id qq27mr96184039ejb.30.1561121042119;
        Fri, 21 Jun 2019 05:44:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561121042; cv=none;
        d=google.com; s=arc-20160816;
        b=SMwyIiJzep90Ow43AzoqekLPMt3o/n8gjFBy3914bq9HpnSLHoaI0QHUqrTw7VLpOR
         hwfbyjwAp9Sfw3HYhlWyq95ZrdXH+6NzB+AmCgH0xoEh3eUzo6QTwg9rqNb+ZMACVes6
         zM+FRHvxhAIzBQr0OcV+WRm3SkZnt2vn167+AFGmosuDiVBHDqpttKrfoYmMtHgZ6CT1
         YqFDBYbaBOPyenoBigsE8aytnQRm60XSEwsIMjieVGrnep6srLviCo5khasxTIvGIC9+
         cVzi9ZYig8+aPBp1mIpZAvppLkJz2HkbcReUFP4tpnyC8ucoqY1lxRDtlYl0DXCUCGOW
         rqQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=OqVBZEPWFSP/e9s0tB0Ipt3Dw5LvuQwd4dI9ko39cRU=;
        b=ttwh5Q4L/6HsVfBBMguiVzudkzunJYcOBaGqswdWef652vSEkX9Gx3yT9e9Q275E4d
         CuSPD7wmzhl9tgRKQNPHJB5dtmTJ1YRXV2pOnLDGZCKgx9QZNzeCQaO/vS7A1oLohq3x
         HnzruORiSfBy+GR/wRJZ4A1dB9JUWyHD3GaN9kN76bl7xLnbtlHcbRl0w6EOgroL7gkN
         KDNnBAhwjpV/sq0qSmeIy/QOPimJHldWbZ4Ha92rjKkQinu2tufuxvxrCxvLc8uDcIdf
         GKFq9FNnComDTiKHs3kVNo6iGUMlaw2oe7ZMrszPtuV8EBNT9+SWugMgopk36nrBcAx8
         xGZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="B//niuCs";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y7sor2759381edd.25.2019.06.21.05.44.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 05:44:02 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="B//niuCs";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=OqVBZEPWFSP/e9s0tB0Ipt3Dw5LvuQwd4dI9ko39cRU=;
        b=B//niuCskz8qf17kB7Iq3o6K45T58/nDnBXWjN/lMtJrjgnyfvaL2a31L14a+fI2p+
         5ChVYoeC82xkf1EHe2lYG+Bl/oyGAgO54WMGewBL1psB3FSD5b4tl9tMsxcoRW/6yIER
         kmTdftp73gm5VP9cZaPDBdc/oUezHnco0r2TCH3bNn9B4PABUavvKWsX4RiyWBruSJHq
         vNjuu5eDcmFQEIdQg3r+0jA131TpF6fLOoWd8ebt6ejVko6orgnK4PaS0pbVmtU+IYzJ
         0OTl/a1Z596ofyzBk40B7tabxY4eKlGFQ0oZKKaAGrKElE9YTyiRHv9JT9lrewUYCXlp
         CJ/w==
X-Google-Smtp-Source: APXvYqyuPh8UjXLvvCCKNbaorIU7bGuaPuVf4C/aLJivx/vVf6Ln9WpleDFHzTJZF8WmtQPEuHB/lw==
X-Received: by 2002:a50:ec03:: with SMTP id g3mr84559343edr.233.1561121041750;
        Fri, 21 Jun 2019 05:44:01 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id i21sm404358ejc.79.2019.06.21.05.44.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 05:44:00 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id CF12B10289C; Fri, 21 Jun 2019 15:44:02 +0300 (+03)
Date: Fri, 21 Jun 2019 15:44:02 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, oleg@redhat.com,
	rostedt@goodmis.org, mhiramat@kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com
Subject: Re: [PATCH v4 3/5] mm, thp: introduce FOLL_SPLIT_PMD
Message-ID: <20190621124402.z4l67ck4vr5g7xe3@box>
References: <20190613175747.1964753-1-songliubraving@fb.com>
 <20190613175747.1964753-4-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613175747.1964753-4-songliubraving@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 10:57:45AM -0700, Song Liu wrote:
> @@ -419,6 +419,11 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
>  			put_page(page);
>  			if (pmd_none(*pmd))
>  				return no_page_table(vma, flags);
> +		} else {  /* flags & FOLL_SPLIT_PMD */
> +			spin_unlock(ptl);
> +			ret = 0;
> +			split_huge_pmd(vma, pmd, address);
> +			pte_alloc(mm, pmd);

pte_alloc() can fail and the failure should be propogated to the caller.

-- 
 Kirill A. Shutemov

