Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28DB4C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 12:11:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D79D720651
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 12:11:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="kG4XT2lK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D79D720651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E36B6B0003; Mon, 12 Aug 2019 08:11:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 694F76B0005; Mon, 12 Aug 2019 08:11:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 583246B0006; Mon, 12 Aug 2019 08:11:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0209.hostedemail.com [216.40.44.209])
	by kanga.kvack.org (Postfix) with ESMTP id 316B96B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 08:11:48 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id CE83B180AD7C1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 12:11:47 +0000 (UTC)
X-FDA: 75813661854.11.toad12_84099dbd7ee36
X-HE-Tag: toad12_84099dbd7ee36
X-Filterd-Recvd-Size: 3921
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 12:11:47 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id h13so621009edq.10
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 05:11:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=hujPz5MzKCPbinmOqr53v4vBoAK56yuLqnChSDEz9qA=;
        b=kG4XT2lKey+4eCUsbMw608+JUTWj1lxYAaeWUpvWhAU4mfmvKO1+mJ2RbJ/TTwzVWz
         EosPGa6L2PH3pvSfpx2JB3jPONr6bQWPR8QPHlKo7gBcN5HJgvlFlZkahclBPmY5SPza
         u9cvzhY3lYXcLrHIpUBRonwmDzBcOdQxD8gYB019tPz4aEzzNpPnkmP9BbhoChr5mPzG
         Qb+3Y9e3MgNaPVnkEkafCYsctwGpOnfIdg90xtn6RsEvJbL5V5x/iyZa/eWrEg7UY7Cl
         b44oBsJHgNUel8LwWzX1ouV8n4wDh8pr89cI5bGwPB29mD6ThSDApXkIpV5tWesvpRxj
         YZFQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=hujPz5MzKCPbinmOqr53v4vBoAK56yuLqnChSDEz9qA=;
        b=YvZX89MGJMcN7FtMGplV9E9uqBAC+mQkY10X/RLsBYpYTOmOa2qjaSiX27zAvcK8Ck
         +4FzdhK/pE2dw7HNMTsA1Q7x205p784F5q7xgMKf5sYwl5iE39qbF/d3TOto8kRM5xEf
         a2TLIJZRFzUQtaJmBExMthJaARjAikkJbj9rGHyvY35Iq7VyGNGHMVIphDmXgja5hlpH
         c4KnyDisWNCQ8fXMrRxXLmsqhlvNw7tepXMkyqcTW9WDAveOAP1doax4Tb100Sxf2YkQ
         JIC133lyAbK1gkHXILvs+PWQ60ceRs+uZpT7U8JgxyryCJoF7+Y3d/t0FthNJsWdS9Lv
         G+oQ==
X-Gm-Message-State: APjAAAVtfVYBFqEmRdopFJCNcR7Bo2oJ9+uHoYvkJoEMHbmWe0oUPwsO
	+/htI1c7A/fHb1BZ48ugK7yLLw==
X-Google-Smtp-Source: APXvYqwghgOTyS9rkCUVPgJV5+8qxWl9q0SIGpjg1BJW8yOQj7jdU3JnAfDL4hy0NKzKdkKqkGV/sw==
X-Received: by 2002:a17:906:e088:: with SMTP id gh8mr6556500ejb.117.1565611905926;
        Mon, 12 Aug 2019 05:11:45 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id x11sm17492035eju.26.2019.08.12.05.11.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Aug 2019 05:11:45 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id DC616100854; Mon, 12 Aug 2019 15:11:44 +0300 (+03)
Date: Mon, 12 Aug 2019 15:11:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: Oleg Nesterov <oleg@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <matthew.wilcox@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	"srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Message-ID: <20190812121144.f46abvpg6lvxwwzs@box>
References: <20190807233729.3899352-1-songliubraving@fb.com>
 <20190807233729.3899352-6-songliubraving@fb.com>
 <20190808163303.GB7934@redhat.com>
 <770B3C29-CE8F-4228-8992-3C6E2B5487B6@fb.com>
 <20190809152404.GA21489@redhat.com>
 <3B09235E-5CF7-4982-B8E6-114C52196BE5@fb.com>
 <4D8B8397-5107-456B-91FC-4911F255AE11@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D8B8397-5107-456B-91FC-4911F255AE11@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 06:01:18PM +0000, Song Liu wrote:
> +		if (pte_none(*pte) || !pte_present(*pte))
> +			continue;

You don't need to check both. Present is never none.

-- 
 Kirill A. Shutemov

