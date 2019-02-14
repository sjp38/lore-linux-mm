Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85163C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:41:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35FBA2229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:41:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="xEPmjA7U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35FBA2229F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A91F58E0002; Thu, 14 Feb 2019 17:41:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A40448E0001; Thu, 14 Feb 2019 17:41:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92F778E0002; Thu, 14 Feb 2019 17:41:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 51BE18E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 17:41:21 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h26so5934233pfn.20
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:41:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PIbuAu83tU6MnBvhuGJcfbmbWhFchHhVCd+8U8eEQ4g=;
        b=Yb/nLua6E0mHEdMws/Oajd00QeQvxPmCOaJxy2/fesLJLatXN7PMHjMFaUwGgbYzWV
         CKEVn0u3wi65Y/KWf++62T7a+ff6h1/G4ylJ5Wp/i494qKmBwx07CxAah9eYeSAtkJSz
         J6TBPnJKYcjyMIY1v0YSj/lnnknIiEIbpyuNKr6ApnuAmloNbyRqR2aOHMyha6EDuo9w
         Nm1pXG2Yl22itNlukjmtxupds6LYmC+MUd7706FXrjnawOYGUWF2N0CWyoW0fEaPfFzf
         NNBDNaayFb+YoSBI7pMYRg3CSoKtA4wWPaL60cqRNZ+yUmPudcYCrG59U72SSlTQvlvB
         AzDA==
X-Gm-Message-State: AHQUAuYCHKi/jeGZjT26npoyfwUofdNQnGtuj0LfFXWniJMMdGv6etB+
	X2PxWpksBRYprFsyEd3orwLluokXCc3OmPssh3QexB8ALQnjwilBMBpjOJNXZRViM+uJEKs6MI7
	djBY3lW5gprvJHe4j9cuGMR6hVLuQWKr3a3Mi+AcTP2vlLL1hTWY1lTGQbBIv6gZbT3MXY2UPMc
	sIL65H76kYRp8sS3pSk+tkWiSjM8+VCBWJnE4fhZj/5ePMHccABihhItZUChcJ64Q/z2JEe/ROi
	+QKQ0e7edjhQ6dPXnTcZJqv/41uoIkfppEmWXRUCl+Q2qTg+Nd0Na4SW+tqwpctvr56IvMDg4ba
	Kcz0ErHXYL/q7NIdL9MWYEku7cvpQ6BfC36562DahAnxPAHV3HQATo6dgQDHAaO786qAk8eOczs
	V
X-Received: by 2002:a17:902:f83:: with SMTP id 3mr145978plz.125.1550184080903;
        Thu, 14 Feb 2019 14:41:20 -0800 (PST)
