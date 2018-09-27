Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id F27FD8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 08:32:56 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id b17-v6so2595119wrq.0
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 05:32:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f138-v6sor1769174wme.22.2018.09.27.05.32.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 05:32:55 -0700 (PDT)
Date: Thu, 27 Sep 2018 14:32:54 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <20180927123254.GB20378@techadventures.net>
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925202053.3576.66039.stgit@localhost.localdomain>
 <20180926075540.GD6278@dhcp22.suse.cz>
 <6f87a5d7-05e2-00f4-8568-bb3521869cea@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6f87a5d7-05e2-00f4-8568-bb3521869cea@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, dave.hansen@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Wed, Sep 26, 2018 at 11:25:37AM -0700, Alexander Duyck wrote:
> With that said I am open to suggestions if you still feel like I need to
> follow this up with some additional work. I just want to avoid introducing
> any regressions in regards to functionality or performance.

Hi Alexander,

the problem I see is that devm/hmm is using some of the memory-hotplug 
features, but their paths are becoming more and more diverged with changes
like this, and that is sometimes a problem when we need to change
something in the generic memory-hotplug code.

E.g: I am trying to fix two issues in the memory-hotplug where we can
access steal pages if we hot-remove memory before online it.
That was not so difficult to fix, but I really struggled with the exceptions
that HMM/devm represent in this regard, for instance, regarding the resources.

The RFCv2 can be found here [1] https://patchwork.kernel.org/patch/10569083/
And the initial discussion with Jerome Glisse can be found here [2].

So it would be great to stick to the memory-hotplug path as much as possible,
otherwise when a problem arises, we need to think how we can workaround
HMM/devm.

[1] https://patchwork.kernel.org/patch/10569083/
[2] https://patchwork.kernel.org/patch/10558725/

-- 
Oscar Salvador
SUSE L3
