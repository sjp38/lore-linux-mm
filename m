Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B55EBC10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 19:34:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E67720675
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 19:34:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E67720675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D0358E0002; Thu, 14 Feb 2019 14:34:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15A8E8E0001; Thu, 14 Feb 2019 14:34:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3CA98E0002; Thu, 14 Feb 2019 14:34:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE83B8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:34:03 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id k10so5585263pfi.5
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:34:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pNBgyeZoVYKDb/USc8wWnC1Ljh9wNOjLun82Oksad2U=;
        b=BWJ+A5ivJJg05Fty6rZCmVMwiBYtqvnmyL6M+hv3B/AhGkj4PNwwNbf6KpjPlaisp5
         ZflBXFwPYZCqWq2uB25eCrJWPpOLk859DDrQQbAGUQaG62Pk/yM87DZ7laP5J400ai0s
         64dCNJyskP07yW/4iOEXifAaoFbBu5SiU3v63Z7ISwn0pRCeXf42NtEcWi9P7AjLS+lG
         BXFA+sP2AaB69+oHcyUc4xyyMwmrbPC9/A0NBOZEsRhoIpEClqUjZvr5x6+s9B8drqnH
         86LktpmKdRa6TeiRUhuW1Q1jfFhzoSHonNk2ubWNXv7jVT66KnLZhMUIF3w/XOhbkm1i
         FKAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubvNYWSLvcjeVuv0HQxZ/yYKIzrXvm+MESFWZi943LAUQYUcWGF
	lktudzNQ9yRcWpHPhTj1t5euzpO5Wqf2BZIzFFb2lYru9BJ+YF6RRgs7E/sSYZjLQWStkkh9hq8
	vvnkITnXVV/BmUNmkGcfliGe+z4LPjPOS9BMa4epP48daSg8i6vepVfHPPq0dlS3Cdg==
X-Received: by 2002:a65:4381:: with SMTP id m1mr1456698pgp.358.1550172843086;
        Thu, 14 Feb 2019 11:34:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbKW2MbFvB7lJYO3UBf3giD90a5P9h+HbI9JVjCw0XcQ4bj3eb1RkRMqFHJ2eeYak9ySaBM
X-Received: by 2002:a65:4381:: with SMTP id m1mr1456624pgp.358.1550172842087;
        Thu, 14 Feb 2019 11:34:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550172842; cv=none;
        d=google.com; s=arc-20160816;
        b=EPsBnqCZs0WTUCa1Z9T7x4Mj2NSw1IAFwh6ZHfI2CBP36P6y19NorunQJkbT3cZQUd
         V46CGf0xS6QVDgevo0je2xXK57zPx8Sbn9akCSENEgBM77L+b4owbRTkM1aD6QJpI8ff
         vYp5AWa5obS8v6yH58xSFCvZcn6GAdlQKqGhFTRdj8euVUZT66CKGH7KmDlm53/gZvJD
         G7ycEdmJirjSoEEpKWkdsz4dRnTRRtDhvI20pu3M2SG8wN52FcR9uIXnU2DZwQFmmFH/
         nhbNlrj0kibOCBvDRbUikZlmLDWHkhojaBxfeDjM6LKm48MFYoCi6svw0jizcjDUvwGb
         3Frg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pNBgyeZoVYKDb/USc8wWnC1Ljh9wNOjLun82Oksad2U=;
        b=O9IUNV8LmHF0bReYwZ/zwQrFvHNR5PvRPkW/xqeg1Fsf8BztRuDNcrIN5fPasSXZxv
         jYl0mq4gZiNDdyKzF/54hBIt34DiYDNHYmPFixv4RP5Bqn3CyxDbnHZ8TTAw6C3FhrY8
         1X91F8qpT3zsK+Cm1//4SrvHEV8WhSYqLSqn9FqpcgeV2/yzNV02LtXCFG9phFrwseDQ
         3zE/4K8ZYPdqUgdzDGa9L62lBVHJUJczWUO0t7Q/Y4pnvZ3C/4MMJa3k08Zzkm3+oJvm
         A4eBQLKulKA4AHXSct4K7P/9pxDA02AxnKLe2RJ4racm62WchI83TTKuXmWO5G5ca3LM
         eISw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id n5si3383420pgc.563.2019.02.14.11.34.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 11:34:02 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 11:34:00 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,369,1544515200"; 
   d="scan'208";a="116276999"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga006.jf.intel.com with ESMTP; 14 Feb 2019 11:33:59 -0800
