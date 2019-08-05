Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29859C32751
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 19:43:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5992205F4
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 19:43:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="FF0ThfX/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5992205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D2976B0007; Mon,  5 Aug 2019 15:43:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 383956B0008; Mon,  5 Aug 2019 15:43:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 272276B000A; Mon,  5 Aug 2019 15:43:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBF876B0007
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 15:43:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e20so54189226pfd.3
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 12:43:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WWvuvR2gfG7sLdu6K+RYuoog4fh46SnlfKdpfISWizo=;
        b=arkJj9TK1eb+3GTqMAErS8HSDqZOqAtLu+maNGdqKFf6zGwNhAlq9hMMO+8Z4xxN6M
         0OryUJU0yamtwxaRE/A3Q7No8zwPpGB0e9nhHGy974Ye+70yCcURJIK4I62dVIYYC+Fi
         svSgoP+CtneaOr7ZhFsH+IU8IGqDcG8BZZbjE2RCqhnLTDFPkLy6upnOj2Mi6XJEMnjF
         /JKTm6NNATywmgRGMPJYNNIXCxSMAtW78x7RERQNc76ZBqSAE3GQMg1PEZZroMcyrDTs
         1RIPt0lOxO6aNX62QjtsFDhoJrB9KSqlqyeXsHod1OmkQuUZ0a0AONYrvx+BZnCbe05/
         j54Q==
X-Gm-Message-State: APjAAAVXp5L/lLkxBW4fRL4kSAMRSu5ckebmTbrG03tm9xLGiz9AUuXL
	XqNJz4VayJ5qXtMhzvG4Iq+9+GCW93dTgsPI1zwhHb3impTasFOxFusAuo5hY4SIoTNkuFtWYXa
	N0Wvly5JTyhCfMZSZWOpJ1aeJa3i/Q1+unrjw9lTD9Icc81Xx432vWxnxibtWZysXDg==
X-Received: by 2002:a63:5648:: with SMTP id g8mr21272405pgm.81.1565034225537;
        Mon, 05 Aug 2019 12:43:45 -0700 (PDT)
X-Received: by 2002:a63:5648:: with SMTP id g8mr21272372pgm.81.1565034224732;
        Mon, 05 Aug 2019 12:43:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565034224; cv=none;
        d=google.com; s=arc-20160816;
        b=c2zcHjWrf3GkXpBWOA72KiOQRXYS4/qCjqVvGnbXZ9HJ4GwUUK1xgWESFV4D/wn8gj
         7efPMKfLCIBhbzk76dDE/43CHtJxfEFaz1v1RqQCbkLtJQFgozQxBczpRUqd/luv/Zm2
         36xYrFTqClFvkCVr6xVzWDbSKYYVPGEcakC1pw87Xth4Puk/Ney7dhRfN3VNIMidsBYF
         b9UHy8xGdt3BAelXVeZpnTGbaBKoRq9peKcwOs4O4cZAcHfPeo3CZOeamAHInfXmgzXJ
         CXSy5a3ThDomq21d6JE1dWkflA2mtGhSIvI86QgzIvumLAzcxxy5H3hnxRO0ymQTUcgv
         W5/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WWvuvR2gfG7sLdu6K+RYuoog4fh46SnlfKdpfISWizo=;
        b=vUnjX7SgfNduyqeG+OjQnbDCxJX+lAf7UHSQao8+YE2kv+/7Uit891PqeCfBtIeuRh
         vMF+Qio8GMrvCWMPDfzYJW7V46qATfCz6Cvv1nqlMw0Q4OJIZnKndfXiE/3dBtVw7ON/
         AAhRBVotVjZV5Hy57ES2E18OeaHTO9ZRawjkh7EwktE5aGN4MYL0scwz9E8WoM+2Iur0
         LQixErj4H/dMl7LeJrPVSJn5KCNw0wo2+ClKGMZAhoR+krThiVIxglpRidlsbOmrwovk
         3sP/ZaGpfwpqZH2jcqTDoky26ZfcGfWneZa6vB489J++Sb2YYoN0yAUZnAo3fsrSx2iV
         lTLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="FF0ThfX/";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w4sor66759886pfb.13.2019.08.05.12.43.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 12:43:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="FF0ThfX/";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=WWvuvR2gfG7sLdu6K+RYuoog4fh46SnlfKdpfISWizo=;
        b=FF0ThfX/bzXj/27mCqPHlsBMwiIYZlOM9RmNphVdMiLTKFTSIINwJ461YEYbUUwEJN
         m26UyZ3XWL77w/tHksUHW1PeyGzJyWNY13DjAPzELJZneSPxWuZasvz9dNFt6/2JPtgv
         qVIywLEuv+OpFrpLPJjL+0VyhOS8hmp386H5C28ioO5TYQorFdFX3xnvENVjSQvV2tyZ
         q5GaWw0MT+HdTeGMxeem1WwEcjvhWzGYE8bRKhHOmp1odj0KsF0vBeTfIHRfi7j/yTkA
         pxF6+yVEj8pUlTHwytLp4HNKWrEMSHivN64CPzymFxxqOyFjW9elvIgLCJFiY5lCLGUn
         dOzg==
X-Google-Smtp-Source: APXvYqxdSjvwIdE9asbvH0WVb955oASYdklotIVD6HjXgjlLwa8lAFefTwAseLg4dhaPLTUjv300/g==
X-Received: by 2002:a62:6083:: with SMTP id u125mr73381751pfb.208.1565034223953;
        Mon, 05 Aug 2019 12:43:43 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::26a1])
        by smtp.gmail.com with ESMTPSA id h26sm89520864pfq.64.2019.08.05.12.43.42
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 12:43:43 -0700 (PDT)
Date: Mon, 5 Aug 2019 15:43:41 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: [PATCH] mm: workingset: fix vmstat counters for shadow nodes
Message-ID: <20190805194341.GA6260@cmpxchg.org>
References: <20190801233532.138743-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801233532.138743-1-guro@fb.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 04:35:32PM -0700, Roman Gushchin wrote:
> Memcg counters for shadow nodes are broken because the memcg pointer is
> obtained in a wrong way. The following approach is used:
> 	virt_to_page(xa_node)->mem_cgroup
> 
> Since commit 4d96ba353075 ("mm: memcg/slab: stop setting page->mem_cgroup
> pointer for slab pages") page->mem_cgroup pointer isn't set for slab pages,
> so memcg_from_slab_page() should be used instead.
> 
> Also I doubt that it ever worked correctly: virt_to_head_page() should be
> used instead of virt_to_page(). Otherwise objects residing on tail pages
> are not accounted, because only the head page contains a valid mem_cgroup
> pointer. That was a case since the introduction of these counters by the
> commit 68d48e6a2df5 ("mm: workingset: add vmstat counter for shadow nodes").

You're right. slub uses order-2 compound pages for radix_tree_node, so
we've been underreporting shadow nodes placed in the three tail pages.

Nice catch.

> Fixes: 4d96ba353075 ("mm: memcg/slab: stop setting page->mem_cgroup pointer for slab pages")
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

