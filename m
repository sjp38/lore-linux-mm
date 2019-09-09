Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A930C4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 16:34:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1477C21D79
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 16:34:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="qXurPKBe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1477C21D79
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0EBF6B0005; Mon,  9 Sep 2019 12:33:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE5A26B0006; Mon,  9 Sep 2019 12:33:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFBC46B0007; Mon,  9 Sep 2019 12:33:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0072.hostedemail.com [216.40.44.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91D646B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:33:59 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 4620B181AC9AE
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 16:33:59 +0000 (UTC)
X-FDA: 75915928998.28.ice02_7a0af4fe3272f
X-HE-Tag: ice02_7a0af4fe3272f
X-Filterd-Recvd-Size: 5683
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 16:33:58 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id f19so13496424eds.12
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 09:33:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QxM9mJktlH2b9W/UrzlsSXilA2r8zVDwLuT+VMLdcm4=;
        b=qXurPKBeQ/50vkdVpdFd3RSFI5atfLR6gPp0JjnuECbcNWDtU74AipRoFJSjkAcOy3
         FfBcaM9GRBg8SD2T1Q6QoVjNV5wloxgkJnhSSmsRUEKZNf8DGRghZRRByKpks6ejiozo
         IBd+bYzG5nzJgRXFlAjDxtSmKg1yemVBjKrqzFuH6AOe4YDZR0qX81XGVRy28dB7ixl1
         n3WhCeqgxzfaUFtdBqVH7E1BzdRpmPnLzzsoVL0ITc9UsIUeivBdItfSqWIxJiTo1tiH
         5M7XG+THkq7pCgQAk0LidvkGLut7VIK/flw5PVz0tWv6WktP5+8smPwLaz/8iyvR625A
         zoNw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=QxM9mJktlH2b9W/UrzlsSXilA2r8zVDwLuT+VMLdcm4=;
        b=bjBsD1v2L9OQEgHn2K2PI/bzrg8yOe9N+clYvF8sJEyIhmibRKYPwZya9WwVnotEPK
         0gfyQN96Lj7BV2cf7bHJYFw8bqJCk0JzV+eRjGl1V0ur+HspSTj/kVCFTMxlLjD5gNe0
         vL7jRlPxoVa/MNssGWFhsef3KUF+WsaZuxf/CYaZH+UYqMD0z/pE5o5Um1QuArQnv4No
         3xtKdkE3xhkT0fNLndSCuSCIoAHmcenPha4DLLgDQMDwSR0U5q99i0qkKKHrd0vyaSSA
         BQZ/I8HlQM5Fqe9jxiA6JxQN5XgrZRIHWTshTVbxglX3M8DFCU6I7+oeSTiUa4qoe3WF
         hzHA==
X-Gm-Message-State: APjAAAXJFmGCr9/OxhnU73mn0JBubtp3pUr17QvtlV0eLAkwHquy05QM
	9js/055ZMMHT+I2ltzbVNG7Ajg==
X-Google-Smtp-Source: APXvYqzchdFdfE1hclnLKzl1/sGN9sqBpqJacSjdc7si3DfczRfamQmuNJFhSHuWNQ94FDn9AyIfeg==
X-Received: by 2002:a17:906:3485:: with SMTP id g5mr19264541ejb.76.1568046837302;
        Mon, 09 Sep 2019 09:33:57 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id w11sm1781938eju.9.2019.09.09.09.33.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Sep 2019 09:33:56 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 56B881029C4; Mon,  9 Sep 2019 19:33:55 +0300 (+03)
Date: Mon, 9 Sep 2019 19:33:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org,
	mst@redhat.com, catalin.marinas@arm.com, david@redhat.com,
	dave.hansen@intel.com, linux-kernel@vger.kernel.org,
	willy@infradead.org, mhocko@kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, will@kernel.org,
	linux-arm-kernel@lists.infradead.org, osalvador@suse.de,
	yang.zhang.wz@gmail.com, pagupta@redhat.com, konrad.wilk@oracle.com,
	nitesh@redhat.com, riel@surriel.com, lcapitulino@redhat.com,
	wei.w.wang@intel.com, aarcange@redhat.com, ying.huang@intel.com,
	pbonzini@redhat.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, kirill.shutemov@linux.intel.com
Subject: Re: [PATCH v9 6/8] mm: Introduce Reported pages
Message-ID: <20190909163355.zueprine5zqwexi4@box>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190907172553.10910.72962.stgit@localhost.localdomain>
 <20190909144209.jcrx6o3ntecdaqmh@box>
 <acfe9744deaede8f8c4fa4f40a04514d9f843259.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <acfe9744deaede8f8c4fa4f40a04514d9f843259.camel@linux.intel.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 09, 2019 at 09:25:04AM -0700, Alexander Duyck wrote:
> > Proper description for the config option?
> 
> I can add one. However the feature doesn't do anything without a caller
> that makes use of it. I guess it would make sense to enable this for
> something such as an out-of-tree module to later use.

Description under 'help' section will not make the option user selectable
if you leave 'bool' without description.

> > > +	mutex_lock(&page_reporting_mutex);
> > > +
> > > +	/* nothing to do if already in use */
> > > +	if (rcu_access_pointer(ph_dev_info)) {
> > > +		err = -EBUSY;
> > > +		goto err_out;
> > > +	}
> > 
> > Again, it's from "something went horribly wrong" category.
> > Maybe WARN_ON()?
> 
> That one I am not so sure about. Right now we only have one user for the
> page reporting interface. My concern is if we ever have more than one we
> may experience collisions. The device driver requesting this should
> display an error message if it is not able tor register the interface.

Fair enough.

> > > +	boundary = kcalloc(MAX_ORDER - PAGE_REPORTING_MIN_ORDER,
> > > +			   sizeof(struct list_head *) * MIGRATE_TYPES,
> > > +			   GFP_KERNEL);
> > 
> > Could you comment here on why this size of array is allocated?
> > The calculation is not obvious to a reader.
> 
> Would something like the following work for you?
>         /*
>          * Allocate space to store the boundaries for the zone we are
>          * actively reporting on. We will need to store one boundary
>          * pointer per migratetype, and then we need to have one of these
>          * arrays per order for orders greater than or equal to
>          * PAGE_REPORTING_MIN_ORDER.
>          */

Ack.

-- 
 Kirill A. Shutemov

