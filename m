Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ECEDC76195
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 04:50:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FB1A21BE6
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 04:50:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FB1A21BE6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDB3C6B0003; Mon, 22 Jul 2019 00:50:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C662B6B0006; Mon, 22 Jul 2019 00:50:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B55858E0001; Mon, 22 Jul 2019 00:50:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 792086B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 00:50:15 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q11so19111631pll.22
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 21:50:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1ZZGpriDkfjat7kCBgBFRYCDd4cLAWDtCuZkaQFp9Yk=;
        b=dWA0OpoIGH9W25MKFEO50soV9geYa1r5G45KpuxoGJLsTp6jTBJDuNtQJ3NBX/N0jk
         gYPKYgnyTE+tL0UTw5bJ73kihlx+ynEjA2sx0BNO7EZwOZdu952Vfg/m99T6HLsewmBS
         3kqj4mQMaLtcZ1YRDi8FOmISWp4y/lXhvsycQglL+ZcRqeqj+2gVe9C2iixIZFRyQ+e0
         SJhaYrgUjLoVaoyAdPl6tqL+a57dgbFqxN9O+EbiDJo3hkBg6UIQAi2p/WOkGDVzHcag
         JzNDZERrArWyIn02tGQS2T2+NhXd6fDTC+99Kqm0Wvj6OkxuvITNnLObJR0oXbKAWlXW
         FR0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWOtMufFPSFL8dKNYh2rpGf6/ZnoY19XjhNokrO9wxdnKO/kIHn
	DswsJjEGOkz8+aQbGkhvqNWnUPt8PFXc3Ncms+mMHe9FKrl2wU75LOqKAWXbI77kLfd/vjIUzIm
	MPkeKBKI1cEz2RDVAGBpExS2n5JqpBSFyv/zdym3Ow6M77jTaETf1wU9b2ljOMaJadw==
X-Received: by 2002:a17:90a:9505:: with SMTP id t5mr74330294pjo.96.1563771015148;
        Sun, 21 Jul 2019 21:50:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz70/Fkv9yP5GVN65/6cinlfrfX0LBUBg+njl75Y39QvrQTRAqTJw1xeyjBK8+Q/dSZHAbr
X-Received: by 2002:a17:90a:9505:: with SMTP id t5mr74330252pjo.96.1563771014471;
        Sun, 21 Jul 2019 21:50:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563771014; cv=none;
        d=google.com; s=arc-20160816;
        b=NRaHWrgxjHxjxWWOWlCsFPBhJwAWA0ufl8RkZzqWD9shClMQC2v26CX0ptN12YEnWi
         tmbu1nwkRU45DjtBg1D0UPAW/CMZJS+tXZFyusRXqjm6Whjbv0snlLC14xvLnjyGaZI/
         CKBRCh/GRDExaTAqffl/DqqTc0auR9KKrCQeMtlvFy69nqQz0ZRNMgwpAk9+nmMaFOlN
         wzSZvBVcMTpx30Z2ao0aMa+SicyfxnsSps/5ZWQprxKlUQ3fFUwD5fCDJvnFbt+cDfFn
         S7JIm/MUOLGLT8OGJSzUve17aiwYK18gZgfDvrLG8VQTXLGHHCqRaXoOpDh4gCikGpV8
         l8bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1ZZGpriDkfjat7kCBgBFRYCDd4cLAWDtCuZkaQFp9Yk=;
        b=PERQGUgUXNxj/2v4gqP96OvvErWbuANfpxS2FYiRB9tGcY68fWYrEUwMBxE4swbpBB
         d+9KkmIj6WSOpWNReAftrRZnaeH7ZALvdet8Z4itdfrpnmD8FytaBnpY60PSqWNWeUQD
         U5U5X1Ow0pRbPZFnoypul5nFz33pGH/Y3R0m5PsQ15pSiAHxxFPh1PZZ7pmTf+lJs/zs
         JKaAu9azG7qIrt/afFMJWnZOtRKiCN/BDkjMUBR2XlRHYl6njQtRJcPfYtlHTNCbxVRS
         Y4i7UWgGXxFgX4bfOiSizohQPSaM0pxTSf6VhRFW2DvOziLFLh13ONfvDDApaGXn1a/8
         TIZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id f5si8054986pln.228.2019.07.21.21.50.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jul 2019 21:50:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Jul 2019 21:49:48 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,293,1559545200"; 
   d="scan'208";a="170755148"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga007.fm.intel.com with ESMTP; 21 Jul 2019 21:49:48 -0700
Date: Sun, 21 Jul 2019 21:49:48 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: arnd@arndb.de, sivanich@sgi.com, gregkh@linuxfoundation.org,
	jhubbard@nvidia.com, jglisse@redhat.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 0/3] sgi-gru: get_user_page changes
Message-ID: <20190722044947.GA6157@iweiny-DESK2.sc.intel.com>
References: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 09:28:02PM +0530, Bharath Vedartham wrote:
> This patch series incorporates a few changes in the get_user_page usage 
> of sgi-gru.
> 
> The main change is the first patch, which is a trivial one line change to 
> convert put_page to put_user_page to enable tracking of get_user_pages.
> 
> The second patch removes an uneccessary ifdef of CONFIG_HUGETLB.
> 
> The third patch adds __get_user_pages_fast in atomic_pte_lookup to retrive
> a physical user page in an atomic context instead of manually walking up
> the page tables like the current code does. This patch should be subject to 
> more review from the gup people.
> 
> drivers/misc/sgi-gru/* builds after this patch series. But I do not have the 
> hardware to verify these changes. 
> 
> The first patch implements gup tracking in the current code. This is to be tested
> as to check whether gup tracking works properly. Currently, in the upstream kernels
> put_user_page simply calls put_page. But that is to change in the future. 
> Any suggestions as to how to test this code?
> 
> The implementation of gup tracking is in:
> https://github.com/johnhubbard/linux/tree/gup_dma_core
> 
> We could test it by applying the first patch to the above tree and test it.
> 
> More details are in the individual changelogs.
> 
> Bharath Vedartham (3):

I don't have an opinion on the second patch regarding any performance concerns
since I'm not familiar with this hardware.

But from a GUP POV For the series.

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

>   sgi-gru: Convert put_page() to get_user_page*()
>   sgi-gru: Remove CONFIG_HUGETLB_PAGE ifdef
>   sgi-gru: Use __get_user_pages_fast in atomic_pte_lookup
> 
>  drivers/misc/sgi-gru/grufault.c | 50 +++++++----------------------------------
>  1 file changed, 8 insertions(+), 42 deletions(-)
> 
> -- 
> 2.7.4
> 

