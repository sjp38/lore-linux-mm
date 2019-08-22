Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CEDEC3A5A3
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 23:14:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1268233A0
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 23:14:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="JnFvVQX5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1268233A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72D1D6B0360; Thu, 22 Aug 2019 19:14:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DBE46B0361; Thu, 22 Aug 2019 19:14:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F1036B0362; Thu, 22 Aug 2019 19:14:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0217.hostedemail.com [216.40.44.217])
	by kanga.kvack.org (Postfix) with ESMTP id 375C06B0360
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 19:14:31 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B97AD180AD7C1
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 23:14:30 +0000 (UTC)
X-FDA: 75851619900.24.shoes49_61891e6e48829
X-HE-Tag: shoes49_61891e6e48829
X-Filterd-Recvd-Size: 3038
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 23:14:30 +0000 (UTC)
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9E6CC2173E;
	Thu, 22 Aug 2019 23:14:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566515669;
	bh=vApCOM3H3LWmBhR9eGKlIz7FlGeav7+0V7QMAv0lrz4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=JnFvVQX53Ce1G2PQ2HOdxbB/SubAMwjIprQiE8EBfadRyLGqt1J+ii+olw/j5668Y
	 +QtLBXDlkv6/aLoxjapTqHtWc0fc3gJRJDtnIBEIp+3qWO0oQofuFmpQXuSE4efjH3
	 lHWO0el4UUudjvso5nDstFN30oxIxxABVA7nHCxs=
Date: Thu, 22 Aug 2019 16:14:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, DRI
 Development <dri-devel@lists.freedesktop.org>, Intel Graphics Development
 <intel-gfx@lists.freedesktop.org>, Daniel Vetter <daniel.vetter@ffwll.ch>,
 Jason Gunthorpe <jgg@ziepe.ca>, Peter Zijlstra <peterz@infradead.org>, Ingo
 Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.com>, David Rientjes
 <rientjes@google.com>, Christian =?ISO-8859-1?Q?K=F6nig?=
 <christian.koenig@amd.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse
 <jglisse@redhat.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Wei
 Wang <wvw@google.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
 Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>, Feng
 Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>, Randy Dunlap
 <rdunlap@infradead.org>, Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 3/4] kernel.h: Add non_block_start/end()
Message-Id: <20190822161428.c9e4479207386d34745ea111@linux-foundation.org>
In-Reply-To: <20190820202440.GH11147@phenom.ffwll.local>
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
	<20190820081902.24815-4-daniel.vetter@ffwll.ch>
	<20190820202440.GH11147@phenom.ffwll.local>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Aug 2019 22:24:40 +0200 Daniel Vetter <daniel@ffwll.ch> wrote:

> Hi Peter,
> 
> Iirc you've been involved at least somewhat in discussing this. -mm folks
> are a bit undecided whether these new non_block semantics are a good idea.
> Michal Hocko still is in support, but Andrew Morton and Jason Gunthorpe
> are less enthusiastic. Jason said he's ok with merging the hmm side of
> this if scheduler folks ack. If not, then I'll respin with the
> preempt_disable/enable instead like in v1.

I became mollified once Michel explained the rationale.  I think it's
OK.  It's very specific to the oom reaper and hopefully won't be used
more widely(?).


