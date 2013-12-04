Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD046B0031
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 08:00:44 -0500 (EST)
Received: by mail-ee0-f43.google.com with SMTP id c13so2367591eek.30
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 05:00:43 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id m44si1477284eeo.247.2013.12.04.05.00.42
        for <linux-mm@kvack.org>;
        Wed, 04 Dec 2013 05:00:42 -0800 (PST)
Date: Wed, 4 Dec 2013 13:00:38 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: high kswapd CPU usage when executing binaries from NFS w/ CMA
 and COMPACTION
Message-ID: <20131204130038.GY11295@suse.de>
References: <CAGVrzcZidrUV93x9t_BwPaDuzgxs-88HoF-HUDRrSEYcfJB_rw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAGVrzcZidrUV93x9t_BwPaDuzgxs-88HoF-HUDRrSEYcfJB_rw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, mhocko@suse.cz, hannes@cmpxchg.org, riel@redhat.com, linux-mm@kvack.org, m.szyprowski@samsung.com, marc.ceeeee@gmail.com

On Tue, Dec 03, 2013 at 06:30:28PM -0800, Florian Fainelli wrote:
> Hi all,
> 
> I am experiencing high kswapd CPU usage on an ARMv7 system running
> 3.8.13 when executing relatively large binaries from NFS. When this
> happens kswapd consumes around 55-60% CPU usage and the applications
> takes a huge time to load.
> 

There were a number of changes made related to how and when kswapd
stalls, particularly when pages are dirty. Brief check confirms that

git log v3.8..v3.12 --pretty=one --author "Mel Gorman" mm/vmscan.c

NFS dirty pages are problematic for compaction as dirty pages cannot be
migrated until cleaned. I'd suggest checking if current mainline suffers
the same problem and if not, focus on patches related to dirty page
handling and kswapd throttling in mm/vmscan.c as backport candidates.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
