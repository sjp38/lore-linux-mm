Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 558056B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 13:53:17 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w204so3303038wmd.16
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 10:53:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j125si6990591wmj.50.2017.04.10.10.53.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 10:53:16 -0700 (PDT)
Date: Mon, 10 Apr 2017 19:53:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
Message-ID: <20170410175310.GP4618@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410163553.GB31356@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170410163553.GB31356@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>

On Mon 10-04-17 12:35:53, Jerome Glisse wrote:
> On Mon, Apr 10, 2017 at 01:03:42PM +0200, Michal Hocko wrote:
> > Hi,
> > The last version of this series has been posted here [1]. It has seen
> > some more serious testing (thanks to Reza Arbab) and fixes for the found
> > issues. I have also decided to drop patch 1 [2] because it turned out to
> > be more complicated than I initially thought [3]. Few more patches were
> > added to deal with expectation on zone/node initialization.
> > 
> > I have rebased on top of the current mmotm-2017-04-07-15-53. It
> > conflicts with HMM because it touches memory hotplug as
> > well. We have discussed [4] with Jerome and he agreed to
> > rebase on top of this rework [5] so I have reverted his series
> > before applyig mine. I will help him to resolve the resulting
> > conflicts. You can find the whole series including the HMM revers in
> > git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git branch
> > attempts/rewrite-mem_hotplug
> > 
> 
> So updated HMM patchset :
> https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-v20
> 
> I am not posting yet as it seems there is couple thing you need to
> fix in your patchset first. However if you could review :

I assume I will resubmit v3 after all the feedback is addressed here.

> https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-v20&id=84fc68534e781cf6125d02b3bfdba4a51e82d9c9
> 
> As it was your idea, i just want to make sure i didn't denatured
> it :)

OK, looks good to me. I would be more specific in the changelog though.
"
mm, memory_hotplug: introduce add_pages

There are new users of memory hotplug emerging. Some of them require
different subset of arch_add_memory. There are some which only require
allocation of struct pages without mapping those pages to the kernel
address space. We currently have __add_pages for that purpose. But this
is rather lowlevel and not very suitable for the code outside of the
memory hotplug. E.g. x86_64 wants to update max_pfn which should be
done by the caller. Introduce add_pages() which should care about those
details if they are needed. Each architecture should define its
implementation and select CONFIG_ARCH_HAS_ADD_PAGES. All others use
the currently existing __add_pages.
"

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
