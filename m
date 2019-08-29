Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77B9EC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:27:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F57720673
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:27:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F57720673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC64A6B0003; Thu, 29 Aug 2019 12:27:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D77056B0005; Thu, 29 Aug 2019 12:27:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8C366B0008; Thu, 29 Aug 2019 12:27:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0215.hostedemail.com [216.40.44.215])
	by kanga.kvack.org (Postfix) with ESMTP id A783C6B0003
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 12:27:07 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 49D6282437D7
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:27:07 +0000 (UTC)
X-FDA: 75875994894.30.meal48_3e5fa8f43725
X-HE-Tag: meal48_3e5fa8f43725
X-Filterd-Recvd-Size: 5923
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:27:06 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6BB02AB9B;
	Thu, 29 Aug 2019 16:27:05 +0000 (UTC)
Date: Thu, 29 Aug 2019 18:27:04 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: Re: [PATCH v2 3/6] mm/memory_hotplug: Process all zones when
 removing memory
Message-ID: <20190829162704.GL28313@dhcp22.suse.cz>
References: <20190826101012.10575-1-david@redhat.com>
 <20190826101012.10575-4-david@redhat.com>
 <20190829153936.GJ28313@dhcp22.suse.cz>
 <c01ceaab-4032-49cd-3888-45838cb46e11@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c01ceaab-4032-49cd-3888-45838cb46e11@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 29-08-19 17:54:35, David Hildenbrand wrote:
> On 29.08.19 17:39, Michal Hocko wrote:
> > On Mon 26-08-19 12:10:09, David Hildenbrand wrote:
> >> It is easier than I though to trigger a kernel bug by removing memory that
> >> was never onlined. With CONFIG_DEBUG_VM the memmap is initialized with
> >> garbage, resulting in the detection of a broken zone when removing memory.
> >> Without CONFIG_DEBUG_VM it is less likely - but we could still have
> >> garbage in the memmap.
> >>
> >> :/# [   23.912993] BUG: unable to handle page fault for address: 000000000000353d
> >> [   23.914219] #PF: supervisor write access in kernel mode
> >> [   23.915199] #PF: error_code(0x0002) - not-present page
> >> [   23.916160] PGD 0 P4D 0
> >> [   23.916627] Oops: 0002 [#1] SMP PTI
> >> [   23.917256] CPU: 1 PID: 7 Comm: kworker/u8:0 Not tainted 5.3.0-rc5-next-20190820+ #317
> >> [   23.918900] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.12.1-0-ga5cab58e9a3f-prebuilt.qemu.4
> >> [   23.921194] Workqueue: kacpi_hotplug acpi_hotplug_work_fn
> >> [   23.922249] RIP: 0010:clear_zone_contiguous+0x5/0x10
> >> [   23.923173] Code: 48 89 c6 48 89 c3 e8 2a fe ff ff 48 85 c0 75 cf 5b 5d c3 c6 85 fd 05 00 00 01 5b 5d c3 0f 1f 840
> >> [   23.926876] RSP: 0018:ffffad2400043c98 EFLAGS: 00010246
> >> [   23.927928] RAX: 0000000000000000 RBX: 0000000200000000 RCX: 0000000000000000
> >> [   23.929458] RDX: 0000000000200000 RSI: 0000000000140000 RDI: 0000000000002f40
> >> [   23.930899] RBP: 0000000140000000 R08: 0000000000000000 R09: 0000000000000001
> >> [   23.932362] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000140000
> >> [   23.933603] R13: 0000000000140000 R14: 0000000000002f40 R15: ffff9e3e7aff3680
> >> [   23.934913] FS:  0000000000000000(0000) GS:ffff9e3e7bb00000(0000) knlGS:0000000000000000
> >> [   23.936294] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >> [   23.937481] CR2: 000000000000353d CR3: 0000000058610000 CR4: 00000000000006e0
> >> [   23.938687] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> >> [   23.939889] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> >> [   23.941168] Call Trace:
> >> [   23.941580]  __remove_pages+0x4b/0x640
> >> [   23.942303]  ? mark_held_locks+0x49/0x70
> >> [   23.943149]  arch_remove_memory+0x63/0x8d
> >> [   23.943921]  try_remove_memory+0xdb/0x130
> >> [   23.944766]  ? walk_memory_blocks+0x7f/0x9e
> >> [   23.945616]  __remove_memory+0xa/0x11
> >> [   23.946274]  acpi_memory_device_remove+0x70/0x100
> >> [   23.947308]  acpi_bus_trim+0x55/0x90
> >> [   23.947914]  acpi_device_hotplug+0x227/0x3a0
> >> [   23.948714]  acpi_hotplug_work_fn+0x1a/0x30
> >> [   23.949433]  process_one_work+0x221/0x550
> >> [   23.950190]  worker_thread+0x50/0x3b0
> >> [   23.950993]  kthread+0x105/0x140
> >> [   23.951644]  ? process_one_work+0x550/0x550
> >> [   23.952508]  ? kthread_park+0x80/0x80
> >> [   23.953367]  ret_from_fork+0x3a/0x50
> >> [   23.954025] Modules linked in:
> >> [   23.954613] CR2: 000000000000353d
> >> [   23.955248] ---[ end trace 93d982b1fb3e1a69 ]---
> > 
> > Yes, this is indeed nasty. I didin't think of this when separating
> > memmap initialization from the hotremove. This means that the zone
> > pointer is a garbage in arch_remove_memory already. The proper fix is to
> > remove it from that level down. Moreover the zone is only needed for the
> > shrinking code and zone continuous thingy. The later belongs to offlining
> > code unless I am missing something. I can see that you are removing zone
> > parameter in a later patch but wouldn't it be just better to remove the
> > whole zone thing in a single patch and have this as a bug fix for a rare
> > bug with a fixes tag?
> > 
> 
> If I remember correctly, this patch already fixed the issue for me,

That might be the case because nothing else does access zone on the way.
But the pointer is simply bogus. Removing it is the proper way to fix
it. And I argue that zone shouldn't even be necessary. Re-evaluating
continuous status of the zone is really something for offlining phase.
Check how we use pfn_to_online_page there.

> without the other cleanup (removing the zone parameter). But I might be
> wrong.
> 
> Anyhow, I'll send a v4 shortly (either this evening or tomorrow), so you
> can safe yourself some review time and wait for that one :)

No rush, really... It seems this is quite unlikely event as most hotplug
usecases simply online memory before removing it later on.

-- 
Michal Hocko
SUSE Labs

