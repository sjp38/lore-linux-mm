Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8584DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 20:10:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CD522148D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 20:10:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CD522148D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1BA46B0005; Fri, 22 Mar 2019 16:10:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCAD86B0006; Fri, 22 Mar 2019 16:10:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB97C6B0007; Fri, 22 Mar 2019 16:10:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 85B4F6B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 16:10:18 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z14so3142366pgv.0
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:10:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QV+yml+dmrKhpJsktkz3H/NnictQC4bT/SAT8qS5SQs=;
        b=N7IWX92+19DJzr26x9CvGaFOP3ONLLq/zHsNz6cM9M27Sdc3sY7skbQYruYqdKynIp
         VkOMz88zERZbZU3bVNpIx+k+q3+sIOgXBHs/gHCQs8pPsFCBekAdjtOyLEs40NHNHwl1
         0l4V9wprCIbohcbWU8KZ+bBjqaxUWc/yucXe+oGExOxmnx7hp1ZinyNdJl80qTHtujWh
         lWvjkD4TxIHeOdpcRE7lgPRLiXaDrFlXo/zbwx5g0q30awHZP0/UHjH+f4TfqO6BZyB6
         +IZFmWf/rws98GXJRe+vLu7XnrJkLB6KeP1O7NkWnven/msTUDhGu7co/Ha057b+NxvC
         w6kw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAXJDwKwWffgJhVn3M8vNSLs4SCbm54qdTDjaJKpk+FVBIniL7LC
	2fVD4nVWlX34Z7KXiJUv/rQuwz8qGNK1ujF6y4RDg7VLdtZ0pwZz82vgurthWI9v0OkWw2iHN2V
	Os41PWlBhw0oWV0naXK83AoovIqgCbAQbCtpJqhfNvmtW0JZhejS0/fOmhALg1iKUlw==
X-Received: by 2002:a62:e904:: with SMTP id j4mr10950341pfh.174.1553285418126;
        Fri, 22 Mar 2019 13:10:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwU5oVDsQMP/N3JGagsK6qu7sqlKATeflnMSmoKEwMhtYLZQ05KRxysZOntJTTMjUFfxdBV
X-Received: by 2002:a62:e904:: with SMTP id j4mr10950275pfh.174.1553285417349;
        Fri, 22 Mar 2019 13:10:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553285417; cv=none;
        d=google.com; s=arc-20160816;
        b=eFtpIAn+0faruxvehkiSOrid6JGHNqS+RH/y3K5B3VddSdjtEfXmj2ufVNa8KB0OXA
         gMYF7gJJPe2yf7dXaYEmwJShxsqjym1tFJ4qB3ajx1YfCWgorZ0esAHDmrr/gYqNaU/M
         BNoqSbsGsINQb66FlysCRHujKJ8mznhkpGzTuIoteQTiLPZuw6W4Tk0eYGjEVjm94e3W
         YHJE89iATz8E166vtvOcAHca/8OhcmEUCw2WWwMbOHCnzQFRNr3ODNeYQbH2Ail7u+KW
         zYjzClIMaG8kONSAwBPadkY4RmtTs9I+Ec7DxkUA/1jMs0nGVwO7Lk5DEE29/fMXw+la
         ytgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=QV+yml+dmrKhpJsktkz3H/NnictQC4bT/SAT8qS5SQs=;
        b=npxH0sysfp+waKHyguCMU/1VQUwEoFC9UsVbvV2LOeMTpeWemtELE/XIiDhOIq7RU2
         lg6lJrZOIk8yZUltCH0ABFCXygaLjY1NFqx4xmaQ26y2FpJWAe+P42B1K3bhoTY02SZy
         lkf3IXhWcZwUzKPj1BXIAWY4YEdBOg/c4WYwLCRLHxpBHiuWLGO+wWocQVdy1nfbKEGR
         huuqsvXi9OJUT/bOi2IIlybL4Fn9PBz4T2uhP5hYWZbDpoy/IQb7vo90osFartZQKBNI
         RBfNq0Kza5BdmF1OMli7v5IPnMt4swBalXRDObzt2ik1X206IKhRXp5aLIrfONZqir6f
         IDfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x64si7181142pfx.156.2019.03.22.13.10.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 13:10:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 9E62D1BC1;
	Fri, 22 Mar 2019 20:10:16 +0000 (UTC)
Date: Fri, 22 Mar 2019 13:10:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Chris Down <chris@chrisdown.name>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou
 <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
 linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Message-Id: <20190322131015.05edf9fac014f4cacf10dd2a@linux-foundation.org>
In-Reply-To: <20190322160307.GA3316@chrisdown.name>
References: <20190228213050.GA28211@chrisdown.name>
	<20190322160307.GA3316@chrisdown.name>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Mar 2019 16:03:07 +0000 Chris Down <chris@chrisdown.name> wrote:

> This patch is an incremental improvement on the existing
> memory.{low,min} relative reclaim work to base its scan pressure
> calculations on how much protection is available compared to the current
> usage, rather than how much the current usage is over some protection
> threshold.
> 
> Previously the way that memory.low protection works is that if you are
> 50% over a certain baseline, you get 50% of your normal scan pressure.
> This is certainly better than the previous cliff-edge behaviour, but it
> can be improved even further by always considering memory under the
> currently enforced protection threshold to be out of bounds. This means
> that we can set relatively low memory.low thresholds for variable or
> bursty workloads while still getting a reasonable level of protection,
> whereas with the previous version we may still trivially hit the 100%
> clamp. The previous 100% clamp is also somewhat arbitrary, whereas this
> one is more concretely based on the currently enforced protection
> threshold, which is likely easier to reason about.
> 
> There is also a subtle issue with the way that proportional reclaim
> worked previously -- it promotes having no memory.low, since it makes
> pressure higher during low reclaim. This happens because we base our
> scan pressure modulation on how far memory.current is between memory.min
> and memory.low, but if memory.low is unset, we only use the overage
> method. In most cromulent configurations, this then means that we end up
> with *more* pressure than with no memory.low at all when we're in low
> reclaim, which is not really very usable or expected.
> 
> With this patch, memory.low and memory.min affect reclaim pressure in a
> more understandable and composable way. For example, from a user
> standpoint, "protected" memory now remains untouchable from a reclaim
> aggression standpoint, and users can also have more confidence that
> bursty workloads will still receive some amount of guaranteed
> protection.

Could you please provide more description of the effect this has upon
userspace?  Preferably in real-world cases.  What problems were being
observed and how does this improve things?

