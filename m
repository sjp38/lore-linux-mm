Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 111356B0009
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 03:36:45 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id x65so101392144pfb.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 00:36:45 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id r15si49683998pfr.8.2016.02.16.00.36.43
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 00:36:44 -0800 (PST)
Date: Tue, 16 Feb 2016 19:35:18 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] kernel: fs: drop_caches: add dds drop_caches_count
Message-ID: <20160216083518.GZ19486@dastard>
References: <1455308080-27238-1-git-send-email-danielwa@cisco.com>
 <20160214211856.GT19486@dastard>
 <56C216CA.7000703@cisco.com>
 <20160215230511.GU19486@dastard>
 <56C264BF.3090100@cisco.com>
 <20160216004531.GA28260@thunk.org>
 <D2E7B337.D5404%nag@cisco.com>
 <20160216053827.GX19486@dastard>
 <alpine.LRH.2.00.1602152258240.4623@mcp-bld-lnx-277.cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.00.1602152258240.4623@mcp-bld-lnx-277.cisco.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nag Avadhanam <nag@cisco.com>
Cc: Theodore Ts'o <tytso@mit.edu>, "Daniel Walker (danielwa)" <danielwa@cisco.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Jonathan Corbet <corbet@lwn.net>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Feb 15, 2016 at 11:14:13PM -0800, Nag Avadhanam wrote:
> On Mon, 15 Feb 2016, Dave Chinner wrote:
> 
> >On Tue, Feb 16, 2016 at 02:58:04AM +0000, Nag Avadhanam (nag) wrote:
> >>Its the calculation of the # of bytes of non-reclaimable file system cache
> >>pages that has been troubling us. We do not want to count inactive file
> >>pages (of programs/binaries) that were once mapped by any process in the
> >>system as reclaimable because that might lead to thrashing under memory
> >>pressure (we want to alert admins before system starts dropping text
> >>pages).
> >
> >The code presented does not match your requirements. It only counts
> >pages that are currently mapped into ptes. hence it will tell you
> >that once-used and now unmapped binary pages are reclaimable, and
> >drop caches will reclaim them. hence they'll need to be fetched from
> >disk again if they are faulted in again after a drop_caches run.
> 
> Will the inactive binary pages be automatically unmapped even if the process
> into whose address space they are mapped is still around? I thought they
> are left mapped until such time there is memory pressure.

Right, page reclaim via memory pressure can unmap mapped pages in
order to reclaim them. Drop caches will skip them.

> We only care for binary pages (active and inactive) mapped into the
> address spaces of live processes. Its okay to aggressively reclaim
> inactive
> pages once mapped into processes that are no longer around.

Ok, if you're only concerned about live processes then drop caches
should behave as you want.

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
