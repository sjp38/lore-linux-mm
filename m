Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3480FC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:10:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F285D218D3
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:10:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F285D218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 810688E00E6; Wed,  6 Feb 2019 18:10:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C2B28E0007; Wed,  6 Feb 2019 18:10:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B2FA8E00E6; Wed,  6 Feb 2019 18:10:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2BBEB8E0007
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 18:10:26 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 202so5724407pgb.6
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 15:10:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ukbSF038uA8QdrAcMJjMRBbSncavGnnI8nn400E+/YQ=;
        b=r95OMQOvy63F10KeWQldVOY1t3XN9eqqHWQVUQH7wT6EMyq53rcowJTQjONb43QX4W
         V7TvBJiFIFyyFQFrktfBPprkec1HdB2ZDCh4QMsMbSRjG5fgXpOXTvxknXxfo247rNOu
         9pnJ5SrpkJ8ufbuYEGh58WtoUJNjeujG90CYr9sLrn4PNFS1Zg9bEaEuojS9SrXvaEF2
         aMSBvFjIoIDgIcZmFyhrDMzPamGZbZJZwuUtKnanq1AuboHWNXNifQEoDMXXsuxMb0eZ
         3SQjySLANA5AbLdQrUJAWxPIk+heylTg9ZNb4xPx8EFaSLPB8tFBnYOhZTG73XiuDZZm
         fVKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZ3Uj1aKTEvyuIgOmScy+cWqTht+rHLZ94vlZhOMSnwlgE+1BVj
	iyvlN2eANwhRc4J9c73jhO+5vvdy+nSRaJz0Msz02yx8kUk8ai7YykEcDeYb9AFpOsrUne/w6YX
	4EgnnBtdpUI6dzNorVw2NJ2/rdPHW5dLwUMPX00NVZxCzENNg4MIOacfOHeNzl5ejbw==
X-Received: by 2002:a63:d84b:: with SMTP id k11mr7967162pgj.142.1549494625806;
        Wed, 06 Feb 2019 15:10:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYZ8LOhzH6kyvdOHJ0vNr7HctJXst4Xa3bCIVTNcknejz6vkwb8SNp0BlQvINXgJqzihH/X
X-Received: by 2002:a63:d84b:: with SMTP id k11mr7967106pgj.142.1549494625067;
        Wed, 06 Feb 2019 15:10:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549494625; cv=none;
        d=google.com; s=arc-20160816;
        b=Hb4BYlWGCfrP+JE2dxazr/1gHACJ6RFDeZmaUY09b67kSgIcy+maBLAc7f5/eXj8oR
         UfqQ8uq8HsBJhJQ1as7C0BMKJsdVzjEmHwucCZAT06SJ0bweGT2UCwGap+bQB31UEJmR
         HZ0pSIgiX1xWHLrjb/LbOJufeK/zLpxU7eJlysu64xHGp4TZoOsAUq1QjJRWFVC2gPS2
         1lHLcRoNrpxuRRBU0mq/pI/RepKF8ynQAqvCaxEiFppH15JG45DLjO3aRlhosSRWeuzZ
         gKZFMt3f0oS2AQpd9e9EMswiAkVMhuWl90jmX1AW+6wft5CeDKsV7WwZ331GRQxnhMFJ
         BkRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ukbSF038uA8QdrAcMJjMRBbSncavGnnI8nn400E+/YQ=;
        b=grK4kfDLMIv+ulL+ZWASWCR72rL9U+Yu+Xzqu+rlRPrzPM2k7CUjSlQ82CDfrqL/E2
         L8CKUl6KT4VAP0tzdtMlqoaqMiEVz94uPNAvH67n8OZljxHYjxt9V7MzcUb8+NTaPEqy
         Wo3te8GVu9HtpzzMkFiAJtMFF/G/4rhnY4uk4D++mNffaNJL0swS9Ffif/9LTo2NmnbL
         ZOmtrKZga54RHeIAWFS8jmyKPtN66u2JX7ePmRVnNPpAu5YPs+E/sdIEP5T3NCzxQ5os
         U9aPFGDmAB+kWpEwxoWD6Ix7u9/0RbZuUZeQYDEnW4NMC1CtDnQjwfJdBp2b4gOJzpX3
         eC0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b9si6662109pgt.293.2019.02.06.15.10.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 15:10:25 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Feb 2019 15:10:24 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,342,1544515200"; 
   d="scan'208";a="273061511"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga004.jf.intel.com with ESMTP; 06 Feb 2019 15:10:23 -0800
Date: Wed, 6 Feb 2019 16:09:53 -0700
From: Keith Busch <keith.busch@intel.com>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv5 04/10] node: Link memory nodes to their compute nodes
Message-ID: <20190206230953.GB30221@localhost.localdomain>
References: <20190124230724.10022-1-keith.busch@intel.com>
 <20190124230724.10022-5-keith.busch@intel.com>
 <CAJZ5v0jE_gRT5WgpQYwZQmx6N5G+axymbSySb2Nk8Q0OGeNt9A@mail.gmail.com>
 <20190205145227.GG17950@kroah.com>
 <CAJZ5v0g4ouD+9YYPSkoN7CRLTXYymeCaVkYNzm6Q6gGdNgJbuQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0g4ouD+9YYPSkoN7CRLTXYymeCaVkYNzm6Q6gGdNgJbuQ@mail.gmail.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 05, 2019 at 04:17:09PM +0100, Rafael J. Wysocki wrote:
> <gregkh@linuxfoundation.org> wrote:
> >
> > When you use a "raw" kobject then userspace tools do not see the devices
> > and attributes in libraries like udev.
> 
> And why would they need it in this particular case?
> 
> > So unless userspace does not care about this at all,
> 
> Which I think is the case here, isn't it?
> 
> > you should use a 'struct device' where ever
> > possible.  The memory "savings" usually just isn't worth it unless you
> > have a _lot_ of objects being created here.
> >
> > Who is going to use all of this new information?
> 
> Somebody who wants to know how the memory in the system is laid out AFAICS.

Yes, this is for user space to make informed decisions about where it
wants to allocate/relocate hot and cold data with respect to particular
compute domains. So user space should care about these attributes,
and they won't always be static when memory hotplug support for these
attributes is added.

Does that change anything, or still recommending kobject? I don't have a
strong opinion either way and have both options coded and ready to
submit new version once I know which direction is most acceptable.

