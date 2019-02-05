Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C5DEC282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 18:01:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED6ED217F9
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 18:01:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED6ED217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 851148E0097; Tue,  5 Feb 2019 13:01:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FFE78E0093; Tue,  5 Feb 2019 13:01:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A2168E0097; Tue,  5 Feb 2019 13:01:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2729A8E0093
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 13:01:42 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id q14so2915263pll.15
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 10:01:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9HbjEquHvPYjk7nKOstiyRPeIIsYizVw4ZLmj6EN9DA=;
        b=AyGaY87PztzcdxIrJix8hsoKl8LKzt3zCrgZsAgmOgJ++fPe9RqlgeDkLpuDPQpQXB
         u/Z0OBvGx8q0ZukLpFoF2zEz+8fw5Ls9Ch3t1UIYWn0B7TUmQYsJwncW21TvCuexghta
         ISxW0JiofSuqkusDSvRpPw9be0jWPcjZDQdyIFbfrT9WU8yx0x/XyxqhnvhGkDlVURnq
         GTr7qbjYUxQxo9OIy7fVtuyVHmMrlvapa23pFQ8VBUC7gnazzPTirbVsJuQGkg3NWw6E
         hn1gUdnhQO7VarqvOVelHALMYQsYLTRRzQ/TPYyFRSR3kh0ugh0Xg0yDGjmQ6XWvfwxG
         aQEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYa9J/X36bHYJXaecOym/PLT1Nm5MlHumA9kELbZ9uKCylnJ7xX
	8z1/4a9O6K8BQop2L9bJnRflmFOcx8t7pBGjBNK6H1KW9fufXlg+3V2FFhnMevEDRL52FjMKNrD
	pXyJt0X53NkN1iG7v41/9Hx9/A8V9YSM8F3W3K8wcIH6ON6L2p5C0XzS8b4xI8LHImA==
X-Received: by 2002:a62:ca9c:: with SMTP id y28mr6195055pfk.236.1549389701797;
        Tue, 05 Feb 2019 10:01:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaJFF5PDVAAEpIpvZWMdCnLsNMGsn2WY+fl/vQu8TaCB9b1VsAAnEgX8632Hf8HEKg/waso
X-Received: by 2002:a62:ca9c:: with SMTP id y28mr6194992pfk.236.1549389700929;
        Tue, 05 Feb 2019 10:01:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549389700; cv=none;
        d=google.com; s=arc-20160816;
        b=HWcrI6ZFKU+7k7lKw/J8WkHKiTFbDeNe/WCiJl3okBTtBjrO0Wvy9SDWTD1+keOMVe
         vOrNmYFWKIlT/vmgEJjCoTcIaIEgvaI+TPs1w7ConWg9q0QRYE91R93g7rJxoJ+/sUvP
         9CUYjCxtmGF8gZ0GRaNLCzVVmnLxD2tt6r2D9h7LhpyXoQr4l1Sp8SZAon5mA2SM3eNJ
         VBmDZ72Z7z+i+sogfb+JYnHpSsci6fBKrTKP1yfC1WsKlKYxtOKbwb+tjJW6V8BdPXF2
         X6wn5kQDYg6B4y2mBAyQ/l+QREFhfLtWo9pOnjdbp60cHztkAW9NoEdsFXshGliK85/C
         VCxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9HbjEquHvPYjk7nKOstiyRPeIIsYizVw4ZLmj6EN9DA=;
        b=px+WU43jbev+xp03XnfUZO4HC4xC/VhZgmW4JfHPsLa+3NP8I5BlwVDElB77RD+Z6+
         9IXpCkZeLVDAHQdMle+YLC6rvstDJBo5URN6YV+eilqmNXCYPPmq6/6St+rIUSrmiyjq
         zDH2skKDVk01y4o+IjvyIolwgLSeSutQm3jji2BssAuhoxFbpTlLPp1DYqGOwdnWi4Dq
         +t/hBsmCdcTRbrpBb8QhPVw+MwFGsOkMyiH1zT8eiBiOsxB2XwukfnQlTO0TyjcF7lWm
         tilxxM0M4KBzYBSPDCmwyokYqczUyZSvyXBWTkRFqW4jpIyAa+XApLJLN8s/8fv9aMZi
         MInA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id x23si3789173pln.100.2019.02.05.10.01.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 10:01:40 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Feb 2019 10:01:40 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,336,1544515200"; 
   d="scan'208";a="124180424"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 05 Feb 2019 10:01:39 -0800
Date: Tue, 5 Feb 2019 10:01:20 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: lsf-pc@lists.linux-foundation.org, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Dave Chinner <david@fromorbit.com>,
	Doug Ledford <dledford@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190205180120.GC21617@iweiny-DESK2.sc.intel.com>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I had an old invalid address for Jason Gunthorpe in my address book...  

Correcting his email in the thread.

On Tue, Feb 05, 2019 at 09:50:59AM -0800, 'Ira Weiny' wrote:
> 
> The problem: Once we have pages marked as GUP-pinned how should various
> subsystems work with those markings.
> 
> The current work for John Hubbards proposed solutions (part 1 and 2) is
> progressing.[1]  But the final part (3) of his solution is also going to take
> some work.
> 
> In Johns presentation he lists 3 alternatives for gup-pinned pages:
> 
> 1) Hold off try_to_unmap
> 2) Allow writeback while pinned (via bounce buffers)
> 	[Note this will not work for DAX]
> 3) Use a "revocable reservation" (or lease) on those pages
> 4) Pin the blocks as busy in the FS allocator
> 
> The problem with lease's on pages used by RDMA is that the references to
> these pages is not local to the machine.  Once the user has been given access
> to the page they, through the use of a remote tokens, give a reference to that
> page to remote nodes.  This is the core essence of RDMA, and like it or not,
> something which is increasingly used by major Linux users.
> 
> Therefore we need to discuss the extent by which leases are appropriate and
> what happens should a lease be revoked which a user does not respond to.
> 
> As John Hubbard put it:
> 
> "Other filesystem features that need to replace the page with a new one can
> be inhibited for pages that are GUP-pinned. This will, however, alter and
> limit some of those filesystem features. The only fix for that would be to
> require GUP users monitor and respond to CPU page table updates. Subsystems
> such as ODP and HMM do this, for example. This aspect of the problem is
> still under discussion."
> 
> 	-- John Hubbard[2]
> 
> The following people have been involved in previous conversations and would be key to
> the face to face discussion.
> 
> John Hubbard
> Jan Kara
> Dave Chinner
> Michal Hocko
> Dan Williams
> Matthew Wilcox
> Jason Gunthorpe
> 
> Thank you,
> Ira Weiny
> 
> [1] https://linuxplumbersconf.org/event/2/contributions/126/attachments/136/168/LPC_2018_gup_dma.pdf
> [2] https://lkml.org/lkml/2019/2/4/7
> 

