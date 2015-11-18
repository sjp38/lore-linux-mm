Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 57B356B028B
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:50:10 -0500 (EST)
Received: by wmec201 with SMTP id c201so279439005wme.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 05:50:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w201si4909578wmd.84.2015.11.18.05.50.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Nov 2015 05:50:08 -0800 (PST)
Subject: Re: [PATCH] mempolicy: convert the shared_policy lock to a rwlock
References: <alpine.DEB.2.10.1511121301490.10324@chino.kir.corp.google.com>
 <1447777078-135492-1-git-send-email-nzimmer@sgi.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <564C820D.1060105@suse.cz>
Date: Wed, 18 Nov 2015 14:50:05 +0100
MIME-Version: 1.0
In-Reply-To: <1447777078-135492-1-git-send-email-nzimmer@sgi.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/17/2015 05:17 PM, Nathan Zimmer wrote:
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

At first glance it seems that RCU would be a good fit here and achieve even
better lookup scalability, have you considered it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
