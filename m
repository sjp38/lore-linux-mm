Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21560C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 13:54:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D187B218A5
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 13:54:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D187B218A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 447296B0003; Fri, 22 Mar 2019 09:54:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F6DA6B0006; Fri, 22 Mar 2019 09:54:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BF1A6B0007; Fri, 22 Mar 2019 09:54:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA88B6B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 09:53:59 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j184so2246908pgd.7
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 06:53:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xlY/ktt7mRUlRAE0U2eRLdDPwg8XEfpyxv/Oacs8Dac=;
        b=m8NeHrJfdPimwnf2Jww2W1oWit278GAhxjskSuyaR9sTB73Qt5Kh5iGPFqhKiApDYZ
         9dqYnz9fZ5CCR9u24sAOaBdM1QGY1JzoPncx5r+tAxb4LpqqS3xOS+tcT2ObsonNLNRt
         YwrpCV3vM0oqmGWUei5wOKINSsFSNjTpG9GNi/0dlJJP80FUHBZQUezBJvhrAD84sSfp
         q1j5Z4mxSIvI6pn8YuyUNK5DgEVZvfcHRivCBzgu2A4Ki6yBdY7Trj7e96rhbtXUxFQ/
         Pq21BC5PG55bbLUPZU8+P0MdEy6xaXK14agN1jAs18nXqDhVJOc4zizYxvY+5+faz05h
         osKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=sakari.ailus@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWooadUKVUNktPSClB/chSzAVs+fX6TCmQajzwln/tqhfVLYQC6
	8N5IlmrNO/RerYdGqnrJ0dAW3m2k8d4sU5cKA3Tr3YsTOl2c65VOVqBvCjKJoZFv5esoGP0Ffex
	vPsn6nOPq/M54HuWBqvtLRQNeWuMdXHu3nwJGMcz2y+NxFI0ZC0uu3Vt9dB/ahrEG4w==
X-Received: by 2002:aa7:91d7:: with SMTP id z23mr9473624pfa.137.1553262839431;
        Fri, 22 Mar 2019 06:53:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBS3lw4C4pH6NFBAcmODnizYkW5H4xpz1voIE4iMY+GSG8Ou0f8kOxKutSBnXwocTiQncY
X-Received: by 2002:aa7:91d7:: with SMTP id z23mr9473556pfa.137.1553262838426;
        Fri, 22 Mar 2019 06:53:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553262838; cv=none;
        d=google.com; s=arc-20160816;
        b=yk+VmHxsjnUiX08f/M0d9RnFe2kEd7Axp/8l1ymzP7jfTS+EKohFT/AVxQ6/DQQrKU
         g1j6MqItctLOPIP7BMuuoP6jjjuMZzVaAH6wZF0Y/AK7WOLae7kLNNdEx14mHm74trAd
         3nQlii+oARg19y5Vb8bkhG6kKKOVzUqyQm+LrIh/1a4bJmpWLEzBVUFmURZs05tjGIPC
         EnEl+VEk/sCRyig3Z6JsPXztjoLYmLjnREDAg4jH0XQp8vsNHReEB5uqwEoSsTLWeK5P
         wckUcHcsWotFM6Qalck+4Ur6+CYaoyy1jOM9kd4JQDnigacWohJacd/akd70enD5GXS5
         wZqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xlY/ktt7mRUlRAE0U2eRLdDPwg8XEfpyxv/Oacs8Dac=;
        b=IXtoMshVl6mIQIbfiqujxuBkKmggKycFEnyPAlktEU0UDp10kzdJI2VAR6q1cNNhxK
         QezQlPOlBH7WkqpUkuY/j6XLBSSCmY7al2iI65pRVEv1m+RhQIZJozjmq+DvP/2pClUo
         SR9/vN0s/dY3agX+X1f5z7Ybzjkv2l7lPcxTvbyyOL2K66z0hYL6/2VdsGosoG2MixSh
         Uwh2+Ugphx9/SYL551+ndeHouThqkVx65SymaMJYrwblGOlXb+mjRDooeyZAwFWBVUNI
         tl+xDDuFWATMTMo94VCxLADG7mADbRIQoFD8fTCTZc/vxBV8ozCWkMENWx8G+Kjr1R8i
         dY5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=sakari.ailus@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id e36si2732361pgm.89.2019.03.22.06.53.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 06:53:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=sakari.ailus@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Mar 2019 06:53:57 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,256,1549958400"; 
   d="scan'208";a="124964705"
