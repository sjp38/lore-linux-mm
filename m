Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id ECC696B0036
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 19:47:37 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id rp18so345645iec.12
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 16:47:37 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id x18si1301523icx.7.2014.07.22.16.47.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 16:47:36 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 22 Jul 2014 17:47:35 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 306D51FF003F
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 17:47:31 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6MNlVsH9437452
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 01:47:31 +0200
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6MNlVN9004733
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 17:47:31 -0600
Date: Tue, 22 Jul 2014 16:47:26 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140722234726.GO4156@linux.vnet.ibm.com>
References: <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com>
 <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
 <20140207054819.GC28952@lge.com>
 <alpine.DEB.2.02.1402080154140.9668@chino.kir.corp.google.com>
 <20140210010936.GA12574@lge.com>
 <20140722010305.GJ4156@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1407211809140.9778@chino.kir.corp.google.com>
 <20140722214311.GM4156@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140722214311.GM4156@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>

On 22.07.2014 [14:43:11 -0700], Nishanth Aravamudan wrote:
> Hi David,

<snip>

> on powerpc now, things look really good. On a KVM instance with the
> following topology:
> 
> available: 2 nodes (0-1)
> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49
> node 0 size: 0 MB
> node 0 free: 0 MB
> node 1 cpus: 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
> node 1 size: 16336 MB
> node 1 free: 14274 MB
> node distances:
> node   0   1 
>   0:  10  40 
>   1:  40  10 
> 
> 3.16.0-rc6 gives:
> 
>         Slab:            1039744 kB
> 	SReclaimable:      38976 kB
> 	SUnreclaim:      1000768 kB

<snip>

> Adding my patch on top of Joonsoo's and the revert, I get:
> 
> 	Slab:             411776 kB
> 	SReclaimable:      40960 kB
> 	SUnreclaim:       370816 kB
> 
> So CONFIG_SLUB still uses about 3x as much slab memory, but it's not so
> much that we are close to OOM with small VM/LPAR sizes.

Just to clarify/add one more datapoint, with a balanced topology:

available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49
node 0 size: 8154 MB
node 0 free: 8075 MB
node 1 cpus: 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
node 1 size: 8181 MB
node 1 free: 7776 MB
node distances:
node   0   1 
  0:  10  40 
  1:  40  10

I see the following for my patch + Joonsoo's + the revert:

Slab:             495872 kB
SReclaimable:      46528 kB
SUnreclaim:       449344 kB

(Although these numbers fluctuate quite a bit between 250M and 500M),
which indicates that the memoryless node slab consumption is now on-par
with a populated topology. And both are still more than CONFIG_SLAB
requires.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
