Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA4B66B0273
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 05:11:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c13-v6so16104705ede.6
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 02:11:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w45-v6si7470403edc.238.2018.10.17.02.11.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 02:11:56 -0700 (PDT)
Subject: Re: [patch] mm, slab: avoid high-order slab pages when it does not
 reduce waste
References: <alpine.DEB.2.21.1810121424420.116562@chino.kir.corp.google.com>
 <20181012151341.286cd91321cdda9b6bde4de9@linux-foundation.org>
 <0100016679e3c96f-c78df4e2-9ab8-48db-8796-271c4b439f16-000000@email.amazonses.com>
 <alpine.DEB.2.21.1810151715220.21338@chino.kir.corp.google.com>
 <010001667d7476a2-f91dcf12-5e90-4ade-97e8-9fd651f7bf17-000000@email.amazonses.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8eaaa366-415a-5d72-7720-82468d853efd@suse.cz>
Date: Wed, 17 Oct 2018 11:09:11 +0200
MIME-Version: 1.0
In-Reply-To: <010001667d7476a2-f91dcf12-5e90-4ade-97e8-9fd651f7bf17-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/16/18 5:17 PM, Christopher Lameter wrote:
>> I'm not necessarily approaching this from a performance point of view, but
>> rather as a means to reduce slab fragmentation when fallback to order-0
>> memory, especially when completely legitimate, is prohibited.  From a
>> performance standpoint, this will depend on separately on fragmentation
>> and contention on zone->lock which both don't exist for order-0 memory
>> until fallback is required and then the pcp are filled with up to
>> batchcount pages.
> Fragmentation is a performance issue and causes degradation of Linux MM
> performance over time.  There are pretty complex mechanism that need to be
> played against one another.
> 
> Come up with some metrics to get meaningful data that allows us to see the
> impact.

I don't think the patch as it is needs some special evaluation. SLAB's
current design is to keep gfporder at minimum that satisfies "Acceptable
internal fragmentation" of 1/8 of the allocated gfporder page (hm
arguably that should be also considered relatively to order-0 page, as
I've argued for the comparison done in this patch as well).

In such design it's simply an oversight that we increase the gfporder in
cases when it doesn't improve the internal fragmentation metric, and it
should be straightforward decision to stop doing it.

I.e. the benefits vs drawbacks of higher order allocations for SLAB are
out of scope here. It would be nice if somebody evaluated them, but the
potential resulting change would be much larger than what concerns this
patch. But it would arguably also make SLAB more like SLUB, which you
already questioned at some point...

Vlastimil
