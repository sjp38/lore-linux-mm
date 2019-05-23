Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C658C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 23:48:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E483D2133D
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 23:48:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E483D2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C1296B0005; Thu, 23 May 2019 19:48:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6718A6B0006; Thu, 23 May 2019 19:48:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 560CB6B0007; Thu, 23 May 2019 19:48:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 191E06B0005
	for <linux-mm@kvack.org>; Thu, 23 May 2019 19:48:44 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e20so4933005pgm.16
        for <linux-mm@kvack.org>; Thu, 23 May 2019 16:48:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AydqY+5NA2QwK3sIaKZoD3clH3qwqW5hznPdtqS1iMA=;
        b=VvB/vNaYaL1qWygUGBfT4CMbZwLjWo1jj5/+g6eSX4/pHO964AJSNclTLw2RtKTEoX
         2PPkZE44Pzg4JPGhbb0AN4sULTTxMTMNYJIyczaRLj7dHFsjDx47YyPrHfuopL/ZREZB
         AUpaqlQhR7Sox9pKPySwUKytEUMeIyL8w12D79DrmDoRnQtSFOEYcryC/LmZKBu7SF3m
         FHFP53C4zKAaDgY537edGZNlRwkf3BR3GcWFgAC+OT9rlHXMddGS8dCX93Usl3SRtgbl
         QlhVM6381XAajBDT4Vv4gT5os6Y/ad32DlUhu4UQupfMMPhzFPAZgv0uYR7XGrlrpl9B
         xELQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU2CN3f9sZtgCLRekbMTQhSDSRhb+wWE0SzZ5hIpw+6as7buOOi
	AaOzpnNxMq7gtf+KcIE/drYZes8avKYbTis1KckWooWepN5+XQAwt/FfeRSRb3wD6xm0BtRGuJR
	3YKOGg7uW/KXdgiRgp0m5j0V4gwB9n/U5NrthIxH0K73cn0CHWHfnbvGol8RO952qDQ==
X-Received: by 2002:a62:ee05:: with SMTP id e5mr106114979pfi.117.1558655323747;
        Thu, 23 May 2019 16:48:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrgO2z5DE1o591C5lMRbJX+TS7HFC7DmNwmZnShqt3bZArzZkecwZyH4DXT/D/2oqh0cZI
X-Received: by 2002:a62:ee05:: with SMTP id e5mr106114886pfi.117.1558655322917;
        Thu, 23 May 2019 16:48:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558655322; cv=none;
        d=google.com; s=arc-20160816;
        b=qypjgQ1qgoeE79+/XN0AD+dGxM4bhCiw/AE5XuR6h2wXmjfm3wgDTud2tZuRBFPYKE
         9XKqA4zZtZIgBbYBfN90fW3kn9znKJ6Fcj94WFScPLAV5oJhdelYsxMAWjf7NFOYeaY5
         XdqjS9h0YPkdDK2H37VbH/33/MJj0JyxCQakxlFTmKLV+xkoJy7Bs6gMmNrNzavcymW6
         YIlcI+EWMsSBEodqlFOx+V+7MwVS/VOg/xgtpLCtNzrPCACgULmotFnB6YB9Nouti9Mj
         XceOgpe2JTnmxG3F4LzQwX/lhk6/MrNp1HkBLX6EY2MAhQDvGq9ICWOa8fUikfPulL0W
         B2pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AydqY+5NA2QwK3sIaKZoD3clH3qwqW5hznPdtqS1iMA=;
        b=hhX3NFl7b7XmfhZvQTP0TeIG7dnuRVBkYFRU8v/TcbFhTUnqbXOzwYOmuidOGF7uGz
         x9qVwy2aBbg2wF4peOEpRU4Ju/6sr8KWGaTgdehmzFdOf1/shKJCPMuF3jkMZcB2GZDp
         Ea0krNMILerzNMg/nYQhsSHRTSqVdVZCu1k630Tk+Zea2KhJviDERr/rvJ6yYU5dc8oX
         FWxnpXiFsuexV3onJ85HpNiqea20VLmUg38JjprPXR5Sf5sMZHi7cwQDkZxf7gDfS4vr
         JgtpNcGG0Mx6VhG1UdcEpm1SGc7ggzrf8m3+klh3Nm5KCHTHiKI2/Kzgj8XHtLM2Lt8n
         OTmw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id k10si1612070plt.133.2019.05.23.16.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 16:48:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 May 2019 16:48:42 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga007.fm.intel.com with ESMTP; 23 May 2019 16:48:41 -0700
Date: Thu, 23 May 2019 16:49:35 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jerome Glisse <jglisse@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [PATCH] hmm: Suppress compilation warnings when
 CONFIG_HUGETLB_PAGE is not set
Message-ID: <20190523234935.GA5472@iweiny-DESK2.sc.intel.com>
References: <20190522195151.GA23955@ziepe.ca>
 <20190522132322.15605c8b344f46b31ea8233b@linux-foundation.org>
 <20190522235102.GA15370@mellanox.com>
 <07f97bf3-cc38-6016-b9fc-1dc4efa5a190@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <07f97bf3-cc38-6016-b9fc-1dc4efa5a190@oracle.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 10:56:09AM -0700, Mike Kravetz wrote:
> On 5/22/19 4:51 PM, Jason Gunthorpe wrote:
> > On Wed, May 22, 2019 at 01:23:22PM -0700, Andrew Morton wrote:
> >>
> >> Also fair enough.  But why the heck is huge_page_shift() a macro?  We
> >> keep doing that and it bites so often :(
> > 
> > Let's fix it, with the below? (compile tested)
> > 
> > Note __alloc_bootmem_huge_page was returning null but the signature
> > was unsigned int.
> > 
> > From b5e2ff3c88e6962d0e8297c87af855e6fe1a584e Mon Sep 17 00:00:00 2001
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > Date: Wed, 22 May 2019 20:45:59 -0300
> > Subject: [PATCH] mm: Make !CONFIG_HUGE_PAGE wrappers into static inlines
> > 
> > Instead of using defines, which looses type safety and provokes unused
> > variable warnings from gcc, put the constants into static inlines.
> > 
> > Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> 
> Thanks for doing this Jason.
> 
> I do not see any issues unless there is some weird arch specific usage which
> would be caught by zero day testing.

Agreed.  I did a couple quick searches and I don't see any such issues.  I was
thinking the same thing WRT zero day.

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> 
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> -- 
> Mike Kravetz
> 

