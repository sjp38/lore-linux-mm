Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00D8EC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:23:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFFB421B1A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:23:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFFB421B1A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 594DC8E00EF; Mon, 11 Feb 2019 10:23:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 544D18E00EB; Mon, 11 Feb 2019 10:23:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40EE68E00EF; Mon, 11 Feb 2019 10:23:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id EDDC28E00EB
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:23:26 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id y8so8551819pgq.12
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:23:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/zgghYOUI+qKDydm+9UQMOAMh5ccTjkEFBniIeQNL7E=;
        b=daXIDZnXf+aefaBU48KLhqbri8m5FeZGVQNUM96W/7NxSL1sclT82TfU1CXokNGZMQ
         EX9dLv2lJQ5dGeR6OeioHyS8QM5lT1si2wZqYaurP4NqCiMO+VlLmf2Imc6Sq84W46wp
         TOLJNJ3yooyymfQt49iMuG/h7elJhaF1dPkHVqFBBd0rpvzYa1aMCApoPD5Wn0GCQtdH
         EEjqgH3Dnlj8LMe2TdAYakQGKqwne3D2mCc7T6aHzwkvLKwv1EiIlt5zU3EcG02GCHME
         ETuKh5CVYzjxxCUkYgRlXMmP3NI/Qbye5zydJq+dIWm9EWOcgv08eqra7sQ8QVAay+55
         tCDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubP4H6TXYcsWLkDjoF+QtHZQ7ntQvFttSLR+9yXSYrjOEgDN7FR
	nh6KWsOy4VgsufQWFkv9iBEgwnlDX66aE1pjQdezrdIvtdOMo/5CGtYq0NAXpT9Cs2O7Rqp/0EO
	DZnDoU4dlLrBLcOMgV4qvz03dU0jwVCTZH9h2/I0em4BQT+LBsMWxDSdlGHRr65VGrQ==
X-Received: by 2002:a62:5b44:: with SMTP id p65mr36705303pfb.47.1549898606495;
        Mon, 11 Feb 2019 07:23:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IafOGrGi9d7oGxveMxPWV4ryjiXLZCohd2gpzexfBcqrcjmLtXgTY+SjX+udT9Sp+pgv52s
X-Received: by 2002:a62:5b44:: with SMTP id p65mr36705252pfb.47.1549898605649;
        Mon, 11 Feb 2019 07:23:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549898605; cv=none;
        d=google.com; s=arc-20160816;
        b=DGHenOszKKdTzp17gI4BVTwFrzVfyrpOWhveW/7hZsDzL/mL+pkmu0PQszv7CsLfr3
         LXSbSGgeJmsAcl53OIKxCtEAohWlp+uZL8Gpo/1ZTSwqZvlK6bWHfq+ODLssdz9s+VuU
         CS1nlNiXT0kj1SuuyuVw/cRVvHAh8ioHp7P2OtvujYEBy5g345d8dqCmVuQeseeWe0+h
         2Ru4hQHTheAFH+raqQBtFZA4EqdobcXMDzhVPglGAfX3FPTB2zMQpdSXUA7VOg3t/XS4
         uztZhIV4BdKLws9YdxGncZJ81SMD56R1wixWUTqz1lr5lTlE8nD0On2nXST226NSXQv/
         uxWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/zgghYOUI+qKDydm+9UQMOAMh5ccTjkEFBniIeQNL7E=;
        b=cU+LOwW2GOEicbxWtotm5BtH1t2wKMEPRfbP4TzXfSbVbvHy44bECcIba+rn2JsXe2
         aZOdWHV+zzdZqCWTqHcRIDkiu4V2ek1gmyFMJCcpe8cafyfavu2ncHG3cHcUPkSrHtDz
         iBf/RdmVvIDYVx4XS0XQuJEizWP1WJUsvFiXGU7iRyghOkEStvcLS5Jy9oPaAR3PhTwi
         Pt4RGUVvlkpcG7x5cpT+9+wMtyygE2wn4ipgD6uDX/5+8v57bNsZM0YUk7vnQ0mX19bO
         uwyHDil0UyE/wb9Cb+4RiJhFXygSquscvX7Hc2VguL5fkVj850K/cifrtmg/UF/+Zs8F
         ArMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n20si292453plp.294.2019.02.11.07.23.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 07:23:25 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 07:23:24 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,359,1544515200"; 
   d="scan'208";a="274157759"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga004.jf.intel.com with ESMTP; 11 Feb 2019 07:23:24 -0800
Date: Mon, 11 Feb 2019 08:23:04 -0700
From: Keith Busch <keith.busch@intel.com>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: Brice Goglin <Brice.Goglin@inria.fr>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	"Hansen, Dave" <dave.hansen@intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>
Subject: Re: [PATCHv4 10/13] node: Add memory caching attributes
Message-ID: <20190211152303.GA4525@localhost.localdomain>
References: <20190116175804.30196-1-keith.busch@intel.com>
 <20190116175804.30196-11-keith.busch@intel.com>
 <4a7d1c0c-c269-d7b2-11cb-88ad62b70a06@inria.fr>
 <20190210171958.00003ab2@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190210171958.00003ab2@huawei.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 10, 2019 at 09:19:58AM -0800, Jonathan Cameron wrote:
> On Sat, 9 Feb 2019 09:20:53 +0100
> Brice Goglin <Brice.Goglin@inria.fr> wrote:
> 
> > Hello Keith
> > 
> > Could we ever have a single side cache in front of two NUMA nodes ? I
> > don't see a way to find that out in the current implementation. Would we
> > have an "id" and/or "nodemap" bitmask in the sidecache structure ?
> 
> This is certainly a possible thing for hardware to do.
>
> ACPI IIRC doesn't provide any means of representing that - your best
> option is to represent it as two different entries, one for each of the
> memory nodes.  Interesting question of whether you would then claim
> they were half as big each, or the full size.  Of course, there are
> other possible ways to get this info beyond HMAT, so perhaps the interface
> should allow it to be exposed if available?

HMAT doesn't do this, but I want this interface abstracted enough from
HMAT to express whatever is necessary.

The CPU cache is the closest existing exported attributes to this,
and they provide "shared_cpu_list". To that end, I can export a
"shared_node_list", though previous reviews strongly disliked multi-value
sysfs entries. :(

Would shared-node symlinks capture the need, and more acceptable?
 
> Also, don't know if it's just me, but calling these sidecaches is
> downright confusing.  In ACPI at least they are always
> specifically referred to as Memory Side Caches.
> I'd argue there should even by a hyphen Memory-Side Caches, the point
> being that that they are on the memory side of the interconnected
> rather than the processor side.  Of course an implementation
> choice might be to put them off to the side (as implied by sidecaches)
> in some sense, but it's not the only one.
> 
> </terminology rant> :)

Now that you mention it, I agree "side" is ambiguous.  Maybe call it
"numa_cache" or "node_cache"?

