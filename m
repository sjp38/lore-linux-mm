Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D021C48BE3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 21:31:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 047842070B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 21:31:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 047842070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=firstfloor.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BC8B6B0005; Thu, 20 Jun 2019 17:31:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96DC18E0002; Thu, 20 Jun 2019 17:31:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 834018E0001; Thu, 20 Jun 2019 17:31:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 48E5E6B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 17:31:51 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a20so2863281pfn.19
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 14:31:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=u/4lpOTrasc/MMyF7sEUYw6eNKYx+4DGyx+RyjMFrII=;
        b=M0bcaFxLFSCHi1OQ1e4ccC+I7CmJoXE8A6gVQ4Yd9K8wHswGj+c1a2dnJt05Q0Vi9G
         x0JNgxaA/w2ChiGRd579/45eE9StQXkhG7NXK9acqmKNKl288tBErw2IpDlQoiW/+H9/
         GAwIPF4BweASRepcmKDrJIV1GnH0AzOjMJO7mRRgQ2b/vYGMXvq8hcuHnNHKuJqSh7De
         SDPD6HAYhVbSP9/tsa5nxEKEnygqBcGBBwzUMa3wfa/Gu6nZFKoRSBn/b7CBooyuMdC+
         RrWL8+10biASWOvQ8Z2MXLwH9FnWfICc6/HWTsOzCIiQeRRYe/pPJdmNnk7uRktKUSOE
         Cj4Q==
X-Original-Authentication-Results: mx.google.com;       spf=fail (google.com: domain of andi@firstfloor.org does not designate 134.134.136.126 as permitted sender) smtp.mailfrom=andi@firstfloor.org
X-Gm-Message-State: APjAAAV6gNFIIOgw4PPIPVdBFIooar0z1FqUtij5C6JAmzy98DK+N6G8
	XVYCMNYVRJKXNZI2oL5B78afIlXwoNiyS3ctyqtlp6v4NQIXWxqT6UuSmgq+FuudxLIuP6Rbd0w
	dV3yIuCQX5P7zDjwsBCCmWObl9XE5PjC9oj9BoU3oVNNz5DP2/LRo3VV/32cNCCM=
X-Received: by 2002:a63:1d5c:: with SMTP id d28mr4238061pgm.10.1561066310922;
        Thu, 20 Jun 2019 14:31:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwFZtBhufm9cDvlxV/9TNQa0GL/T16PY3/OwSFBHyyQZGDUBwcygXPPj2xKvj9LV+ldFOL
