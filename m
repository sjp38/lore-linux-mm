Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 771AEC3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 13:24:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45D882133F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 13:24:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45D882133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8E756B0281; Thu, 15 Aug 2019 09:24:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3F046B0282; Thu, 15 Aug 2019 09:24:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C53C76B0283; Thu, 15 Aug 2019 09:24:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0163.hostedemail.com [216.40.44.163])
	by kanga.kvack.org (Postfix) with ESMTP id A3A466B0281
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 09:24:26 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4C5D38248AA7
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:24:26 +0000 (UTC)
X-FDA: 75824731332.30.idea94_43ca4519b200f
X-HE-Tag: idea94_43ca4519b200f
X-Filterd-Recvd-Size: 3263
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:24:25 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 64041AE12;
	Thu, 15 Aug 2019 13:24:24 +0000 (UTC)
Date: Thu, 15 Aug 2019 15:24:23 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190815132423.GJ9477@dhcp22.suse.cz>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814134558.fe659b1a9a169c0150c3e57c@linux-foundation.org>
 <20190815084429.GE9477@dhcp22.suse.cz>
 <20190815130415.GD21596@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815130415.GD21596@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 15-08-19 10:04:15, Jason Gunthorpe wrote:
> On Thu, Aug 15, 2019 at 10:44:29AM +0200, Michal Hocko wrote:
> 
> > As the oom reaper is the primary guarantee of the oom handling forward
> > progress it cannot be blocked on anything that might depend on blockable
> > memory allocations. These are not really easy to track because they
> > might be indirect - e.g. notifier blocks on a lock which other context
> > holds while allocating memory or waiting for a flusher that needs memory
> > to perform its work.
> 
> But lockdep *does* track all this and fs_reclaim_acquire() was created
> to solve exactly this problem.
> 
> fs_reclaim is a lock and it flows through all the usual lockdep
> schemes like any other lock. Any time the page allocator wants to do
> something the would deadlock with reclaim it takes the lock.

Our emails have crossed. Even if fs_reclaim can be re-purposed for other
than FS/IO reclaim contexts which I am not sure about I think that
lockdep is too heavy weight for the purpose of this debugging aid in the
first place. The non block mode is really something as simple as "hey
mmu notifier you are only allowed to do a lightweight processing, if you
cannot guarantee that then just back off". The annotation will give us a
warning if the notifier gets out of this promise.

-- 
Michal Hocko
SUSE Labs

