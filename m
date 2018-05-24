Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id DAC506B0007
	for <linux-mm@kvack.org>; Thu, 24 May 2018 04:56:30 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n33-v6so617119qte.23
        for <linux-mm@kvack.org>; Thu, 24 May 2018 01:56:30 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id e7-v6si8742068qkf.265.2018.05.24.01.56.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 01:56:30 -0700 (PDT)
Date: Thu, 24 May 2018 16:56:11 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH v1 00/10] mm: online/offline 4MB chunks controlled by
 device driver
Message-ID: <20180524085610.GA5467@dhcp-128-65.nay.redhat.com>
References: <20180523151151.6730-1-david@redhat.com>
 <20180524075327.GU20441@dhcp22.suse.cz>
 <14d79dad-ad47-f090-2ec0-c5daf87ac529@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14d79dad-ad47-f090-2ec0-c5daf87ac529@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Balbir Singh <bsingharora@gmail.com>, Baoquan He <bhe@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dmitry Vyukov <dvyukov@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>, Jan Kara <jack@suse.cz>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Miles Chen <miles.chen@mediatek.com>, Oscar Salvador <osalvador@techadventures.net>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, Rashmica Gupta <rashmica.g@gmail.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>

Hi,

[snip]
> > 
> >> For kdump and onlining/offlining code, we
> >> have to mark pages as offline before a new segment is visible to the system
> >> (e.g. as these pages might not be backed by real memory in the hypervisor).
> > 
> > Please expand on the kdump part. That is really confusing because
> > hotplug should simply not depend on kdump at all. Moreover why don't you
> > simply mark those pages reserved and pull them out from the page
> > allocator?
> 
> 1. "hotplug should simply not depend on kdump at all"
> 
> In theory yes. In the current state we already have to trigger kdump to
> reload whenever we add/remove a memory block.
> 
> 
> 2. kdump part
> 
> Whenever we offline a page and tell the hypervisor about it ("unplug"),
> we should not assume that we can read that page again. Now, if dumping
> tools assume they can read all memory that is offline, we are in trouble.
> 
> It is the same thing as we already have with Pg_hwpoison. Just a
> different meaning - "don't touch this page, it is offline" compared to
> "don't touch this page, hw is broken".

Does that means in case an offline no kdump reload as mentioned in 1)?

If we have the offline event and reload kdump, I assume the memory state
is refreshed so kdump will not read the memory offlined, am I missing
something?

> 
> Balloon drivers solve this problem by always allowing to read unplugged
> memory. In virtio-mem, this cannot and should even not be guaranteed.
> 

Hmm, that sounds a bug..

> And what we have to do to make this work is actually pretty simple: Just
> like Pg_hwpoison, track per page if it is online and provide this
> information to kdump.
> 
> 

Thanks
Dave
