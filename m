Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id D1C1B6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 16:10:29 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so76214702pab.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 13:10:29 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id up8si22165101pac.111.2015.11.12.13.10.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 13:10:28 -0800 (PST)
Received: by padhx2 with SMTP id hx2so76155001pad.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 13:10:28 -0800 (PST)
Date: Thu, 12 Nov 2015 13:10:27 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] mempolicy: convert the shared_policy lock to a rwlock
In-Reply-To: <1447348263-131817-1-git-send-email-nzimmer@sgi.com>
Message-ID: <alpine.DEB.2.10.1511121301490.10324@chino.kir.corp.google.com>
References: <1447348263-131817-1-git-send-email-nzimmer@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Thu, 12 Nov 2015, Nathan Zimmer wrote:

> When running the SPECint_rate gcc on some very large boxes it was noticed
> that the system was spending lots of time in mpol_shared_policy_lookup.
> The gamess benchmark can also show it and is what I mostly used to chase
> down the issue since the setup for that I found a easier.
> 
> To be clear the binaries were on tmpfs because of disk I/O reqruirements.
> We then used text replication to avoid icache misses and having all the
> copies banging on the memory where the instruction code resides.
> This results in us hitting a bottle neck in mpol_shared_policy_lookup
> since lookup is serialised by the shared_policy lock.
> 
> I have only reproduced this on very large (3k+ cores) boxes.  The problem
> starts showing up at just a few hundred ranks getting worse until it
> threatens to livelock once it gets large enough.
> For example on the gamess benchmark at 128 ranks this area consumes only
> ~1% of time, at 512 ranks it consumes nearly 13%, and at 2k ranks it is
> over 90%.
> 
> To alleviate the contention on this area I converted the spinslock to a
> rwlock.  This allows the large number of lookups to happen simultaneously.
> The results were quite good reducing this to consumtion at max ranks to
> around 2%.
> 

There're a couple of places in the sp_lookup() comment that would need to 
be fixed to either correct that this is no longer a spinlock and that the 
caller must hold the read lock.  The comment for sp_insert() would have to 
be fixed to specify the caller must hold the write lock.  When that's 
fixed, feel free to add

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
