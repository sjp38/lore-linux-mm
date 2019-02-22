Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 268CCC10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:13:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C16752075C
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:13:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C16752075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 205268E0128; Fri, 22 Feb 2019 13:13:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B37F8E0123; Fri, 22 Feb 2019 13:13:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F2798E0128; Fri, 22 Feb 2019 13:13:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C2E188E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 13:13:16 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 36so1063199plc.22
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:13:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=UPXqYQSvBigj5Z/jCDB0is60bv3UjJTf/SF5G7T2YLo=;
        b=IPtL0FVwwQvsTUS6UsPJTMefGbgZa4Tk88CGixs0fEdTccvxFlmoUTjingID0yCnMe
         MT5z5L3m4hL5XWZVLQQiU0FLE99zmKmh0KVABT50TEMxn2m9irLyMywOd6OVRJrS2vkP
         U96hob+NPtcuBLSOeeXiqVWZ1V1dtp4mkkrNWpOslzRmHnN4hntEGS0vlvYe3HvplWkL
         qlm5Q3GMyDOmKUhzuWCTjAJTS5jWYDrH+m7uLJDEtUJS9EMBe6f9f/BxFpvqT900/+Ol
         H0OTaFTbrrWKre1HfPA31PavPr9bxCSzYcxprpli66DeB52cSroABQIhlioDwQC1/8xT
         QG5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaetVGoECUrUXRTcMRzgSwqCNb/lCBzGPhFVjzRG38ZL5muo73x
	L18EzpWh/b7ibMhgijXW+3Q88tn+ijPmZ9TQigTOFIoqciP92lj7mGF4gDigcKgVTAxfrjEayUc
	DJY7vs7foEhF+JU2nLPHizWcrYQn87M4nT6frUaEkAixPg6wIIZgPJ1M+cmUhCONirQ==
X-Received: by 2002:a17:902:788d:: with SMTP id q13mr5531948pll.154.1550859196422;
        Fri, 22 Feb 2019 10:13:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYujdZNqyan4dQgs+BBEGZ4n9NXsqMJVP/WCL8AcVgHxL3xkc8ZkCg3BpGof1LLFdnsNzlt
X-Received: by 2002:a17:902:788d:: with SMTP id q13mr5531884pll.154.1550859195552;
        Fri, 22 Feb 2019 10:13:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550859195; cv=none;
        d=google.com; s=arc-20160816;
        b=Ytn6MOpgp1KSv6LbB1QtVyYBigcYgCo7ppKxnIdPjBpZJT+v3dXT5dNP6F9ST4UJ4b
         c7RhU8CPGv2ZK7xXBwXCGlo4XEBdb4TNwrBH1Eq4q6PEh+u20RzVsNgUisCV/0nu67tf
         y37zaPvxW3VEcvz47JM6Hbh5IUCt4593Ig1uXDKWrNbtOBxcXjRDE+vNVruVZeq5XmT7
         qS2U33RgOLHl/5yh2qRvzcD31q05+1r7r/7HqpAMAIro4QZen9MgYjDwMLSDcuRp1bP5
         bcuA+7cIXm6Gq0thSUrpCX9QBOGsDSz/sIHc82wVi7011/nBOx7E5Dhh3a5Pvv6WLeVg
         1A/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=UPXqYQSvBigj5Z/jCDB0is60bv3UjJTf/SF5G7T2YLo=;
        b=jGmTV6UUa3wd+pshIuDxgg2bVnHjjSSDwPwf1bFQMp1BVeSRjfa4AWaZ7V3gwpMnYG
         ++5GLwJ6yyQFFbZazNGt5Kj/eOUQONoxjqZwKOIw/BQ4BSHug4lRaJVqVdKg4CkC5ulF
         4pIcV4P2jDT22/h7AVJRQ8ZzlZbAW+jythrR8Bl/2CppjidYCRF4qnY8B5QKg30I5i3+
         dBLyhed0z/B6WRBAsTsNOn1dFEJUS3jV+ET8eNiuX9W5m3LBHH41/ebGsdiVJed+nUS7
         C0zmg8iCaanOQqI6sOFtzzGqb1U+w3xSDH7kxoUq6oHoxb3cdxYhg6RK/fkZ29JI39wZ
         LyNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r35si1899753pgl.379.2019.02.22.10.13.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 10:13:15 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Feb 2019 10:13:14 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,400,1544515200"; 
   d="scan'208";a="136443818"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga002.jf.intel.com with ESMTP; 22 Feb 2019 10:13:13 -0800
Date: Fri, 22 Feb 2019 11:13:17 -0700
From: Keith Busch <keith.busch@intel.com>
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org,
	linux-mm@kvack.org, linux-api@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv6 06/10] node: Add memory-side caching attributes
Message-ID: <20190222181316.GE10237@localhost.localdomain>
References: <20190214171017.9362-1-keith.busch@intel.com>
 <20190214171017.9362-7-keith.busch@intel.com>
 <16221be9-2f60-3a39-fd6c-5299cd94dc02@inria.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <16221be9-2f60-3a39-fd6c-5299cd94dc02@inria.fr>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 11:22:12AM +0100, Brice Goglin wrote:
> Le 14/02/2019 à 18:10, Keith Busch a écrit :
> > +What:		/sys/devices/system/node/nodeX/memory_side_cache/indexY/associativity
> > +Date:		December 2018
> > +Contact:	Keith Busch <keith.busch@intel.com>
> > +Description:
> > +		The caches associativity: 0 for direct mapped, non-zero if
> > +		indexed.
> 
> 
> Should we rename "associativity" into "indexing" or something else?
>
> When I see "associativity" that contains 0, I tend to interpret this as
> the associativity value itself, which would mean fully-associative here
> (as in CPU-side cache "ways_of_associativity" attribute), while actually
> 0 means direct-mapped (ie 1-associative) with yout semantics.
> 
> Brice

Yes, that's a good suggestion.

