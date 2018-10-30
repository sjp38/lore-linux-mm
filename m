Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA916B000D
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 04:05:41 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id x17-v6so8639721pln.4
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 01:05:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u5-v6sor23031390pfd.38.2018.10.30.01.05.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Oct 2018 01:05:40 -0700 (PDT)
MIME-Version: 1.0
References: <20181011085509.GS5873@dhcp22.suse.cz> <6f32f23c-c21c-9d42-7dda-a1d18613cd3c@linux.intel.com>
 <20181017075257.GF18839@dhcp22.suse.cz> <971729e6-bcfe-a386-361b-d662951e69a7@linux.intel.com>
 <20181029141210.GJ32673@dhcp22.suse.cz> <84f09883c16608ddd2ba88103f43ec6a1c649e97.camel@linux.intel.com>
 <20181029163528.GL32673@dhcp22.suse.cz> <18dfc5a0db11650ff31433311da32c95e19944d9.camel@linux.intel.com>
 <20181029172415.GM32673@dhcp22.suse.cz> <8e7a4311a240b241822945c0bb4095c9ffe5a14d.camel@linux.intel.com>
 <20181029181827.GO32673@dhcp22.suse.cz> <3281f3044fa231bbc1b02d5c5efca3502a0d05a8.camel@linux.intel.com>
In-Reply-To: <3281f3044fa231bbc1b02d5c5efca3502a0d05a8.camel@linux.intel.com>
From: Oscar Salvador <osalvador.vilardaga@gmail.com>
Date: Tue, 30 Oct 2018 09:05:27 +0100
Message-ID: <CAOXBz7h-yiFCPoK5tNm6qSAGm8n83fSwHYU42x5DjtSbL84zQg@mail.gmail.com>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-nvdimm@lists.01.org, Pavel Tatashin <pavel.tatashin@microsoft.com>, dave.hansen@intel.com, Jerome Glisse <jglisse@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, yi.z.zhang@linux.intel.com

> Yes, the hotplug lock was part of the original issue. However that
> starts to drift into the area I believe Oscar was working on as a part
> of his patch set in encapsulating the move_pfn_range_to_zone and other
> calls that were contained in the hotplug lock into their own functions.


While reworking it for my patchset, I thought that we can move
move_pfn_range_to_zone
out of hotplug lock.
But then I __think__ we would have to move init_currently_empty_zone() within
the span lock as zone->zone_start_pfn is being touched there.
At least that is what the zone locking rules say about it.

Since I saw that Dan was still reworking his patchset about unify HMM/devm code,
I just took one step back and I went simpler [1].
The main reason for backing off was I felt a bit demotivated due to
the lack of feedback,
and I did not want to interfer either with your work or Dan's work.
Plus I also was unsure about some other things like whether it is ok calling
kasan_add_zero_shadow/kasan_remove_zero_shadow out of the lock.
So I decided to make less changes in regard of HMM/devm.

Unfortunately, I did not get a lot of feedback there yet.
Just some reviews from David and a confirmation that fixes one of the
issues Jonathan reported [2].

>
> I was hoping to wait until after Dan's HMM patches and Oscar's changes
> had been sorted before I get into any further refactor of this specific
> code.


I plan to ping the series, but I wanted to give more time to people
since we are in the merge window now.

[1] https://patchwork.kernel.org/cover/10642049/
[2] https://patchwork.kernel.org/patch/10642057/#22275173
