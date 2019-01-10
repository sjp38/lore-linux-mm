Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A8E5C43387
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 17:42:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06AEB20685
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 17:42:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06AEB20685
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CAEC8E0004; Thu, 10 Jan 2019 12:42:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87B0E8E0001; Thu, 10 Jan 2019 12:42:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7436B8E0004; Thu, 10 Jan 2019 12:42:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 475738E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 12:42:06 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 42so11682017qtr.7
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 09:42:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=9a3eFfbaT8vDYva3IjQioRihGSsMlLf/tiqVgKkvJHE=;
        b=VDrDVTfETp2OPk2/9LJUG2YESkGdEN+wBXC/976VJJMSB1qUWD39DixSR/OvL5z4wp
         Q5azk1gKPo8mF6jqdRFLa37Tt6Q7xIAAt0Gd3T3xuWW3bA2bqsJYHKokWHzKXxKH9WEC
         nDVcXKUKZYWjUywM38Mggkoock2TCJn0vQPUKzptvEMRG/pDy3XvMFIois8kSV2Oud01
         r8RRPLKQd+g09kfAGCHo3riBdsnThz4tZ+7se2NPQ3ZrrnSpD0QpGd+m9wSB+hX8/1xP
         L7/K9e4Sv3aorX0ZTaxdYn5A7LZkV0zvEsrm7FbCppAuGGL/bPuB1icHLyfqvixIEylC
         VOKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukckwIIDh9fs4xc0C+s+7T707fSHPtnv+GvuC2LOftkVho/bFb07
	2t3l9Zmjs1KoGNG067b6ZHze1QgoK8NjaLTw3Sxsi/c9YbfCjnlyVWK//TWufpNjACty3NDyn6w
	wuYWCTWI48ZrjKWqHDc6/R7rop5CSGg9esu/yrhBP+PaKsqUd61pN4v2i2Et7/ZrCPQ==
X-Received: by 2002:ae9:c106:: with SMTP id z6mr10092041qki.197.1547142126043;
        Thu, 10 Jan 2019 09:42:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7csSkmDxBqKmoAJV/ky/RDVth9AKZ19zRThc25uMT2Atx54kIIb/khkjG13bobFuiB/gyb
X-Received: by 2002:ae9:c106:: with SMTP id z6mr10091999qki.197.1547142125165;
        Thu, 10 Jan 2019 09:42:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547142125; cv=none;
        d=google.com; s=arc-20160816;
        b=xZ43w3ClNoWE7xXz0EaRmbpgCAW2lcTRwrdueIizH+lzMNsdQZWxzf0GbOJgM3+n2r
         jQCicffsTRLyNzhFBKHa66s3KSCf3dS3rdif1zMdy5P/GraE7vkuJI6VtGJv6Dm9m+ze
         2LwXEvkniluMl/jrk00uJ72wUazbNNl+c+J6y2RaGCa1t6pZ1bVZ7LBgJTqBtNzL7wsp
         A7dAA8n3GKjGiFjxVokunnPLgP/rj+QUVZYNLjuKIjaQx2gPfRxORHI6WtfkdI/3q7bY
         GWcN9OKKy+XtPTyFrercbazMy82jxAbAODZQxy4YUdxpsVuwkYxFaaKVj5PageY/4ASj
         1bKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=9a3eFfbaT8vDYva3IjQioRihGSsMlLf/tiqVgKkvJHE=;
        b=SMjOd9cpuOsVyWjTn9iG5QFErPX35sjvRaM1zO7aJHIunNWHb+YmfnSpu7KfiG/mwI
         uVOX8GbkzgXjiYygJETdDWnpPddq6oIPdFTHepGtLg+pF+xNug73Dn38B1/LVGLodQpP
         1Y4vbjThEfg9ETVvzRagKp3z5Uz/ZXCxFkw2y4A60X5uryUt01kpNfE/nsEpImMXLeQw
         q1DS35cTJg+OCVVpQjz4bBriRp7SY+8wKMy7/ab8mKz7k0oyKsKV0ThLAjt0HLvOYpTj
         PaHiSsBNc6mrfEF1ZxzuZ59/uUh1IZ8ngdTHmU9cEmRzlxV9h9poBtpKMC56rn35uCAW
         nIow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h10si11610485qtc.140.2019.01.10.09.42.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 09:42:05 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CD347C0C5A4E;
	Thu, 10 Jan 2019 17:42:03 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.215])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D5DF05C6C1;
	Thu, 10 Jan 2019 17:42:01 +0000 (UTC)
Date: Thu, 10 Jan 2019 12:42:00 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	Huang Ying <ying.huang@intel.com>,
	Zhang Yi <yi.z.zhang@linux.intel.com>, kvm@vger.kernel.org,
	Dave Hansen <dave.hansen@intel.com>,
	Liu Jingqi <jingqi.liu@intel.com>, Yao Yuan <yuan.yao@intel.com>,
	Fan Du <fan.du@intel.com>, Dong Eddie <eddie.dong@intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Peng Dong <dongx.peng@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	linux-accelerators@lists.ozlabs.org, Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20190110174159.GD4394@redhat.com>
References: <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
 <20181228084105.GQ16738@dhcp22.suse.cz>
 <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
 <20181228121515.GS16738@dhcp22.suse.cz>
 <20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
 <20181228195224.GY16738@dhcp22.suse.cz>
 <20190102122110.00000206@huawei.com>
 <20190108145256.GX31793@dhcp22.suse.cz>
 <20190110155317.GB4394@redhat.com>
 <20190110164248.GO31793@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190110164248.GO31793@dhcp22.suse.cz>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 10 Jan 2019 17:42:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110174200.zqFodphxD1BbKrTb-uA7IfGbNa69XtI4J_5lF_2IAIw@z>

On Thu, Jan 10, 2019 at 05:42:48PM +0100, Michal Hocko wrote:
> On Thu 10-01-19 10:53:17, Jerome Glisse wrote:
> > On Tue, Jan 08, 2019 at 03:52:56PM +0100, Michal Hocko wrote:
> > > On Wed 02-01-19 12:21:10, Jonathan Cameron wrote:
> > > [...]
> > > > So ideally I'd love this set to head in a direction that helps me tick off
> > > > at least some of the above usecases and hopefully have some visibility on
> > > > how to address the others moving forwards,
> > > 
> > > Is it sufficient to have such a memory marked as movable (aka only have
> > > ZONE_MOVABLE)? That should rule out most of the kernel allocations and
> > > it fits the "balance by migration" concept.
> > 
> > This would not work for GPU, GPU driver really want to be in total
> > control of their memory yet sometimes they want to migrate some part
> > of the process to their memory.
> 
> But that also means that GPU doesn't really fit the model discussed
> here, right? I thought HMM is the way to manage such a memory.

HMM provides the plumbing and tools to manage but right now the patchset
for nouveau expose API through nouveau device file as nouveau ioctl. This
is not a good long term solution when you want to mix and match multiple
GPUs memory (possibly from different vendors). Then you get each device
driver implementing their own mem policy infrastructure and without any
coordination between devices/drivers. While it is _mostly_ ok for single
GPU case, it is seriously crippling for the multi-GPUs or multi-devices
cases (for instance when you chain network and GPU together or GPU and
storage).

People have been asking for a single common API to manage both regular
memory and device memory. As anyway the common case is you move things
around depending on which devices/CPUs is working on the dataset.

Cheers,
Jérôme

