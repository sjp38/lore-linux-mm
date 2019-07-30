Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7683C76186
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 01:38:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAE9D206DD
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 01:38:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAE9D206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32A188E0003; Mon, 29 Jul 2019 21:38:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DAB28E0002; Mon, 29 Jul 2019 21:38:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A49E8E0003; Mon, 29 Jul 2019 21:38:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D575C8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 21:38:43 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g18so34278505plj.19
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 18:38:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=T9wlwU4+IdaLH16sk1MGPVkORFJXYdyoerOjUtew3ms=;
        b=Q4k7XLZhnqy8zIvWwQ4J7n4CsMeMW8Fv0v8Ux3QJDs+I8HhIKIWRInG6EBj419muBU
         VEtsaMvLvwAoV2VqWp7QPBwD/hCeDjX9LSVoGHtSzj5YHbscjQWWKci0HVEvXEotXOSR
         W0p7OmsgLbtEp6vNwkwLmDPHNMr16YGfnO2jP5p7j4FSvDt25NXiQSlr/S0KPRpbWXr1
         EfIwzlPeEsEw4klSeapKYPBCnS6WqT0zz8eogSJLj1xW7LLrMAqLxT4YjVG3iRKrX/KT
         xJgdOSAysObob5Jc9jqGfni+aM8H8sOGx+/XWL2aQLAYaruVkF9YloSHRWaNzMfsecsJ
         xe4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUK4tozfYyv9/4wKI/0YbK2u9eRoyVok9MfZF6mPfoaqvz1Sij/
	JGyEnXOfouLW69yQ+T1lgLqniQBlBlrZn+NNiaXNO0YkhLpCyHbLYvnQMaYpamMH/1gjtqpsQSO
	h6/zRWFqCHskcad7BSkh4e2eI89d2GCeowsM+FKbV+TxIxiKpo7iF4FeTc1UFvo0CPA==
X-Received: by 2002:aa7:92d2:: with SMTP id k18mr30357911pfa.153.1564450723509;
        Mon, 29 Jul 2019 18:38:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5ruw+l3liYdDKweKkKtmm8iXAmA4FaW7nnL7PGCC82MpXz0CJh6/lEAf66BcgJM3mR94S
X-Received: by 2002:aa7:92d2:: with SMTP id k18mr30357864pfa.153.1564450722734;
        Mon, 29 Jul 2019 18:38:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564450722; cv=none;
        d=google.com; s=arc-20160816;
        b=YjVPz9dD5a/e0d15IMXcAazlqxEqqUw7DuFq76ioxNVDFt0DThtS5LE56jiQivJAcR
         4NGROG++1iM8y2KX1m7gKQDsgdIs2CjXvvChbsdd/vh7oJEOy3BHuyWC/sSCK/vLD+QL
         1JkbanUL1DVOD+tCi4f0BXHnxRPMWhuwRF+mJtR5onbIC94vqYgeFWOVa2oZvoJSsDkg
         UBsOgOMV6IlQGyS0Rph7YnFSf2zIHZ5wunkWRwDbQTs+/MoeNrnDCXdBYkQxh9HuBjXG
         tzGVVeeZaepMoPJ/WJYww57bhUoN0SeenaJw9wmcEgJejHgquxMsOdTTGzR3LmNfZ/y8
         wYuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=T9wlwU4+IdaLH16sk1MGPVkORFJXYdyoerOjUtew3ms=;
        b=qe5BSBzPsLMPdEcK/RlOOMRWpPR/jy7O4ZmWAH4OJJr2C28/rC1SKDpW1v7UkdPtgd
         Dpf5LsJZQt/6ecjEvaTr3JJNzfzXgJtAl9iNaGivnSqtQwUKUC3spooLGsu1Uk1N7p1v
         NfGwXNGNx3pt0RAAY7oFX7Z68pXHGwjJllDuR61vB7SayEe4qL0SsCTjXaHthDGl2QTE
         gmhOQIgx7ARwWbsK9Ju7lP109GZTXlxek14AVSA4EjuwY5letxpZ9Zk26UZMIDnPvnxe
         QpxyP1DiCPw3nhvNe3VMrXeyxkljAhasYLoKp7xNcZXrPPpZRUfrFQmef8ROILKJD6+A
         /egA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id j74si28385353pje.12.2019.07.29.18.38.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 18:38:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Jul 2019 18:38:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,324,1559545200"; 
   d="scan'208";a="165675363"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by orsmga008.jf.intel.com with ESMTP; 29 Jul 2019 18:38:40 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>,  Peter Zijlstra <peterz@infradead.org>,  Ingo Molnar <mingo@kernel.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Rik van Riel <riel@redhat.com>,  <jhladky@redhat.com>,  <lvenanci@redhat.com>,  Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND] autonuma: Fix scan period updating
