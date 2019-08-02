Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64F09C32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 15:14:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2058A204EC
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 15:14:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2058A204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7ACC6B000A; Fri,  2 Aug 2019 11:14:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B51C56B000E; Fri,  2 Aug 2019 11:14:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DFCD6B0010; Fri,  2 Aug 2019 11:14:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 43FA66B000A
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 11:14:01 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g21so48434100pfb.13
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 08:14:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=dQC4QQHwsy7W9GS1q2h0LgCu7EnesoVqk01uiLBVQG8=;
        b=Ka/aW37yURAALh3KqrQ/AeadwkvfMvf4F3XiOQjeRpMNrqlCzmYH+OmicC5vgqR0BU
         R3uC6DEqOLvFJkkWftv5sDHOjOP+/qxWppmumbD5VKHzVDvGeSGMhlu7pFGkciUqhspv
         +GumBdP2k8uywQW56IL5DxE4ENpWr2Df8NRXccsRAUtIZxUfa9UfEcMoWmj+61N4Chbo
         i4MlgtbriKBDK76dl3V4JyBtAQUCMjFjnqJ8MGAhOZRX/Rb2JeAOyQXXIwas+xaJzOG1
         a+NTEnG8OUKwOTeZILerAeWX+79nSCicC9QuNKucofqi8J1XzaDPnonVnvSt2sgH7pPo
         VSuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVpganAawDSlfpE7KqLogyy9NbZsO/5Y5KO2rXPSAm5cKhMpm1X
	OimqQRwjU++zRBXURpehilHmsYjOvTHFCFY6rD9Df7KrV7Jw2BON9I28KxfsH7bN9QzESJuXElc
	oFLk+3TCbCNCZZYu+P0VCGJBLUOnWcE06fwwd3KPDxwhdk0KsJyDSOgu1/GRWbbgz3g==
X-Received: by 2002:a63:561b:: with SMTP id k27mr25067072pgb.380.1564758840712;
        Fri, 02 Aug 2019 08:14:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrFys5IoVUMbfahJJcupfHrpONvBaq4CHy8QSvdE5tRJyIiNJhsTefoEilXz6F7cNFWFc+
X-Received: by 2002:a63:561b:: with SMTP id k27mr25066965pgb.380.1564758839193;
        Fri, 02 Aug 2019 08:13:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564758839; cv=none;
        d=google.com; s=arc-20160816;
        b=HycbL8lN/7oPwHn9Y+jVe5WoU/ZYke5Bl52SR7QAlb+0y90SCd47Ln4exyxUkaK30+
         WOJC2gx7Gon9eIdv7Mi5HM5W5LkIcpa9aT2E/GenSud9pBANTy7lmxjWMsSW7uLTPlyj
         6NzfMDTA+LPBKyOdJUQ9DtmP1Cwr9LDuFLy8um9YcsyQ2Gj3CWsVLqVQHmzYZMKa4ECe
         G447mS7t/M+mffP7mYr9IG+00Uofoi89AerD8G6Hi7cLHqwZ3Yd3Owe+vOolwQzCr+2Y
         xiPW/2O16UxcAtE5S8Bqb9WZ63wmRXVelZiRcuTv2ukj7qywWWQlcQH12FA+aNYt4pMt
         680w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=dQC4QQHwsy7W9GS1q2h0LgCu7EnesoVqk01uiLBVQG8=;
        b=j5gdgJoELWylJgFYxz5XCDbnFTxg8NR/3GRx0ZlBSgzSpRrMOshcYo1Bd2QZzPNUR5
         ef/hl9/jw/Gr4/3ez6JxFtvn6XQ8RM2GG5MaYEcjDtbUYOiulMu/eEdjaW/LT4fVd61/
         1+0xkeKuU86hdFioBK/pu9Je5fxTzsIQ9gJ6axcEpxGxf1FQ5sGk1q1NmJ2Q79ajz0hG
         t3rPNpHnKUHHRPZGqvp4zoJ5B4/jNJj+27AD8GsKRIf1IENEL+2o+99PWdYF2cJ6E1y+
         eNUcibmSJd6x1h43WNxDoJegqhYxIXPbOquG3YJGiuP1xXmol65VhilPkZ2I8JWfmRt/
         8KRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id cl8si34609177plb.47.2019.08.02.08.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 08:13:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 Aug 2019 08:13:58 -0700
X-IronPort-AV: E=Sophos;i="5.64,338,1559545200"; 
   d="scan'208";a="324597851"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga004-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 Aug 2019 08:13:56 -0700