X-Received: by 2002:a17:902:f83:: with SMTP id 3mr145944plz.125.1550184080252;
        Thu, 14 Feb 2019 14:41:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550184080; cv=none;
        d=google.com; s=arc-20160816;
        b=0fSfSfZ+JN6e8ofoDcivESYhmI6leY2k2mxGjD97Ony5aGaLdM5ZCTgFhsZefq4lBX
         l9TmKifz2WC3Uz0ORUBmCjuu/hrq00wpcbo+dwzu9Lm58cA+vSTel6av1GSbvxTSvztT
         r13FhxPZv061FjnPTt3GkzJdkAtGXTX3tHXDjaX0l7hrd5SizoX/LYlCxn+rFMQZD3hn
         kgpeAnHQKl10S9QsHAgaj9+pM2lwxyfZNhVQox3wdniOqmE/BKbUECLNZzZG3omXHxzV
         x7DGgiVgqW+wzvFZ5c/YvOshvVaInoVFAhsaPu9uHG+L9lDYG3oL4k1XJZgQrhP46iK+
         S4tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PIbuAu83tU6MnBvhuGJcfbmbWhFchHhVCd+8U8eEQ4g=;
        b=vUYRGqlEk9qnXUSMyAFPtvAIFUEQaOqNHx6Rcjjb7jK7SjsHedPNOiGRce4r/ZVnYm
         xIkRrV/Bk3UChawAknGgoj/oCCpOuX/edLW/g4sC1Ln0BTUYJl0Ei9nm1Y+1QtEixlvw
         NEhERi1cb5+D8JVjXB+RnqwZKP6haMz5lv+x+3BGFkPB4nJ3LvoWDagbxo7mrgx3kvFr
         x3BVmI5+UnwEwoOU7osuQWj1mk262IcLTRM5rinSP8nXXFLTE5qEnxBFscdj7YQ33XEe
         F+v+rYCpX8R3wtruhTokR5YjLvg9H1A2a7UkXx21Q5hj6p1SXjRs63UlSLunInC0vUY5
         jAdA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=xEPmjA7U;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g13sor5960339pgk.35.2019.02.14.14.41.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 14:41:20 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=xEPmjA7U;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=PIbuAu83tU6MnBvhuGJcfbmbWhFchHhVCd+8U8eEQ4g=;
        b=xEPmjA7Ur5QzxnY9HhmKWp7m+N5ET2X6uJICYKN7XEucCSvCzbZxF/x41NDa6DPxOp
         z2RmqocGPk9l96tUFltKq9ZyYc7eII3va/hoMjNGfG8OcugOfFT/QlFc3YhFx3SOmPFS
         ueNpacTm8PbBaOuJOfuk1srGZpuxqL3QUpMWeh0w5FVGSz5sTC1wuJD+hsV5GGfL0xEa
         5xvWTga/HwNx13PHrF6hGMeo5OoDVC7ZC7QPFUexcjT9BT12or4ZylghiiNPt+fpBhWP
         gUBEu6BJZ3u0AL1Qx2UkKhJA1u7MLdoABEHSmVRf4mog0D+tXiwqTREobiHRhWeUZzTD
         s7kA==
X-Google-Smtp-Source: AHgI3IbBtBc8ecYjxuLAkMM7INBEAgmMEWl4Mr9FMhVLpVQuuO5irj0i9E/fjpQNvqRUQZIPf7zhlg==
X-Received: by 2002:a63:516:: with SMTP id 22mr2159642pgf.353.1550184079904;
        Thu, 14 Feb 2019 14:41:19 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id m68sm10097613pfj.89.2019.02.14.14.41.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 14:41:19 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 899A03008A8; Fri, 15 Feb 2019 01:41:15 +0300 (+03)
Date: Fri, 15 Feb 2019 01:41:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190214224115.4edwl7x72abztajb@kshutemo-mobl1>
References: <20190212183454.26062-1-willy@infradead.org>
 <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 04:30:04PM +0300, Kirill A. Shutemov wrote:
> On Tue, Feb 12, 2019 at 10:34:54AM -0800, Matthew Wilcox wrote:
> > Transparent Huge Pages are currently stored in i_pages as pointers to
> > consecutive subpages.  This patch changes that to storing consecutive
> > pointers to the head page in preparation for storing huge pages more
> > efficiently in i_pages.
> > 
> > Large parts of this are "inspired" by Kirill's patch
> > https://lore.kernel.org/lkml/20170126115819.58875-2-kirill.shutemov@linux.intel.com/
> > 
> > Signed-off-by: Matthew Wilcox <willy@infradead.org>
> 
> I believe I found few missing pieces:
> 
>  - page_cache_delete_batch() will blow up on
> 
> 			VM_BUG_ON_PAGE(page->index + HPAGE_PMD_NR - tail_pages
> 					!= pvec->pages[i]->index, page);
> 
>  - migrate_page_move_mapping() has to be converted too.

  - __delete_from_swap_cache() will blow up on

	VM_BUG_ON_PAGE(entry != page + i, entry);

-- 
 Kirill A. Shutemov

