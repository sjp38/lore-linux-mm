Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 580C66B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 03:44:11 -0500 (EST)
Received: by mail-io0-f174.google.com with SMTP id z135so114708948iof.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 00:44:11 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id w42si49633765ioi.91.2016.02.16.00.44.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 00:44:10 -0800 (PST)
Date: Tue, 16 Feb 2016 11:43:46 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] kernel: fs: drop_caches: add dds drop_caches_count
Message-ID: <20160216084346.GA8511@esperanza>
References: <1455308080-27238-1-git-send-email-danielwa@cisco.com>
 <20160214211856.GT19486@dastard>
 <56C216CA.7000703@cisco.com>
 <20160215230511.GU19486@dastard>
 <56C264BF.3090100@cisco.com>
 <20160216004531.GA28260@thunk.org>
 <D2E7B337.D5404%nag@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <D2E7B337.D5404%nag@cisco.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Nag Avadhanam (nag)" <nag@cisco.com>
Cc: Theodore Ts'o <tytso@mit.edu>, "Daniel Walker (danielwa)" <danielwa@cisco.com>, Dave Chinner <david@fromorbit.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Jonathan Corbet <corbet@lwn.net>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Feb 16, 2016 at 02:58:04AM +0000, Nag Avadhanam (nag) wrote:
> We have a class of platforms that are essentially swap-less embedded
> systems that have limited memory resources (2GB and less).
> 
> There is a need to implement early alerts (before the OOM killer kicks in)
> based on the current memory usage so admins can take appropriate steps (do
> not initiate provisioning operations but support existing services,
> de-provision certain services, etc. based on the extent of memory usage in
> the system) . 
> 
> There is also a general need to let end users know the available memory so
> they can determine if they can enable new services (helps in planning).
> 
> These two depend upon knowing approximate (accurate within few 10s of MB)
> memory usage within the system. We want to alert admins before system
> exhibits any thrashing behaviors.

Have you considered using /proc/kpageflags for counting such pages? It
should already export all information about memory pages you might need,
e.g. which pages are mapped, which are anonymous, which are inactive,
basically all page flags and even more. Moreover, you can even determine
the set of pages that are really read/written by processes - see
/sys/kernel/mm/page_idle/bitmap. On such a small machine scanning the
whole pfn range should be pretty cheap, so you might find this API
acceptable.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
