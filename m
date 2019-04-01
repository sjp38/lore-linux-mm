Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68CE2C10F05
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 04:58:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14B8F20896
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 04:58:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14B8F20896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 526196B0003; Mon,  1 Apr 2019 00:58:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D5326B0006; Mon,  1 Apr 2019 00:58:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EB9B6B0007; Mon,  1 Apr 2019 00:58:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 077FF6B0003
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 00:58:58 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x2so3458150pge.16
        for <linux-mm@kvack.org>; Sun, 31 Mar 2019 21:58:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ej2Q0qRvz8B14shkQbVDplcYjITBeWriGFg8TVeUH90=;
        b=pD8mLBalEiAL2jVYl6cPeMGfYubJFJbQAb8Q6nHJqYyTorxxVp3xOG3M3qwxCFd4k1
         vvsiRW1VWMK0tRDP5HrXugYX44t0xzp9Xcetgjw4+KDJIDGTj/2rM13lEkBllC91YmW5
         nBhyoku+f1sjDNspU2UEjcOOiL3O9fRuCUDla/ZovM1xUcdoeESepWfwGGg9hRMtUxtC
         T1zO8eNZTHojETWJsiufRB3OU1BSYd+ixPYVMv/+3deJmFNOWw2EAxPXv+9Z/u7hGjcw
         j0G+KmLhgjpuCrPGFRSI3K7RU/ddEz4+pHQcao0ArpPErX28kPxDupqLqmiSMrC7+Iwa
         VWpQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.93 as permitted sender) smtp.mailfrom=kbusch@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVP/ohZgHXv3tZwV/0hor0FNxRYjk8v4R5B/tMKS2pLrqgp3k25
	VP/s9lK8dywUcMpHnO9eJGDFQJq3uBPKvodHZ0syS4LEyc4npmIakOPDOFYepAWw2Uu2WK55dhl
	lBiaDFaWG4nUY8XQMKMDZ4wkRoSY/rV7HxnW65IJCl4x4a6hHWMXrncTxXM0cE54=
X-Received: by 2002:a63:b305:: with SMTP id i5mr12993373pgf.274.1554094737571;
        Sun, 31 Mar 2019 21:58:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFa+tBo+oWNLI7g44xw2UMIeb2iDt/N8KEtA9ssEBeUFW2Kolb9Fz2aDCBveUG/jIhO5Xq
X-Received: by 2002:a63:b305:: with SMTP id i5mr12993332pgf.274.1554094736645;
        Sun, 31 Mar 2019 21:58:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554094736; cv=none;
        d=google.com; s=arc-20160816;
        b=nVcuog903hRKOtAsYHtv3vZQ8leCZc2/7h41+S1FIWXPsksn15qWNXH4nHL1VHcb0O
         Yv1XAD72aQBXGIH7QEw+XbsVC2/LPYSkhjcEWON0r7Wdgk4pV6LtYCaaFnH057Y8lpAn
         hGinD/GSZcfGp3GRwOrHV2Q6aU6OkCVAnoSEWG3F+XQ0l6YyIz9Yzx1t9Y4oS0JTLllA
         FkqVHo9v2LxNlDZtjzQitSi83wwYPL3F556liit0RKuz+DVhL8M2RtqxnE4kycyAXGPC
         QmWotQKjxRIUET4rWluXqdwDx3k9KtCA2VaZbm6M+lut5XGv2v+FmOPdDEcEK3//sFsG
         L0nA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ej2Q0qRvz8B14shkQbVDplcYjITBeWriGFg8TVeUH90=;
        b=B9DySSoYhyGXFJC02++hMJrj4VR5Md1fyZyABFARb950SYRy+p+xVeOtLWOE91B73t
         2nIL0WwPYGFLAcWGb5OdvJKfvWLdL5MwTtXhxGa3Xt8fNNvqKrIVvQqY00LFX440CusP
         I8MUdQEKs0kjJdM/TkDwgackTdfAPc9RzngmRbEi5MAIkUzpk/GZ8h2s3qHCfeccpHkF
         KLKHTxNSHeafdNtyQ46PmxyLzydRfXaqif1cpujdC0HzIXazEQQphDhH7iUL1taTFqEF
         nqcKtonRuz2RbIKV/MjjnvXTAx+57xMefXEaYiB9QgUi1apUNZARVXKgUbEZuBLEeuO0
         3oHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.93 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 60si8421592plf.122.2019.03.31.21.58.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Mar 2019 21:58:56 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.93 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 31 Mar 2019 21:58:55 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,295,1549958400"; 
   d="scan'208";a="160163267"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga001.fm.intel.com with ESMTP; 31 Mar 2019 21:58:55 -0700
Date: Sun, 31 Mar 2019 23:00:16 -0600
From: Keith Busch <kbusch@kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Keith Busch <keith.busch@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux API <linux-api@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Jonathan Cameron <jonathan.cameron@huawei.com>,
	Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: [PATCHv8 07/10] acpi/hmat: Register processor domain to its
 memory
Message-ID: <20190401050016.GA16792@localhost.localdomain>
References: <20190311205606.11228-1-keith.busch@intel.com>
 <20190311205606.11228-8-keith.busch@intel.com>
 <CAPcyv4j5bLiUtmjdnjt7KNOtNm4sRHWp=5T3m1bWD=U1zBXeqQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4j5bLiUtmjdnjt7KNOtNm4sRHWp=5T3m1bWD=U1zBXeqQ@mail.gmail.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 02:15:03PM -0700, Dan Williams wrote:
> On Mon, Mar 11, 2019 at 1:55 PM Keith Busch <keith.busch@intel.com> wrote:
> > +static __init struct memory_target *find_mem_target(unsigned int mem_pxm)
> > +{
> > +       struct memory_target *target;
> > +
> > +       list_for_each_entry(target, &targets, node)
> > +               if (target->memory_pxm == mem_pxm)
> > +                       return target;
> > +       return NULL;
> 
> The above implementation assumes that every SRAT entry has a unique
> @mem_pxm. I don't think that's valid if the memory map is sparse,
> right?

Oh, we don't really care if multiple entries report the same PXM. We do
assume there may be multiple entires with the same PXM and have tested
this, but we're just allocating one memory target per unique memory
PXM and consider multiple entires comprise the same memory target. That
is okay if since we only need to identify unique PXMs and have no use
for the adderss ranges that make up that target, which is the case
for this series. I see you have a future use that has address ranges
considerations, so separate targets for sparse ranges can definitely
be added.

