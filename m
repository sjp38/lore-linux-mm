Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A93AC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:56:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF854216C8
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:56:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF854216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 531B38E0003; Mon, 29 Jul 2019 04:56:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E2528E0002; Mon, 29 Jul 2019 04:56:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F90E8E0003; Mon, 29 Jul 2019 04:56:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E96148E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 04:56:50 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y15so37880564edu.19
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:56:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZMmBM5Wr92POpPWvgrvOdwkj5fTvXMbb6KDmjWvPUZA=;
        b=PnLoNZ2xBi4K50vSv3PVFwghi0RjtCjWDOIyO5W81kuPNCT9DaKnxImMWdNqbqa/xU
         XGBtPZaRiOQB7++ErYE8I042fZB1QRUL9fpXlpqaCpeBqyrtKSk1fsHZTPv5EJvwRBol
         qrLDdtWqRBWg85VMVjjnzkLj1NNr4tAUqvu8lS2gSS+BJUB54I3vGyVdbciP9r6m4vwb
         tZl67LIat3wdy/LNVQmXL8CD2t/znskvgkinJZE/cR4BCPV+p578GvHHdEw8AzcSyMrH
         UGmtIMPDf6/Fz77e5i2F/PpqyAXdddcazFOekUZ0mtOgpcJIXvwB6po5yIMeKxGdq0Eo
         4f0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAVa3Xo3WxiVBfwLMz5TU61BRbJ44myI57nCxG8cr8qjXDE+Wkfc
	BPoGPngDHXeJHHQ67AquM/GfBWviuisEBq9jrZVQqHmmIHjSjvxHEIjHEKVNjIjhu+ZopaNaaGF
	kYAuDtTpd0bj7Vm8F8+q2CKY6N7hnlp4/TWioLzsR7zG3VjdEFXYHrlkUdwWw2TvxWQ==
X-Received: by 2002:a50:886a:: with SMTP id c39mr27800177edc.214.1564390610519;
        Mon, 29 Jul 2019 01:56:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4Z4JAwN6NcjA1Pjn5tfBXZVinP/Oy/nvEARsRH5KAfkXOkjI1KA+/8MQGpghlxEFUd1qG
X-Received: by 2002:a50:886a:: with SMTP id c39mr27800134edc.214.1564390609729;
        Mon, 29 Jul 2019 01:56:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564390609; cv=none;
        d=google.com; s=arc-20160816;
        b=UGbM4hIHt1kSl6Jl4vxjEV/tLOrx/jPVf/2nidWehn9H8FDkirZXzn8qLVB/hyOO7j
         7oerAC8FKxxqX8oIeCUjOvM9ICnG+36OOpwqh0U85RPM/kfOLRyZSmvkJELuRjXt4JJ5
         oaw03VDOkQtPOi8qihohDevpT872k2kC/z58aXxYqWa4ZtkHZnKd9OfPcaN4nUooggPB
         XvwpqIXlPFc59U6RHDRSJ1PR8xcQnyQJh+ufymnzx5tU6/lM3iJgLjYQ7TDoUCkViwBT
         fv+uyR2Rv/7N4tWx+ePQOYiovhsPjGWCvm1l0DHHM4i3S49pKOkrtSzgBthpOiqgUvpw
         Oz5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZMmBM5Wr92POpPWvgrvOdwkj5fTvXMbb6KDmjWvPUZA=;
        b=QDkMUTvl22IR7ewUl6uF0wLcSnn0YaUVcuWTxegzLVPwh8SeT9cDkg+LDHoG5NcQHH
         KJ8g9tl2ap3SQ+jAKRgGxzWP9BO0dGYWTDBRehCMVt9b2mCFj54ROHHsYdCGL0Oy5YSC
         kklBxWNLZbxbTFZFTwv4cawBVADVYV7FMgGSY3I4N8LV3cmkU8hBLWDOES7zP04ZRm+e
         w50FDqeXxcJwUbNzyF79LE3PXo30Mg6yKRRs8pLGgbBJBAMiTEfJTi+0Fpep0pCdinga
         flQiGFeGMuzDmszVUfzyZhUu2sW8O8861Aej3fk6x23aoFYX6eUm5ks22qdVww7RIcuL
         nvqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r21si14000487ejz.133.2019.07.29.01.56.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 01:56:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D8379B5EC;
	Mon, 29 Jul 2019 08:56:48 +0000 (UTC)
