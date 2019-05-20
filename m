Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 330E6C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 17:05:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFA1F216B7
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 17:05:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="Rg3JGm7c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFA1F216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79F9F6B0003; Mon, 20 May 2019 13:05:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 729826B0005; Mon, 20 May 2019 13:05:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A2326B0006; Mon, 20 May 2019 13:05:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F73D6B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 13:05:33 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bg6so9465690plb.8
        for <linux-mm@kvack.org>; Mon, 20 May 2019 10:05:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=4ZOI+jnwXBptD9UIpostnVMZFPCwcvxnpKvL3qurL40=;
        b=g98+DeDWftaCEnbmPgf3/utNfcT8Oyk8rm3ChfqYhH6rPS3zvVibsdIMWxddzDFM0N
         M+vVHcyCKYVCsRjaW0msKGcENVsEgNknGRrI0TdfAi1vg0soU9yBPwEGqaiRHaS5+uqO
         fp9nd5seJGR5OAbM9XZg+aWV2a3n0oQTSqpSkRurwevVcFrumD9fGmNUD4fw4APvN70E
         4E5LMOuTA8tfW1hgdvPNItupFmChNjRO0nUKc4EP6xibV4cK/TgyqQIH+bO22xIHJapy
         iKDwmeinjCGaBAX42Efi0kLtb8abDmOnWppl75xiAKc/tiavROtoOT3Ha4/CQcsByQmm
         YhSg==
X-Gm-Message-State: APjAAAUA0AiNWbTlNCHByB8qqV3hbKDo3r82I8RfRnRzQ68NnxfIt1/s
	eqlANv8i75m7hjlREIQJKK2DLcuekOBtYL19BYSNTPA9ADTOgVwa1zSrLPyAUZQoex7ynGZN9OF
	73St9f1cmcQqpwvGf++JxZvnHK+TpoyjlcA51D9lJwG+F0wRPeWrqPEQ6RUU/MD+GCg==
X-Received: by 2002:a63:da14:: with SMTP id c20mr15041496pgh.191.1558371932783;
        Mon, 20 May 2019 10:05:32 -0700 (PDT)
X-Received: by 2002:a63:da14:: with SMTP id c20mr15041426pgh.191.1558371931854;
        Mon, 20 May 2019 10:05:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558371931; cv=none;
        d=google.com; s=arc-20160816;
        b=Ojv6Q9SOY88Sdyw1MGp+8SSdDNQtrumQUiW+bGopO9yPtZGwcRSegTHxueDO6TwKnr
         nc2bP/X9Jo6dk/R4R17Ky3KmZBnemq1VFqm6CA5fjA1TGdF0zWX6WjmRdipabY1rsBhD
         6WdHk0teKJRgcJHd7X4pZ0QY8+vCQFW9GXXGW1SmnGb2p+RBnbTWu7LngcORDpY7E5PL
         PzXN/2K6dYAFjtJSD44Er8SsO4qVTylcnKRTBCEcqwwcYldZsXjVeyy/c3hYw2Hj4vOy
         c2ppHdRrJ6CLs63Q6TlGFfI/yT+FURPK39K72Xj4zYz1WB4vwVrMy6xoAzYvLmPqD8hF
         HWew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=4ZOI+jnwXBptD9UIpostnVMZFPCwcvxnpKvL3qurL40=;
        b=BAcQUNotWvNs8Ax/OPrwbMCVYR0VojkXuPOcdUDAbXa5HzK2Kb7cyH8stVou4Fv7Ng
         tD6ibp5fFlaMF7enleNtCM3Ga9Y8CDTmIhZ6J/M2jKmetX0uC96FK1EGUHYVd2r3UFa5
         MNJiVqBRI3lWXI+hPGeQgRRf4AbEMOFCkAiicQf27JrF7050vgmNfQaztIUK3KgEXAOP
         YcnChABCdw8vvTKvM00sbnBHUmOikRo/LI0yPtOtXww75QlaWr+cVx4+v8ADGQT8vqHJ
         8NzAa0qa4voi+dcDwH5RQc0o+LIahBQs/qoNsYGNvaauu36fU10isI2Fdmd2yDOwjruM
         eYyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=Rg3JGm7c;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor18267965pgt.21.2019.05.20.10.05.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 10:05:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=Rg3JGm7c;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=4ZOI+jnwXBptD9UIpostnVMZFPCwcvxnpKvL3qurL40=;
        b=Rg3JGm7cAcDM+AZNutQuRwGkJ3ubXbt1UCwOCgZnkJntyOzhCrWnunCiEjWY7ROSIZ
         kVmBbyBsGGB57A5oVMp546xpWJgwU/oSoyDYqohN31no/hHulLW0cV3TFXQxHRGm3Arh
         oZI0B0sNElaQefwHOOurYmhojHza1z+7f0MdJSYwJgf0UX78I0BFmHNhkkyTJP+ysJgA
         1oq4KvyqLM9FGoFmGF0bhA3gzuw3Xcn/MOZUKRVRWJpoiE+3D/NOeDKnUVfhlEhq8tFr
         ACelj15Q04D4dmGoY8dB6fOkc4qS2Hmb9f4IVHnDWYoNGwTJItV3oZNqdJ6Lf+b5E2oC
         /1IA==
