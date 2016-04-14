Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 769346B007E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 16:08:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t124so147936236pfb.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 13:08:40 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id f63si8949081pfj.137.2016.04.14.13.08.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 13:08:39 -0700 (PDT)
Received: by mail-pa0-x231.google.com with SMTP id fs9so29043750pac.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 13:08:39 -0700 (PDT)
Date: Thu, 14 Apr 2016 13:08:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/1] mm: update min_free_kbytes from khugepaged after
 core initialization
In-Reply-To: <2bd05bd3f581116cee2d6396ea72613cf217a8c5.1460488349.git.jbaron@akamai.com>
Message-ID: <alpine.DEB.2.10.1604141307580.6593@chino.kir.corp.google.com>
References: <cover.1460488349.git.jbaron@akamai.com> <2bd05bd3f581116cee2d6396ea72613cf217a8c5.1460488349.git.jbaron@akamai.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Baron <jbaron@akamai.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, mgorman@techsingularity.net, mhocko@suse.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 12 Apr 2016, Jason Baron wrote:

> Khugepaged attempts to raise min_free_kbytes if its set too low. However,
> on boot khugepaged sets min_free_kbytes first from subsys_initcall(), and
> then the mm 'core' over-rides min_free_kbytes after from
> init_per_zone_wmark_min(), via a module_init() call.
> 
> Khugepaged used to use a late_initcall() to set min_free_kbytes (such that
> it occurred after the core initialization), however this was removed when
> the initialization of min_free_kbytes was integrated into the starting of
> the khugepaged thread.
> 
> The fix here is simply to invoke the core initialization using a
> core_initcall() instead of module_init(), such that the previous
> initialization ordering is restored. I didn't restore the late_initcall()
> since start_stop_khugepaged() already sets min_free_kbytes via
> set_recommended_min_free_kbytes().
> 
> This was noticed when we had a number of page allocation failures when
> moving a workload to a kernel with this new initialization ordering. On an
> 8GB system this restores min_free_kbytes back to 67584 from 11365 when
> CONFIG_TRANSPARENT_HUGEPAGE=y is set and either
> CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y or
> CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y.
> 
> Fixes: 79553da293d3 ("thp: cleanup khugepaged startup")
> Signed-off-by: Jason Baron <jbaron@akamai.com>

Acked-by: David Rientjes <rientjes@google.com>

I assume it could also be fixed by not setting min_free_kbytes lower in 
init_per_zone_wmark_min(), but if the ordering is correct this is less 
code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
