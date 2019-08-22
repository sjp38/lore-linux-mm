Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BEF3C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 23:23:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 160FD233A2
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 23:23:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="fN7pTYAW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 160FD233A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A80576B0362; Thu, 22 Aug 2019 19:23:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A57CA6B0363; Thu, 22 Aug 2019 19:23:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9943F6B0364; Thu, 22 Aug 2019 19:23:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0196.hostedemail.com [216.40.44.196])
	by kanga.kvack.org (Postfix) with ESMTP id 72AE26B0362
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 19:23:04 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 1E4AE6D8D
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 23:23:04 +0000 (UTC)
X-FDA: 75851641488.25.sock91_1abd6a67e2916
X-HE-Tag: sock91_1abd6a67e2916
X-Filterd-Recvd-Size: 3204
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 23:23:03 +0000 (UTC)
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 629EA205ED;
	Thu, 22 Aug 2019 23:23:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566516182;
	bh=SSwCNTMur/081Fa89ShN1PC9iyHoJEAT2lJPl/mFI/c=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=fN7pTYAWAY6uFIgSUWEb45q3M+mQkLeoWqX/mCfeuskBzOAv6Ybrj4x02GR2iv10W
	 AA0Nzh7hRjMILRQgp1wsk8ONqdtZwWgZdUj9ToNXXYVBKbAuaT2nfAAth7w0gFdDpF
	 dsORVNJq0PzaEJ5nODlx0Va6QvwJJY8lWPfYhB5c=
Date: Thu, 22 Aug 2019 16:23:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Henry Burns <henryburns@google.com>, Minchan Kim <minchan@kernel.org>,
 Nitin Gupta <ngupta@vflare.org>, Shakeel Butt <shakeelb@google.com>,
 Jonathan Adams <jwadams@google.com>, HenryBurns
 <henrywolfeburns@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2 v2] mm/zsmalloc.c: Fix race condition in
 zs_destroy_pool
Message-Id: <20190822162302.6fdda379ada876e46a14a51e@linux-foundation.org>
In-Reply-To: <20190820025939.GD500@jagdpanzerIV>
References: <20190809181751.219326-1-henryburns@google.com>
	<20190809181751.219326-2-henryburns@google.com>
	<20190820025939.GD500@jagdpanzerIV>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Aug 2019 11:59:39 +0900 Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> On (08/09/19 11:17), Henry Burns wrote:
> > In zs_destroy_pool() we call flush_work(&pool->free_work). However, we
> > have no guarantee that migration isn't happening in the background
> > at that time.
> > 
> > Since migration can't directly free pages, it relies on free_work
> > being scheduled to free the pages.  But there's nothing preventing an
> > in-progress migrate from queuing the work *after*
> > zs_unregister_migration() has called flush_work().  Which would mean
> > pages still pointing at the inode when we free it.
> > 
> > Since we know at destroy time all objects should be free, no new
> > migrations can come in (since zs_page_isolate() fails for fully-free
> > zspages).  This means it is sufficient to track a "# isolated zspages"
> > count by class, and have the destroy logic ensure all such pages have
> > drained before proceeding.  Keeping that state under the class
> > spinlock keeps the logic straightforward.
> > 
> > Fixes: 48b4800a1c6a ("zsmalloc: page migration support")
> > Signed-off-by: Henry Burns <henryburns@google.com>
> 
> Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> 

Thanks.  So we have a couple of races which result in memory leaks?  Do
we feel this is serious enough to justify a -stable backport of the
fixes?


