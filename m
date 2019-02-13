Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D496EC282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:28:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 968F120811
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:28:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="uGndb9Pr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 968F120811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 174C58E0002; Wed, 13 Feb 2019 08:28:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FD378E0001; Wed, 13 Feb 2019 08:28:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE3448E0002; Wed, 13 Feb 2019 08:28:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A67078E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:28:06 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id b1so1682152plr.21
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:28:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lmiH+RHVhxB+obP/+7+ZvQfxCISotDUjH4WduRSJgp4=;
        b=S/0tkE13yhuzR4IDH/A+CgAhD2GXBWsyagr1jrepCtiOmQDpQoG9LUGniacYT+oHKn
         vzl46GXQiA4VXyAgnuFBrNW1LE/PAznLk0pGjxYkbIFyFt4XRhmCcemnFUmDcatKfd9E
         5O1MBf5cFtr61vgyfWH+fDhrdTb80LEXkjgYxOxzYiemd0+oTygKohHmr2EE6kL6a7jI
         U2b/ITyDY2Lp95bwqIS+cBNdextPUkZXH+EN+dQXm818xOFhlfBtYHv76SXzMijzq19r
         VgOfH5YSaSn1kFenOFF9OBxbBYBAN6SQO+kwZH23DffTsrmHT4zue0qorFYdQRJzuHmP
         vOCg==
X-Gm-Message-State: AHQUAubCZo0DXU1FW49PtHk/CIFRfMJT1ylnw6wFB0ne8qsJjnsPneyn
	GEHBhKkslJpeBJejvf2PPdBw9iDGorINQBADO74qxvQuAV6Ec4UXoJUhQ3hBcSsHLEOQHOOaaUa
	POp8DywtD2qntM6nhur2x4lKDTHP7U3bIbmdsaiYsEXLsh73Ce308ZV+1eI1M6cjDsHUE4QV02Y
	gzjeoacal9ELztbn5hH7aB7tfM6GKw3eB8zORNzvXVwdmd6qVzQQ7EeyfAndMN7LknO9AalltML
	9XCSAY6HYTR/JZkvnk/vL2y8Ri1rUb+3ZQFVYwgczdfFeHJGhoeuleKYioigbtjPsvQBV/2RE3T
	A1XLcTsmGMAF+0GMYM+pa3b+2itGIxz5mi3jFqo/JfevCePPEla9Zt//d65fCoDXjMTKzYKV/z0
	7
X-Received: by 2002:a63:4665:: with SMTP id v37mr454916pgk.425.1550064486361;
        Wed, 13 Feb 2019 05:28:06 -0800 (PST)
