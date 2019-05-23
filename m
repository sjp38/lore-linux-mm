Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEFECC282DE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:03:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8803A2177E
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:03:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8803A2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39F856B028D; Thu, 23 May 2019 15:03:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34FFA6B0290; Thu, 23 May 2019 15:03:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 267086B0293; Thu, 23 May 2019 15:03:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E61CF6B028D
	for <linux-mm@kvack.org>; Thu, 23 May 2019 15:03:32 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g38so4424989pgl.22
        for <linux-mm@kvack.org>; Thu, 23 May 2019 12:03:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KqGAq2Kn4l7r0bF2ES0l0CVItmj8+uVIeJFieuoStEs=;
        b=RknCs/lr7COvnQOH3+Abge5m5WNDPBGbH5L3sS/9FtjfGQxMqy3WfZZqa4DIYnvCJ1
         4m/eEmtNiOzr+ba+U240fQczlf/2igQRGZP4tRtRctbh3q9m/eAG0ZbKUk7GZ99vsa4y
         Ou9G4005+5Fyq/xQDQMmAflRN69aTSobfMgO6mRin7rXy+8RjxtUWRY+UbQCXpY484aJ
         NxsBYjGZXnUlzTnKGhZhARkQWzwVo/oU8qYGc/a2apz1ZgjwVHjbEW4Sg/xs8DmzScJU
         NXQPjT2gsEOHY0H1o94Q9J64O+DK4FfCunLfkKsHqijFEvsmWBMWjfy0/mpsxw5P1oQ5
         nktQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUDH6hmAK3g4FqqrMhEcpmC3ujPGgil6sY8J3t1uSCl5cZVFAeu
	7u9EtGa2kLD7JC3cGfwyR9N91ngJm+1VLQt6Y9i8SJokwiZUYMDPWjLKn5VNRtBf9ZYimKyFSif
	ENXdkv/cbvpeyp08fLE+L47caqaHjw7MqEYn6ENdmIUu6yHSvFydsfuD1eRF5ccv4mw==
X-Received: by 2002:a17:90a:2ec9:: with SMTP id h9mr3549969pjs.130.1558638212596;
        Thu, 23 May 2019 12:03:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRyMlhHyf8pwKF85uX7Jc6FEiXaTzmX+euHp95Kw7fRFnw/dwijCUk2O5e2iWeNBJI4OG6
X-Received: by 2002:a17:90a:2ec9:: with SMTP id h9mr3549863pjs.130.1558638211800;
        Thu, 23 May 2019 12:03:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558638211; cv=none;
        d=google.com; s=arc-20160816;
        b=pF1mkSCwOFllXyen8nXeTk78heVHcoSIrtqtkOsg1SAfcb87QoQDGJytQPW87wBAKH
         YBieUaCd+/xIgoi1cvl2ULcI7uCRALIX+ZkaBFEbvRJ+TGST6AZi0KSBJow/GHgmRai3
         qpUBda6pKst0JnsL4t+wM17NpveQ4b/H0stGGseqbza8peS2xSwAeW4JLJDM07gnJwY4
         0MBQ0mfjykQdBKcvcxh0ioZ5/p3ExzQtELn0a1j5VvBBXyCDN8ICg6qJhJf/zLlncdkZ
         uH/cWaVZS45QUusReVKSTUqrGuALSJMRlTDPaKHB9Xfbdim4WGtSe2B5Is3V702ww8hC
         uYGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KqGAq2Kn4l7r0bF2ES0l0CVItmj8+uVIeJFieuoStEs=;
        b=tXGo9NSgza9BvH6L46U4xuwBKCDXU5Ptz1Q7OnV6l+npJsXJKTaHF7gBPP40yD8z6K
         DqORuumP7gToHi2aqf+A6xY5j3Renow+LMfMMR2Dg9OEKtPeZVUgCDIw0eiUGOJqRPPK
         ObJoZVRV/je5ux9k9JlQL2v6OwE91k4Ar8UIJ+HF456YbBzEWAOfddpSgcuutHEL7Tad
         POw5gnca6jlqB8k4UcIfpKmf8d//tD92gusjGyzyVKmEy1YoNwR9pGMopQS+eZLFT6u0
         SoS6pmnFLyKNv4ZMfwa2868GgFnU1xqu4dcK8Yefxq34sgGRFi3yiz61BAPsdWnKgTl/
         zdcA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id c1si259289pjs.86.2019.05.23.12.03.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 12:03:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 May 2019 12:03:31 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga008.jf.intel.com with ESMTP; 23 May 2019 12:03:30 -0700
