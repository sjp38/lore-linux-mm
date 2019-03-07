Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42312C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 00:40:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03EEA206DD
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 00:40:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03EEA206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codewreck.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A88A08E0003; Wed,  6 Mar 2019 19:40:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A37A68E0002; Wed,  6 Mar 2019 19:40:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 926D68E0003; Wed,  6 Mar 2019 19:40:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB1D8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 19:40:53 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id j16so7874394wrp.4
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 16:40:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XCmbGIXK9VORoIc+UM5FEN48dSgza63HkuNymhdproE=;
        b=WW4WDICeMDwUChzBqQxxyxih8aVq3P7OGNrlgtjsUwlUreotGPwbE367u5lveG9V1B
         UF5L80H4areXivb5FnK7OKQWlA5DtLWE+rop5kycG20MkYEGefdTnCilkoreR3FkPLoz
         FRX8Xlo+1jjwbZurxxJXqIaOdibvipf9NJVmLV3bH8jyv/i0a4WEKFGbEJwVFXAmWOfj
         Vug0KhyDk9n7QQJcucXnrTMixuzt8si/aWVT2VTWw9HCtpw+lKTP0cwQuKjIgLNcw5MF
         w25rLf3jzB5z87M6kA61ZcZcranCA5gSlfpP8LnRZ56apCH1ZUT8hhnYxfHL9vYPUSA6
         r3Ww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of asmadeus@notk.org designates 91.121.71.147 as permitted sender) smtp.mailfrom=asmadeus@notk.org
X-Gm-Message-State: APjAAAXQGKJyLd+Bbd6Q3amCsbVR0jjT7nFh5Jln/9k5pvDYN8fFNTPn
	WCA3IzZGODhvIDggLalqXsnt5/93E5P7wYR8k6+wbsx+eriUDuNF6XJOMBEFKESgWf9gIHBlKZ8
	1qYLjszQ0AmQplciT7hq+oYYg2AS2ZWdf4LPJxf+PmEfCybcPeRJ5oh5/XQB7IuI=
X-Received: by 2002:adf:dd10:: with SMTP id a16mr4578914wrm.37.1551919252858;
        Wed, 06 Mar 2019 16:40:52 -0800 (PST)
X-Google-Smtp-Source: APXvYqyagTgXdJ3+RolcOPCPzisj3uyTnCIYewyQZ2556YwUSxeSxs5k9sThKFWIQE5B+XzKX/LL
X-Received: by 2002:adf:dd10:: with SMTP id a16mr4578886wrm.37.1551919252134;
        Wed, 06 Mar 2019 16:40:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551919252; cv=none;
        d=google.com; s=arc-20160816;
        b=Fd0GPDtIJWV21w+5w6bFdRDvK6yyClb+OrN+bXCwvlmT+pi4Mm1ig5RvFHRMS5DJ+v
         n5OREXEP2q9KysN2RN6al26+1EPbjEOMhWswkagsACRnc76uTFCvMEjAKCCIOgSpu98y
         ftIqHLAkUCZPun9AaXX8x41h17R45Vxg1/pkJcAYiQfDq4ba5qXKnYkzhJXmnRmekFHm
         agSGlijm10BfqqPA0oO/s7BB21WXQ6sxh8QH/ex+s2RBgCkLzgEI233npVmt719K+Sk4
         UHvkT3dweob+15DDLUDpIzaP9lDZcciQ2IxXVHLZ7LpTvS+pbQ4OpZMM6hwPO1JluSGr
         oLdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XCmbGIXK9VORoIc+UM5FEN48dSgza63HkuNymhdproE=;
        b=L5YbhyVae6/O8nf9KbfDMzwwwNlv0WSXhAzFxRN5h9W0ANyPJBtHdsg/qQWyuCJGM2
         xj4ZbER4YF/IwwHHMfvYvKW5XUuLvijAYdiPhzlxYMiikFUJmtf3Qz4IyVm16ItqoN0P
         t5UVA7oTF5TxC0V1kVV06nOHTfb9XLRjGzWmZ4+2cudKzzkeOswJog83Ow27+MS0kngR
         1WCPc0DRObX3GpTNd1iDGmiLpAOG1hgDoVwQS/fwkEc2OMQkT5IlApywakDeSZpSKTEU
         MYPbYYM6rMsVW6LbpJXfuwufREn9mBSzTdJBePATluvyDJZcrqgOGeOIAAhKzVLiUjdb
         gnAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of asmadeus@notk.org designates 91.121.71.147 as permitted sender) smtp.mailfrom=asmadeus@notk.org
Received: from nautica.notk.org (nautica.notk.org. [91.121.71.147])
        by mx.google.com with ESMTPS id o3si2077402wmc.180.2019.03.06.16.40.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 16:40:52 -0800 (PST)
Received-SPF: pass (google.com: domain of asmadeus@notk.org designates 91.121.71.147 as permitted sender) client-ip=91.121.71.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of asmadeus@notk.org designates 91.121.71.147 as permitted sender) smtp.mailfrom=asmadeus@notk.org
Received: by nautica.notk.org (Postfix, from userid 1001)
	id A4A33C009; Thu,  7 Mar 2019 01:40:51 +0100 (CET)
Date: Thu, 7 Mar 2019 01:40:36 +0100
From: Dominique Martinet <asmadeus@codewreck.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Chinner <david@fromorbit.com>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>
Subject: Re: [PATCH 1/3] mm/mincore: make mincore() more conservative
Message-ID: <20190307004036.GA16785@nautica>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
 <20190130124420.1834-2-vbabka@suse.cz>
 <20190306151351.f8ae1acae51ccad1a3537284@linux-foundation.org>
 <nycvar.YFH.7.76.1903070047360.19912@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1903070047360.19912@cbobk.fhfr.pm>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Jiri Kosina wrote on Thu, Mar 07, 2019:
> > I'm not sure this is correct in all cases.   If
> > 
> > 	addr = 4095
> > 	vma->vm_end = 4096
> > 	pages = 1000
> > 
> > then `end' is 4096 and `(end - addr) << PAGE_SHIFT' is zero, but it
> > should have been 1.
> 
> Good catch! It should rather be something like
> 
> 	unsigned long pages = (end >> PAGE_SHIFT) - (addr >> PAGE_SHIFT);

That would be 0 for addr = 0 and vma->vm_end = 1; I assume we would
still want to count that as one page.
I'm not too familiar with this area of the code, but I think there's a
handy macro we can use for this, perhaps
  DIV_ROUND_UP(end - addr, PAGE_SIZE) ?

kernel/kexec_core.c has defined PAGE_COUNT() which seems more
appropriate but I do not see a global equivalent
#define PAGE_COUNT(x) (((x) + PAGE_SIZE - 1) >> PAGE_SHIFT)

-- 
Dominique

