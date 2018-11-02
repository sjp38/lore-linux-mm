Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9DF066B0006
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 08:35:24 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id a188-v6so1193357oih.0
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 05:35:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i6-v6sor719516oiy.65.2018.11.02.05.35.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Nov 2018 05:35:23 -0700 (PDT)
MIME-Version: 1.0
References: <20181031081945.207709-1-vovoy@chromium.org> <20181031142458.GP32673@dhcp22.suse.cz>
 <cc44aa53-8705-02ea-6c59-f311427d93af@intel.com> <20181031164231.GQ32673@dhcp22.suse.cz>
 <CAEHM+4pSkv_fD3Yb2KX1xFrOmRHU1e=+wCBrCyLAAMBG3zP75w@mail.gmail.com> <20181101130910.GI23921@dhcp22.suse.cz>
In-Reply-To: <20181101130910.GI23921@dhcp22.suse.cz>
From: Vovo Yang <vovoy@chromium.org>
Date: Fri, 2 Nov 2018 20:35:11 +0800
Message-ID: <CAEHM+4rvBmFWhzPXZrwxXvMEmVdkpsgRg26wVNYSA8HKF_8AwQ@mail.gmail.com>
Subject: Re: [PATCH v3] mm, drm/i915: mark pinned shmemfs pages as unevictable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Nov 1, 2018 at 9:10 PM Michal Hocko <mhocko@kernel.org> wrote:
> OK, so that explain my question about the test case. Even though you
> generate a lot of page cache, the amount is still too small to trigger
> pagecache mostly reclaim and anon LRUs are scanned as well.
>
> Now to the difference with the previous version which simply set the
> UNEVICTABLE flag on mapping. Am I right assuming that pages are already
> at LRU at the time? Is there any reason the mapping cannot have the flag
> set before they are added to the LRU?

I checked again. When I run gem_syslatency, it sets unevictable flag
first and then adds pages to LRU, so my explanation to the previous
test result is wrong. It should not be necessary to explicitly move
these pages to unevictable list for this test case. The performance
improvement of this patch on kbl might be due to not calling
shmem_unlock_mapping.

The perf result of a shmem lock test shows find_get_entries is the
most expensive part of shmem_unlock_mapping.
85.32%--ksys_shmctl
        shmctl_do_lock
         --85.29%--shmem_unlock_mapping
                   |--45.98%--find_get_entries
                   |           --10.16%--radix_tree_next_chunk
                   |--16.78%--check_move_unevictable_pages
                   |--16.07%--__pagevec_release
                   |           --15.67%--release_pages
                   |                      --4.82%--free_unref_page_list
                   |--4.38%--pagevec_remove_exceptionals
                    --0.59%--_cond_resched
