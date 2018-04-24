Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD746B0026
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 09:41:54 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id a13-v6so12814811oti.4
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 06:41:54 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c130-v6si5207576oih.416.2018.04.24.06.41.53
        for <linux-mm@kvack.org>;
        Tue, 24 Apr 2018 06:41:53 -0700 (PDT)
Date: Tue, 24 Apr 2018 14:41:48 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in
 gfp_kmemleak_mask
Message-ID: <20180424134148.qkvqqa4c37l6irvg@armageddon.cambridge.arm.com>
References: <1524243513-29118-1-git-send-email-chuhu@redhat.com>
 <20180420175023.3c4okuayrcul2bom@armageddon.cambridge.arm.com>
 <20180422125141.GF17484@dhcp22.suse.cz>
 <CACT4Y+YWUgyzCBadg+Oe8wDkFCaBzmcKDgu3rKjQxim7NXNLpg@mail.gmail.com>
 <CABATaM6eWtssvuj3UW9LHLK3HWo8P9g0z9VzFnuqKPKO5KMJ3A@mail.gmail.com>
 <20180424132057.GE17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180424132057.GE17484@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chunyu Hu <chuhu.ncepu@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Chunyu Hu <chuhu@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Apr 24, 2018 at 07:20:57AM -0600, Michal Hocko wrote:
> On Mon 23-04-18 12:17:32, Chunyu Hu wrote:
> [...]
> > So if there is a new flag, it would be the 25th bits.
> 
> No new flags please. Can you simply store a simple bool into fail_page_alloc
> and have save/restore api for that?

For kmemleak, we probably first hit failslab. Something like below may
do the trick:

diff --git a/mm/failslab.c b/mm/failslab.c
index 1f2f248e3601..63f13da5cb47 100644
--- a/mm/failslab.c
+++ b/mm/failslab.c
@@ -29,6 +29,9 @@ bool __should_failslab(struct kmem_cache *s, gfp_t gfpflags)
 	if (failslab.cache_filter && !(s->flags & SLAB_FAILSLAB))
 		return false;
 
+	if (s->flags & SLAB_NOLEAKTRACE)
+		return false;
+
 	return should_fail(&failslab.attr, s->object_size);
 }
 

Can we get a second should_fail() via should_fail_alloc_page() if a new
slab page is allocated?

-- 
Catalin
