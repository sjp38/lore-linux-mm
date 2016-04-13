Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 24180828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 06:36:31 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id v188so166552721wme.1
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 03:36:31 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id z140si28686534wmc.41.2016.04.13.03.36.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Apr 2016 03:36:29 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id v188so166552038wme.1
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 03:36:29 -0700 (PDT)
Date: Wed, 13 Apr 2016 13:36:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/1] mm: update min_free_kbytes from khugepaged after
 core initialization
Message-ID: <20160413103627.GA5051@node.shutemov.name>
References: <cover.1460488349.git.jbaron@akamai.com>
 <2bd05bd3f581116cee2d6396ea72613cf217a8c5.1460488349.git.jbaron@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2bd05bd3f581116cee2d6396ea72613cf217a8c5.1460488349.git.jbaron@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Baron <jbaron@akamai.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, rientjes@google.com, aarcange@redhat.com, mgorman@techsingularity.net, mhocko@suse.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 12, 2016 at 03:54:37PM -0400, Jason Baron wrote:
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

Looks good to me:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
