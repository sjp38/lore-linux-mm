Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E35346B0006
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 08:26:58 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id w140so7965521qkb.15
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 05:26:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x94sor4593369qte.143.2018.03.12.05.26.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Mar 2018 05:26:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACjP9X_tpVVDPUvyc-B2QU=2J5MXbuFsDcG90d7L0KuwEEuR-g@mail.gmail.com>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
 <cover.1520011944.git.neelx@redhat.com> <0485727b2e82da7efbce5f6ba42524b429d0391a.1520011945.git.neelx@redhat.com>
 <20180302164052.5eea1b896e3a7125d1e1f23a@linux-foundation.org> <CACjP9X_tpVVDPUvyc-B2QU=2J5MXbuFsDcG90d7L0KuwEEuR-g@mail.gmail.com>
From: Sudeep Holla <sudeep.holla@arm.com>
Date: Mon, 12 Mar 2018 12:26:56 +0000
Message-ID: <CAPKp9ubzXBMeV6Oi=KW1HaPOrv_P78HOXcdQeZ5e1=bqY97tkA@mail.gmail.com>
Subject: Re: [PATCH v3 2/2] mm/page_alloc: fix memmap_init_zone pageblock alignment
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, stable@vger.kernel.org, Sudeep Holla <sudeep.holla@arm.com>

Hi,

I couldn't find the exact mail corresponding to the patch merged in v4.16-rc5
but commit 864b75f9d6b01 "mm/page_alloc: fix memmap_init_zone
pageblock alignment"
cause boot hang on my ARM64 platform.

Log:
[    0.000000] NUMA: No NUMA configuration found
[    0.000000] NUMA: Faking a node at [mem
0x0000000000000000-0x00000009ffffffff]
[    0.000000] NUMA: NODE_DATA [mem 0x9fffcb480-0x9fffccf7f]
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x0000000080000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x00000009ffffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000080000000-0x00000000f8f9afff]
[    0.000000]   node   0: [mem 0x00000000f8f9b000-0x00000000f908ffff]
[    0.000000]   node   0: [mem 0x00000000f9090000-0x00000000f914ffff]
[    0.000000]   node   0: [mem 0x00000000f9150000-0x00000000f920ffff]
[    0.000000]   node   0: [mem 0x00000000f9210000-0x00000000f922ffff]
[    0.000000]   node   0: [mem 0x00000000f9230000-0x00000000f95bffff]
[    0.000000]   node   0: [mem 0x00000000f95c0000-0x00000000fe58ffff]
[    0.000000]   node   0: [mem 0x00000000fe590000-0x00000000fe5cffff]
[    0.000000]   node   0: [mem 0x00000000fe5d0000-0x00000000fe5dffff]
[    0.000000]   node   0: [mem 0x00000000fe5e0000-0x00000000fe62ffff]
[    0.000000]   node   0: [mem 0x00000000fe630000-0x00000000feffffff]
[    0.000000]   node   0: [mem 0x0000000880000000-0x00000009ffffffff]
[    0.000000]  Initmem setup node 0 [mem 0x0000000080000000-0x00000009ffffffff]

On Sat, Mar 3, 2018 at 1:08 AM, Daniel Vacek <neelx@redhat.com> wrote:
> On Sat, Mar 3, 2018 at 1:40 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
>> On Sat,  3 Mar 2018 01:12:26 +0100 Daniel Vacek <neelx@redhat.com> wrote:
>>
>>> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>>> where possible") introduced a bug where move_freepages() triggers a
>>> VM_BUG_ON() on uninitialized page structure due to pageblock alignment.
>>
>> b92df1de5d28 was merged a year ago.  Can you suggest why this hasn't
>> been reported before now?
>
> Yeah. I was surprised myself I couldn't find a fix to backport to
> RHEL. But actually customers started to report this as soon as 7.4
> (where b92df1de5d28 was merged in RHEL) was released. I remember
> reports from September/October-ish times. It's not easily reproduced
> and happens on a handful of machines only. I guess that's why. But
> that does not make it less serious, I think.
>
> Though there actually is a report here:
> https://bugzilla.kernel.org/show_bug.cgi?id=196443
>
> And there are reports for Fedora from July:
> https://bugzilla.redhat.com/show_bug.cgi?id=1473242
> and CentOS: https://bugs.centos.org/view.php?id=13964
> and we internally track several dozens reports for RHEL bug
> https://bugzilla.redhat.com/show_bug.cgi?id=1525121
>
> Enough? ;-)
>
>> This makes me wonder whether a -stable backport is really needed...
>
> For some machines it definitely is. Won't hurt either, IMHO.
>
> --nX
