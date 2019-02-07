Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E160BC282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:08:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A88612190C
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:08:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A88612190C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36FA78E0039; Thu,  7 Feb 2019 10:08:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31C5D8E0002; Thu,  7 Feb 2019 10:08:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20C598E0039; Thu,  7 Feb 2019 10:08:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D13D08E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 10:08:48 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id c17so95059pgb.10
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 07:08:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WS6pHY+7O4e2KTlC65+H75ElK+x0ftH+OILlTArtVgc=;
        b=TfMZT772YaAWOi0oGbrBZeWNWb58KGY7pncFcEJBwjoADsenBQM0nrFx6EQSS+MV1a
         mOosIfI4QDeRMXZIkmZkrH1u3se3OgM3s0UbqfOA/OEiKkGaxG/W+ydG7lrBkV9VkteB
         bhMUNrBFJjPv7+8z1C2RMEzL0WaVX7EFqT3CvZsfOpt9O2/NSxymnqolS4Gt0WOHU20+
         yrR42f24ton+fZgQ/f75zQJ75ZN+Ze/2dtwiNv+gj8ALLrxGL0gIDBkZMcwzh/9eHsAy
         HjHwwd3T2YoaClDW2zwJvyighxs/tC33agPnLfsyscXrzJLmMvAI+bBpzTn4NU2ldMkD
         Ykdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuazo5wIdwO/jT37FbcSdMUEXCpa4C1VsJBZpPV3fQNh68ePweIi
	aLEv2MNwDZtqTtvEkVj0S2+hSg2D48otUT9CKff4p3QfvbMDhFdf9hdQyyaOQfj3O5YM9OX2eog
	lEo7gyPh6YW556GipFcV+2CIZSyoRRhfQftyoTidMc18Cl43KAaPMHA0uD1R+ZOoEbQ==
X-Received: by 2002:a63:4566:: with SMTP id u38mr15128759pgk.4.1549552128517;
        Thu, 07 Feb 2019 07:08:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbKP8yEWjjCmVqr1xV7Jg3OS3CX6xNUGOn9nB4JMAAY/d81wDrT0wQG8m6/XiUUeaTh0yA7
X-Received: by 2002:a63:4566:: with SMTP id u38mr15128698pgk.4.1549552127645;
        Thu, 07 Feb 2019 07:08:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549552127; cv=none;
        d=google.com; s=arc-20160816;
        b=YfPDlZJoLWI7Z6HiOMrjXQbJJr5olyqbhSrVVKoGBR5rNdC7KXN6a9TV52sqOLVMJ6
         ShkfXD1s7svVrCWFQkcSm7mlroSbVbQdx8ieqtpwB2L9UeAgwUDYm5y81APD/eI/aN4+
         U4SOqF9UmT2c/TLRpz2t+glbRo5JPdF1Gs+Ajpfzemn61fTMgFy7dd5mH7INEIcZ6IZq
         joZM7jhdlt5c4yl/WiP/tdBzOHgfP0C2THh9kWnLtEDJzY+zlDLO+v2lm46dNalYHyFz
         52E2XqxosPKfcH9tsUTdPEZ7lXZxhJ5n8DsPlt+G6X99/9OKLZJyXnpTbtKR+C5zciJ+
         Takw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WS6pHY+7O4e2KTlC65+H75ElK+x0ftH+OILlTArtVgc=;
        b=SKcKpJ75N2m+xse9bCpI5Tv5OIwzT/6IVZsdt91uYKQLQQSbI3fD6m+rJOBhNCTD6X
         u1hT5Ngl1JBq0IPnGI0Lw4IrUfGtQnSdC/hW74KihrRRclr3lgSqY13VTrs24M2FLz6Y
         vWAzxJlC7NblM9RbveV2cqG02XVSozegp1T7rtJfxMQPQNIxEbddk+6RJQrdwub7ARMt
         F23JRRw+9HgmhjIDGpaf95Vv5tNXMGFjLRwrz6qh7WULSiuay5vdmc2zluNhfRLtINlj
         5/4vlDJYVr5H1Ex6S9lUqxgi5TrjAtSpRoyeg/UmBOA0U8bvXt+suuzLjcZtKO5IZS9x
         s0ng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id a6si9270471pfo.90.2019.02.07.07.08.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 07:08:47 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Feb 2019 07:08:47 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,344,1544515200"; 
   d="scan'208";a="114427874"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga006.jf.intel.com with ESMTP; 07 Feb 2019 07:08:46 -0800
Date: Thu, 7 Feb 2019 08:08:17 -0700
From: Keith Busch <keith.busch@intel.com>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	"Hansen, Dave" <dave.hansen@intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>,
	"linuxarm@huawei.com" <linuxarm@huawei.com>
Subject: Re: [PATCHv5 00/10] Heterogeneuos memory node attributes
Message-ID: <20190207150817.GC30221@localhost.localdomain>
References: <20190124230724.10022-1-keith.busch@intel.com>
 <20190207095336.0000529f@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190207095336.0000529f@huawei.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 01:53:36AM -0800, Jonathan Cameron wrote:
> As a general heads up, ACPI 6.3 is out and makes some changes.
> Discussions I've had in the past suggested there were few systems
> shipping with 6.2 HMAT and that many firmwares would start at 6.3.
> Of course, that might not be true, but there was fairly wide participation
> in the meeting so fingers crossed it's accurate.
> 
> https://uefi.org/sites/default/files/resources/ACPI_6_3_final_Jan30.pdf
> 
> Particular points to note:
> 1. Most of the Memory Proximity Domain Attributes Structure was deprecated.
>    This includes the reservation hint which has been replaced
>    with a new mechanism (not used in this patch set)

Yes, and duplicating all the address ranges with SRAT never made any
sense. No need to define the same thing in multiple places; that's just
another opprotunity to get it wrong.
 
> 2. Base units for latency changed to picoseconds.  There is a lot more
>    explanatory text around how those work.
>
> 3. The measurements of latency and bandwidth no longer have an
>    'aggregate performance' version.  Given the work load was not described
>    this never made any sense.  Better for a knowledgeable bit of software
>    to work out it's own estimate.

Nice. Though they shifted 1st level cached to occupy the same value that
the aggregate used. They could have just deprecated the old value so we
could maintain compatibility, but that's okay!
 
> 4. There are now Generic Initiator Domains that have neither memory nor
>    processors.  I'll come back with proposals on handling those soon if
>    no one beats me to it. (I think it's really easy but may be wrong ;)
>    I've not really thought out how this series applies to GI only domains
>    yet.  Probably not useful to know you have an accelerator near to
>    particular memory if you are deciding where to pin your host processor
>    task ;)

I haven't any particular use for these at the moment either, though it
shouldn't change what this is going to export.

Thanks for the heads up! I'll incorporate 6.3 into v6.

