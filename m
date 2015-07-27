Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6688E6B0038
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 07:29:50 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so135764381wib.1
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 04:29:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ga1si13417143wib.115.2015.07.27.04.29.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 04:29:48 -0700 (PDT)
Subject: Re: [RFC v2 4/4] mm: fallback for offline nodes in alloc_pages_node
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz>
 <1437749126-25867-4-git-send-email-vbabka@suse.cz>
 <alpine.DEB.2.11.1507241047110.6461@east.gentwo.org>
 <alpine.DEB.2.10.1507241251460.5215@chino.kir.corp.google.com>
 <55B2A292.7080503@suse.cz>
 <alpine.DEB.2.10.1507241559181.12744@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B61629.1060701@suse.cz>
Date: Mon, 27 Jul 2015 13:29:45 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1507241559181.12744@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 07/25/2015 01:06 AM, David Rientjes wrote:
> On Fri, 24 Jul 2015, Vlastimil Babka wrote:
>
>> Because I didn't think you would suggest the "nid = numa_mem_id()" for
>> !node_online(nid) fixup would happen only for CONFIG_DEBUG_VM kernels. But it
>> seems that you do suggest that? I would understand if the fixup (correcting an
>> offline node to some that's online) was done regardless of DEBUG_VM, and
>> DEBUG_VM just switched between silent and noisy fixup. But having a debug option
>> alter the outcome seems wrong?
>
> Hmm, not sure why this is surprising, I don't expect people to deploy
> production kernels with CONFIG_DEBUG_VM enabled, it's far too expensive.
> I was expecting they would enable it for, well... debug :)

But is there any other place that does such thing for debug builds?

> In that case, if nid is a valid node but offline, then the nid =
> numa_mem_id() fixup seems fine to allow the kernel to continue debugging.
>
> When a node is offlined as a result of memory hotplug, the pgdat doesn't
> get freed so it can be onlined later.  Thus, alloc_pages_node() with an
> offline node and !CONFIG_DEBUG_VM may not panic.  If it does, this can
> probably be removed because we're covered.

I've checked, but can't say I understand the hotplug code completely... 
but it seems there are two cases
- the node was never online, and the nid passed to alloc_pages_node() is 
clearly bogus. Then there's no pgdat and it should crash on NULL pointer 
dereference. VM_WARN_ON() in __alloc_pages_node() will already catch 
this and provide more details as to what caused the crash. Fixup would 
allow "continue debugging", but it seems that having configured e.g. a 
crashdump to inspect is a better way to debug than letting the kernel 
continue?
- the node has been online in the past, so the nid pointing to an 
offline node might be due to a race with offlining. It shouldn't crash, 
and most likely the zonelist that is left untouched by the offlining 
(AFAICS) will allow fallback to other nodes. Unless there is a nodemask 
of __GFP_THIS_NODE, in which case allocation fails. Again, VM_WARN_ON() 
in __alloc_pages_node() will warn us already. I doubt the fixup is 
needed here?

So I would just drop this patch. We already have the debug warning in 
__alloc_pages_node(), and a fixup is imho just confusing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