References: <20190725080124.494-1-ying.huang@intel.com>
	<20190725173516.GA16399@linux.vnet.ibm.com>
	<87y30l5jdo.fsf@yhuang-dev.intel.com>
	<20190726092021.GA5273@linux.vnet.ibm.com>
	<87ef295yn9.fsf@yhuang-dev.intel.com>
	<20190729072845.GC7168@linux.vnet.ibm.com>
	<87wog145nn.fsf@yhuang-dev.intel.com> <20190729085646.GG2708@suse.de>
Date: Tue, 30 Jul 2019 09:38:39 +0800
In-Reply-To: <20190729085646.GG2708@suse.de> (Mel Gorman's message of "Mon, 29
	Jul 2019 09:56:46 +0100")
Message-ID: <87ftmo47z4.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman <mgorman@suse.de> writes:

> On Mon, Jul 29, 2019 at 04:16:28PM +0800, Huang, Ying wrote:
>> Srikar Dronamraju <srikar@linux.vnet.ibm.com> writes:
>> 
>> >> >> 
>> >> >> if (lr_ratio >= NUMA_PERIOD_THRESHOLD)
>> >> >>     slow down scanning
>> >> >> else if (sp_ratio >= NUMA_PERIOD_THRESHOLD) {
>> >> >>     if (NUMA_PERIOD_SLOTS - lr_ratio >= NUMA_PERIOD_THRESHOLD)
>> >> >>         speed up scanning
>> >> 
>> >> Thought about this again.  For example, a multi-threads workload runs on
>> >> a 4-sockets machine, and most memory accesses are shared.  The optimal
>> >> situation will be pseudo-interleaving, that is, spreading memory
>> >> accesses evenly among 4 NUMA nodes.  Where "share" >> "private", and
>> >> "remote" > "local".  And we should slow down scanning to reduce the
>> >> overhead.
>> >> 
>> >> What do you think about this?
>> >
>> > If all 4 nodes have equal access, then all 4 nodes will be active nodes.
>> >
>> > From task_numa_fault()
>> >
>> > 	if (!priv && !local && ng && ng->active_nodes > 1 &&
>> > 				numa_is_active_node(cpu_node, ng) &&
>> > 				numa_is_active_node(mem_node, ng))
>> > 		local = 1;
>> >
>> > Hence all accesses will be accounted as local. Hence scanning would slow
>> > down.
>> 
>> Yes.  You are right!  Thanks a lot!
>> 
>> There may be another case.  For example, a workload with 9 threads runs
>> on a 2-sockets machine, and most memory accesses are shared.  7 threads
>> runs on the node 0 and 2 threads runs on the node 1 based on CPU load
>> balancing.  Then the 2 threads on the node 1 will have "share" >>
>> "private" and "remote" >> "local".  But it doesn't help to speed up
>> scanning.
>> 
>
> Ok, so the results from the patch are mostly neutral. There are some
> small differences in scan rates depending on the workload but it's not
> universal and the headline performance is sometimes worse. I couldn't
> find something that would justify the change on its own.

Thanks a lot for your help!

> I think in the short term -- just fix the comments.

Then we will change the comments to something like,

"Slow down scanning if most memory accesses are private."

It's hard to be understood.  Maybe we just keep the code and comments as
it was until we have better understanding.

> For the shared access consideration, the scan rate is important but so too
> is the decision on when pseudo interleaving should be used. Both should
> probably be taken into account when making changes in this area. The
> current code may not be optimal but it also has not generated bug reports,
> high CPU usage or obviously bad locality decision in the field.  Hence,
> for this patch or a similar series, it is critical that some workloads are
> selected that really care about the locality of shared access and evaluate
> based on that. Initially it was done with a large battery of tests run
> by different people but some of those people have changed role since and
> would not be in a position to rerun the tests. There also was the issue
> that when those were done, NUMA balancing was new so it's comparative
> baseline was "do nothing at all".

Yes.  I totally agree that we should change the behavior based on
testing.

Best Regards,
Huang, Ying

