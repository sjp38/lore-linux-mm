Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 144EE6B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 07:52:59 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so790733pbc.12
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 04:52:57 -0700 (PDT)
Date: Wed, 9 Oct 2013 07:52:43 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [RFC 0/4] cleancache: SSD backed cleancache backend
Message-ID: <20131009115243.GA1198@thunk.org>
References: <20130926141428.392345308@kernel.org>
 <20130926161401.GA3288@medulla.variantweb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130926161401.GA3288@medulla.variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Shaohua Li <shli@kernel.org>, linux-mm@kvack.org, bob.liu@oracle.com, dan.magenheimer@oracle.com

On Thu, Sep 26, 2013 at 11:14:01AM -0500, Seth Jennings wrote:
> 
> I can see this burning out your SSD as well.  If someone enabled this on
> a machine that did large (relative to the size of the SDD) streaming
> reads, you'd be writing to the SSD continuously and never have a cache
> hit.

If we are to do page-level caching, we really need to change the VM to
use something like IBM's Adaptive Replacement Cache[1], which allows
us to track which pages have been more frequently used, so that we
only cache those pages, as opposed to those that land in the cache
once and then aren't used again.  (Consider what might happen if you
are using clean cache and then the user does a full backup of the
system.)

[1] http://en.wikipedia.org/wiki/Adaptive_replacement_cache

This is how ZFS does SSD caching; the basic idea is to only consider
for cacheing those pages which have been promoted into its Frequenly
Refrenced list, and then have been subsequently aged out.  At that
point, the benefit we would have over a dm-cache solution is that we
would be taking advantage of the usage information tracked by the VM
to better decide what is cached on the SSD.

So something to think about,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
