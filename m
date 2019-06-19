Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83A7FC31E5E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:51:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56CDE204FD
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:51:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56CDE204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6C176B0003; Wed, 19 Jun 2019 11:51:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1D278E0003; Wed, 19 Jun 2019 11:51:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0B708E0001; Wed, 19 Jun 2019 11:51:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 854B76B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 11:51:07 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a5so10082724pla.3
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 08:51:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:organization:references:date:message-id
         :mime-version;
        bh=IpvRdtFuS1xeF29g/RZ+xRkUZrNqu0y2Z7Jt6zvPc00=;
        b=D4vD+ofRib/rKGFMlPcaAqk3sx2w8MYYOeRxcvz+M6RkLD3QSwC1Ze1ElYPLeTdVkA
         HBjp7r54gvRxJMweCambZGI2Mk8rc6EC6/3bN5CUSj7iB/KFscGvGBSwiI/TSJAQZ4zE
         /cL2bEeFcPUSAJWMXtoDTO5u8QWE0bCVNWrDKq4684hxnCay6bKOhb/dIfZbbWlBN/WO
         doskm1ss4f2bMvl6fnPaLL5+ct2wqwVCp6/hSDwYtGiRvZxf1c+lhOVSiJdz752KPn5z
         wpDMZ5EaE8Z8QcGqQAg2dCo+97wDBj0iEsUFC5JZCTys60T1qM2mrsTAPd+/uCpS1pKl
         518A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jani.nikula@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=jani.nikula@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWgDxq0T1KDWZd6QPnyh+MGbHwRaVsnH3bZbMEbp9fYvJbtGKFG
	gH0HEoYIQU5S3t+Qkh1yX6epXtt79E8NYjiRLJyrCAHmr/M2rWXdUZYC3FV9tcjcC3ecHD1NYWX
	W3WCPJwO5Fim0IcV/1aIjBRBKmNCIDci4V6lEvMQ7zBeDlTV7yRh9bJxVr0Gjrs2U1Q==
X-Received: by 2002:a17:90a:f498:: with SMTP id bx24mr12057345pjb.91.1560959467104;
        Wed, 19 Jun 2019 08:51:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoHyzTT9OSmZ6+I0fx0fVBSPLej+CT8mJR9rG1ohgV2NQXnqTNg2J+pEmDHGMOhgrfa864
X-Received: by 2002:a17:90a:f498:: with SMTP id bx24mr12057265pjb.91.1560959466055;
        Wed, 19 Jun 2019 08:51:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560959466; cv=none;
        d=google.com; s=arc-20160816;
        b=c2sSZjeXVZK6MiCq/fQBFpF6uo1VORxs/WRXXLGd6SLAEc3eLqVRrYEuxYEV/acil1
         ZHxOMvOxqmMNQN/oLsXlFpd9sw+NdxKH80FLPs6JONnxj7hqOFobq1p4tdCriUyXdQ8w
         fqZvvh9kFKKejR0dEjlElH6HKt2wmVrjRO+KVPZCfh6GJPUkzlkJ/p6XT9l4z2xHKZoM
         wSRl6clanl960wnt8f0lms90kgnfyyyNE+IUHP6iYe2UZFmTBH/7RI5Hqv8Ao6bLBhjg
         hqsY6XM+hFicRnWl0hkwwZMj3IHAfCZnxRUDDf9+MYcFejlvSGHR7MCXZtpzrs9OV6aP
         CJlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:organization:in-reply-to
         :subject:cc:to:from;
        bh=IpvRdtFuS1xeF29g/RZ+xRkUZrNqu0y2Z7Jt6zvPc00=;
        b=Q73kXhEQKQOqn/yNjeQ67LxxEDm/YLIfnb6C0Bb72w52giw8/fff0ExiH7AlLLAzvW
         fh06BPgVnIQcfaqOePMP2Q8Shjfu8nPY4lQXL4EobQlQEU+vYdNm5+mH+w7nqtTRDxcP
         6yYcGPNzF8tSEQfR6OW1m/tZ1SxxvwWdW9t2VZAjrSxw4E5yGQGojx0EyHvmtd/ONRSY
         6SXydqSSTfcwLJer6vW3T2Y+5uhE3LRfuGbeEdPDzK/o1L1z+zqSTBAwim/KgRxpTt9M
         TD1qNC0ZUfpLw7t3ZAvTEH3gnzCKKWxFRVEhaENF9ovU0pNwY7Q14fHrxgvmq3+27Kbo
         OZvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jani.nikula@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=jani.nikula@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e127si3293668pgc.214.2019.06.19.08.51.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 08:51:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of jani.nikula@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jani.nikula@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=jani.nikula@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Jun 2019 08:51:05 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,392,1557212400"; 
   d="scan'208";a="181661305"
Received: from mcostacx-wtg.ger.corp.intel.com (HELO localhost) ([10.249.47.136])
  by fmsmga001.fm.intel.com with ESMTP; 19 Jun 2019 08:51:02 -0700
From: Jani Nikula <jani.nikula@linux.intel.com>
To: Jonathan Corbet <corbet@lwn.net>, Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: David Howells <dhowells@redhat.com>, Linux Doc Mailing List <linux-doc@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v1 12/22] docs: driver-api: add .rst files from the main dir
In-Reply-To: <20190619085458.08872dbb@lwn.net>
Organization: Intel Finland Oy - BIC 0357606-4 - Westendinkatu 7, 02160 Espoo
References: <20190619072218.4437f891@coco.lan> <cover.1560890771.git.mchehab+samsung@kernel.org> <b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org> <CAKMK7uGM1aZz9yg1kYM8w2gw_cS6Eaynmar-uVurXjK5t6WouQ@mail.gmail.com> <11422.1560951550@warthog.procyon.org.uk> <20190619111528.3e2665e3@coco.lan> <20190619085458.08872dbb@lwn.net>
Date: Wed, 19 Jun 2019 18:52:32 +0300
Message-ID: <874l4llghr.fsf@intel.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jun 2019, Jonathan Corbet <corbet@lwn.net> wrote:
> Organization of the documentation tree is important; it has never really
> gotten any attention so far, and we're trying to make it better.  But
> moving documents will, by its nature, annoy people.  We can generally get
> past that, but I'd really like to avoid moving things twice.  In general,
> I would rather see a single document converted, read critically and
> updated, and carefully integrated with the rest than a hundred of them
> swept into different piles...

FWIW, as a first step, my preference would actually be cleaning up the
top level Documentation/ directory. Move every file to an existing or a
new subdirectory, even if just as .txt, or just delete. I understand
this would lead to an extra rst conversion and extension change later,
which you'd like to avoid, but IMO would be helpful.

We could even add an attic directory, which would be a suitable place
for things like zorro.txt. Attic is where I'd look for my old Amiga
hardware, so feels natural.

BR,
Jani.


-- 
Jani Nikula, Intel Open Source Graphics Center

