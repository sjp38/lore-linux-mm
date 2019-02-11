Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98639C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:43:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 587C3218A1
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:43:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 587C3218A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C67778E016D; Mon, 11 Feb 2019 16:43:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C15458E0165; Mon, 11 Feb 2019 16:43:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B044A8E016D; Mon, 11 Feb 2019 16:43:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C74C8E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:43:10 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id g188so291816pgc.22
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:43:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YTDlf2RTH584J6DrNrQ2c7PdqUdHLwVLsz2j2+k9pMs=;
        b=h70THtc21KknxvWBNEnY1OksaZcPUA40N1WOjWPGWDBh17JeX7oZw6baKenOzQOU7t
         CwfVmFUaRYwkUVV7xFA81MIE+znMKGGFDihDTjxHmGVhH2s29L9CLk3XobFdUKKytYIo
         3HDJOjliIUvjHmRKvgLDiGnETFW7w9aS4TFAewQWnmVXzlYH8DmK+HQWEJssjIBZ4XEx
         NStiihk9v+ffTcvCeH1sg9pNSnxIWmGLthxLbRN+Ng9NRek9+YHJUU4UEmnoveLSAd/A
         eymFVBX3kCbuUwzPr8EWiNcum6hI6fu1o8KbRE579ZHDhwMaUlqdZBzoV1WcKZDBiRsc
         rRvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaT8ljTYXxp2MjCenMah/ijRISQhF8DirvOZdK0QjtT6d/GpYi7
	D82JCL+XPhWS9hoVKHR2Y4ha3rgVCJyugT3C8KQ0JQJdWhhDyWk0EwgWKZ0ALmLF7KZgo0p8fTJ
	HwNr2vzoysTd8dZG+jpbzBq3kQjK1aPYY5zcOIwavKLHCTTG0k5M3sbQMjZ7i9L6Ghw==
X-Received: by 2002:a17:902:209:: with SMTP id 9mr389594plc.288.1549921390111;
        Mon, 11 Feb 2019 13:43:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaQ3WSggGz5ploMdyS8yWVtHXc9vw03uob5sEAh5qBr+UX17sB2nc571zIyF2aDVlN2XIxX
X-Received: by 2002:a17:902:209:: with SMTP id 9mr389556plc.288.1549921389493;
        Mon, 11 Feb 2019 13:43:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549921389; cv=none;
        d=google.com; s=arc-20160816;
        b=N1I11O+n34HwlN9nKEQ2APBoxHuVtCtjNVxzCOIKkBGjtRl2lHRXslEaEltDfR6WZk
         dHM4JOqffmY7+m12NOmHBCKWt50BRUZELw/GX80VU+rJ9XB1Y0fNmVBeTNfaIilXWf5Y
         nX3SzZT7klljSMzdkEivHcKkp83jY7sjgN8YXv3MjYLXFwFcj08Ss46XS97pVOx+YJJv
         eITQilNzGfkZVH8VauK6yjw8F4OoNSai1EGtv/AYUry8jaHxxZVLt1tOSFXzCzlfPINR
         BZSOCZ1Jnbo+zOaEcP4Bzbdgz2/Xyn0VHmBCHzLxcEdm5KiORzuHVtWEz/HPrF1fatez
         4DGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YTDlf2RTH584J6DrNrQ2c7PdqUdHLwVLsz2j2+k9pMs=;
        b=RLmTSGUE2ni20eaxCOPDOlh3j2QKDA1avisyOjYhKuOqUxm1IFsAynm/C+Erkcn2Z1
         TwVjo1vLXRR0pmSMQL4wpJJAaS1F4MBBU1huL+T/Gx+IsOhQcC3vQTYAYomq854O8kRU
         jW7GpoVpjNea4hMOqUU0n7TLEtYyrIZTnBkCsbmrzTjOelzfWJVPCdiVDKofw6gwae1V
         SsIJHqSdP35p9+lL3dpNgES5dOUTnT+MYC84XoCSTUzUv7UE8gsL5xROsru5gHkXno0N
         lRpIweh/g8xlvD4yu2E+FLAFXjB7C/EBhLezPAmgrpHEmwmNzEbVWy7Qk3DT1aGS+53m
         Qodg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id p9si10535411pgc.448.2019.02.11.13.43.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 13:43:09 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 13:43:08 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="123692351"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 11 Feb 2019 13:43:08 -0800
Date: Mon, 11 Feb 2019 13:42:57 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Daniel Borkmann <daniel@iogearbox.net>,
	netdev@vger.kernel.org,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 0/3] Add gup fast + longterm and use it in HFI1
Message-ID: <20190211214257.GA7891@iweiny-DESK2.sc.intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211203417.a2c2kbmjai43flyz@linux-r8p5>
 <20190211204710.GE24692@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211204710.GE24692@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 01:47:10PM -0700, Jason Gunthorpe wrote:
> On Mon, Feb 11, 2019 at 12:34:17PM -0800, Davidlohr Bueso wrote:
> > On Mon, 11 Feb 2019, ira.weiny@intel.com wrote:
> > > Ira Weiny (3):
> > >  mm/gup: Change "write" parameter to flags
> > >  mm/gup: Introduce get_user_pages_fast_longterm()
> > >  IB/HFI1: Use new get_user_pages_fast_longterm()
> > 
> > Out of curiosity, are you planning on having all rdma drivers
> > use get_user_pages_fast_longterm()? Ie:
> > 
> > hw/mthca/mthca_memfree.c:       ret = get_user_pages_fast(uaddr & PAGE_MASK, 1, FOLL_WRITE, pages);
> 
> This one is certainly a mistake - this should be done with a umem.

It looks like this is mapping a page allocated by user space for a doorbell?!?!
And that this is supporting the old memory free cards.  I remember that these
cards used system memory instead of memory on the cards but why it expects user
space to allocate that memory and how it all works is way too old for me to
even try to remember.

This does not seem to be allocating memory regions.  Jason, do you want a patch
to just convert these calls and consider it legacy code?

Ira

> 
> Jason

