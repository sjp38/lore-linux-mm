Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9345C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 15:19:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A093920840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 15:19:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A093920840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36B828E0003; Thu,  7 Mar 2019 10:19:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31AB58E0002; Thu,  7 Mar 2019 10:19:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BF008E0003; Thu,  7 Mar 2019 10:19:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCC2F8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 10:19:13 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id z1so18134956pfz.8
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 07:19:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+AHp0RucQjCfAIAYJGoA6OeFHqTVPnwS4ZyRJVethww=;
        b=oGZ+TpC1gesMX7EG+9xJzzMUR/5/AVh3f25n7hkjPJChActfwlH5xFwQqOq2MLfQ7J
         RX0cKONJP+xWAQtWRNfJZP3JcbaaE6UWBN+jBdJi1YSJAqDNmhRb1EauGcOthOVf6RsF
         R5nkpsqy22ssy8MXpMmOSKsHZ7jFHbIsVOCos6NRkMJlNw4C3SMDge9HQV74bYR1gHuR
         nfM/yjJ3xBAd5u6BXtRf9k4IvbjgUVVUxqmJBCiS8kY5vsXDBOrO+ZP0NzYoWGOrE/O6
         9yWjbG3hkqB1+MYKjdPdWA6TSm1orHUtAsxCdazVjQi7LG91CDsVrfXaYwMV8FZ6/vYC
         3+4w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.20 as permitted sender) smtp.mailfrom=kbusch@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVweHsvbM6qPnvxt5/hyt7fddWSLHMAEvv1g2iSCBIov2b/Ll0v
	hJopGtJmYe1vfmTm76QAc10tG6aOd+BrzFr2sGLABS+6Fn/j4kZm2Wz7g+9hZ7q4yXHIXsPJzT6
	c9b0sumfxHaB8lGFVlXvMydWBen8NORN5daSkJ15bm5weTkUyMn8EsqRNcJ1RWDY=
X-Received: by 2002:a65:4348:: with SMTP id k8mr11928303pgq.289.1551971953433;
        Thu, 07 Mar 2019 07:19:13 -0800 (PST)
X-Google-Smtp-Source: APXvYqx0Y1kyxtA+WBMwMuhrdiBdle5ap3rNrwljIZuieG0Iv5VLuN6pLQuTdSCZG5vJ53EOnzRp
X-Received: by 2002:a65:4348:: with SMTP id k8mr11928057pgq.289.1551971949607;
        Thu, 07 Mar 2019 07:19:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551971949; cv=none;
        d=google.com; s=arc-20160816;
        b=oFtaXZiWf9dpSgsBOKXX/pYfm5b2gLZ6jrbpXGJ6DMd5I2CqfCYMXyOc+4xfIkBzov
         1LoLDYJllVbJXfHUI9LYxYtt/Sq7sMVY0aazjZV4ik9jA/+WUblXfTUUC+OgK+FtzXBp
         PZjKa8dXwkN7jawfweCsFkFMk0wAAbhagJ7oZ/Tp0bcWe8c5kiFKBYPBbuUlZ9yn0JQG
         iwkFxMtAEW1deUWJc+5zZiV71RQ2ZXjM2BmMHC7vBfmJXQ8UYlQFSekdBdZYIg6+tP+Z
         tN2CChs3F78moHPdb1WSSn86BOyfZJh4dvemi7EEWoEF39voszUkG9FwndtFLnpw8AJJ
         A7Vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+AHp0RucQjCfAIAYJGoA6OeFHqTVPnwS4ZyRJVethww=;
        b=t4Tc74Mw7mTiyTLFEBHPVB6Fq7jHQFtrkuYZpJHxguZYgo2Jfujsv7Jx92VKth2WWH
         WuVyn/o1sPaAbNb/DV0Bns23LwZFAb04OXPih0OwN8IQwvLAgx+gpvXKykSb2Uni2ZQH
         Jf4irHN1blZEykUrRGxd6C/nBM7sHMAp3td1Jq1pQYWRgDePR87Rb6xDGZpRT/C8/j52
         8H6Vi73BBWIBd2u03QCfhNH7lS3Oya6JeGA9xImYbMQd9lrukhXBg7lJ3zbCmL3/bDS8
         d8yMnMeV2U/ANKEFOLglsjUBcVNR5P2Jntp0Y9kQ4JwJamKUwWK0MyYpDzcaHBdMbJE5
         Sqqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.20 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g63si4040769pgc.382.2019.03.07.07.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 07:19:09 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.20 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Mar 2019 07:19:09 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,451,1544515200"; 
   d="scan'208";a="150180347"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga004.fm.intel.com with ESMTP; 07 Mar 2019 07:19:08 -0800
Date: Thu, 7 Mar 2019 08:19:38 -0700
From: Keith Busch <kbusch@kernel.org>
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: "Busch, Keith" <keith.busch@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	"Hansen, Dave" <dave.hansen@intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>
Subject: Re: [PATCHv6 07/10] acpi/hmat: Register processor domain to its
 memory
Message-ID: <20190307151938.GC1844@localhost.localdomain>
References: <20190214171017.9362-1-keith.busch@intel.com>
 <20190214171017.9362-8-keith.busch@intel.com>
 <8fb27d2c-2165-7029-6ea1-94fc379b3be7@inria.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8fb27d2c-2165-7029-6ea1-94fc379b3be7@inria.fr>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Brice,

Please see v7 of this series from last week instead for reviews:

 https://patchwork.kernel.org/cover/10832365/

