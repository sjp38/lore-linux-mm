Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2710C742B3
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 10:48:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 971B221019
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 10:48:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 971B221019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32FB68E0137; Fri, 12 Jul 2019 06:48:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BA628E00DB; Fri, 12 Jul 2019 06:48:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 159F68E0137; Fri, 12 Jul 2019 06:48:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D07418E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 06:48:10 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n1so4987677plk.11
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:48:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=Ub/f+9PbS0Ef1IevZSrePbxMAyMtEPOLg3vMNYOOQ8o=;
        b=NuAiwaIGdl0B0U7IIbGEOd9/mIIrQMlsYIK+d6C0p+gwvchfHueOMntM/KJLF0WblW
         TsMYGz6u7V8GwaGAVmxjq5qKX9lZyw3XCGRF8LVvrwVA615vVa2VWq1Jrmh+y5WvAbCr
         KVWKLJnaIK4p2aCPqXlauHTUDJP1xpRl3zjFQBmpD7ZBGkb9LJxAT177I9bNYPzIPQU2
         nZ/2loFvKpVu5WReZtEOltq1+EsCNGucxQhH3UTbQ+JeRSGfCty73GPt8Xd2b1kWhbOP
         x/BR+FAqLs7ppVrXABELQYzz8w5mygpT9joyIMmiTkQuTcxRyJl/gPDHlayn9ARlJK36
         hsjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWTnI1spbl9sbdkFy4dGw5EcqzmNhgUpQJGJU8jbex7o8aJG7YE
	z+Zmoa7MuRTZPa16VCgyDSC52JHKNyUwWoHeeos2FbRZMilSBFCQBkKbVrTxdtSzh3+KpGSWXqj
	he1H7X+FCocH+q6axZkH2ksOtdlJR2TXeo+ClgY/uL5230PXCLf+UO99YMEru+ninkA==
X-Received: by 2002:a63:c508:: with SMTP id f8mr10246594pgd.48.1562928490196;
        Fri, 12 Jul 2019 03:48:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmy6+rqMwjcrYMgYq7qeIFIW8qa0yLKRJz+3lebLBzREJHM5YLCcXW/bJuumFVz0IYATNE
X-Received: by 2002:a63:c508:: with SMTP id f8mr10246526pgd.48.1562928489313;
        Fri, 12 Jul 2019 03:48:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562928489; cv=none;
        d=google.com; s=arc-20160816;
        b=FCq7AVpbCDHkH40O3vwbD24lyaPsx1e8Zu9eSyhvHMx0b0cEhEI4399yQ4FdltLvRO
         5ZMwLvsQcimeX7eiHGac/INeFWWmXIyzhYLUtE3/ANgbeb+4ZkE3jH+gAl/3ZYGgL8ZF
         rr0+8UEQF7qj+c+N9OruUiL0wXYqgVfOpL2AH3BjA4nDFKrCNh/dfW4COLSCW9BJniSr
         MkEaZVqX/cCWLCIfWOqMa+3dYtsgtpo1nnKfg+/HpNPW3IJNoOI5xydgScDTjIllrwzg
         onS81fNXb4skdwDedoxSyn0ep8sPCQAsLoI1vLelv24jvalTbLl3gukO06KHatgqFi/K
         GGXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=Ub/f+9PbS0Ef1IevZSrePbxMAyMtEPOLg3vMNYOOQ8o=;
        b=mn2f7+j400lM+XbUVgZnr4lj0PGJHyVx9KGZlYdw/6Qp9VKODP/NdnIpYfDTnPxdIZ
         4T8XA1ffhJTCtmMHHHXrbOEjq6kL93c9PmpggS9OoP4IWy40CEh+EYn3OVxat0kC+HI9
         fUKz0IOMDuNEB9fDtVVTdE2BFfYF+ALjXlO9AEB85/Ui+pp9sZHtyZ/3WUXONCvTwPJ8
         WLFQpKrHLisUSEkZUmdFdSPPelZC1akARsq16tpT9xi+FUWSO/GEOHCnyrhdXDTXHyo6
         26MJNaIeYYrXISdyaVdkCJIZUFOhNvn+t6qgUPHP60U5H2MLzKAneQH3gU08dInf+VE/
         RmqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id w31si7452102pla.334.2019.07.12.03.48.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 03:48:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Jul 2019 03:48:08 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,482,1557212400"; 
   d="scan'208";a="177468984"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by orsmga002.jf.intel.com with ESMTP; 12 Jul 2019 03:48:06 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Mel Gorman <mgorman@suse.de>
