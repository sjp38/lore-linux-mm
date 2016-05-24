Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 06D9F6B025E
	for <linux-mm@kvack.org>; Tue, 24 May 2016 11:30:34 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id d66so45793837vkb.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 08:30:34 -0700 (PDT)
Received: from mail-yw0-x229.google.com (mail-yw0-x229.google.com. [2607:f8b0:4002:c05::229])
        by mx.google.com with ESMTPS id n5si18687105ywe.69.2016.05.24.08.30.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 08:30:32 -0700 (PDT)
Received: by mail-yw0-x229.google.com with SMTP id h19so19431599ywc.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 08:30:32 -0700 (PDT)
Date: Tue, 24 May 2016 11:30:29 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: bpf: use-after-free in array_map_alloc
Message-ID: <20160524153029.GA3354@mtj.duckdns.org>
References: <5713C0AD.3020102@oracle.com>
 <20160417172943.GA83672@ast-mbp.thefacebook.com>
 <5742F127.6080000@suse.cz>
 <5742F267.3000309@suse.cz>
 <20160523213501.GA5383@mtj.duckdns.org>
 <57441396.2050607@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57441396.2050607@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, ast@kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Linux-MM layout <linux-mm@kvack.org>, marco.gra@gmail.com

Hello,

On Tue, May 24, 2016 at 10:40:54AM +0200, Vlastimil Babka wrote:
> [+CC Marco who reported the CVE, forgot that earlier]
> 
> On 05/23/2016 11:35 PM, Tejun Heo wrote:
> > Hello,
> > 
> > Can you please test whether this patch resolves the issue?  While
> > adding support for atomic allocations, I reduced alloc_mutex covered
> > region too much.
> > 
> > Thanks.
> 
> Ugh, this makes the code even more head-spinning than it was.

Locking-wise, it isn't complicated.  It used to be a single mutex
protecting everything.  Atomic alloc support required putting core
allocation parts under spinlock.  It is messy because the two paths
are mixed in the same function.  If we break out the core part to a
separate function and let the sleepable path call into that, it should
look okay, but that's for another patch.

Also, I think protecting chunk's lifetime w/ alloc_mutex is making it
a bit nasty.  Maybe we should do per-chunk "extending" completion and
let pcpu_alloc_mutex just protect populating chunks.

> > @@ -435,6 +435,8 @@ static int pcpu_extend_area_map(struct pcpu_chunk *chunk, int new_alloc)
> >   	size_t old_size = 0, new_size = new_alloc * sizeof(new[0]);
> >   	unsigned long flags;
> > 
> > +	lockdep_assert_held(&pcpu_alloc_mutex);
> 
> I don't see where the mutex gets locked when called via
> pcpu_map_extend_workfn? (except via the new cancel_work_sync() call below?)

Ah, right.

> Also what protects chunks with scheduled work items from being removed?

cancel_work_sync(), which now obviously should be called outside
alloc_mutex.

> > @@ -895,6 +897,9 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
> >   		return NULL;
> >   	}
> > 
> > +	if (!is_atomic)
> > +		mutex_lock(&pcpu_alloc_mutex);
> 
> BTW I noticed that
> 	bool is_atomic = (gfp & GFP_KERNEL) != GFP_KERNEL;
> 
> this is too pessimistic IMHO. Reclaim is possible even without __GFP_FS and
> __GFP_IO. Could you just use gfpflags_allow_blocking(gfp) here?

vmalloc hardcodes GFP_KERNEL, so getting more relaxed doesn't buy us
much.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
