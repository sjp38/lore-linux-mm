Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D403C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 08:24:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5754120644
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 08:24:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5754120644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C599F6B0007; Fri, 16 Aug 2019 04:24:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0B406B0008; Fri, 16 Aug 2019 04:24:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B200E6B000A; Fri, 16 Aug 2019 04:24:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0195.hostedemail.com [216.40.44.195])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF7A6B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 04:24:32 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 3D6826D7A
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:24:32 +0000 (UTC)
X-FDA: 75827604384.12.bread00_7edbb9247a425
X-HE-Tag: bread00_7edbb9247a425
X-Filterd-Recvd-Size: 4315
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:24:31 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 11D2CAFC3;
	Fri, 16 Aug 2019 08:24:30 +0000 (UTC)
Date: Fri, 16 Aug 2019 10:24:28 +0200
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
Message-ID: <20190816082428.GB27790@dhcp22.suse.cz>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814134558.fe659b1a9a169c0150c3e57c@linux-foundation.org>
 <20190815084429.GE9477@dhcp22.suse.cz>
 <20190815151509.9ddbd1f11fb9c4c3e97a67a5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815151509.9ddbd1f11fb9c4c3e97a67a5@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 15-08-19 15:15:09, Andrew Morton wrote:
> On Thu, 15 Aug 2019 10:44:29 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > I continue to struggle with this.  It introduces a new kernel state
> > > "running preemptibly but must not call schedule()".  How does this make
> > > any sense?
> > > 
> > > Perhaps a much, much more detailed description of the oom_reaper
> > > situation would help out.
> >  
> > The primary point here is that there is a demand of non blockable mmu
> > notifiers to be called when the oom reaper tears down the address space.
> > As the oom reaper is the primary guarantee of the oom handling forward
> > progress it cannot be blocked on anything that might depend on blockable
> > memory allocations. These are not really easy to track because they
> > might be indirect - e.g. notifier blocks on a lock which other context
> > holds while allocating memory or waiting for a flusher that needs memory
> > to perform its work. If such a blocking state happens that we can end up
> > in a silent hang with an unusable machine.
> > Now we hope for reasonable implementations of mmu notifiers (strong
> > words I know ;) and this should be relatively simple and effective catch
> > all tool to detect something suspicious is going on.
> > 
> > Does that make the situation more clear?
> 
> Yes, thanks, much.  Maybe a code comment along the lines of
> 
>   This is on behalf of the oom reaper, specifically when it is
>   calling the mmu notifiers.  The problem is that if the notifier were
>   to block on, for example, mutex_lock() and if the process which holds
>   that mutex were to perform a sleeping memory allocation, the oom
>   reaper is now blocked on completion of that memory allocation.

    reaper is now blocked on completion of that memory allocation
    and cannot provide the guarantee of the OOM forward progress.

OK. 
 
> btw, do we need task_struct.non_block_count?  Perhaps the oom reaper
> thread could set a new PF_NONBLOCK (which would be more general than
> PF_OOM_REAPER).  If we run out of PF_ flags, use (current == oom_reaper_th).

Well, I do not have a strong opinion here. A simple check for the value
seems to be trivial. There are quite some holes in task_struct to hide
this counter without increasing the size.
-- 
Michal Hocko
SUSE Labs

