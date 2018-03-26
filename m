Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DFE9F6B000E
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 04:15:14 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n11so4016263wmg.0
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 01:15:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z73si383287wmc.219.2018.03.26.01.15.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Mar 2018 01:15:13 -0700 (PDT)
Date: Mon, 26 Mar 2018 10:15:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] mmu_notifier contextual information
Message-ID: <20180326081512.GB5652@dhcp22.suse.cz>
References: <20180323171748.20359-1-jglisse@redhat.com>
 <e22988c5-2d58-45bb-e2f7-c7ca7bdb9e49@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e22988c5-2d58-45bb-e2f7-c7ca7bdb9e49@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>
Cc: jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Dan Williams <dan.j.williams@intel.com>, Joerg Roedel <joro@8bytes.org>, Paolo Bonzini <pbonzini@redhat.com>, Leon Romanovsky <leonro@mellanox.com>, Artemy Kovalyov <artemyko@mellanox.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Alex Deucher <alexander.deucher@amd.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>

On Fri 23-03-18 19:34:04, Christian Konig wrote:
> Am 23.03.2018 um 18:17 schrieb jglisse@redhat.com:
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > This patchset are the improvements to mmu_notifier i wish to discuss
> > at next LSF/MM. I am sending now to give time to people to look at
> > them and think about them.
> > 
> > git://people.freedesktop.org/~glisse/linux mmu-notifier-rfc
> > https://cgit.freedesktop.org/~glisse/linux/log/?h=mmu-notifier-rfc
> > 
> > First patch just use a struct for invalidate_range_start/end arguments
> > this make the other 2 patches easier and smaller.
> > 
> > The idea is to provide more information to mmu_notifier listener on
> > the context of each invalidation. When a range is invalidated this
> > can be for various reasons (munmap, protection change, OOM, ...). If
> > listener can distinguish between those it can take better action.
> > 
> > For instance if device driver allocate structure to track a range of
> > virtual address prior to this patch it always have to assume that it
> > has to free those on each mmu_notifieir callback (having to assume it
> > is a munmap) and reallocate those latter when the device try to do
> > something with that range again.
> > 
> > OOM is also an interesting case, recently a patchset was added to
> > avoid OOM on a mm if a blocking mmu_notifier listener have been
> > registered [1]. This can be improve by adding a new OOM event type and
> > having listener take special path on those. All mmu_notifier i know
> > can easily have a special path for OOM that do not block (beside
> > taking a short lived, across driver, spinlock). If mmu_notifier usage
> > grows (from a point of view of more process using devices that rely on
> > them) then we should also make sure OOM can do its bidding.
> 
> +1 for better handling that.
> 
> The fact that the OOM killer now avoids processes which might sleep during
> their MM destruction gave me a few sleepless night recently.

I have tried to clarify this [1] but could you be more specific about
the issue you were seeing?

[1] http://lkml.kernel.org/r/20180326081356.GA5652@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs
