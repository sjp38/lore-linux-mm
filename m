Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2CF8C6B0069
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 10:37:25 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id d140so5406834wmd.4
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 07:37:25 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ha9si1521914wjc.118.2017.01.12.07.37.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 07:37:24 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id r144so4520031wme.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 07:37:23 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/6 v3] kvmalloc
Date: Thu, 12 Jan 2017 16:37:11 +0100
Message-Id: <20170112153717.28943-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, Andreas Dilger <adilger@dilger.ca>, Andreas Dilger <andreas.dilger@intel.com>, Anton Vorontsov <anton@enomsg.org>, Ben Skeggs <bskeggs@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Colin Cross <ccross@android.com>, Dan Williams <dan.j.williams@intel.com>, David Sterba <dsterba@suse.com>, Eric Dumazet <edumazet@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, Hariprasad S <hariprasad@chelsio.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Ilya Dryomov <idryomov@gmail.com>, Kees Cook <keescook@chromium.org>, Kent Overstreet <kent.overstreet@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@suse.com>, Mike Snitzer <snitzer@redhat.com>, Oleg Drokin <oleg.drokin@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Santosh Raspatur <santosh@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Theodore Ts'o <tytso@mit.edu>, Tom Herbert <tom@herbertland.com>, Tony Luck <tony.luck@intel.com>, "Yan, Zheng" <zyan@redhat.com>, Yishai Hadas <yishaih@mellanox.com>

Hi,
this has been previously posted as a single patch [1] but later on more
built on top. It turned out that there are users who would like to have
__GFP_REPEAT semantic. This is currently implemented for costly >64B
requests. Doing the same for smaller requests would require to redefine
__GFP_REPEAT semantic in the page allocator which is out of scope of
this series.

There are many open coded kmalloc with vmalloc fallback instances in
the tree.  Most of them are not careful enough or simply do not care
about the underlying semantic of the kmalloc/page allocator which means
that a) some vmalloc fallbacks are basically unreachable because the
kmalloc part will keep retrying until it succeeds b) the page allocator
can invoke a really disruptive steps like the OOM killer to move forward
which doesn't sound appropriate when we consider that the vmalloc
fallback is available.

As it can be seen implementing kvmalloc requires quite an intimate
knowledge if the page allocator and the memory reclaim internals which
strongly suggests that a helper should be implemented in the memory
subsystem proper.

Most callers I could find have been converted to use the helper instead.
This is patch 5. There are some more relying on __GFP_REPEAT in the
networking stack which I have converted as well but considering we do
not have a support for __GFP_REPEAT for requests smaller than 64kB I
have marked it RFC.

[1] http://lkml.kernel.org/r/20170102133700.1734-1-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