X-Google-Smtp-Source: APXvYqwYUPMF0FEJQ8SH6f6V9L+pAAf6oW7lozkMuesu1RZqnBX5kL/J9WlcSj5ZD7fx0NEgV+if8A==
X-Received: by 2002:a63:1045:: with SMTP id 5mr32327108pgq.55.1558371931150;
        Mon, 20 May 2019 10:05:31 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::3:df5f])
        by smtp.gmail.com with ESMTPSA id u76sm21219972pgc.84.2019.05.20.10.05.29
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 May 2019 10:05:30 -0700 (PDT)
Date: Mon, 20 May 2019 13:05:28 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>,
	Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Chris Down <chris@chrisdown.name>,
	linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm, memcg: introduce memory.events.local
Message-ID: <20190520170528.GC11665@cmpxchg.org>
References: <20190518001818.193336-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190518001818.193336-1-shakeelb@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 05:18:18PM -0700, Shakeel Butt wrote:
> The memory controller in cgroup v2 exposes memory.events file for each
> memcg which shows the number of times events like low, high, max, oom
> and oom_kill have happened for the whole tree rooted at that memcg.
> Users can also poll or register notification to monitor the changes in
> that file. Any event at any level of the tree rooted at memcg will
> notify all the listeners along the path till root_mem_cgroup. There are
> existing users which depend on this behavior.
> 
> However there are users which are only interested in the events
> happening at a specific level of the memcg tree and not in the events in
> the underlying tree rooted at that memcg. One such use-case is a
> centralized resource monitor which can dynamically adjust the limits of
> the jobs running on a system. The jobs can create their sub-hierarchy
> for their own sub-tasks. The centralized monitor is only interested in
> the events at the top level memcgs of the jobs as it can then act and
> adjust the limits of the jobs. Using the current memory.events for such
> centralized monitor is very inconvenient. The monitor will keep
> receiving events which it is not interested and to find if the received
> event is interesting, it has to read memory.event files of the next
> level and compare it with the top level one. So, let's introduce
> memory.events.local to the memcg which shows and notify for the events
> at the memcg level.
> 
> Now, does memory.stat and memory.pressure need their local versions.
> IMHO no due to the no internal process contraint of the cgroup v2. The
> memory.stat file of the top level memcg of a job shows the stats and
> vmevents of the whole tree. The local stats or vmevents of the top level
> memcg will only change if there is a process running in that memcg but
> v2 does not allow that. Similarly for memory.pressure there will not be
> any process in the internal nodes and thus no chance of local pressure.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

This looks reasonable to me. Thanks for working out a clear use case
and also addressing how it compares to the stats and pressure files.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

