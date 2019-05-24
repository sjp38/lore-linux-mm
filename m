Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25D99C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 20:29:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D98CA20868
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 20:29:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D98CA20868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78CFB6B0008; Fri, 24 May 2019 16:29:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73DFA6B000A; Fri, 24 May 2019 16:29:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 604386B000C; Fri, 24 May 2019 16:29:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3EFAC6B0008
	for <linux-mm@kvack.org>; Fri, 24 May 2019 16:29:49 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id 76so2509077uat.12
        for <linux-mm@kvack.org>; Fri, 24 May 2019 13:29:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=X58Az4dHX3doqWoVsrR+YLAOqx/yB2iQnaJ8PW+XYpg=;
        b=g2NZoNUlEw4qdrJCVHSHJuJvMLPuArUDxta4eMuxc2lg42fUEhRyzYZIqWldLSywHm
         aFr0G6LbLEeo3DuxHYadRA/6pnU+GgauZAbhEMmDU9gA7lyLa4tTp9ZUmT2TqcZBfFD6
         CLhRS/pDlHeuLTrD5BeLs0eo3teebwNLRggBzxCLoFQetyGBZw/5llxz0kJmz5pZQNk1
         UHh2OCodCTk9GgwLAqVwCcZiPbmfqopZJIzU7d5G2W07HYuQ/571FePvHuGS5m5Ve9PK
         uUKP68Dd8ZNsivtaVu1bP013J8ptdtARYY42N+31s9nOO30cTB9pvxg97fh51cyS8M06
         fDmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUakKh8cgAxQguBmXI9ovGihuS79JYaqRP63N464JtAaZbzX2Fj
	JGeEUD3ifWPf61b5a25m/jK1/QNlfQAOPQJIJ/gpUPdXYAHSPO0mh9UOO0YLpy51JkVhVMVqJ6p
	0Ic3gQciigdpafjzx6dcz7uMX9cUnfbLNPSZf5W3CC2Hio8+o8baiYLuuWfnJW5icxA==
X-Received: by 2002:a67:dd8e:: with SMTP id i14mr11176758vsk.149.1558729788991;
        Fri, 24 May 2019 13:29:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyY4w1d+rPyc9RBLOBPJm1+6P0gJlhNRbDicbgdweGwrLWHxbTY+RygQhG6RZakppi1asyP
X-Received: by 2002:a67:dd8e:: with SMTP id i14mr11176664vsk.149.1558729788058;
        Fri, 24 May 2019 13:29:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558729788; cv=none;
        d=google.com; s=arc-20160816;
        b=Ypxfl1T0pzAcY+lTd7y/RLazYchJAjMW8sMqWo+so6/CWwx0RzvL5qCyk4o1fP2two
         E5XR+MH3efWMZ2d2OfuYVSWutndMRHkU5d1r7yTyIkw8xFx8h1ba3rHAsSpvvKKRTGmL
         kz+B0rdyhXCKgErky704nHwQh9s2F1oHOX++FEhoLJ+a4DBTF5GrQhFyIMaoc9W6yU/F
         7FabLsrMuRAwSVJejp45+Tcsz2EA0Mn8bEiru7gd/qi0qjzQP1OpjG5yKUhvuZz85C/9
         YQw2g5pSX3rA6BcvKOYSBY5W9ApbH7DGhUp+uWAmNjcZR8WJCrzZwxy/zFot1hjCYDuw
         HE3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=X58Az4dHX3doqWoVsrR+YLAOqx/yB2iQnaJ8PW+XYpg=;
        b=BT4yemBvZxstPA95P+rZVNtp8DHKpdbrkQWossFDeSeGELmR+PpdgmkF2sScX7djKC
         CAall1CjhLM2sHz4Kk6GmEKmLWpYHBmHnm7hb8XyyZKGpsOnCX9y6dqhca1XdqqhCmIZ
         v/UmQA2VGpLPK8IjAr6CtgzAfPfYzh7RTARX0LT3RLORkp6s8VPE0bkzlADQ4kiTEHLr
         foq1qd7H4rUjD1s+E6iEjU1a0GrYnNWTLZPWiHvmZmZRs4fSWy7/CnSnTFTLF1Sp9aqp
         ZLoENJpXndKFjDcfzD06QOQ57K4nLZvYpyfDeKhiuX097mgw85pPEgG/WaW92fJxDDeb
         6j6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h8si1335319vsq.215.2019.05.24.13.29.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 13:29:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 940B630821B3;
	Fri, 24 May 2019 20:29:35 +0000 (UTC)
