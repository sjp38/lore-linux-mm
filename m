Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF9466B000D
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 04:55:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e5-v6so4759204eda.4
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 01:55:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t15-v6si14113196edd.398.2018.10.11.01.55.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 01:55:11 -0700 (PDT)
Date: Thu, 11 Oct 2018 10:55:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <20181011085509.GS5873@dhcp22.suse.cz>
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925202053.3576.66039.stgit@localhost.localdomain>
 <20181009170051.GA40606@tiger-server>
 <CAPcyv4g99_rJJSn0kWv5YO0Mzj90q1LH1wC3XrjCh1=x6mo7BQ@mail.gmail.com>
 <25092df0-b7b4-d456-8409-9c004cb6e422@linux.intel.com>
 <20181010095838.GG5873@dhcp22.suse.cz>
 <f97de51c-67dd-99b2-754e-0685cac06699@linux.intel.com>
 <20181010172451.GK5873@dhcp22.suse.cz>
 <98c35e19-13b9-0913-87d9-b3f1ab738b61@linux.intel.com>
 <20181010185242.GP5873@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010185242.GP5873@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Dave Hansen <dave.hansen@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, yi.z.zhang@linux.intel.com

On Wed 10-10-18 20:52:42, Michal Hocko wrote:
[...]
> My recollection was that we do clear the reserved bit in
> move_pfn_range_to_zone and we indeed do in __init_single_page. But then
> we set the bit back right afterwards. This seems to be the case since
> d0dc12e86b319 which reorganized the code. I have to study this some more
> obviously.

so my recollection was wrong and d0dc12e86b319 hasn't really changed
much because __init_single_page wouldn't zero out the struct page for
the hotplug contex. A comment in move_pfn_range_to_zone explains that we
want the reserved bit because pfn walkers already do see the pfn range
and the page is not fully associated with the zone until it is onlined.

I am thinking that we might be overzealous here. With the full state
initialized we shouldn't actually care. pfn_to_online_page should return
NULL regardless of the reserved bit and normal pfn walkers shouldn't
touch pages they do not recognize and a plain page with ref. count 1
doesn't tell much to anybody. So I _suspect_ that we can simply drop the
reserved bit setting here.

Regarding the post initialization required by devm_memremap_pages and
potentially others. Can we update the altmap which is already a way how
to get alternative struct pages by a constructor which we could call
from memmap_init_zone and do the post initialization? This would reduce
the additional loop in the caller while it would still fit the overall
design of the altmap and the core hotplug doesn't have to know anything
about DAX or whatever needs a special treatment.

Does that make any sense?
-- 
Michal Hocko
SUSE Labs