Date: Thu, 23 May 2019 12:04:24 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>,
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>, Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/1] infiniband/mm: convert put_page() to put_user_page*()
Message-ID: <20190523190423.GA19578@iweiny-DESK2.sc.intel.com>
References: <20190523072537.31940-1-jhubbard@nvidia.com>
 <20190523072537.31940-2-jhubbard@nvidia.com>
 <20190523172852.GA27175@iweiny-DESK2.sc.intel.com>
 <20190523173222.GH12145@mellanox.com>
 <fa6d7d7c-13a3-0586-6384-768ebb7f0561@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa6d7d7c-13a3-0586-6384-768ebb7f0561@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 10:46:38AM -0700, John Hubbard wrote:
> On 5/23/19 10:32 AM, Jason Gunthorpe wrote:
> > On Thu, May 23, 2019 at 10:28:52AM -0700, Ira Weiny wrote:
> > > > @@ -686,8 +686,8 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
> > > >   			 * ib_umem_odp_map_dma_single_page().
> > > >   			 */
> > > >   			if (npages - (j + 1) > 0)
> > > > -				release_pages(&local_page_list[j+1],
> > > > -					      npages - (j + 1));
> > > > +				put_user_pages(&local_page_list[j+1],
> > > > +					       npages - (j + 1));
> > > 
> > > I don't know if we discussed this before but it looks like the use of
> > > release_pages() was not entirely correct (or at least not necessary) here.  So
> > > I think this is ok.
> > 
> > Oh? John switched it from a put_pages loop to release_pages() here:
> > 
> > commit 75a3e6a3c129cddcc683538d8702c6ef998ec589
> > Author: John Hubbard <jhubbard@nvidia.com>
> > Date:   Mon Mar 4 11:46:45 2019 -0800
> > 
> >      RDMA/umem: minor bug fix in error handling path
> >      1. Bug fix: fix an off by one error in the code that cleans up if it fails
> >         to dma-map a page, after having done a get_user_pages_remote() on a
> >         range of pages.
> >      2. Refinement: for that same cleanup code, release_pages() is better than
> >         put_page() in a loop.
> > 
> > And now we are going to back something called put_pages() that
> > implements the same for loop the above removed?
> > 
> > Seems like we are going in circles?? John?
> > 
> 
> put_user_pages() is meant to be a drop-in replacement for release_pages(),
> so I made the above change as an interim step in moving the callsite from
> a loop, to a single call.
> 
> And at some point, it may be possible to find a way to optimize put_user_pages()
> in a similar way to the batching that release_pages() does, that was part
> of the plan for this.
> 
> But I do see what you mean: in the interim, maybe put_user_pages() should
> just be calling release_pages(), how does that change sound?

I'm certainly not the expert here but FWICT release_pages() was originally
designed to work with the page cache.

aabfb57296e3  mm: memcontrol: do not kill uncharge batching in free_pages_and_swap_cache

But at some point it was changed to be more general?

ea1754a08476 mm, fs: remove remaining PAGE_CACHE_* and page_cache_{get,release} usage

... and it is exported and used outside of the swapping code... and used at
lease 1 place to directly "put" pages gotten from get_user_pages_fast()
[arch/x86/kvm/svm.c]

From that it seems like it is safe.

But I don't see where release_page() actually calls put_page() anywhere?  What
am I missing?

Ira

