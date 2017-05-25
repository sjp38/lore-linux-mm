Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5F47F6B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 04:58:31 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y22so19443878wry.1
        for <linux-mm@kvack.org>; Thu, 25 May 2017 01:58:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 7si22729640edt.108.2017.05.25.01.58.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 May 2017 01:58:30 -0700 (PDT)
Date: Thu, 25 May 2017 10:58:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: dm ioctl: Restore __GFP_HIGH in copy_params()
Message-ID: <20170525085827.GH12721@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1705191934340.17646@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522093725.GF8509@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705220759001.27401@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522120937.GI8509@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705221026430.20076@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522150321.GM8509@dhcp22.suse.cz>
 <20170522180415.GA25340@redhat.com>
 <alpine.DEB.2.10.1705221325200.30407@chino.kir.corp.google.com>
 <20170523060534.GA12813@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705231236210.20039@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1705231236210.20039@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Mike Snitzer <snitzer@redhat.com>, Junaid Shahid <junaids@google.com>, Alasdair Kergon <agk@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, andreslc@google.com, gthelen@google.com, vbabka@suse.cz, linux-kernel@vger.kernel.org

On Tue 23-05-17 12:44:18, Mikulas Patocka wrote:
> 
> 
> On Tue, 23 May 2017, Michal Hocko wrote:
> 
> > On Mon 22-05-17 13:35:41, David Rientjes wrote:
> > > On Mon, 22 May 2017, Mike Snitzer wrote:
> > [...]
> > > > While adding the __GFP_NOFAIL flag would serve to document expectations
> > > > I'm left unconvinced that the memory allocator will _not fail_ for an
> > > > order-0 page -- as Mikulas said most ioctls don't need more than 4K.
> > > 
> > > __GFP_NOFAIL would make no sense in kvmalloc() calls, ever, it would never 
> > > fallback to vmalloc :)
> > 
> > Sorry, I could have been more specific. You would have to opencode
> > kvmalloc obviously. It is documented to not support this flag for the
> > reasons you have mentioned above.
> > 
> > > I'm hoping this can get merged during the 4.12 window to fix the broken 
> > > commit d224e9381897.
> > 
> > I obviously disagree. Relying on memory reserves for _correctness_ is
> > clearly broken by design, full stop. But it is dm code and you are going
> > it is responsibility of the respective maintainers to support this code.
> 
> Block loop device is broken in the same way - it converts block requests 
> to filesystem reads and writes and those FS reads and writes allocate 
> memory.

I do not see those would depend on the __GFP_HIGH. Also writes are throttled
so the memory shouldn't get full of dirty pages.

> Network block device needs an userspace daemon to perform I/O.

which makes it pretty much not reliable for any forward progress. AFAIR
swap over NBD access full memory reserves to overcome this. But that is
merely an exception

> iSCSI also needs to allocate memory to perform I/O.

Shouldn't it use mempools? I am sorry but I am not familiar with this
area at all.
 
> NFS and other networking filesystems are also broken in the same way (they 
> need to receive a packet to acknowledge a write and packet reception needs 
> to allocate memory).
> 
> So - what should these *broken* drivers do to reduce the possibility of 
> the deadlock?

the IO path has traditionally used mempools to guarantee a forward
progress. If this is not an option then the choice is not all that
great. We are throttling memory writers (or drop packets when the memory
is too low) and finally have the OOM killer to free up some memory. 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