Received: from ultra.random (ovpn-120-242.rdu2.redhat.com [10.10.120.242])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 51E0868B02;
	Fri, 24 May 2019 20:29:32 +0000 (UTC)
Date: Fri, 24 May 2019 16:29:31 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>,
	Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
	Zi Yan <zi.yan@cs.rutgers.edu>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	"Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage
 allocations"
Message-ID: <20190524202931.GB11202@redhat.com>
References: <20190503223146.2312-1-aarcange@redhat.com>
 <20190503223146.2312-3-aarcange@redhat.com>
 <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com>
 <20190520153621.GL18914@techsingularity.net>
 <alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
 <20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Fri, 24 May 2019 20:29:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello everyone,

On Thu, May 23, 2019 at 05:57:37PM -0700, Andrew Morton wrote:
> On Mon, 20 May 2019 10:54:16 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
> > We are going in circles, *yes* there is a problem for potential swap 
> > storms today because of the poor interaction between memory compaction and 
> > directed reclaim but this is a result of a poor API that does not allow 
> > userspace to specify that its workload really will span multiple sockets 
> > so faulting remotely is the best course of action.  The fix is not to 
> > cause regressions for others who have implemented a userspace stack that 
> > is based on the past 3+ years of long standing behavior or for specialized 
> > workloads where it is known that it spans multiple sockets so we want some 
> > kind of different behavior.  We need to provide a clear and stable API to 
> > define these terms for the page allocator that is independent of any 
> > global setting of thp enabled, defrag, zone_reclaim_mode, etc.  It's 
> > workload dependent.
> 
> um, who is going to do this work?

That's a good question. It's going to be a not simple patch to
backport to -stable: it'll be intrusive and it will affect
mm/page_alloc.c significantly so it'll reject heavy. I wouldn't
consider it -stable material at least in the short term, it will
require some testing.

This is why applying a simple fix that avoids the swap storms (and the
swap-less pathological THP regression for vfio device assignment GUP
pinning) is preferable before adding an alloc_pages_multi_order (or
equivalent) so that it'll be the allocator that will decide when
exactly to fallback from 2M to 4k depending on the NUMA distance and
memory availability during the zonelist walk. The basic idea is to
call alloc_pages just once (not first for 2M and then for 4k) and
alloc_pages will decide which page "order" to return.

> Implementing a new API doesn't help existing userspace which is hurting
> from the problem which this patch addresses.

Yes, we can't change all apps that may not fit in a single NUMA
node. Currently it's unsafe to turn "transparent_hugepages/defrag =
always" or the bad behavior can then materialize also outside of
MADV_HUGEPAGE. Those apps that use MADV_HUGEPAGE on their long lived
allocations (i.e. guest physical memory) like qemu are affected even
with the default "defrag = madvise". Those apps are using
MADV_HUGEPAGE for more than 3 years and they are widely used and open
source of course.

> It does appear to me that this patch does more good than harm for the
> totality of kernel users, so I'm inclined to push it through and to try
> to talk Linus out of reverting it again.  

That sounds great. It's also what 3 enterprise distributions had to do
already.

As Mel described in detail, remote THP can't be slower than the swap
I/O (even if we'd swap on a nvdimm it wouldn't change this).

As Michael suggested a dynamic "numa_node_id()" mbind could be pursued
orthogonally to still be able to retain the current upstream behavior
for small apps that can fit in the node and do extremely long lived
static allocations and that don't care if they cause a swap storm
during startup. All we argue about is the default "defrag = always"
and MADV_HUGEPAGE behavior.

The current behavior of "defrag = always" and MADV_HUGEPAGE is way
more aggressive than zone_reclaim_mode in fact, which is also not
enabled by default for similar reasons (but enabling zone_reclaim_mode
by default would cause much less risk of pathological regressions to
large workloads that can't fit in a single node). Enabling
zone_reclaim_mode would eventually fallback to remote nodes
gracefully. As opposed the fallback to remote nodes with
__GFP_THISNODE can only happen after the 2M allocation has failed and
the problem is that 2M allocation don't fail because
compaction+reclaim interleaving keeps succeeding by swapping out more
and more memory, which would the perfectly right behavior for
compaction+reclaim interleaving if only the whole system would be out
of memory in all nodes (and it isn't).

The false positive result from the automated testing (where swapping
overall performance decreased because fariness increased) wasn't
anybody's fault and so the revert at the end of the merge window was a
safe approach. So we can try again to fix it now.

Thanks!
Andrea

