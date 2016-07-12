Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E322D6B0253
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:59:18 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p41so9800147lfi.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 04:59:18 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id j142si20099411wmg.142.2016.07.12.04.59.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 04:59:17 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id o80so22188706wme.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 04:59:17 -0700 (PDT)
Date: Tue, 12 Jul 2016 13:59:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Page Allocation Failures/OOM with dm-crypt on software RAID10
 (Intel Rapid Storage)
Message-ID: <20160712115915.GG14586@dhcp22.suse.cz>
References: <02580b0a303da26b669b4a9892624b13@mail.ud19.udmedia.de>
 <20160712095013.GA14591@dhcp22.suse.cz>
 <d9dbe0328e938eb7544fdb2aa8b5a9c7@mail.ud19.udmedia.de>
 <20160712114920.GF14586@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160712114920.GF14586@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Cc: linux-raid@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org

On Tue 12-07-16 13:49:20, Michal Hocko wrote:
> On Tue 12-07-16 13:28:12, Matthias Dahl wrote:
> > Hello Michal...
> > 
> > On 2016-07-12 11:50, Michal Hocko wrote:
> > 
> > > This smells like file pages are stuck in the writeback somewhere and the
> > > anon memory is not reclaimable because you do not have any swap device.
> > 
> > Not having a swap device shouldn't be a problem -- and in this case, it
> > would cause even more trouble as in disk i/o.
> > 
> > What could cause the file pages to get stuck or stopped from being written
> > to the disk? And more importantly, what is so unique/special about the
> > Intel Rapid Storage that it happens (seemingly) exclusively with that
> > and not the the normal Linux s/w raid support?
> 
> I am not a storage expert (not even mention dm-crypt). But what those
> counters say is that the IO completion doesn't trigger so the
> PageWriteback flag is still set. Such a page is not reclaimable
> obviously. So I would check the IO delivery path and focus on the
> potential dm-crypt involvement if you suspect this is a contributing
> factor.
>  
> > Also, if the pages are not written to disk, shouldn't something error
> > out or slow dd down?
> 
> Writers are normally throttled when we the dirty limit. You seem to have
> dirty_ratio set to 20% which is quite a lot considering how much memory
> you have.

And just to clarify. dirty_ratio refers to dirtyable memory which is
free_pages+file_lru pages. In your case you you have only 9% of the total
memory size dirty/writeback but that is 90% of dirtyable memory. This is
quite possible if somebody consumes free_pages racing with the writer.
Writer will get throttled but the concurrent memory consumer will not
normally. So you can end up in this situation.

> If you get back to the memory info from the OOM killer report:
> [18907.592209] active_anon:110314 inactive_anon:295 isolated_anon:0
>                 active_file:27534 inactive_file:819673 isolated_file:160
>                 unevictable:13001 dirty:167859 writeback:651864 unstable:0
>                 slab_reclaimable:177477 slab_unreclaimable:1817501
>                 mapped:934 shmem:588 pagetables:7109 bounce:0
>                 free:49928 free_pcp:45 free_cma:0
> 
> The dirty+writeback is ~9%. What is more interesting, though, LRU
> pages are negligible to the memory size (~11%). Note the numer of
> unreclaimable slab pages (~20%). Who is consuming those objects?
> Where is the rest 70% of memory hiding?


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