Date: Mon, 29 Jul 2019 09:56:46 +0100
From: Mel Gorman <mgorman@suse.de>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>,
	jhladky@redhat.com, lvenanci@redhat.com,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND] autonuma: Fix scan period updating
Message-ID: <20190729085646.GG2708@suse.de>
References: <20190725080124.494-1-ying.huang@intel.com>
 <20190725173516.GA16399@linux.vnet.ibm.com>
 <87y30l5jdo.fsf@yhuang-dev.intel.com>
 <20190726092021.GA5273@linux.vnet.ibm.com>
 <87ef295yn9.fsf@yhuang-dev.intel.com>
 <20190729072845.GC7168@linux.vnet.ibm.com>
 <87wog145nn.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <87wog145nn.fsf@yhuang-dev.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 04:16:28PM +0800, Huang, Ying wrote:
> Srikar Dronamraju <srikar@linux.vnet.ibm.com> writes:
> 
> >> >> 
> >> >> if (lr_ratio >= NUMA_PERIOD_THRESHOLD)
> >> >>     slow down scanning
> >> >> else if (sp_ratio >= NUMA_PERIOD_THRESHOLD) {
> >> >>     if (NUMA_PERIOD_SLOTS - lr_ratio >= NUMA_PERIOD_THRESHOLD)
> >> >>         speed up scanning
> >> 
> >> Thought about this again.  For example, a multi-threads workload runs on
> >> a 4-sockets machine, and most memory accesses are shared.  The optimal
> >> situation will be pseudo-interleaving, that is, spreading memory
> >> accesses evenly among 4 NUMA nodes.  Where "share" >> "private", and
> >> "remote" > "local".  And we should slow down scanning to reduce the
> >> overhead.
> >> 
> >> What do you think about this?
> >
> > If all 4 nodes have equal access, then all 4 nodes will be active nodes.
> >
> > From task_numa_fault()
> >
> > 	if (!priv && !local && ng && ng->active_nodes > 1 &&
> > 				numa_is_active_node(cpu_node, ng) &&
> > 				numa_is_active_node(mem_node, ng))
> > 		local = 1;
> >
> > Hence all accesses will be accounted as local. Hence scanning would slow
> > down.
> 
> Yes.  You are right!  Thanks a lot!
> 
> There may be another case.  For example, a workload with 9 threads runs
> on a 2-sockets machine, and most memory accesses are shared.  7 threads
> runs on the node 0 and 2 threads runs on the node 1 based on CPU load
> balancing.  Then the 2 threads on the node 1 will have "share" >>
> "private" and "remote" >> "local".  But it doesn't help to speed up
> scanning.
> 

Ok, so the results from the patch are mostly neutral. There are some
small differences in scan rates depending on the workload but it's not
universal and the headline performance is sometimes worse. I couldn't
find something that would justify the change on its own. I think in the
short term -- just fix the comments.

For the shared access consideration, the scan rate is important but so too
is the decision on when pseudo interleaving should be used. Both should
probably be taken into account when making changes in this area. The
current code may not be optimal but it also has not generated bug reports,
high CPU usage or obviously bad locality decision in the field.  Hence,
for this patch or a similar series, it is critical that some workloads are
selected that really care about the locality of shared access and evaluate
based on that. Initially it was done with a large battery of tests run
by different people but some of those people have changed role since and
would not be in a position to rerun the tests. There also was the issue
that when those were done, NUMA balancing was new so it's comparative
baseline was "do nothing at all".

-- 
Mel Gorman
SUSE Labs

