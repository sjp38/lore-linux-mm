Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AD8F06B02A3
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 04:49:50 -0400 (EDT)
Subject: Re: [patch] mm: vmap area cache
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <20100701090211.GI22976@laptop>
References: <20100531080757.GE9453@laptop>
	 <20100602144905.aa613dec.akpm@linux-foundation.org>
	 <20100603135533.GO6822@laptop>
	 <1277470817.3158.386.camel@localhost.localdomain>
	 <20100626083122.GE29809@laptop>
	 <20100630162602.874ebd2a.akpm@linux-foundation.org>
	 <1277974154.2477.3.camel@localhost>  <20100701090211.GI22976@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 14 Jul 2010 09:55:05 +0100
Message-ID: <1279097705.2465.51.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, "Barry J. Marson" <bmarson@redhat.com>, avi@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

During testing of the most recent version of this patch we've hit a kernel bug
in alloc_vmap_area():


             }
412                 BUG_ON(first->va_start < addr);                     <- Bug triggers here      
413                 if (addr + cached_hole_size < first->va_start)
414                         cached_hole_size = first->va_start - addr;
415         }


This appears to be caused by a call from:

[<c050f870>] ? kmem_cache_alloc_notrace+0xa0/0xb0                
[<c0503695>] ? __get_vm_area_node+0xc5/0x1c0                     
[<c0458625>] ? walk_system_ram_range+0xa5/0x1c0                  
[<c050383e>] ? get_vm_area_caller+0x4e/0x60                      
[<f827328c>] ? intel_opregion_init+0xbc/0x510 [i915]             
[<c0430ce0>] ? __ioremap_caller+0x2b0/0x420                      
[<f827328c>] ? intel_opregion_init+0xbc/0x510 [i915]             
[<c0430f98>] ? ioremap_nocache+0x18/0x20                         
[<f827328c>] ? intel_opregion_init+0xbc/0x510 [i915]             
[<f827328c>] ? intel_opregion_init+0xbc/0x510 [i915]
[<c04cdc7c>] ? delayed_slow_work_enqueue+0xcc/0xf0               
[<f80f7c20>] ? drm_kms_helper_poll_init+0xc0/0x130 [drm_kms_helper]
[<f8248ec7>] ? i915_driver_load+0x757/0x10c0 [i915]              
[<f82471b0>] ? i915_vga_set_decode+0x0/0x20 [i915]               
[<f81c5675>] ? drm_sysfs_device_add+0x75/0xa0 [drm]              
[<f81c33d7>] ? drm_get_dev+0x2b7/0x4c0 [drm]                     
[<c05f6986>] ? pci_match_device+0x16/0xc0                        
[<c05f68ab>] ? local_pci_probe+0xb/0x10                          
[<c05f76b1>] ? pci_device_probe+0x61/0x80                        
[<c06a34f7>] ? driver_probe_device+0x87/0x290                 
etc.

So I guess that there might be something odd about that ioremap. It
triggers on every boot of the machine in question. It looks to me as if
perhaps its found a cached entry which doesn't fit in some way, but I'm
not certain of that yet,

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
