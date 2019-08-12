Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1262CC41514
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:19:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C721B206C2
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:19:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="XyRII+3I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C721B206C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60C266B0003; Mon, 12 Aug 2019 17:19:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 596866B0005; Mon, 12 Aug 2019 17:19:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 483F76B0006; Mon, 12 Aug 2019 17:19:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0089.hostedemail.com [216.40.44.89])
	by kanga.kvack.org (Postfix) with ESMTP id 2182A6B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:19:27 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C6B9A180AD7C1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:19:26 +0000 (UTC)
X-FDA: 75815041932.17.ball67_6f8710722504f
X-HE-Tag: ball67_6f8710722504f
X-Filterd-Recvd-Size: 2847
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:19:26 +0000 (UTC)
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 26DD0206C2;
	Mon, 12 Aug 2019 21:19:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565644765;
	bh=dHo2t329Id4otpA/Rrjyv9seqUsvy6Z6EEJcEyMJIMw=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=XyRII+3I9wWVWSEqAOP7ZcGdiajnySWhn+aeL+QjbQeopq1r8BppDCR7LG+WCZTaC
	 rhX8JnwudyqzoxJPmWfE9gCemQK+DLgIsu4tnU1xB8d8BwM4X/tFP/ypcGwOIo0ei5
	 qidMBcxIItLjf+ISX6m2+F3bbZnLUpPWTUODQd9U=
Date: Mon, 12 Aug 2019 14:19:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Cc: bjorn.topel@intel.com, linux-mm@kvack.org, xdp-newbies@vger.kernel.org,
 netdev@vger.kernel.org, bpf@vger.kernel.org, linux-kernel@vger.kernel.org,
 ast@kernel.org, magnus.karlsson@intel.com
Subject: Re: [PATCH v2 bpf-next] mm: mmap: increase sockets maximum memory
 size pgoff for 32bits
Message-Id: <20190812141924.32136e040904d0c5a819dcb1@linux-foundation.org>
In-Reply-To: <20190812124326.32146-1-ivan.khoronzhuk@linaro.org>
References: <20190812113429.2488-1-ivan.khoronzhuk@linaro.org>
	<20190812124326.32146-1-ivan.khoronzhuk@linaro.org>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 12 Aug 2019 15:43:26 +0300 Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org> wrote:

> The AF_XDP sockets umem mapping interface uses XDP_UMEM_PGOFF_FILL_RING
> and XDP_UMEM_PGOFF_COMPLETION_RING offsets. The offsets seems like are
> established already and are part of configuration interface.
> 
> But for 32-bit systems, while AF_XDP socket configuration, the values
> are to large to pass maximum allowed file size verification.
> The offsets can be tuned ofc, but instead of changing existent
> interface - extend max allowed file size for sockets.


What are the implications of this?  That all code in the kernel which
handles mapped sockets needs to be audited (and tested) for correctly
handling mappings larger than 4G on 32-bit machines?  Has that been
done?  Are we confident that we aren't introducing user-visible buggy
behaviour into unsuspecting legacy code?

Also...  what are the user-visible runtime effects of this change? 
Please send along a paragraph which explains this, for the changelog. 
Does this patch fix some user-visible problem?  If so, should be code
be backported into -stable kernels?


