Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44EC8C282CC
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:35:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DAC721721
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:35:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DAC721721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 990BC8E0056; Thu,  7 Feb 2019 12:35:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 919AB8E0002; Thu,  7 Feb 2019 12:35:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BC578E0056; Thu,  7 Feb 2019 12:35:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF958E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 12:35:23 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id h26so394300pfn.20
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 09:35:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wJETO+Ta/zADySOqP6xlMu9L04nwUVuKDpERbQR6imo=;
        b=s7vfwWKMZY0YdnIWfjHt0oK+fuG+nSB8qAnXNq7ECpSwBmjvBtiJ2MEUXKUcL3htj6
         PMblGaEmJ9qqUL8CGSFrQjXVM4JWdfTLkk4KauxNdYSQetnOsxMEOlWUfEO5QiO+tEkz
         rbiBodi6Bd/fFylyoNRFCQWl/Jgj3vmQv/8gHf49AKI3HN2VdCIgNReTiNXqViLcSZcY
         idvAp5zyi93mZmJcLriAaxmrfgY4C5hdQuw4kWPuyBgaxqMHSHJB+Ihq6ORQFlWrhY9p
         vXHBQjtFabHcLOTTCF8J8E0XxpxrAzFFF9oWiU+XEkNvkdSVhTtXbNcGiQ9DUnDveXB6
         fXdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAub1WkpSQXX4eyBMPoCgy0W+9JAEISF/A013SX+KNO4hvD5XO3Cy
	LnES6Xuse+PDiSUWYdmY4OIY3PDfoiNTYwgFJNbyVzv1A/z8KVQmuUkNah/UNfKqp7s1ushDbJ/
	sthL7uj1rRwNAQDhUJV/hTqvQYOqF0Uxhb7WsWYxzInr29LChJtR5A28xFUiesiVOmg==
X-Received: by 2002:a63:1824:: with SMTP id y36mr16060734pgl.68.1549560922870;
        Thu, 07 Feb 2019 09:35:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbSsdRqJ3prNZ9UiDPRFxjcTYClh1fBKEnXrCATdSPlSZNIZ3JRTO1CJKlfvfgvyT6Z4MW7
X-Received: by 2002:a63:1824:: with SMTP id y36mr16060676pgl.68.1549560922154;
        Thu, 07 Feb 2019 09:35:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549560922; cv=none;
        d=google.com; s=arc-20160816;
        b=o1dDCtftcNW/r5h62StK6SYsEP78+mMsAeCJE1/UnoZzC2De7TDPTFhT01mAHVaUou
         PpvTZU9GQ0anzVa3rVxwzcGYSXCyyDCfmzpg45C/03AE/YsJHGfRxfG6mKiSuqYdlxbS
         N1+cjmLA+/GXJY5K1a3jTdDXs1SfWD6OpHJvG84n5QShqWQwlgsdb9O2hhJji3QMEojY
         uwx39vaXtZqjxmz7BCh2HDb6FKi+BpPBVBkNpdgVm5VwT+gSa/sB6Uq3RK+9YZiSleXx
         fWBWVUW2mDUvGGZclZ00TW8xpCwHrJye5AjWRDVmYtaYvR629JdH66lYFoU5xdj7qtgo
         3FhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wJETO+Ta/zADySOqP6xlMu9L04nwUVuKDpERbQR6imo=;
        b=edzr3r3kSluVbJUc+6hU76rAcVs8qh7m+j1dkbh6cq/xm9/kt6ACvHGc8KweiXSMXO
         DfEWZtqhv6qD478+RGU1ngFOm+cVZtQsC29KLdmpgsVDxHEKhTfjVLXSPicpw55gBwPx
         HbZVfgSlKxv6YyvveO2+zvSISDI+U0+R2lErdiNcjXpqtwpHvzUgfGCao4QaUiL7xbyq
         +EDo6dacZuprhzpL29aqZaelo0/4oO86Yr9Q8wjIYkyUJENmV3F0Kj1T4NYS+S4xwabI
         yxsjhWauEwpDmlln4kKE6s0VAlLjlwg9TQMLyom60LufJn2ca2toKt3cdbSge2OkMCc9
         VlZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id q15si8844683pgm.420.2019.02.07.09.35.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 09:35:22 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Feb 2019 09:35:21 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,344,1544515200"; 
   d="scan'208";a="136687393"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 07 Feb 2019 09:35:20 -0800
Date: Thu, 7 Feb 2019 09:35:04 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Christopher Lameter <cl@linux.com>
Cc: Doug Ledford <dledford@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190207173504.GD29531@iweiny-DESK2.sc.intel.com>
References: <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 04:55:37PM +0000, Christopher Lameter wrote:
> One approach that may be a clean way to solve this:
> 
> 1. Long term GUP usage requires the virtual mapping to the pages be fixed
>    for the duration of the GUP Map. There never has been a way to break
>    the pinnning and thus this needs to be preserved.

How does this fit in with the changes John is making?

> 
> 2. Page Cache Long term pins are not allowed since regular filesystems
>    depend on COW and other tricks which are incompatible with a long term
>    pin.

Unless the hardware supports ODP or equivalent functionality.  Right?

> 
> 3. Filesystems that allow bypass of the page cache (like XFS / DAX) will
>    provide the virtual mapping when the PIN is done and DO NO OPERATIONS
>    on the longterm pinned range until the long term pin is removed.
>    Hardware may do its job (like for persistent memory) but no data
>    consistency on the NVDIMM medium is guaranteed until the long term pin
>    is removed  and the filesystems regains control over the area.

I believe Dan attempted something like this and it became pretty difficult.

> 
> 4. Long term pin means that the mapped sections are an actively used part
>    of the file (like a filesystem write) and it cannot be truncated for
>    the duration of the pin. It can be thought of as if the truncate is
>    immediate followed by a write extending the file again. The mapping
>    by RDMA implies after all that remote writes can occur at anytime
>    within the area pinned long term.
>

This is a very interesting idea.  I've never quite thought of it that way.

That would be essentially like failing the truncate but without actually
failing it...  sneaky.  ;-)

What if user space then writes to the end of the file?  Does that write end
up at the point they truncated to or off the end of the mmaped area (old
length)?

I can see the behavior being defined either way.  But one interferes with the
RDMA data and the other does not.  Not sure which is easier for the FS to
handle either.

Ira

