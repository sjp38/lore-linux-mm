Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E62368E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:10:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k16-v6so942160ede.6
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 07:10:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c2-v6si1317206edr.105.2018.09.12.07.10.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 07:10:55 -0700 (PDT)
Date: Wed, 12 Sep 2018 16:10:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm: Provide kernel parameter to allow disabling page
 init poisoning
Message-ID: <20180912141053.GL10951@dhcp22.suse.cz>
References: <20180910232615.4068.29155.stgit@localhost.localdomain>
 <20180910234341.4068.26882.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180910234341.4068.26882.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, mingo@kernel.org, dave.hansen@intel.com, jglisse@redhat.com, akpm@linux-foundation.org, logang@deltatee.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com

On Mon 10-09-18 16:43:41, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> On systems with a large amount of memory it can take a significant amount
> of time to initialize all of the page structs with the PAGE_POISON_PATTERN
> value. I have seen it take over 2 minutes to initialize a system with
> over 12GB of RAM.
> 
> In order to work around the issue I had to disable CONFIG_DEBUG_VM and then
> the boot time returned to something much more reasonable as the
> arch_add_memory call completed in milliseconds versus seconds. However in
> doing that I had to disable all of the other VM debugging on the system.
> 
> In order to work around a kernel that might have CONFIG_DEBUG_VM enabled on
> a system that has a large amount of memory I have added a new kernel
> parameter named "page_init_poison" that can be set to "off" in order to
> disable it.

I am still not convinced that this all is worth the additional code. It
is much better than a new config option for sure. If we really want this
though then I suggest that the parameter handler should note the
disabled state (when CONFIG_DEBUG_VM is on) to the kernel log. I would
also make it explicit who might want to do that in the parameter
description.

> +	page_init_poison=	[KNL] Boot-time parameter changing the
> +			state of poisoning of page structures during early
> +			boot. Used to verify page metadata is not accessed
> +			prior to initialization. Available with
> +			CONFIG_DEBUG_VM=y.
> +			off: turn off poisoning
> +			on: turn on poisoning (default)
> +

what about the following wording or something along those lines

Boot-time parameter to control struct page poisoning which is a
debugging feature to catch unitialized struct page access. This option
is available only for CONFIG_DEBUG_VM=y and it affects boot time
(especially on large systems). If there are no poisoning bugs reported
on the particular system and workload it should be safe to disable it to
speed up the boot time.
-- 
Michal Hocko
SUSE Labs
