Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3EAB16B000E
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 10:11:01 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z5-v6so2464982edr.19
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 07:11:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i31-v6si292615edd.265.2018.07.30.07.10.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 07:10:59 -0700 (PDT)
Date: Mon, 30 Jul 2018 16:10:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm: inititalize struct pages when adding a section
Message-ID: <20180730141058.GV24267@dhcp22.suse.cz>
References: <20180727165454.27292-1-david@redhat.com>
 <20180730113029.GM24267@dhcp22.suse.cz>
 <6cc416e7-522c-a67e-2706-f37aadff084f@redhat.com>
 <20180730120529.GN24267@dhcp22.suse.cz>
 <7b58af7b-5187-2c76-b458-b0f49875a1fc@redhat.com>
 <CAGM2reahiWj5LFq1npRpwK2k-4K-L9hr3AHUV9uYcmT2s3Bnuw@mail.gmail.com>
 <56e97799-fbe1-9546-46ab-a9b8ee8794e0@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56e97799-fbe1-9546-46ab-a9b8ee8794e0@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, gregkh@linuxfoundation.org, mingo@kernel.org, Andrew Morton <akpm@linux-foundation.org>, dan.j.williams@intel.com, jack@suse.cz, mawilcox@microsoft.com, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, kirill.shutemov@linux.intel.com, Vlastimil Babka <vbabka@suse.cz>, osalvador@techadventures.net, yasu.isimatu@gmail.com, malat@debian.org, Mel Gorman <mgorman@suse.de>, iamjoonsoo.kim@lge.com

On Mon 30-07-18 15:51:45, David Hildenbrand wrote:
> On 30.07.2018 15:30, Pavel Tatashin wrote:
[...]
> > Hi David,
> > 
> > Have you figured out why we access struct pages during hot-unplug for
> > offlined memory? Also, a panic trace would be useful in the patch.
> 
> __remove_pages() needs a zone as of now (e.g. to recalculate if the zone
> is contiguous). This zone is taken from the first page of memory to be
> removed. If the struct pages are uninitialized that value is random and
> we might even get an invalid zone.
>
> The zone is also used to locate pgdat.
> 
> No stack trace available so far, I'm just reading the code and try to
> understand how this whole memory hotplug/unplug machinery works.

Yes this is a mess (evolution of the code called otherwise ;) [1].
Functionality has been just added on top of not very well thought
through bases. This is a nice example of it. We are trying to get a zone
to 1) special case zone_device 2) recalculate zone state. The first
shouldn't be really needed because we should simply rely on altmap.
Whether it is used for zone device or not. 2) shouldn't be really needed
if the section is offline and we can check that trivially.

[1] on the other hand I can see why people were reluctant to understand
the mess and rather tweak their tiny thing on top...
-- 
Michal Hocko
SUSE Labs
