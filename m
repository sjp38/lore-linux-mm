Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37689C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:34:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F270F2080F
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:34:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F270F2080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AAED8E0002; Tue, 29 Jan 2019 13:34:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95A1B8E0001; Tue, 29 Jan 2019 13:34:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 821F18E0002; Tue, 29 Jan 2019 13:34:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0AE8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:34:33 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q63so17553418pfi.19
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:34:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5ShSzWg3ZO08wVcQFPFywh+fH/s2U3oCckOgFxqPJA8=;
        b=ZPN53S0kPxf2zeIkdfYukt8wmHZZkPpfXpVVRp4VXXxHowP8Lef9XlFgkoXG4ovUec
         vtR5FvJLTPWKH6UHH6P+vEcVgn4pd/MhU1fNlQBjUfcFifrF8EySMf6g6SkzDumMzOEt
         OUGhwR50UrnPMTj4TVcsDBgK1OhjR1BLE818YEGt5WVzoXdA3G/ucJhDN0Z/7IXSo91y
         T0hgzjBUR7Gjj77u73dYnbq/HzR5nLUOxUBWotLSpfMVA3+Btigpiy4cZ1gEpFfaRCIR
         UW1OYWAHGqorCCKboeRV3NqndLV7SfWtXB5BRX1HDbli0ZRgx/IVo76ufcQmENIP0kFd
         GC5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukdDtvWtEl5tEJtp5KrBKpCp9VMGhlZxmz4U9RKJRhHWYOevzu0d
	tQiU4x54PlTLCR9iyhYyiMkDjAw3fL/wD5rTg6auqM7c2I0I8066euKRigE4WBE1NIU9r5Yk1lA
	sKn7mhJ67lqjiC9WTrHFDLpuUOL2I1De+7amyoRi1xUoBYffzv9arbyd3NidfBudTyg==
X-Received: by 2002:a63:d252:: with SMTP id t18mr24878094pgi.133.1548786872922;
        Tue, 29 Jan 2019 10:34:32 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4W/R6KXsnmxGc4vpV9+tjjYd5W+NJdjmARUB/yTxgm4JbCB4veRvfNpfme2Ddk3+j9K69e
X-Received: by 2002:a63:d252:: with SMTP id t18mr24878064pgi.133.1548786872380;
        Tue, 29 Jan 2019 10:34:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548786872; cv=none;
        d=google.com; s=arc-20160816;
        b=cdJ/TQe2WqGDw0MCvyPi+fyM/ztRRS7rl6YvfY0tG6FyNvOa0UVuvE7Hfr+EZ893/U
         gpsBr8oNhKm+7pesf40ZLDtLr1gNrqDQZXjiV/bZWAexTNpKcaSIZ0c82jhSbQbRXDiN
         KJPRKk5hThD4DE3+7RtvRJ6Umjg94L+5C/SEAN+N8nZRFtZHycp5dRv5t4QC6ZX4gnZh
         sEGMe6L7ybzPQWZ1W78sY0IlsPsDkQfx8MNVA6oWsaxCj6VvHjhsmwkS1C0LbRJL6256
         4XDkKgm4zGnbVzcSBAydslAWVlYDwkPNZlU9oaNpKznBbIfW3DXtaxnU3OSGyc7tnEb4
         jXuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5ShSzWg3ZO08wVcQFPFywh+fH/s2U3oCckOgFxqPJA8=;
        b=PdG39nw8TIUX6l9vXnKCtYrHy8z99X26nOXo4GW3y/gOMEGJCNp9HYYMm6EPPQzD/S
         GwryKSW9smbL2lVR2br3eCOL0S/fANXii7Vw2tZo2WNOdDxZ8OQqK9S8pKZyHbS7ZN14
         DVkbKHBdXl8AB+elK4SBo68ecxaywOHLegiC+6FZ47YLSFlzpodohT98EH3eIZ7WZaoU
         lxoD+AtP/1X7Jz5CQ1kA7SNPFNxHG4BuWDXdpcDKFRyfKhFz9LEBTWSEHblbNIGlQFW8
         WQqrAvNJuwUd26hhSjyHejPb1N/rH5z2r5KPeBn2Wbk4Ho8oRO6D2A9bICUmW+1ZT37i
         gLxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 10si2536613pgk.101.2019.01.29.10.34.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 10:34:32 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Jan 2019 10:34:31 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,537,1539673200"; 
   d="scan'208";a="120448958"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 29 Jan 2019 10:34:31 -0800
Date: Tue, 29 Jan 2019 10:34:03 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Steve Wise <swise@opengridcomputing.com>
Cc: Joel Nider <joeln@il.ibm.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Leon Romanovsky <leon@kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/5] RDMA: reg_remote_mr
Message-ID: <20190129183402.GB10129@iweiny-DESK2.sc.intel.com>
References: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
 <8cdb77b6-c160-81d0-62be-5bbf84a98d69@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8cdb77b6-c160-81d0-62be-5bbf84a98d69@opengridcomputing.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 10:44:48AM -0600, Steve Wise wrote:
> 
> On 1/29/2019 7:26 AM, Joel Nider wrote:
> > As discussed at LPC'18, there is a need to be able to register a memory
> > region (MR) on behalf of another process. One example is the case of
> > post-copy container migration, in which CRIU is responsible for setting
> > up the migration, but the contents of the memory are from the migrating
> > process. In this case, we want all RDMA READ requests to be served by
> > the address space of the migration process directly (not by CRIU). This
> > patchset implements a new uverbs command which allows an application to
> > register a memory region in the address space of another process.
> 
> Hey Joel,
> 
> Dumb question:
> 
> Doesn't this open a security hole by allowing any process to register
> memory in any other process?

I agree, Changing all MR to use FOLL_REMOTE seems wrong.

Ira

> 
> Steve.
> 
> 

