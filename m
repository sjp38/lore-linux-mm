Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 05A6C6B000C
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 04:14:01 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w10so9765097wrg.15
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 01:14:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l1si9836473wmb.261.2018.03.26.01.13.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Mar 2018 01:13:59 -0700 (PDT)
Date: Mon, 26 Mar 2018 10:13:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] mmu_notifier contextual information
Message-ID: <20180326081356.GA5652@dhcp22.suse.cz>
References: <20180323171748.20359-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180323171748.20359-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Dan Williams <dan.j.williams@intel.com>, Joerg Roedel <joro@8bytes.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Leon Romanovsky <leonro@mellanox.com>, Artemy Kovalyov <artemyko@mellanox.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Alex Deucher <alexander.deucher@amd.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>

I haven't read through the whole thread, I just wanted to clarify the
OOM aspect.
On Fri 23-03-18 13:17:45, jglisse@redhat.com wrote:
[...]
> OOM is also an interesting case, recently a patchset was added to
> avoid OOM on a mm if a blocking mmu_notifier listener have been
> registered [1].

This is not quite right. We only skip oom _reaper_ (aka async oom victim
address space tear down). We still do allow such a task to be selected
as an OOM victim and killed. So the worst case that we might kill
another task if the current victim is not able to make a forward
progress on its own.

> This can be improve by adding a new OOM event type and
> having listener take special path on those. All mmu_notifier i know
> can easily have a special path for OOM that do not block (beside
> taking a short lived, across driver, spinlock). If mmu_notifier usage
> grows (from a point of view of more process using devices that rely on
> them) then we should also make sure OOM can do its bidding.

If we can distinguish the OOM path and enforce no locks or indirect
dependencies on the memory allocation the the situation would improve
for sure.
-- 
Michal Hocko
SUSE Labs
