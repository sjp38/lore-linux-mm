Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E7E4F6B0038
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 08:10:12 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d140so37985371wmd.4
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:10:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g109si26844971wrd.9.2017.01.25.05.10.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 05:10:11 -0800 (PST)
Date: Wed, 25 Jan 2017 14:10:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Message-ID: <20170125131006.GQ32377@dhcp22.suse.cz>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170124151752.GO6867@dhcp22.suse.cz>
 <20170124191716.GA23114@ast-mbp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170124191716.GA23114@ast-mbp.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, Andreas Dilger <adilger@dilger.ca>, Andreas Dilger <andreas.dilger@intel.com>, Anton Vorontsov <anton@enomsg.org>, Ben Skeggs <bskeggs@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Colin Cross <ccross@android.com>, Dan Williams <dan.j.williams@intel.com>, David Sterba <dsterba@suse.com>, Eric Dumazet <edumazet@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, Hariprasad S <hariprasad@chelsio.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Ilya Dryomov <idryomov@gmail.com>, Kees Cook <keescook@chromium.org>, Kent Overstreet <kent.overstreet@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Oleg Drokin <oleg.drokin@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Santosh Raspatur <santosh@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Theodore Ts'o <tytso@mit.edu>, Tom Herbert <tom@herbertland.com>, Tony Luck <tony.luck@intel.com>, "Yan, Zheng" <zyan@redhat.com>, Yishai Hadas <yishaih@mellanox.com>, Daniel Borkmann <daniel@iogearbox.net>

On Tue 24-01-17 11:17:21, Alexei Starovoitov wrote:
> On Tue, Jan 24, 2017 at 04:17:52PM +0100, Michal Hocko wrote:
> > On Thu 12-01-17 16:37:11, Michal Hocko wrote:
> > > Hi,
> > > this has been previously posted as a single patch [1] but later on more
> > > built on top. It turned out that there are users who would like to have
> > > __GFP_REPEAT semantic. This is currently implemented for costly >64B
> > > requests. Doing the same for smaller requests would require to redefine
> > > __GFP_REPEAT semantic in the page allocator which is out of scope of
> > > this series.
> > > 
> > > There are many open coded kmalloc with vmalloc fallback instances in
> > > the tree.  Most of them are not careful enough or simply do not care
> > > about the underlying semantic of the kmalloc/page allocator which means
> > > that a) some vmalloc fallbacks are basically unreachable because the
> > > kmalloc part will keep retrying until it succeeds b) the page allocator
> > > can invoke a really disruptive steps like the OOM killer to move forward
> > > which doesn't sound appropriate when we consider that the vmalloc
> > > fallback is available.
> > > 
> > > As it can be seen implementing kvmalloc requires quite an intimate
> > > knowledge if the page allocator and the memory reclaim internals which
> > > strongly suggests that a helper should be implemented in the memory
> > > subsystem proper.
> > > 
> > > Most callers I could find have been converted to use the helper instead.
> > > This is patch 5. There are some more relying on __GFP_REPEAT in the
> > > networking stack which I have converted as well but considering we do
> > > not have a support for __GFP_REPEAT for requests smaller than 64kB I
> > > have marked it RFC.
> > 
> > Are there any more comments? I would really appreciate to hear from
> > networking folks before I resubmit the series.
> 
> while this patchset was baking the bpf side switched to use bpf_map_area_alloc()
> which fixes the issue with missing __GFP_NORETRY that we had to fix quickly.
> See commit d407bd25a204 ("bpf: don't trigger OOM killer under pressure with map alloc")
> it covers all kmalloc/vmalloc pairs instead of just one place as in this set.
> So please rebase and switch bpf_map_area_alloc() to use kvmalloc().

OK, will do. Thanks for the heads up.


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
