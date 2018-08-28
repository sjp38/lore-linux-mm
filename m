Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id D66536B4610
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:47:13 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id p105-v6so1093028wrc.11
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 04:47:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x25-v6sor309307wmc.70.2018.08.28.04.47.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 04:47:12 -0700 (PDT)
Date: Tue, 28 Aug 2018 13:47:09 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC v2 0/2] Do not touch pages in remove_memory path
Message-ID: <20180828114709.GA13859@techadventures.net>
References: <20180817154127.28602-1-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180817154127.28602-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, jglisse@redhat.com, david@redhat.com, jonathan.cameron@huawei.com, Pavel.Tatashin@microsoft.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Fri, Aug 17, 2018 at 05:41:25PM +0200, Oscar Salvador wrote:
> From: Oscar Salvador <osalvador@suse.de>
[...]
> 
> The main difficulty I faced here was in regard of HMM/devm, as it really handles
> the hot-add/remove memory particulary, and what is more important,
> also the resources.
> 
> I really scratched my head for ideas about how to handle this case, and
> after some fails I came up with the idea that we could check for the
> res->flags.
> 
> Memory resources that goes through the "official" memory-hotplug channels
> have the IORESOURCE_SYSTEM_RAM flag.
> This flag is made of (IORESOURCE_MEM|IORESOURCE_SYSRAM).
> 
> HMM/devm, on the other hand, request and release the resources
> through devm_request_mem_region/devm_release_mem_region, and 
> these resources do not contain the IORESOURCE_SYSRAM flag.
> 
> So what I ended up doing is to check for IORESOURCE_SYSRAM
> in release_mem_region_adjustable.
> If we see that a resource does not have such a flag, we know that
> we are dealing with a resource coming from HMM/devm, and so,
> we do not need to do anything as HMM/dev will take care of that part.
> 

Jerome/Dan, now that the merge window is closed, and before sending the RFCv3, could you please check
this and see if you see something that is flagrant wrong? (about devm/HMM)

If you prefer I can send v3 spliting up even more.
Maybe this will ease the review.

Thanks
-- 
Oscar Salvador
SUSE L3
