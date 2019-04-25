Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0009C43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:42:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F20322088F
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:42:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F20322088F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DE936B0005; Thu, 25 Apr 2019 11:42:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28E756B0008; Thu, 25 Apr 2019 11:42:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A4AC6B000A; Thu, 25 Apr 2019 11:42:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC3426B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:41:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m47so11865863edd.15
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:41:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=O5skhjHrYWhqU67JX5Jcw3ZxBcpKyb2qQr7cJnhnfcE=;
        b=JLVvBy9sjRlPTJiJjg6fYJkZEKz7ZOwBjT7ewd9td23pNgmPxaxUB+fARkGwodkiy2
         2kuy8yDqbfPpGhM05YrWTtBel08+8lFYr/V3YY7GxFh6KnmJULm1EENLYM7KYPjPspvw
         sieMPyinVjiQHFIDDuWvU86dya/D5rqIesM9MZPu3d5atgChLJXHOkJqCFvnCtLV6GGO
         69W/c7p5ahZGTKx5D5QrYeRo5W0m9V56NSvoDVS73DdoFMatZqIfquTTYPY4QcVO/CKv
         212HOr0BN7v01z7qMatIKL7ORlx4BytUPvGI3ydMzBoMNSxhxGNSCokbHAYebGfdkVK6
         FNPA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWRa9rrZ8n7ANikPgZfIAZPGv+qRgQYq1PKtO8JUmZP0QUXo/o1
	BkBADZpOxFbzDWN8LjBVafBn/kWkCnq1trlrNwc0LvFJlI61Qds3KWtSk+N7mdoZr2sAvp4Rgi8
	9qtbK7O6WLLwV0jWghqsmxEbUOvw7jST26I+emi9khEVjl64lYTBaX49DWQXTABo=
X-Received: by 2002:a17:906:f0f:: with SMTP id z15mr20237515eji.125.1556206919278;
        Thu, 25 Apr 2019 08:41:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0YY0VA4s0cG0O0fRoGloaTQvLBCgsZMU72hBvIe/L0i23nIL2lgZBASHkAtoMbBsEn+kk
X-Received: by 2002:a17:906:f0f:: with SMTP id z15mr20237486eji.125.1556206918446;
        Thu, 25 Apr 2019 08:41:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556206918; cv=none;
        d=google.com; s=arc-20160816;
        b=kQ4xlguTmV45u9+g/zzuS6/ntCOfg6yceGrno/fH28gMAv2xg+ai5HD/9A6Qv7dEBr
         zDUjqJfk5jXX8zj/WWMMPqN+j5hwBHRlw+yo9IU9phO+Osas7nKYzN2+rgcihKdTJy5b
         jmhycksi3rSAVD0SZKbrVEKZPREkSsvzCgcHkGVHfcLoviTAn+ccp4sRsfNNYj3hNcKH
         hVaFnvcV30kD5Tldkwyq29p7xIiHnMxnImN/I/e3TOmyiISqMXYTIDqMAHfZMfrzJlGQ
         qUrtnFoA4f1/snnfgBaVYFWflfJbP2VO3gMFFzH3wex/nFSBxkFisZpLdmaplSDsxn1J
         WnKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=O5skhjHrYWhqU67JX5Jcw3ZxBcpKyb2qQr7cJnhnfcE=;
        b=L5GrcsKbtB9CVyPjX6vgDJgfxxJUNLYHjxuVpKw0s3RMwFL5Imn2YJQVIPL7UvqNNH
         xB07dV+aLg144g75d0d1OBxPLt9POULJLe1buGi+lMcVJWP+1w+ZBvTFuM9QkO8GYCtM
         2sPfYW89pOeBCqVLiQql3IMhxvGPEwMp9JUCDRX/OsFOK8zPTX9bSMsTFvH5+ImdO0b9
         5YGdIW9qk0C7AZ3wiD3bFXmF9qqn5auTid+z7ShpWscXBHQo07AOkOPudWJRY1S1i5sW
         fd1qs1xTMaSCPOoWqXeDYdkCCgt4gxq+nzqrwINw7zv8Ch87yCiNrxT1dJYRRsHxK7/n
         CHFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k38si472170eda.300.2019.04.25.08.41.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 08:41:58 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C7F89AFED;
	Thu, 25 Apr 2019 15:41:57 +0000 (UTC)
Date: Thu, 25 Apr 2019 17:41:56 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>, jmorris@namei.org,
	sashal@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, akpm@linux-foundation.org,
	dave.hansen@linux.intel.com, dan.j.williams@intel.com,
	keith.busch@intel.com, vishal.l.verma@intel.com,
	dave.jiang@intel.com, zwisler@kernel.org, thomas.lendacky@amd.com,
	ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de,
	bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de,
	jglisse@redhat.com, catalin.marinas@arm.com,
	rppt@linux.vnet.ibm.com, ard.biesheuvel@linaro.org,
	andrew.murray@arm.com, james.morse@arm.com, marc.zyngier@arm.com,
	sboyd@kernel.org, linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH] arm64: configurable sparsemem section size
Message-ID: <20190425154156.GZ12751@dhcp22.suse.cz>
References: <20190423203843.2898-1-pasha.tatashin@soleen.com>
 <20190425152550.GY12751@dhcp22.suse.cz>
 <20190425153138.GC25193@fuggles.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190425153138.GC25193@fuggles.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 16:31:38, Will Deacon wrote:
> On Thu, Apr 25, 2019 at 05:25:50PM +0200, Michal Hocko wrote:
> > On Tue 23-04-19 16:38:43, Pavel Tatashin wrote:
> > > sparsemem section size determines the maximum size and alignment that
> > > is allowed to offline/online memory block. The bigger the size the less
> > > the clutter in /sys/devices/system/memory/*. On the other hand, however,
> > > there is less flexability in what granules of memory can be added and
> > > removed.
> > > 
> > > Recently, it was enabled in Linux to hotadd persistent memory that
> > > can be either real NV device, or reserved from regular System RAM
> > > and has identity of devdax.
> > > 
> > > The problem is that because ARM64's section size is 1G, and devdax must
> > > have 2M label section, the first 1G is always missed when device is
> > > attached, because it is not 1G aligned.
> > > 
> > > Allow, better flexibility by making section size configurable.
> > 
> > Is there any inherent reason (64k page size?) that enforces such a large
> > memsection?
> 
> I gave *vague* memories of running out of bits in the page flags if we
> changed this, but that was a while back. If that's no longer the case,
> then I'm open to changing the value, but I really don't want to expose
> it as a Kconfig option as proposed in this patch. People won't have a
> clue what to set and it doesn't help at all with the single-Image effort.

Ohh, I absolutely agree about the config option part JFTR. 1GB section
loos quite excessive. I am not really sure a standard arm64 memory
layout looks though.
-- 
Michal Hocko
SUSE Labs