Date: Thu, 14 Feb 2019 11:33:53 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
	dave@stgolabs.net, jack@suse.cz, cl@linux.com, linux-mm@kvack.org,
	kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
	linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
	paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
	hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru
Subject: Re: [PATCH 0/5] use pinned_vm instead of locked_vm to account pinned
 pages
Message-ID: <20190214193352.GA7512@iweiny-DESK2.sc.intel.com>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
 <20190211225447.GN24692@ziepe.ca>
 <20190214015314.GB1151@iweiny-DESK2.sc.intel.com>
 <20190214060006.GE24692@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214060006.GE24692@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 11:00:06PM -0700, Jason Gunthorpe wrote:
> On Wed, Feb 13, 2019 at 05:53:14PM -0800, Ira Weiny wrote:
> > On Mon, Feb 11, 2019 at 03:54:47PM -0700, Jason Gunthorpe wrote:
> > > On Mon, Feb 11, 2019 at 05:44:32PM -0500, Daniel Jordan wrote:
> > > 
> > > > All five of these places, and probably some of Davidlohr's conversions,
> > > > probably want to be collapsed into a common helper in the core mm for
> > > > accounting pinned pages.  I tried, and there are several details that
> > > > likely need discussion, so this can be done as a follow-on.
> > > 
> > > I've wondered the same..
> > 
> > I'm really thinking this would be a nice way to ensure it gets cleaned up and
> > does not happen again.
> > 
> > Also, by moving it to the core we could better manage any user visible changes.
> > 
> > From a high level, pinned is a subset of locked so it seems like we need a 2
> > sets of helpers.
> > 
> > try_increment_locked_vm(...)
> > decrement_locked_vm(...)
> > 
> > try_increment_pinned_vm(...)
> > decrement_pinned_vm(...)
> > 
> > Where try_increment_pinned_vm() also increments locked_vm...  Of course this
> > may end up reverting the improvement of Davidlohr  Bueso's atomic work...  :-(
> > 
> > Furthermore it would seem better (although I don't know if at all possible) if
> > this were accounted for in core calls which tracked them based on how the pages
> > are being used so that drivers can't call try_increment_locked_vm() and then
> > pin the pages...  Thus getting the account wrong vs what actually happened.
> > 
> > And then in the end we can go back to locked_vm being the value checked against
> > RLIMIT_MEMLOCK.
> 
> Someone would need to understand the bug that was fixed by splitting
> them. 
>

My suggestion above assumes that splitting them is required/correct.  To be
fair I've not dug into if this is true or not, but I trust Christopher.

What I have found is this commit:

bc3e53f682d9 mm: distinguish between mlocked and pinned pages

I think that commit introduced the bug (for IB) which at the time may have been
"ok" because many users of IB at the time were HPC/MPI users and I don't think
MPI does a lot of _separate_ mlock operations so the count of locked_vm was
probably negligible.  Alternatively, the clusters I've worked on in the past
had compute nodes set with RLIMIT_MEMLOCK to 'unlimited' whilst running MPI
applications on compute nodes of a cluster...  :-/

I think what Christopher did was probably ok for the internal tracking but we
_should_ have had something which summed the 2 for RLIMIT_MEMLOCK checking at
that time to be 100% correct?  Christopher do you remember why you did not do
that?

[1] http://lkml.kernel.org/r/20130524140114.GK23650@twins.programming.kicks-ass.net

> 
> I think it had to do with double accounting pinned and mlocked pages
> and thus delivering a lower than expected limit to userspace.
> 
> vfio has this bug, RDMA does not. RDMA has a bug where it can
> overallocate locked memory, vfio doesn't.

Wouldn't vfio also be able to overallocate if the user had RDMA pinned pages?

I think the problem is that if the user calls mlock on a large range then both
vfio and RDMA could potentially overallocate even with this fix.  This was your
initial email to Daniel, I think...  And Alex's concern.

> 
> Really unclear how to fix this. The pinned/locked split with two
> buckets may be the right way.

Are you suggesting that we have 2 user limits?

Ira

> 
> Jason