Received: from paasikivi.fi.intel.com ([10.237.72.42])
  by orsmga007.jf.intel.com with ESMTP; 22 Mar 2019 06:53:51 -0700
Received: by paasikivi.fi.intel.com (Postfix, from userid 1000)
	id C176C205C1; Fri, 22 Mar 2019 15:53:50 +0200 (EET)
Date: Fri, 22 Mar 2019 15:53:50 +0200
From: Sakari Ailus <sakari.ailus@linux.intel.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Petr Mladek <pmladek@suse.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	scsi <linux-scsi@vger.kernel.org>,
	Linux PM list <linux-pm@vger.kernel.org>,
	Linux MMC List <linux-mmc@vger.kernel.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	linux-um@lists.infradead.org,
	linux-f2fs-devel@lists.sourceforge.net, linux-block@vger.kernel.org,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-btrfs <linux-btrfs@vger.kernel.org>,
	linux-pci <linux-pci@vger.kernel.org>,
	sparclinux <sparclinux@vger.kernel.org>,
	xen-devel@lists.xenproject.org,
	ceph-devel <ceph-devel@vger.kernel.org>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Linux MM <linux-mm@kvack.org>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Lars Ellenberg <drbd-dev@lists.linbit.com>
Subject: Re: [PATCH 0/2] Remove support for deprecated %pf and %pF in vsprintf
Message-ID: <20190322135350.2btpno7vspvewxvk@paasikivi.fi.intel.com>
References: <20190322132108.25501-1-sakari.ailus@linux.intel.com>
 <CAMuHMdVmqqjVx7As9AAywYxYXG=grijF5rF77OBn6TUjM9+xKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdVmqqjVx7As9AAywYxYXG=grijF5rF77OBn6TUjM9+xKw@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Geert,

On Fri, Mar 22, 2019 at 02:37:18PM +0100, Geert Uytterhoeven wrote:
> Hi Sakari,
> 
> On Fri, Mar 22, 2019 at 2:25 PM Sakari Ailus
> <sakari.ailus@linux.intel.com> wrote:
> > The printk family of functions supports %ps and %pS conversion specifiers
> > to print function names. Yet the deprecated %pf and %pF conversion
> > specifiers with equivalent functionality remain supported. A number of
> > users of %pf and %pF remain.
> >
> > This patchsets converts the existing users of %pf and %pF to %ps and %pS,
> > respectively, and removes support for the deprecated %pf and %pF.
> >
> > The patches apply cleanly both on 5.1-rc1 as well as on Linux-next. No new
> > %pf or %pF users have been added in the meantime so the patch is
> > sufficient as itself on linux-next, too.
> 
> Do you know in which commit they became deprecated, so the backporters
> know how far this can be backported safely?

That appears to be 04b8eb7a4ccd
("symbol lookup: introduce dereference_symbol_descriptor()"), the same
patch that made %p[fF] and %p[sS] functionally equivalent.

But my personal opinion would be not to backport the patch for two reasons:
the sheer number of files it touches (those format strings change for
various reasons) and the meager benefits it has on older kernels as any
backported patch using %s or %S still works as such. Porting a patch
forward should have no issues either as checkpatch.pl has been complaining
of the use of %pf and %pF for a while now.

-- 
Kind regards,

Sakari Ailus
sakari.ailus@linux.intel.com

