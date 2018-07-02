Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB126B0010
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 08:56:34 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c19-v6so1302582edt.4
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 05:56:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v12-v6si896147edf.375.2018.07.02.05.56.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 05:56:32 -0700 (PDT)
Date: Mon, 2 Jul 2018 14:56:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180702125629.GR19043@dhcp22.suse.cz>
References: <20180622150242.16558-1-mhocko@kernel.org>
 <20180627074421.GF32348@dhcp22.suse.cz>
 <71f4184c-21ea-5af1-eeb6-bf7787614e2d@amd.com>
 <20180702115423.GK19043@dhcp22.suse.cz>
 <725cb1ad-01b0-42b5-56f0-c08c29804cb4@amd.com>
 <20180702122003.GN19043@dhcp22.suse.cz>
 <02d1d52c-f534-f899-a18c-a3169123ac7c@amd.com>
 <20180702123521.GO19043@dhcp22.suse.cz>
 <91ad1106-6bd4-7d2c-4d40-7c5be945ba36@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <91ad1106-6bd4-7d2c-4d40-7c5be945ba36@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Felix Kuehling <felix.kuehling@amd.com>

On Mon 02-07-18 14:39:50, Christian Konig wrote:
[...]
> Not wanting to block something as important as this, so feel free to add an
> Acked-by: Christian Konig <christian.koenig@amd.com> to the patch.

Thanks a lot!

> Let's rather face the next topic: Any idea how to runtime test this?

This is a good question indeed. One way to do that would be triggering
the OOM killer from the context which uses each of these mmu notifiers
(one at the time) and see how that works. You would see the note in the
log whenever the notifier would block. The primary thing to test is how
often the oom reaper really had to back off completely.

> I mean I can rather easily provide a test which crashes an AMD GPU, which in
> turn then would mean that the MMU notifier would block forever without this
> patch.

Well, you do not really have to go that far. It should be sufficient to
do the above. The current code would simply back of without releasing
any memory. The patch should help to reclaim some memory.
 
> But do you know a way to let the OOM killer kill a specific process?

Yes, you can set its oom_score_adj to 1000 which means always select
that task.
-- 
Michal Hocko
SUSE Labs
