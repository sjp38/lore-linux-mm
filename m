Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7EC2C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:26:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66145218AD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:26:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66145218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 156028E00CD; Wed,  6 Feb 2019 11:26:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 105FD8E00B1; Wed,  6 Feb 2019 11:26:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE8B98E00CD; Wed,  6 Feb 2019 11:26:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9C478E00B1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 11:26:26 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id e68so5258391plb.3
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 08:26:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mQtiybdErV8s1OsqpG1q41Tptk1Di0HWlyJEPWij4Ag=;
        b=BcAoYR2eX2Xrn1EUxGaQbH1Aj+nWlS3L/nBS1VNuSzkAJ6fQVq1SbZ7/8aOlkwoR27
         uS7BoN1BtEf2BRP06ELboyK48isjeeyJbBWwI1JgzENstqVeN16ghJkOnsgGA69cVMw0
         g1CSUTzpNP8V4a9FM+THBcDWvT+pHf+zZlB2Du51aiW3G5IenT0QO0dWnp1UvQUEER6e
         S64amrFMJqjZDuJL1o8rYCS6X0HbCQ0fPzrFAfAdD+NP0p2dCAilpDy8xYx5ZwP1cTLH
         Vbdm3oMPcoWjPpl6B8cLRrn9uhVIMgHaof+W3M5owcGw0UdnQuZT8jNY+t++XtDLqNGo
         CYBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubIgKoOeXNkkzb+OAHGtjo1wN3BwN/60wAMUYEgP7cRbPKQ7Rwl
	Ty1VodHqIgDo3k+TmAkV9d+oKVEVJNZLeH7MjbH5K9rEtrBby1mixZjzN7Lfi6DtmLs9z/SNlOA
	qjKlRPnxLCAVqLLw+mFDsznPEYSjUYLzCM3T3i6M4UvB85TigA1K8BiFXpwbQXbraLA==
X-Received: by 2002:a65:60c5:: with SMTP id r5mr5702984pgv.427.1549470386353;
        Wed, 06 Feb 2019 08:26:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ4vi9PBONTcbq9RKeP3qa2DIzYyLYA20Z2vqyhPXjrhzAMXp6RoPAUsDVeT6me/p2gH3E3
X-Received: by 2002:a65:60c5:: with SMTP id r5mr5702938pgv.427.1549470385677;
        Wed, 06 Feb 2019 08:26:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549470385; cv=none;
        d=google.com; s=arc-20160816;
        b=mlZWi9hUf1XYrhPV6LpzgK8+YcH98Qi9pKigcCwhAjbxPr0SlW6YqjQcyfdxNjteEH
         wjs8gxS9R0qL3l4YYhoSTyRt8o+JymHnmvXjlMdi/u9Pr7zwDyM++V73eCKCMgQvCcJE
         3MD7dCY3VJnoNMHJgcHsldbSshOjgBAjQ2ERtOHn5Pz3MYZeYC5nj7Ch+Qh9it4filMd
         E4rmuOQ3UkxShL817vjSiDBBoutTktF/gv6ql9bdQ+a0ofwcbBMatOTc3CpHG1sMVcOm
         IO1Q3nYjdDqMoHoSJQw+gFcLOd2R23TEGh5cRarS1e5PaALn1H4lU98HkMbiVLb9mcG9
         fnnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mQtiybdErV8s1OsqpG1q41Tptk1Di0HWlyJEPWij4Ag=;
        b=cZHAvtNSJGC2KyIouw+WGFhBMK9QaYxOptIMkrLGxIDPvbP2ouKsorHDQ1cccyZoFI
         98DnVkjsdQMjF0jlbOkn7QlqJaWnZmgYTvayG2Kjv80NyM63OcjG2ezoS4hXZVlLzJB9
         CwyqQf4TTIjSkfcyI3rp+MLds0gm/QOjQYiMrc/3KbrKFa8CbOAQ3+OpzZetxiO39FMT
         uI195vbAkRTu5IGyEgPvg9PJIKnpjKbDt4+c9mMSoIspdxvO4/ymQUTLqmLuLgHirkjM
         M7LGWJRLt1hIGDy6524TqnhaoDeCr4IjXO7ty+Csh7eL7tkHG08UebylmCZhadREvswl
         tSKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id u137si6450829pfc.133.2019.02.06.08.26.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 08:26:25 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Feb 2019 08:26:25 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,340,1544515200"; 
   d="scan'208";a="132038943"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga002.jf.intel.com with ESMTP; 06 Feb 2019 08:26:24 -0800
Date: Wed, 6 Feb 2019 09:25:53 -0700
From: Keith Busch <keith.busch@intel.com>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org,
	linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>, linuxarm@huawei.com
Subject: Re: [PATCHv5 10/10] doc/mm: New documentation for memory performance
Message-ID: <20190206162553.GI28064@localhost.localdomain>
References: <20190124230724.10022-1-keith.busch@intel.com>
 <20190124230724.10022-11-keith.busch@intel.com>
 <20190206104552.00003bad@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206104552.00003bad@huawei.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 10:45:52AM +0000, Jonathan Cameron wrote:
> On Thu, 24 Jan 2019 16:07:24 -0700
> Keith Busch <keith.busch@intel.com> wrote:
> > +	# tree -P "read*|write*" /sys/devices/system/node/nodeY/access0/
> > +	/sys/devices/system/node/nodeY/access0/
> > +	|-- read_bandwidth
> > +	|-- read_latency
> > +	|-- write_bandwidth
> > +	`-- write_latency
> 
> These seem to be under
> /sys/devices/system/node/nodeY/access0/initiators/
> (so one directory deeper).

You're right, I used data from the previous series to generate that.
 
> > +	# tree sys/devices/system/node/node0/side_cache/
> > +	/sys/devices/system/node/node0/side_cache/
> > +	|-- index1
> > +	|   |-- associativity
> > +	|   |-- level
> 
> What is the purpose of having level in here?  Isn't it the same as the A..C
> in the index naming?

Yes, it is redundant with the name. I will remove it.
 
> > +	|   |-- line_size
> > +	|   |-- size
> > +	|   `-- write_policy
> > +
> > +The "associativity" will be 0 if it is a direct-mapped cache, and non-zero
> > +for any other indexed based, multi-way associativity.
> 
> Is it worth providing the ACPI mapping in this doc?  We have None, Direct and
> 'complex'.   Fun question of what None means?  Not specified?

Yeah, my take on "none" was that it's unreported and we don't know what
is actually happening..

> > +
> > +The "level" is the distance from the far memory, and matches the number
> > +appended to its "index" directory.
> > +
> > +The "line_size" is the number of bytes accessed on a cache miss.
> 
> Maybe "number of bytes accessed from next cache level" ?

Sounds good.

