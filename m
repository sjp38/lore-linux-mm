Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D82EFC41514
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 08:44:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6EEC21855
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 08:44:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6EEC21855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2063C6B0003; Thu, 15 Aug 2019 04:44:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B7286B0005; Thu, 15 Aug 2019 04:44:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CDFE6B0010; Thu, 15 Aug 2019 04:44:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0254.hostedemail.com [216.40.44.254])
	by kanga.kvack.org (Postfix) with ESMTP id DF6A96B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 04:44:38 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 84656440C
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 08:44:38 +0000 (UTC)
X-FDA: 75824026236.22.stick90_62b0187ad7955
X-HE-Tag: stick90_62b0187ad7955
X-Filterd-Recvd-Size: 4181
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 08:44:38 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 39BCDAE84;
	Thu, 15 Aug 2019 08:44:31 +0000 (UTC)
Date: Thu, 15 Aug 2019 10:44:29 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
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
Message-ID: <20190815084429.GE9477@dhcp22.suse.cz>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814134558.fe659b1a9a169c0150c3e57c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814134558.fe659b1a9a169c0150c3e57c@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 14-08-19 13:45:58, Andrew Morton wrote:
> On Wed, 14 Aug 2019 22:20:24 +0200 Daniel Vetter <daniel.vetter@ffwll.ch> wrote:
> 
> > In some special cases we must not block, but there's not a
> > spinlock, preempt-off, irqs-off or similar critical section already
> > that arms the might_sleep() debug checks. Add a non_block_start/end()
> > pair to annotate these.
> > 
> > This will be used in the oom paths of mmu-notifiers, where blocking is
> > not allowed to make sure there's forward progress. Quoting Michal:
> > 
> > "The notifier is called from quite a restricted context - oom_reaper -
> > which shouldn't depend on any locks or sleepable conditionals. The code
> > should be swift as well but we mostly do care about it to make a forward
> > progress. Checking for sleepable context is the best thing we could come
> > up with that would describe these demands at least partially."
> > 
> > Peter also asked whether we want to catch spinlocks on top, but Michal
> > said those are less of a problem because spinlocks can't have an
> > indirect dependency upon the page allocator and hence close the loop
> > with the oom reaper.
> 
> I continue to struggle with this.  It introduces a new kernel state
> "running preemptibly but must not call schedule()".  How does this make
> any sense?
> 
> Perhaps a much, much more detailed description of the oom_reaper
> situation would help out.
 
The primary point here is that there is a demand of non blockable mmu
notifiers to be called when the oom reaper tears down the address space.
As the oom reaper is the primary guarantee of the oom handling forward
progress it cannot be blocked on anything that might depend on blockable
memory allocations. These are not really easy to track because they
might be indirect - e.g. notifier blocks on a lock which other context
holds while allocating memory or waiting for a flusher that needs memory
to perform its work. If such a blocking state happens that we can end up
in a silent hang with an unusable machine.
Now we hope for reasonable implementations of mmu notifiers (strong
words I know ;) and this should be relatively simple and effective catch
all tool to detect something suspicious is going on.

Does that make the situation more clear?

-- 
Michal Hocko
SUSE Labs

