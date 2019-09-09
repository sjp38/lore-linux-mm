Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E843C433EF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 09:56:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0011E2086D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 09:56:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="y4Aem2zd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0011E2086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 941646B0005; Mon,  9 Sep 2019 05:56:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F1A96B0006; Mon,  9 Sep 2019 05:56:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E0996B0007; Mon,  9 Sep 2019 05:56:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0217.hostedemail.com [216.40.44.217])
	by kanga.kvack.org (Postfix) with ESMTP id 594D76B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 05:56:12 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 130CD824CA3F
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 09:56:12 +0000 (UTC)
X-FDA: 75914926584.06.pies75_8d658969ead1a
X-HE-Tag: pies75_8d658969ead1a
X-Filterd-Recvd-Size: 4622
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 09:56:11 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id c20so3359758eds.1
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 02:56:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TkcuSrktiec/3aeNNPIPbr3CY/ViMiJEbi8XPnPDeFE=;
        b=y4Aem2zdEw/0MY0GP//C3Dw/NpPHTs0qKqdBb4xrcHA1pZ0xHXXvj9eCql7CFteyRf
         y4akVA0lJFLoGkrZCPbFNlfznQs3ZbJ9CWr+JuD8Z3kSt7xxylldudDPRN/rQfgO+vW6
         4Pivn2PbcNEY2vN6cCwbQCaHwbvuTKNjsJxKXF06Q624NzL3x+QwiZ8yNorQ6D5vsCJf
         L8tqOz85eAHvcZKFkHNZDRJXs1a4nwiMxGa5yAOxiQQ8VFLx+6VaURSLOJbM9dRa4N2k
         Yb/2g2O7SVOnxZ7wb4kdBg3Pqci3bFH370K9sGIEGhXDnJaqKth32tPYECQ2HLF3tGdq
         JTsg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=TkcuSrktiec/3aeNNPIPbr3CY/ViMiJEbi8XPnPDeFE=;
        b=NoNH6ChzyNXLHTog/nfaT+V6VNwtKK1wW3y5p8V3NTZuijtiVvPBGM9uNWJ0cs9Ip0
         wxIlCKcmZn9vrMRhzMwFKpvuod2QnVkLrpz0p9mDVND9J+pOSxZogqI1f4TAcM9vlKfh
         /euahQU1XSker10abXBsBre9rilaSW+O2lX4twytsp1rY5YKaZpbvstmh1EW99PSPEfJ
         QJddVLZOKpu3KfHwXQLThgyb7Big51HaTyiddNVfXWA2mSDOI11cvEQwMkrrbIrzegGd
         CLsvjYwWt0ncfOGd29qAWzrEmmGoETuxQ6tkym32vyhvpR4eAYUplJzMeocS2Gw1CC3m
         tjDQ==
X-Gm-Message-State: APjAAAX++UZpN2+fgDSCCeuRFZBLSLwH0hyPf+jmrjV6ZLMKSfxTidVU
	232i3A3A7m5WViM+tGeoObdnDw==
X-Google-Smtp-Source: APXvYqyRn+kl2/TWZQY25cP+eDKMrBVhD4QUydeucAx1gsJCDQV6FE+USGZXHlRVlnYWQyI9ItE3Qw==
X-Received: by 2002:a17:906:5a8d:: with SMTP id l13mr18691711ejq.219.1568022970390;
        Mon, 09 Sep 2019 02:56:10 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id d24sm2946102edp.88.2019.09.09.02.56.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Sep 2019 02:56:09 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 7D24A1003B5; Mon,  9 Sep 2019 12:56:08 +0300 (+03)
Date: Mon, 9 Sep 2019 12:56:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, mst@redhat.com,
	catalin.marinas@arm.com, david@redhat.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, willy@infradead.org,
	mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
	will@kernel.org, linux-arm-kernel@lists.infradead.org,
	osalvador@suse.de, yang.zhang.wz@gmail.com, pagupta@redhat.com,
	konrad.wilk@oracle.com, nitesh@redhat.com, riel@surriel.com,
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
	ying.huang@intel.com, pbonzini@redhat.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, alexander.h.duyck@linux.intel.com,
	kirill.shutemov@linux.intel.com
Subject: Re: [PATCH v9 3/8] mm: Move set/get_pcppage_migratetype to mmzone.h
Message-ID: <20190909095608.jwachx3womhqmjbl@box>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190907172528.10910.37051.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190907172528.10910.37051.stgit@localhost.localdomain>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Sep 07, 2019 at 10:25:28AM -0700, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> In order to support page reporting it will be necessary to store and
> retrieve the migratetype of a page. To enable that I am moving the set and
> get operations for pcppage_migratetype into the mm/internal.h header so
> that they can be used outside of the page_alloc.c file.
> 
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>

I'm not sure that it's great idea to export this functionality beyond
mm/page_alloc.c without any additional safeguards. How would we avoid to
messing with ->index when the page is not in the right state of its
life-cycle. Can we add some VM_BUG_ON()s here?

-- 
 Kirill A. Shutemov