Message-ID: <3f6c133ec1eabb8f4fd5c0277f8af254b934b14f.camel@linux.intel.com>
Subject: Re: [PATCH v3 0/6] mm / virtio: Provide support for unused page
 reporting
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>, kvm@vger.kernel.org, david@redhat.com, 
	mst@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com, 
	konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com, 
	dan.j.williams@intel.com
Date: Fri, 02 Aug 2019 08:13:56 -0700
In-Reply-To: <9cddf98d-e2ce-0f8a-d46c-e15a54bc7391@redhat.com>
References: <20190801222158.22190.96964.stgit@localhost.localdomain>
	 <9cddf98d-e2ce-0f8a-d46c-e15a54bc7391@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-08-02 at 10:41 -0400, Nitesh Narayan Lal wrote:
> On 8/1/19 6:24 PM, Alexander Duyck wrote:
> > This series provides an asynchronous means of reporting to a hypervisor
> > that a guest page is no longer in use and can have the data associated
> > with it dropped. To do this I have implemented functionality that allows
> > for what I am referring to as unused page reporting
> > 
> > The functionality for this is fairly simple. When enabled it will allocate
> > statistics to track the number of reported pages in a given free area.
> > When the number of free pages exceeds this value plus a high water value,
> > currently 32, it will begin performing page reporting which consists of
> > pulling pages off of free list and placing them into a scatter list. The
> > scatterlist is then given to the page reporting device and it will perform
> > the required action to make the pages "reported", in the case of
> > virtio-balloon this results in the pages being madvised as MADV_DONTNEED
> > and as such they are forced out of the guest. After this they are placed
> > back on the free list, and an additional bit is added if they are not
> > merged indicating that they are a reported buddy page instead of a
> > standard buddy page. The cycle then repeats with additional non-reported
> > pages being pulled until the free areas all consist of reported pages.
> > 
> > I am leaving a number of things hard-coded such as limiting the lowest
> > order processed to PAGEBLOCK_ORDER, and have left it up to the guest to
> > determine what the limit is on how many pages it wants to allocate to
> > process the hints. The upper limit for this is based on the size of the
> > queue used to store the scatterlist.
> > 
> > My primary testing has just been to verify the memory is being freed after
> > allocation by running memhog 40g on a 40g guest and watching the total
> > free memory via /proc/meminfo on the host. With this I have verified most
> > of the memory is freed after each iteration. As far as performance I have
> > been mainly focusing on the will-it-scale/page_fault1 test running with
> > 16 vcpus. With that I have seen up to a 2% difference between the base
> > kernel without these patches and the patches with virtio-balloon enabled
> > or disabled.
> 
> A couple of questions:
> 
> - The 2% difference which you have mentioned, is this visible for
>   all the 16 cores or just the 16th core?
> - I am assuming that the difference is seen for both "number of process"
>   and "number of threads" launched by page_fault1. Is that right?

Really, the 2% is bordering on just being noise. Sometimes it is better
sometimes it is worse. However I think it is just slight variability in
the tests since it doesn't usually form any specific pattern.

I have been able to tighten it down a bit by actually splitting my guest
over 2 nodes and pinning the vCPUs so that the nodes in the guest match up
to the nodes in the host. Doing that I have seen results where I had less
than 1% variability between with the patches and without.

One thing I am looking at now is modifying the page_fault1 test to use THP
instead of 4K pages as I suspect there is a fair bit of overhead in
accessing the pages 4K at a time vs 2M at a time. I am hoping with that I
can put more pressure on the actual change and see if there are any
additional spots I should optimize.

> > One side effect of these patches is that the guest becomes much more
> > resilient in terms of NUMA locality. With the pages being freed and then
> > reallocated when used it allows for the pages to be much closer to the
> > active thread, and as a result there can be situations where this patch
> > set will out-perform the stock kernel when the guest memory is not local
> > to the guest vCPUs.
> 
> Was this the reason because of which you were seeing better results for
> page_fault1 earlier?

Yes I am thinking so. What I have found is that in the case where the
patches are not applied on the guest it takes a few runs for the numbers
to stabilize. What I think was going on is that I was running memhog to
initially fill the guest and that was placing all the pages on one node or
the other and as such was causing additional variability as the pages were
slowly being migrated over to the other node to rebalance the workload.
One way I tested it was by trying the unpatched case with a direct-
assigned device since that forces it to pin the memory. In that case I was
getting bad results consistently as all the memory was forced to come from
one node during the pre-allocation process.

