Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id A25096B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 02:14:22 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id xk3so244738799obc.2
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 23:14:22 -0800 (PST)
Received: from rcdn-iport-3.cisco.com (rcdn-iport-3.cisco.com. [173.37.86.74])
        by mx.google.com with ESMTPS id zb3si2720028obb.101.2016.02.15.23.14.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 23:14:21 -0800 (PST)
Date: Mon, 15 Feb 2016 23:14:13 -0800 (PST)
From: Nag Avadhanam <nag@cisco.com>
Subject: Re: [PATCH] kernel: fs: drop_caches: add dds drop_caches_count
In-Reply-To: <20160216053827.GX19486@dastard>
Message-ID: <alpine.LRH.2.00.1602152258240.4623@mcp-bld-lnx-277.cisco.com>
References: <1455308080-27238-1-git-send-email-danielwa@cisco.com> <20160214211856.GT19486@dastard> <56C216CA.7000703@cisco.com> <20160215230511.GU19486@dastard> <56C264BF.3090100@cisco.com> <20160216004531.GA28260@thunk.org> <D2E7B337.D5404%nag@cisco.com>
 <20160216053827.GX19486@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Theodore Ts'o <tytso@mit.edu>, "Daniel Walker (danielwa)" <danielwa@cisco.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Jonathan Corbet <corbet@lwn.net>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 15 Feb 2016, Dave Chinner wrote:

> On Tue, Feb 16, 2016 at 02:58:04AM +0000, Nag Avadhanam (nag) wrote:
>> Its the calculation of the # of bytes of non-reclaimable file system cache
>> pages that has been troubling us. We do not want to count inactive file
>> pages (of programs/binaries) that were once mapped by any process in the
>> system as reclaimable because that might lead to thrashing under memory
>> pressure (we want to alert admins before system starts dropping text
>> pages).
>
> The code presented does not match your requirements. It only counts
> pages that are currently mapped into ptes. hence it will tell you
> that once-used and now unmapped binary pages are reclaimable, and
> drop caches will reclaim them. hence they'll need to be fetched from
> disk again if they are faulted in again after a drop_caches run.

Will the inactive binary pages be automatically unmapped even if the process
into whose address space they are mapped is still around? I thought they
are left mapped until such time there is memory pressure.

We only care for binary pages (active and inactive) mapped into the address 
spaces of live processes. Its okay to aggressively reclaim inactive
pages once mapped into processes that are no longer around.

thanks,
nag

>
> Cheers,
>
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
