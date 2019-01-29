Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27030C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:41:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D341120881
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:41:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D341120881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EC608E0002; Tue, 29 Jan 2019 18:41:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69DD88E0001; Tue, 29 Jan 2019 18:41:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DC248E0002; Tue, 29 Jan 2019 18:41:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 457788E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 18:41:03 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id b16so26364508qtc.22
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:41:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=PIsQixD5Tkp+1BKb6s8Xb53MCMHgYS1IcudttOLlDvQ=;
        b=Z6iJWCWRQoE7XwyhbS+k9vZleQrMOnucua2YP3fJecsUt7YbBNzulG42fIHtylS63i
         V/SZMnHJJRbGNLwua8w4U4VpMFDkvzCTFS1frsU4CPkSrht835veRZcqe4i7Cu1Y7Gw8
         e5fnTZZpMHFAA5CGU/8yTzn79vCEQkoaTZkaht5Zu3n5CfAlzqup4pI33dTDHkSIClPS
         3AD0GS6yHGs8qe3UUvJ21bvmGoQlU6/iAT/6/8t/jHFBS097s7+A8RkGgow3pKtCNh0o
         cihBwirtLnKulz8h5dE67yInzb3PIhgiNM9oar7YQiMwdohV2S7B8FR19Hv3V1q+9GgO
         NlEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdhS70vzRe1c7PYTwIqz6PRoa2hYMKFTlvtOAoesHN+07gcOhTV
	MVou1RofJ2Ie53fsrznPqov3xaf+xlCYSUa8cFCBz/hVFQxfRoib6lHfOIbXy8FVNHMzTl2kYvX
	G47bV5S4s5tlv1kATZvLNIzyCzjEQpe5eJynWkq62vuc8i0SWlkl5klkxDmy3MeEf5A==
X-Received: by 2002:a37:ae87:: with SMTP id x129mr25989819qke.15.1548805262959;
        Tue, 29 Jan 2019 15:41:02 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7v7IOnXwH6feC3uNYQTZ1pTKQo2TkaYHdx7EDw+k9f+5ZXaIj0NhwvTiyTVPjYDAqAw2Rx
X-Received: by 2002:a37:ae87:: with SMTP id x129mr25989790qke.15.1548805262267;
        Tue, 29 Jan 2019 15:41:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548805262; cv=none;
        d=google.com; s=arc-20160816;
        b=v8FAnROj1KohvRj5g4iftL3l70+XBaoieHihAYJURU+/Uu3WgIt2+B5Y9xQ+/LrjA2
         3xI+Nh4Px+1V2Ue1aidE/0Do+1b0NcQTi8QJHZjp+j/H9XXXDTAAd0slzebrnN5/G0Sq
         lpOUAGXFSvcgN3DGAUADzTgn40F+lCFEliX1yOWtdaUoudDX/Y1vDdHYGnrU+95PTYBx
         f8/eEJfxGhD+fbd6DOJVRRiaCwT012pQ/jgAOqoA6jIzkjgNXc+CDuIr9Mey5dSDh63J
         RdnYFVLxvwWYuEikNszJxs2OZvfS48upUOIzNk+95c2n9efBw3VrtGX3uGadHOM2HX68
         BwjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=PIsQixD5Tkp+1BKb6s8Xb53MCMHgYS1IcudttOLlDvQ=;
        b=ohQpP4P6g+1Mb+A8xDp3cdnoEe9l6h+9owo1dP+Ixn6vxz7qw8kEFHB8kUrvumyCgr
         zsICuR3dAqYtSW5EwGFtAUYWDxr9w8ASiCk9yR8ngd2fFNQYJ7ECvbZyl5iIoc+VIxLX
         O2kA4/iuNOYRyytiQT9dpVMuVefdegm9YiUaSt8QBTolRhhizy9PP+Kp6+5zLYKZiCFN
         IEA1ZHNufLnrjNyiJT5V1CDQn1xQ6z3Q7uYZIS0PfvVVg+yiyEDweA+5l2mV6Mkv/ysj
         BpASEunQ9bqVEsHPQXXucJ14jVvg7MHkORYf8XsX3qMG3g6yKxMTmcPDiuYvi+kgbfA9
         pJvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 49si4212719qts.164.2019.01.29.15.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 15:41:02 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 466A29B309;
	Tue, 29 Jan 2019 23:41:01 +0000 (UTC)
