Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 28E646B2FCA
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 09:01:38 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id w19-v6so4007085pfa.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 06:01:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b36-v6si6675505pla.420.2018.08.24.06.01.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 06:01:36 -0700 (PDT)
Date: Fri, 24 Aug 2018 15:01:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180824130132.GP29735@dhcp22.suse.cz>
References: <20180716115058.5559-1-mhocko@kernel.org>
 <8cbfb09f-0c5a-8d43-1f5e-f3ff7612e289@I-love.SAKURA.ne.jp>
 <20180824113248.GH29735@dhcp22.suse.cz>
 <b088e382-e90e-df63-a079-19b2ae2b985d@gmail.com>
 <20180824115226.GK29735@dhcp22.suse.cz>
 <a27ad1a3-34bd-6b7d-fd09-7737ec3c888d@gmail.com>
 <20180824120339.GL29735@dhcp22.suse.cz>
 <eb546bcb-9c5f-7d5d-43a7-bfde489f0e7f@amd.com>
 <20180824123341.GN29735@dhcp22.suse.cz>
 <b11df415-baf8-0a41-3c16-60dfe8d32bd3@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b11df415-baf8-0a41-3c16-60dfe8d32bd3@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>
Cc: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, kvm@vger.kernel.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Dimitri Sivanich <sivanich@sgi.com>, Jason Gunthorpe <jgg@ziepe.ca>, linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org, David Airlie <airlied@linux.ie>, Doug Ledford <dledford@redhat.com>, David Rientjes <rientjes@google.com>, xen-devel@lists.xenproject.org, intel-gfx@lists.freedesktop.org, Jani Nikula <jani.nikula@linux.intel.com>, Leon Romanovsky <leonro@mellanox.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, LKML <linux-kernel@vger.kernel.org>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Deucher <alexander.deucher@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Felix Kuehling <felix.kuehling@amd.com>

On Fri 24-08-18 14:52:26, Christian Konig wrote:
> Am 24.08.2018 um 14:33 schrieb Michal Hocko:
[...]
> > Thiking about it some more, I can imagine that a notifier callback which
> > performs an allocation might trigger a memory reclaim and that in turn
> > might trigger a notifier to be invoked and recurse. But notifier
> > shouldn't really allocate memory. They are called from deep MM code
> > paths and this would be extremely deadlock prone. Maybe Jerome can come
> > up some more realistic scenario. If not then I would propose to simplify
> > the locking here. We have lockdep to catch self deadlocks and it is
> > always better to handle a specific issue rather than having a code
> > without a clear indication how it can recurse.
> 
> Well I agree that we should probably fix that, but I have some concerns to
> remove the existing workaround.
> 
> See we added that to get rid of a real problem in a customer environment and
> I don't want to that to show up again.

It would really help to know more about that case and fix it properly
rather than workaround it like this. Anyway, let me think how to handle
the non-blocking notifier invocation then. I was not able to come up
with anything remotely sane yet.
-- 
Michal Hocko
SUSE Labs
