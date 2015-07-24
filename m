Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id A99656B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 16:39:51 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so43564335wib.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:39:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bp20si63295wib.36.2015.07.24.13.39.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 13:39:50 -0700 (PDT)
Message-ID: <55B2A292.7080503@suse.cz>
Date: Fri, 24 Jul 2015 22:39:46 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC v2 4/4] mm: fallback for offline nodes in alloc_pages_node
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz> <1437749126-25867-4-git-send-email-vbabka@suse.cz> <alpine.DEB.2.11.1507241047110.6461@east.gentwo.org> <alpine.DEB.2.10.1507241251460.5215@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1507241251460.5215@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 24.7.2015 21:54, David Rientjes wrote:
> On Fri, 24 Jul 2015, Christoph Lameter wrote:
> 
>> On Fri, 24 Jul 2015, Vlastimil Babka wrote:
>>
>>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>>> index 531c72d..104a027 100644
>>> --- a/include/linux/gfp.h
>>> +++ b/include/linux/gfp.h
>>> @@ -321,8 +321,12 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>>>  						unsigned int order)
>>>  {
>>>  	/* Unknown node is current (or closest) node */
>>> -	if (nid == NUMA_NO_NODE)
>>> +	if (nid == NUMA_NO_NODE) {
>>>  		nid = numa_mem_id();
>>> +	} else if (!node_online(nid)) {
>>> +		VM_WARN_ON(!node_online(nid));
>>> +		nid = numa_mem_id();
>>> +	}
>>
>> I would think you would only want this for debugging purposes. The
>> overwhelming majority of hardware out there has no memory
>> onlining/offlining capability after all and this adds the overhead to each
>> call to alloc_pages_node.
>>
>> Make this dependo n CONFIG_VM_DEBUG or some such thing?
>>
> 
> Yeah, the suggestion was for VM_WARN_ON() in the conditional, but the 
> placement has changed somewhat because of the new __alloc_pages_node().  I 
> think
> 
> 	else if (VM_WARN_ON(!node_online(nid)))
> 		nid = numa_mem_id();
> 
> should be fine since it only triggers for CONFIG_DEBUG_VM.

Um, so on your original suggestion I thought that you assumed that the condition
inside VM_WARN_ON is evaluated regardless of CONFIG_DEBUG_VM, it just will or
will not generate a warning. Which is how BUG_ON works, but VM_WARN_ON (and
VM_BUG_ON) doesn't. IIUC VM_WARN_ON() with !CONFIG_DEBUG_VM will always be false.
Because I didn't think you would suggest the "nid = numa_mem_id()" for
!node_online(nid) fixup would happen only for CONFIG_DEBUG_VM kernels. But it
seems that you do suggest that? I would understand if the fixup (correcting an
offline node to some that's online) was done regardless of DEBUG_VM, and
DEBUG_VM just switched between silent and noisy fixup. But having a debug option
alter the outcome seems wrong?
Am I correct that passing an offline node is not fatal, just the zonelist will
be empty and the allocation will fail? Now without DEBUG_VM it would silently
fail, and with DEBUG_VM it would warn, but succeed on another node.

So either we do fixup regardless of DEBUG_VM, or drop this patch, as the
VM_WARN_ON(!node_online(nid)) is already done in __alloc_pages_node() thanks to
patch 2/4?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