Received: from sky.random (ovpn-121-14.rdu2.redhat.com [10.10.121.14])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DB1D6112C1A0;
	Tue, 29 Jan 2019 23:40:58 +0000 (UTC)
Date: Tue, 29 Jan 2019 18:40:58 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Peter Xu <peterx@redhat.com>,
	Blake Caldwell <blake.caldwell@colorado.edu>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	David Rientjes <rientjes@google.com>
Subject: [LSF/MM TOPIC] NUMA remote THP vs NUMA local non-THP under
 MADV_HUGEPAGE
Message-ID: <20190129234058.GH31695@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 29 Jan 2019 23:41:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I'd like to attend the LSF/MM Summit 2019. I'm interested in most MM
topics and it's enlightening to listen to the common non-MM topics
too.

One current topic that could be of interest is the THP / NUMA tradeoff
in subject.

One issue about a change in MADV_HUGEPAGE behavior made ~3 years ago
kept floating around for the last 6 months (~12 months since it was
initially reported as regression through an enterprise-like workload)
and it was hot-fixed in commit
ac5b2c18911ffe95c08d69273917f90212cf5659, but it got quickly reverted
for various reasons.

I posted some benchmark results showing that for tasks without strong
NUMA locality the __GFP_THISNODE logic is not guaranteed to be optimal
(and here of course I mean even if we ignore the large slowdown with
swap storms at allocation time that might be caused by
__GFP_THISNODE). The results also show NUMA remote THPs help
intrasocket as well as intersocket.

https://lkml.kernel.org/r/20181210044916.GC24097@redhat.com
https://lkml.kernel.org/r/20181212104418.GE1130@redhat.com

The following seems the interim conclusion which I happen to be in
agreement with Michal and Mel:

https://lkml.kernel.org/r/20181212095051.GO1286@dhcp22.suse.cz
https://lkml.kernel.org/r/20181212170016.GG1130@redhat.com

Hopefully this strict issue will be hot-fixed before April (like we
had to hot-fix it in the enterprise kernels to avoid the 3 years old
regression to break large workloads that can't fit it in a single NUMA
node and I assume other enterprise distributions will follow suit),
but whatever hot-fix will likely allow ample margin for discussions on
what we can do better to optimize the decision between local non-THP
and remote THP under MADV_HUGEPAGE.

It is clear that the __GFP_THISNODE forced in the current code
provides some minor advantage to apps using MADV_HUGEPAGE that can fit
in a single NUMA node, but we should try to achieve it without major
disadvantages to apps that can't fit in a single NUMA node.

For example it was mentioned that we could allocate readily available
already-free local 4k if local compaction fails and the watermarks
still allows local 4k allocations without invoking reclaim, before
invoking compaction on remote nodes. The same can be repeated at a
second level with intra-socket non-THP memory before invoking
compaction inter-socket. However we can't do things like that with the
current page allocator workflow. It's possible some larger change is
required than just sending a single gfp bitflag down to the page
allocator that creates an implicit MPOL_LOCAL binding to make it
behave like the obsoleted numa/zone reclaim behavior, but weirdly only
applied to THP allocations.

--

In addition to the above "NUMA remote THP vs NUMA local non-THP
tradeoff" topic, there are other developments in "userfaultfd" land that
are approaching merge readiness and that would be possible to provide a
short overview about:

- Peter Xu made significant progress in finalizing the userfaultfd-WP
  support over the last few months. That feature was planned from the
  start and it will allow userland to do some new things that weren't
  possible to achieve before. In addition to synchronously blocking
  write faults to be resolved by an userland manager, it has also the
  ability to obsolete the softdirty feature, because it can provide
  the same information, but with O(1) complexity (as opposed of the
  current softdirty O(N) complexity) similarly to what the Page
  Modification Logging (PML) does in hardware for EPT write accesses.

- Blake Caldwell maintained the UFFDIO_REMAP support to atomically
  remove memory from a mapping with userfaultfd (which can't be done
  with a copy as in UFFDIO_COPY and it requires a slow TLB flush to be
  safe) as an alternative to host swapping (which of course also
  requires a TLB flush for similar reasons). Notably UFFDIO_REMAP was
  rightfully naked early on and quickly replaced by UFFDIO_COPY which
  is more optimal to add memory to a mapping is small chunks, but we
  can't remove memory with UFFDIO_COPY and UFFDIO_REMAP should be as
  efficient as it gets when it comes to removing memory from a
  mapping.

Thank you,
Andrea

