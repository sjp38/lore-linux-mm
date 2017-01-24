Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C30EC6B0266
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:17:27 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 80so247974369pfy.2
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 11:17:27 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id 2si20314128pfe.63.2017.01.24.11.17.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 11:17:26 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 204so17346375pge.2
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 11:17:26 -0800 (PST)
Date: Tue, 24 Jan 2017 11:17:21 -0800
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Message-ID: <20170124191716.GA23114@ast-mbp.thefacebook.com>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170124151752.GO6867@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170124151752.GO6867@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, Andreas Dilger <adilger@dilger.ca>, Andreas Dilger <andreas.dilger@intel.com>, Anton Vorontsov <anton@enomsg.org>, Ben Skeggs <bskeggs@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Colin Cross <ccross@android.com>, Dan Williams <dan.j.williams@intel.com>, David Sterba <dsterba@suse.com>, Eric Dumazet <edumazet@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, Hariprasad S <hariprasad@chelsio.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Ilya Dryomov <idryomov@gmail.com>, Kees Cook <keescook@chromium.org>, Kent Overstreet <kent.overstreet@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Oleg Drokin <oleg.drokin@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Santosh Raspatur <santosh@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Theodore Ts'o <tytso@mit.edu>, Tom Herbert <tom@herbertland.com>, Tony Luck <tony.luck@intel.com>, "Yan, Zheng" <zyan@redhat.com>, Yishai Hadas <yishaih@mellanox.com>, Daniel Borkmann <daniel@iogearbox.net>

On Tue, Jan 24, 2017 at 04:17:52PM +0100, Michal Hocko wrote:
> On Thu 12-01-17 16:37:11, Michal Hocko wrote:
> > Hi,
> > this has been previously posted as a single patch [1] but later on more
> > built on top. It turned out that there are users who would like to have
> > __GFP_REPEAT semantic. This is currently implemented for costly >64B
> > requests. Doing the same for smaller requests would require to redefine
> > __GFP_REPEAT semantic in the page allocator which is out of scope of
> > this series.
> > 
> > There are many open coded kmalloc with vmalloc fallback instances in
> > the tree.  Most of them are not careful enough or simply do not care
> > about the underlying semantic of the kmalloc/page allocator which means
> > that a) some vmalloc fallbacks are basically unreachable because the
> > kmalloc part will keep retrying until it succeeds b) the page allocator
> > can invoke a really disruptive steps like the OOM killer to move forward
> > which doesn't sound appropriate when we consider that the vmalloc
> > fallback is available.
> > 
> > As it can be seen implementing kvmalloc requires quite an intimate
> > knowledge if the page allocator and the memory reclaim internals which
> > strongly suggests that a helper should be implemented in the memory
> > subsystem proper.
> > 
> > Most callers I could find have been converted to use the helper instead.
> > This is patch 5. There are some more relying on __GFP_REPEAT in the
> > networking stack which I have converted as well but considering we do
> > not have a support for __GFP_REPEAT for requests smaller than 64kB I
> > have marked it RFC.
> 
> Are there any more comments? I would really appreciate to hear from
> networking folks before I resubmit the series.

while this patchset was baking the bpf side switched to use bpf_map_area_alloc()
which fixes the issue with missing __GFP_NORETRY that we had to fix quickly.
See commit d407bd25a204 ("bpf: don't trigger OOM killer under pressure with map alloc")
it covers all kmalloc/vmalloc pairs instead of just one place as in this set.
So please rebase and switch bpf_map_area_alloc() to use kvmalloc().
Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
