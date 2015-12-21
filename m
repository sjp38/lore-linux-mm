Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5056B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 08:15:13 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l126so69506501wml.1
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 05:15:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n188si3056454wmf.113.2015.12.21.05.15.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Dec 2015 05:15:11 -0800 (PST)
Subject: Re: [PATCH] mempolicy: convert the shared_policy lock to a rwlock
References: <alpine.DEB.2.10.1511121301490.10324@chino.kir.corp.google.com>
 <1447777078-135492-1-git-send-email-nzimmer@sgi.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5677FB5D.7010805@suse.cz>
Date: Mon, 21 Dec 2015 14:15:09 +0100
MIME-Version: 1.0
In-Reply-To: <1447777078-135492-1-git-send-email-nzimmer@sgi.com>
Content-Type: text/plain; charset=utf-8; format=flowed
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
>
> Acked-by: David Rientjes <rientjes@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
