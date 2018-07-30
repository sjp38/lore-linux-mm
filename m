Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF6236B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 09:31:00 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id c6-v6so10382189qta.6
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 06:31:00 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id x63-v6si1107861qkd.352.2018.07.30.06.30.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 06:30:59 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6UDT7lb152575
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 13:30:58 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2130.oracle.com with ESMTP id 2kgfwsvgjj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 13:30:58 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w6UDUvuQ001934
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 13:30:57 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6UDUvkS004949
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 13:30:57 GMT
Received: by mail-oi0-f49.google.com with SMTP id l10-v6so21207379oii.0
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 06:30:57 -0700 (PDT)
MIME-Version: 1.0
References: <20180727165454.27292-1-david@redhat.com> <20180730113029.GM24267@dhcp22.suse.cz>
 <6cc416e7-522c-a67e-2706-f37aadff084f@redhat.com> <20180730120529.GN24267@dhcp22.suse.cz>
 <7b58af7b-5187-2c76-b458-b0f49875a1fc@redhat.com>
In-Reply-To: <7b58af7b-5187-2c76-b458-b0f49875a1fc@redhat.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 30 Jul 2018 09:30:14 -0400
Message-ID: <CAGM2reahiWj5LFq1npRpwK2k-4K-L9hr3AHUV9uYcmT2s3Bnuw@mail.gmail.com>
Subject: Re: [PATCH v1] mm: inititalize struct pages when adding a section
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@redhat.com
Cc: mhocko@kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, gregkh@linuxfoundation.org, mingo@kernel.org, Andrew Morton <akpm@linux-foundation.org>, dan.j.williams@intel.com, jack@suse.cz, mawilcox@microsoft.com, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, kirill.shutemov@linux.intel.com, Vlastimil Babka <vbabka@suse.cz>, osalvador@techadventures.net, yasu.isimatu@gmail.com, malat@debian.org, Mel Gorman <mgorman@suse.de>, iamjoonsoo.kim@lge.com

On Mon, Jul 30, 2018 at 8:11 AM David Hildenbrand <david@redhat.com> wrote:
>
> On 30.07.2018 14:05, Michal Hocko wrote:
> > On Mon 30-07-18 13:53:06, David Hildenbrand wrote:
> >> On 30.07.2018 13:30, Michal Hocko wrote:
> >>> On Fri 27-07-18 18:54:54, David Hildenbrand wrote:
> >>>> Right now, struct pages are inititalized when memory is onlined, not
> >>>> when it is added (since commit d0dc12e86b31 ("mm/memory_hotplug: optimize
> >>>> memory hotplug")).
> >>>>
> >>>> remove_memory() will call arch_remove_memory(). Here, we usually access
> >>>> the struct page to get the zone of the pages.
> >>>>
> >>>> So effectively, we access stale struct pages in case we remove memory that
> >>>> was never onlined. So let's simply inititalize them earlier, when the
> >>>> memory is added. We only have to take care of updating the zone once we
> >>>> know it. We can use a dummy zone for that purpose.
> >>>
> >>> I have considered something like this when I was reworking memory
> >>> hotplug to not associate struct pages with zone before onlining and I
> >>> considered this to be rather fragile. I would really not like to get
> >>> back to that again if possible.
> >>>
> >>>> So effectively, all pages will already be initialized and set to
> >>>> reserved after memory was added but before it was onlined (and even the
> >>>> memblock is added). We only inititalize pages once, to not degrade
> >>>> performance.
> >>>
> >>> To be honest, I would rather see d0dc12e86b31 reverted. It is late in
> >>> the release cycle and if the patch is buggy then it should be reverted
> >>> rather than worked around. I found the optimization not really
> >>> convincing back then and this is still the case TBH.
> >>>
> >>
> >> If I am not wrong, that's already broken in 4.17, no? What about that?
> >
> > Ohh, I thought this was merged in 4.18.
> > $ git describe --contains d0dc12e86b31 --match="v*"
> > v4.17-rc1~99^2~44
> >
> > proves me wrong. This means that the fix is not so urgent as I thought.
> > If you can figure out a reasonable fix then it should be preferable to
> > the revert.
> >
> > Fake zone sounds too hackish to me though.
> >
>
> If I am not wrong, that's the same we had before d0dc12e86b31 but now it
> is explicit and only one single value for all kernel configs
> ("ZONE_NORMAL").
>
> Before d0dc12e86b31, struct pages were initialized to 0. So it was
> (depending on the config) ZONE_DMA, ZONE_DMA32 or ZONE_NORMAL.
>
> Now the value is random and might not even be a valid zone.

Hi David,

Have you figured out why we access struct pages during hot-unplug for
offlined memory? Also, a panic trace would be useful in the patch.

As I understand the bug may occur only when hotremove is enabled, and
default onlining of added memory is disabled. Is this correct? I
suspect the reason we have not heard about this bug is that it is rare
to add memory and not to online it.

Thank you,
Pavel
