Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07692C28CC2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:16:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6E9D24054
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:16:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6E9D24054
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C3936B0266; Wed, 29 May 2019 14:16:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 573986B026A; Wed, 29 May 2019 14:16:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 462646B026B; Wed, 29 May 2019 14:16:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3BB6B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:16:16 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y1so2095364plr.13
        for <linux-mm@kvack.org>; Wed, 29 May 2019 11:16:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=c+j2R/6rmBgZH0ZVTdSGUfpKhS3Y/x74kV5FQru2f8o=;
        b=qN6k80hKvDIcI/xuvgLjoA3p+QP15Lv8RNxI4add/42i4sVoN55uCDotu+mneS7ncm
         5pnTf3B1YMOSyBoxSJvt0qzwdM/oYCavOESRA+BbBtlI7gwWjRHiJlfo7G6MFsOInwCo
         vNm7Ofo7hIZN8yWtBIhXtSSCVeUhYrT4lHhSvgoPJzjaeizXwOhLb7Juef347c3yFaDK
         SS1BHe2KBvLFGEdZCwMCP+KyPs2u2MOCoJynHQEmcBue6cxobdniA3snhPrOGz/q+FM8
         w5l//o00XMB0bKEl4U0OQtrKfDrXGxPtmtxQEgncICDWcQI2hDTU2Q0lJ6CUFojp1CGT
         BROw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUE3mySjLcpkU9pKZPKmrrTltIEJejEliFuqKZiDlJWjcM+Joxm
	ajHZeEsQdbEmz5cJNWY490B+LHLMS8JQWRJJ6Bp+lE1E4+xm761YmU2AVq+SE/MJmr4od0QS8kO
	wWlHKnHzdyEwJAvH/2Gsq03Wnwa4Vi8ejQsqEILtNmOGvUU7/ZIMIZm+tenrtyR7LUg==
X-Received: by 2002:a17:902:15c5:: with SMTP id a5mr144585127plh.39.1559153775692;
        Wed, 29 May 2019 11:16:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyblFAFpFuZl9cH/49loc8L579suth3i1XRCZTVggA7jIyFaQu2Y9F2Fjch9uZ5lGOo4LtX
X-Received: by 2002:a17:902:15c5:: with SMTP id a5mr144585048plh.39.1559153774770;
        Wed, 29 May 2019 11:16:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559153774; cv=none;
        d=google.com; s=arc-20160816;
        b=XWJuLmTOUl/PoHgfdVyR8MpWs4QSH63CkjTEOx0B8i4uxZg86A8BgeipI5Op/+ZqAM
         Pm4NZRDWdQztowhI8x2RWIItUy51vJ7CVXMv963KE8xLeUtX/a8dScUzAKTfI03Ri1M8
         GLKUkQo1oetOGCsO7KkNrd1R7BhaIf4bKegshlgpQfDbXATUlRpZC1P8J2gq/YZizzKC
         Or9Js+lS3x965U/JkGL5R0I4p1UFvD2ZCh2NnRMSls5tfKcdODoai/HdbAzv+RnRhqPF
         srngi8wjwMdIR6R6eCeDzk36sMxUOO0989O9QmZUO0hksQZpn7t3EUk/JQmkTX7JxFV/
         H7NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=c+j2R/6rmBgZH0ZVTdSGUfpKhS3Y/x74kV5FQru2f8o=;
        b=ITlY37m5ohzt5cXaEESXZ9AWA/Ug5XmLpGohZjIYdSUbo8gN5b74gmAgyYmPSdqTV0
         oA1vLe57o5VwFpxTyINfkIJ0nkrz8/J/ihq0fGxb/m1mVgkI8V61NVuUmPS6+kIaloIu
         H8wlbpyMGTWIWFaV4kRUYNvUJI3cVtx6HD520csyO2O1n7J/7aGXlM9/MllBv9K0UVGq
         nnoewaNTPJBf5Kc/Ami4mHuACrTaqaectw1luCSFRG+L2uCTTZbjIkazROYGGbrpcr0p
         6lxFXTyfdcnpfrfPMK9GBBB/Vj7MscGt9FnPCx8SCU9Zyq9rHZZT63aCniJUbb4+mdz9
         c17w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id n1si399905pld.261.2019.05.29.11.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 11:16:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 May 2019 11:16:13 -0700
X-ExtLoop1: 1
Received: from alison-desk.jf.intel.com ([10.54.74.53])
  by fmsmga005.fm.intel.com with ESMTP; 29 May 2019 11:16:13 -0700
Date: Wed, 29 May 2019 11:20:04 -0700
From: Alison Schofield <alison.schofield@intel.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 00/62] Intel MKTME enabling
Message-ID: <20190529182004.GA525@alison-desk.jf.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190529073006.GG3656@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529073006.GG3656@rapoport-lnx>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 10:30:07AM +0300, Mike Rapoport wrote:
> On Wed, May 08, 2019 at 05:43:20PM +0300, Kirill A. Shutemov wrote:
> > = Intro =
> > 
> > The patchset brings enabling of Intel Multi-Key Total Memory Encryption.
> > It consists of changes into multiple subsystems:
> > 
> >  * Core MM: infrastructure for allocation pages, dealing with encrypted VMAs
> >    and providing API setup encrypted mappings.
> >  * arch/x86: feature enumeration, program keys into hardware, setup
> >    page table entries for encrypted pages and more.
> >  * Key management service: setup and management of encryption keys.
> >  * DMA/IOMMU: dealing with encrypted memory on IO side.
> >  * KVM: interaction with virtualization side.
> >  * Documentation: description of APIs and usage examples.
> > 
> > The patchset is huge. This submission aims to give view to the full picture and
> > get feedback on the overall design. The patchset will be split into more
> > digestible pieces later.
> > 
> > Please review. Any feedback is welcome.
> 
> It would be nice to have a brief usage description in cover letter rather
> than in the last patches in the series ;-)
>  

Thanks for making it all the way to the last patches in the set ;)

Yes, we will certainly include that usage model in the cover letters
of future patchsets. 

Alison

