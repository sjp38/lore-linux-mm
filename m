Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 671ABC282CC
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:54:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D3B821908
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:54:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D3B821908
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFB348E004B; Thu,  7 Feb 2019 11:54:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA8498E0002; Thu,  7 Feb 2019 11:54:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A96228E004B; Thu,  7 Feb 2019 11:54:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6AE7C8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 11:54:27 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id l76so347137pfg.1
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 08:54:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3u7JlvCen7uMA/t/vWJeEiw410szcBl0z8J2T7dsiPo=;
        b=hV3NRIAJi54K8KrRYrCqMNxcU9TClHDJFpfVJArTQAvTo+XyZZuZxeWu1RPeUmJkP2
         vOnfwzETLNJTty5d92o87C4xSPxQB6mu4zqV3u9HkV1+jmfMwfjc92YnP5dpaOA4uckw
         8TFQsClEwtwBzvJKn2iUrPCrd1UPlT1E7xdfwq+hAn7aCJgNv76sm3dM73vBq3zIEQxa
         7IZUozh7SdcgYUJKMp6uGr8XOomfslFh8qiqoPGusIU+aK1pqPzrlI7Mz5Z7Y2VpHoyv
         X8xCiq4yDwGL6orNqHZW9e4pX0eH5WzHi0rjZF1/RaRgidrZ351rxFuoZt7ng5Qmy9KA
         Uk1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYy3JyIx+rXaKhBsyzoRY6qJrmI1BxlTQulJ+WnAAfxt5w0HNAI
	7Bq5RXLLThFCsvlviseIJpXqE0ldpDT/9OMeGi2O9wbZr/RXgUfYpgSFxrfIZp9u5rApMypZmgU
	SuXJD9YaoMt/umzrStf9AfJGy+2M/uxwlg1g49Qe2c7sJsnO36C6l3Nl5WGycRNOIxA==
X-Received: by 2002:a62:2c4d:: with SMTP id s74mr16968264pfs.6.1549558467129;
        Thu, 07 Feb 2019 08:54:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibg4vYnPV+o4CyoVF41wZjvqLD/nXzDZ3WkdRkryMkHPMal98j9ecGm9+FoHzRl79ser4r7
X-Received: by 2002:a62:2c4d:: with SMTP id s74mr16968216pfs.6.1549558466465;
        Thu, 07 Feb 2019 08:54:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549558466; cv=none;
        d=google.com; s=arc-20160816;
        b=DrvjOuphfl9Xy1rNNBqJOySnt7+GXVsfkG3L+WvltjyG9soSv+bD7iiLDqKKgVipd+
         8woIwGNsMrvkBa2sYkIvLv8OBi8nDxNpQe8eciDME8p4RmQcFSDMuR1yWRmN+1UnTANL
         vIQFpG3AMM17TT8rp72sYBM5yXID8qNOc0ytcdf5jqvpTwjsPSInV2UwhvzEir+IF03u
         OtDuGflCxeYZ5yWx+haTPqLQNgaSqFf9h/M/TnHYkSjQX2GawrxYrG7+lzwzkJGgT5Lc
         0Fci6jxSM9BYxB5MpdefBwIrws2EUl4I9hq2SX0R7suDSYkwala4pWrw7icz+T5/5t+o
         M2ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3u7JlvCen7uMA/t/vWJeEiw410szcBl0z8J2T7dsiPo=;
        b=Olf004Wm12skmVn+6px4lo1XpA46YHJ1WgN26Nle+8Q1d6zwhImqMbe7VW3Cu+YrrR
         za/iOdi5MkgPl0WGwS+urjYCjSpPxfEZpat4ZjSeIOxp/uGQytHn4YafqJkw+56ak8Go
         l78GQGra1gkFpXcgq8muXrKOeQbm4sfEU89gVO5VRebaMl5iynvtMfjNkTjlvkjjRmSZ
         Z4tigHxeU2sQYb0wlUwtuyhnm+YF2ZwBTranPwVFMaIYdV+2fOCrGT25iBfN5ufg5Drj
         43MNUW1Ze8FXlrPYLxhVFNX0UkVQ4Afx7YBTtIIyjf1aeXO+te7e/DYqhlR12UyEEgHI
         yQHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id i13si8941555pgj.199.2019.02.07.08.54.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 08:54:26 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Feb 2019 08:54:25 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,344,1544515200"; 
   d="scan'208";a="142417351"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga004.fm.intel.com with ESMTP; 07 Feb 2019 08:54:24 -0800
Date: Thu, 7 Feb 2019 08:54:08 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dave Chinner <david@fromorbit.com>, Doug Ledford <dledford@redhat.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	lsf-pc@lists.linux-foundation.org, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190207165407.GA29531@iweiny-DESK2.sc.intel.com>
References: <20190206095000.GA12006@quack2.suse.cz>
 <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <20190207035258.GD6173@dastard>
 <20190207052310.GA22726@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190207052310.GA22726@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 10:23:10PM -0700, Jason Gunthorpe wrote:
> On Thu, Feb 07, 2019 at 02:52:58PM +1100, Dave Chinner wrote:
> 
> > Requiring ODP capable hardware and applications that control RDMA
> > access to use file leases and be able to cancel/recall client side
> > delegations (like NFS is already able to do!) seems like a pretty
> 
> So, what happens on NFS if the revoke takes too long?

This is the fundamental issue with RDMA revoke.  With RDMA and some hardware
you are going to end up killing processes.  If the decision is that only
processes on non-ODP hardware get killed and the user basically "should not
have done that" then I'm ok with that.  However, then we really need to
prevented them from registering the memory in the first place.  Which means we
leave in the "longterm" GUP registration and fail those registrations can't be
supported.

Ira