Cc: huang ying <huang.ying.caritas@gmail.com>,  Andrew Morton <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  LKML <linux-kernel@vger.kernel.org>,  Rik van Riel <riel@redhat.com>,  "Peter Zijlstra" <peterz@infradead.org>,  <jhladky@redhat.com>,  <lvenanci@redhat.com>,  Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH -mm] autonuma: Fix scan period updating
References: <20190624025604.30896-1-ying.huang@intel.com>
	<20190624140950.GF2947@suse.de>
	<CAC=cRTNYUxGUcSUvXa-g9hia49TgrjkzE-b06JbBtwSn2zWYsw@mail.gmail.com>
	<20190703091747.GA13484@suse.de> <87ef3663nd.fsf@yhuang-dev.intel.com>
	<20190712082710.GH13484@suse.de>
Date: Fri, 12 Jul 2019 18:48:05 +0800
In-Reply-To: <20190712082710.GH13484@suse.de> (Mel Gorman's message of "Fri,
	12 Jul 2019 09:27:10 +0100")
Message-ID: <87d0ifwmu2.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman <mgorman@suse.de> writes:

> On Thu, Jul 04, 2019 at 08:32:06AM +0800, Huang, Ying wrote:
>> Mel Gorman <mgorman@suse.de> writes:
>> 
>> > On Tue, Jun 25, 2019 at 09:23:22PM +0800, huang ying wrote:
>> >> On Mon, Jun 24, 2019 at 10:25 PM Mel Gorman <mgorman@suse.de> wrote:
>> >> >
>> >> > On Mon, Jun 24, 2019 at 10:56:04AM +0800, Huang Ying wrote:
>> >> > > The autonuma scan period should be increased (scanning is slowed down)
>> >> > > if the majority of the page accesses are shared with other processes.
>> >> > > But in current code, the scan period will be decreased (scanning is
>> >> > > speeded up) in that situation.
>> >> > >
>> >> > > This patch fixes the code.  And this has been tested via tracing the
>> >> > > scan period changing and /proc/vmstat numa_pte_updates counter when
>> >> > > running a multi-threaded memory accessing program (most memory
>> >> > > areas are accessed by multiple threads).
>> >> > >
>> >> >
>> >> > The patch somewhat flips the logic on whether shared or private is
>> >> > considered and it's not immediately obvious why that was required. That
>> >> > aside, other than the impact on numa_pte_updates, what actual
>> >> > performance difference was measured and on on what workloads?
>> >> 
>> >> The original scanning period updating logic doesn't match the original
>> >> patch description and comments.  I think the original patch
>> >> description and comments make more sense.  So I fix the code logic to
>> >> make it match the original patch description and comments.
>> >> 
>> >> If my understanding to the original code logic and the original patch
>> >> description and comments were correct, do you think the original patch
>> >> description and comments are wrong so we need to fix the comments
>> >> instead?  Or you think we should prove whether the original patch
>> >> description and comments are correct?
>> >> 
>> >
>> > I'm about to get knocked offline so cannot answer properly. The code may
>> > indeed be wrong and I have observed higher than expected NUMA scanning
>> > behaviour than expected although not enough to cause problems. A comment
>> > fix is fine but if you're changing the scanning behaviour, it should be
>> > backed up with data justifying that the change both reduces the observed
>> > scanning and that it has no adverse performance implications.
>> 
>> Got it!  Thanks for comments!  As for performance testing, do you have
>> some candidate workloads?
>> 
>
> Ordinarily I would hope that the patch was motivated by observed
> behaviour so you have a metric for goodness. However, for NUMA balancing
> I would typically run basic workloads first -- dbench, tbench, netperf,
> hackbench and pipetest. The objective would be to measure the degree
> automatic NUMA balancing is interfering with a basic workload to see if
> they patch reduces the number of minor faults incurred even though there
> is no NUMA balancing to be worried about. This measures the general
> overhead of a patch. If your reasoning is correct, you'd expect lower
> overhead.
>
> For balancing itself, I usually look at Andrea's original autonuma
> benchmark, NAS Parallel Benchmark (D class usually although C class for
> much older or smaller machines) and spec JBB 2005 and 2015. Of the JBB
> benchmarks, 2005 is usually more reasonable for evaluating NUMA balancing
> than 2015 is (which can be unstable for a variety of reasons). In this
> case, I would be looking at whether the overhead is reduced, whether the
> ratio of local hits is the same or improved and the primary metric of
> each (time to completion for Andrea's and NAS, throughput for JBB).
>
> Even if there is no change to locality and the primary metric but there
> is less scanning and overhead overall, it would still be an improvement.

Thanks a lot for your detailed guidance.

> If you have trouble doing such an evaluation, I'll queue tests if they
> are based on a patch that addresses the specific point of concern (scan
> period not updated) as it's still not obvious why flipping the logic of
> whether shared or private is considered was necessary.

I can do the evaluation, but it will take quite some time for me to
setup and run all these benchmarks.  So if these benchmarks have already
been setup in your environment, so that your extra effort is minimal, it
will be great if you can queue tests for the patch.  Feel free to reject
me for any inconvenience.

Best Regards,
Huang, Ying