X-Received: by 2002:a63:1d5c:: with SMTP id d28mr4238023pgm.10.1561066310179;
        Thu, 20 Jun 2019 14:31:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561066310; cv=none;
        d=google.com; s=arc-20160816;
        b=d8ODZ+aTyEuMUdPf1YDoU/wfp7Rdr7KDrRXj08UIMZo4CofQ+HlNIVNEyy2FGRXvPH
         z8cUzCtzb5QOXPNdxzBm892AnhD4Mn6gCkgiyrNhYaMMUmUQCjUH0O6fq4mBHo3Doi32
         9wAYTOrVlLB18a83v40bVX2U0zyt8YTlpMuLke48Ffp5o9FwcW2hdUtZLqfMUSxOilx4
         m5l3HtVhwTvOw/AFBRoKSKIKwTngbgs14EYkm1Q1Rh4JTAWd5CeBluAlcAamfK56QWub
         ziZodQGd28Crfeqlx2I6VeTYGPbu/QYw8itBH1L/tROxEoC//YP9Gghu1tUTjqG0LyEW
         bKqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=u/4lpOTrasc/MMyF7sEUYw6eNKYx+4DGyx+RyjMFrII=;
        b=eUrOH+hOEv7x8l69vfmu8PT4J9m1U8ZG++T8i6gCKl+ntokcQGVqVlhL8WbXN8WMrh
         5AmLddK3GtLvslmvdwX7k2C4k8edjJGZOZ/q4Iuqh2NGtwxLeHGWUfoBH7WfWh7kvI1b
         NkRvfXsDx0bdBf8zXTsf/iM5HH96/Ld8zm/jHX47k9ohud/P/TjvT81Hlys0zeux8N3O
         OCqdyCjjC7VaTrP97eozicyonYNNDpcXDl9t4fSZTZXFPoZelmxICVYndiaQxgmLZsFY
         9Y5sLtMMZLtktrO5mEKo+eOVSfwdpefhh7cwZ86pwfOxlqJfI2JOKHT4xPnVwKdLT97T
         pqWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=fail (google.com: domain of andi@firstfloor.org does not designate 134.134.136.126 as permitted sender) smtp.mailfrom=andi@firstfloor.org
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id k3si763113pjt.87.2019.06.20.14.31.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 14:31:49 -0700 (PDT)
Received-SPF: fail (google.com: domain of andi@firstfloor.org does not designate 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=fail (google.com: domain of andi@firstfloor.org does not designate 134.134.136.126 as permitted sender) smtp.mailfrom=andi@firstfloor.org
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Jun 2019 14:31:48 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,398,1557212400"; 
   d="scan'208";a="181950299"
Received: from tassilo.jf.intel.com (HELO tassilo.localdomain) ([10.7.201.137])
  by fmsmga001.fm.intel.com with ESMTP; 20 Jun 2019 14:31:48 -0700
Received: by tassilo.localdomain (Postfix, from userid 1000)
	id 8001B300FFA; Thu, 20 Jun 2019 14:31:48 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>,  Nadav Amit <namit@vmware.com>,  Andrew Morton <akpm@linux-foundation.org>,  LKML <linux-kernel@vger.kernel.org>,  Linux-MM <linux-mm@kvack.org>,  Borislav Petkov <bp@suse.de>,  Toshi Kani <toshi.kani@hpe.com>,  Peter Zijlstra <peterz@infradead.org>,  Dave Hansen <dave.hansen@linux.intel.com>,  Ingo Molnar <mingo@kernel.org>,  "Kleen\, Andi" <andi.kleen@intel.com>
Subject: Re: [PATCH 3/3] resource: Introduce resource cache
References: <20190613045903.4922-1-namit@vmware.com>
	<20190613045903.4922-4-namit@vmware.com>
	<20190617215750.8e46ae846c09cd5c1f22fdf9@linux-foundation.org>
	<98464609-8F5A-47B9-A64E-2F67809737AD@vmware.com>
	<8072D878-BBF2-47E4-B4C9-190F379F6221@vmware.com>
	<CAErSpo5eiweMk2rfT81Kwnpd=MZsOa01prPo_rAFp-MZ9F2xdQ@mail.gmail.com>
	<CAPcyv4iAbWnWUT2d2VhnvuHvJE0-Vxgbf1TYtOPjkR6j3qROtw@mail.gmail.com>
Date: Thu, 20 Jun 2019 14:31:48 -0700
In-Reply-To: <CAPcyv4iAbWnWUT2d2VhnvuHvJE0-Vxgbf1TYtOPjkR6j3qROtw@mail.gmail.com>
	(Dan Williams's message of "Wed, 19 Jun 2019 14:53:54 -0700")
Message-ID: <8736k49c57.fsf@firstfloor.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:
>
> The underlying issue is that the x86-PAT implementation wants to
> ensure that conflicting mappings are not set up for the same physical
> address. This is mentioned in the developer manuals as problematic on
> some cpus. Andi, is lookup_memtype() and track_pfn_insert() still
> relevant?

There have been discussions about it in the past, and the right answer
will likely differ for different CPUs: But so far the official answer
for Intel CPUs is that these caching conflicts should be avoided.

So I guess the cache in the original email makes sense for now.

-Andi