X-Received: by 2002:a63:4665:: with SMTP id v37mr454858pgk.425.1550064485623;
        Wed, 13 Feb 2019 05:28:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550064485; cv=none;
        d=google.com; s=arc-20160816;
        b=0kb4SaqlUVK4bf79dy9NlIUatJEF+GIWqY+1p+9pEJgTsUnwo0+UHwQ2L7/9mzAj5+
         d2XmGrVDIbng83Gmn8+8WCburDjC1qmFvs78NBKOAKP5m7U/LXiYcAyjAw1lzywRanWk
         eEWalhelB2ilQD3idbX/mzpdOHzCheuT/fKc0ctnv55JTwNfOQk6BhegObxMzap5xoNx
         8RvJkuoVNkGW5A2taDga1j9EDu32NEPXugMTQg8utuuBw8KtDtpCI67o7C07+p0N+5dp
         e+ruY842KYterSSnHBM/wIThwNq5t5vkkPrEEe8sOFcdfi7ekT5fCDq7mfdQ5IroJQZq
         so5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lmiH+RHVhxB+obP/+7+ZvQfxCISotDUjH4WduRSJgp4=;
        b=dfe61d7r7AWHNJa/+F3PHBaX43hR2fEGzOxP/mvXqMrZehgENXYYolCqCk2S80tWTS
         4D1hDJUU60+NOOq2TpjfOjKe6ZNVFtJZGUgleQUQlUCivpimcb98+/D8twfrBf3SAz6A
         C2BwrSMJkUAnu2ZnPjOqTIDEhJpP+lYdzfBK/MChmT1YKbXIQhKVY+tmQgRlLcyu+Zb+
         BN6ybbYMKovUGPpr7Z72MfkwV6spo/EpW/eEe2HaGgzibiZN6wkrUgNbA/jphth6GweJ
         de9VZ9Vf/9cYNh94OFJsJibKwbXPTxZqoxUxVNbvr5xbIoiiQ9+r7sAIk9nRV0IpMSKE
         W/Aw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=uGndb9Pr;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l15sor1183316pfi.1.2019.02.13.05.28.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:28:05 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=uGndb9Pr;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=lmiH+RHVhxB+obP/+7+ZvQfxCISotDUjH4WduRSJgp4=;
        b=uGndb9PrlFKPp128sjUuhzeQyXtHaBhX0QhQf99IU33dON5iEdRbB9ViezpinCL2VJ
         /6I8J7auazuseYQKJDf/qCA0DkL9uvW6RQB2p/y7iTJw2GpVRL3UsPfsY4IrHrjBo9Yn
         4XoqHSEWtPOUgMSi1Suvq3pVQGfzdHFogA3paVkc23twhG1Rq9X0CrsUlN7pyL401YpT
         v+x9n6HfqPifh2XCOGm3ZFtr/9g3voB3r62Czp+eS5UN/RZFwkFtWA3pl5YAXiJU8GUf
         rS2OQJVLVNmHVrUzFiNZerpcAHKMFMyu9NivttsJDqxFkVes58+YmzHUgEaPP5WOIVk5
         DMgw==
X-Google-Smtp-Source: AHgI3IYYNPzlTxNjPzRht3OcT4ya72upkHab0DSJv1opzlibqWdDm5S4f71312mBCIr9J+FN5YDErQ==
X-Received: by 2002:a62:5003:: with SMTP id e3mr536528pfb.23.1550064484753;
        Wed, 13 Feb 2019 05:28:04 -0800 (PST)
Received: from kshutemo-mobl1.localdomain (fmdmzpr03-ext.fm.intel.com. [192.55.54.38])
        by smtp.gmail.com with ESMTPSA id 10sm32945751pfq.146.2019.02.13.05.28.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:28:03 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 4790B3002B2; Wed, 13 Feb 2019 16:28:00 +0300 (+03)
Date: Wed, 13 Feb 2019 16:28:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	lsf-pc@lists.linux-foundation.org,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [LSF/MM TOPIC] Non standard size THP
Message-ID: <20190213132800.dekg525rhrjn3cmj@kshutemo-mobl1>
References: <dcb0b2cf-ba5c-e6ef-0b05-c6006227b6a9@arm.com>
 <20190212083331.dtch7xubjxlmz5tf@kshutemo-mobl1>
 <20190213130647.GQ12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213130647.GQ12668@bombadil.infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 05:06:47AM -0800, Matthew Wilcox wrote:
> On Tue, Feb 12, 2019 at 11:33:31AM +0300, Kirill A. Shutemov wrote:
> > To consider it seriously we need to understand what it means for
> > split_huge_p?d()/split_huge_page()? How khugepaged will deal with this?
> > 
> > In particular, I'm worry to expose (to user or CPU) page table state in
> > the middle of conversion (huge->small or small->huge). Handling this on
> > page table level provides a level atomicity that you will not have.
> 
> We could do an RCU-style trick where (eg) for merging 16 consecutive
> entries together, we allocate a new PTE leaf, take the mmap_sem for write,
> copy the page table over, update the new entries, then put the new leaf
> into the PMD level.  Then iterate over the old PTE leaf again, and set
> any dirty bits in the new leaf which were set during the race window.
> 
> Does that cover all the problems?

Probably, but it will kill scalability. Taking mmap_sem for write to
handle page fault or MADV_DONTNEED will not make anybody happy.

-- 
 Kirill A. Shutemov

