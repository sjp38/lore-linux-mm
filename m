Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5559C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 12:36:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FDFB21738
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 12:36:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FDFB21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB9096B000D; Fri,  5 Apr 2019 08:36:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C67D76B0266; Fri,  5 Apr 2019 08:36:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B08C56B0269; Fri,  5 Apr 2019 08:36:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 73F8F6B000D
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 08:36:51 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s22so4129184plq.1
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 05:36:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=X9J+BZCeLM7FNBjPzS9jrmqvvYuyZHO51FULjwaVxxg=;
        b=DrB0YQyX0HJaF96nMCMHyeQr6M3IX39P8JVnws34H51B597wgz9D75woLluSPtureh
         A2w9GV3ary7+D6OlYv9iiMqo2sIC5+spaV3Mq0cUjcVeNbyZWoNtKEQSHWNV2Y1eTs3A
         V7+afVWGwrGSSc+LdoxYsIO/glQ0Rb0YduklxZjNbmywloxggYqWJK9u+r5Z04OP9VHJ
         P6Vtj99TI8L+NNKrkMWbIfv78Ib7x9k8Wr5fEdEFgia6RIdLs2ZbegfF52jZPRrkahob
         KGyepYhDNrKPvqAmr/ese9T1gHG3BtYhaIAJiV098yruIkEzyQudvAYRi//WaNypR1Ef
         dFhg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX6i5AIghLFTm/VCOJMlK4k8w3H38yDan650KCbCZqRCxgdNPKe
	b55ovUpwKWhvwAgWTNt0iZye2w+qNm/fstQxyiiap8kBKW/nxCELlgksxmlGD5pPaZhz5q/SDDU
	qUxnIW8xNp5xp1Pjcw+iHdmakMR3ez++XuPIWvTCCWVylDTv8CDscR9YG1ijKYfEs2Q==
X-Received: by 2002:a17:902:aa5:: with SMTP id 34mr12518015plp.302.1554467810920;
        Fri, 05 Apr 2019 05:36:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUw+AKVpBF8E7bQWNdkGh/ZimGQy/jmMTUevCmAjWtBr/sjMM76xwrCitFwgD082rfYuNo
X-Received: by 2002:a17:902:aa5:: with SMTP id 34mr12517949plp.302.1554467810109;
        Fri, 05 Apr 2019 05:36:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554467810; cv=none;
        d=google.com; s=arc-20160816;
        b=E1jpfK0s3jw3OMWOdqS4sw/vMEi02CqaOfpmBuU6wVRLCHs6uBS3SSHLTrsVUPrQ7M
         OwBMDxZ6VtudTNxnGl1AJQzoRaJJZpamr6RKTKm8L/PpiYk5+YKb72dnLaVwUIAfj/4U
         BowIV+3f2hdc1B2+qgtrNW9gafJ1Ube8/7oE9nsaM5LkzhR3WUPs+w/xDqDa1g4LDmTp
         DIx8EjCowTEKfrOqJMHMHqatnHEgrzw+4XQCm5dhlFIzlgkKsgiwh97JuhWmVwVSPrOL
         ummwQGj7Z9lyg8zZ2I9FxFLOXZZsACNCRUL3zNCZmnOGn3/eQqnfDFCzStXmi32fTib7
         NHIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=X9J+BZCeLM7FNBjPzS9jrmqvvYuyZHO51FULjwaVxxg=;
        b=ni2AAI1YJuuPpPmv7QYosVDJ/kAUPaojGANdD61p5g+wP2urV+RbhM92+j2ido63Ar
         45c2F+I1C3hJmO3zl/4YfLl2Pn6t8IkW5tvT0zQEqf0qJBY5NIHYI9fvmPo/qBvHn4Re
         VCPIcNshkhY8qyt41mxCA2vzkD8S3QYmHpG1p5leAYVuZfNKgkl06htPMDw3IaidFoSg
         x5GXkvrhQLk73j7/docwF9S/KzKS0qWyVueA1SBxiB1cQ1cyhlWpobULi/T4rGinBZFF
         XPI3oGLEecfs+fquSs30iKm4m0JubGBWwSn3psgns9Vgj5rF/djlSRoyGVFE4WndItnD
         Kqsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id c12si15019134plr.19.2019.04.05.05.36.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 05:36:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Apr 2019 05:36:49 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,312,1549958400"; 
   d="scan'208";a="140369549"
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga007.fm.intel.com with ESMTP; 05 Apr 2019 05:36:48 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 2E4B63B7; Fri,  5 Apr 2019 15:36:47 +0300 (EEST)
Date: Fri, 5 Apr 2019 15:36:47 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Huang Shijie <sjhuang@iluvatar.ai>, akpm@linux-foundation.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] mm:rmap: use the pra.mapcount to do the check
Message-ID: <20190405123646.fen7bwaewaaiqlxr@black.fi.intel.com>
References:<20190404054828.2731-1-sjhuang@iluvatar.ai>
 <de5865e2-a9e4-f0f9-f740-f1301679258a@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To:<de5865e2-a9e4-f0f9-f740-f1301679258a@oracle.com>
User-Agent: NeoMutt/20170714-126-deb55f (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 11:08:33PM +0000, Mike Kravetz wrote:
> On 4/3/19 10:48 PM, Huang Shijie wrote:
> > We have the pra.mapcount already, and there is no need to call
> > the page_mapped() which may do some complicated computing
> > for compound page.
> > 
> > Signed-off-by: Huang Shijie <sjhuang@iluvatar.ai>
> 
> This looks good to me.  I had to convince myself that there were no
> issues if we were operating on a sub-page of a compound-page.  However,
> Kirill is the expert here and would know of any subtle issues I may have
> overlooked.

Looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

