Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A683A6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 12:44:24 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c75so64885588qka.7
        for <linux-mm@kvack.org>; Tue, 23 May 2017 09:44:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l35si22434554qta.3.2017.05.23.09.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 09:44:23 -0700 (PDT)
Date: Tue, 23 May 2017 12:44:18 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: dm ioctl: Restore __GFP_HIGH in copy_params()
In-Reply-To: <20170523060534.GA12813@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1705231236210.20039@file01.intranet.prod.int.rdu2.redhat.com>
References: <1508444.i5EqlA1upv@js-desktop.svl.corp.google.com> <20170519074647.GC13041@dhcp22.suse.cz> <alpine.LRH.2.02.1705191934340.17646@file01.intranet.prod.int.rdu2.redhat.com> <20170522093725.GF8509@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705220759001.27401@file01.intranet.prod.int.rdu2.redhat.com> <20170522120937.GI8509@dhcp22.suse.cz> <alpine.LRH.2.02.1705221026430.20076@file01.intranet.prod.int.rdu2.redhat.com> <20170522150321.GM8509@dhcp22.suse.cz> <20170522180415.GA25340@redhat.com>
 <alpine.DEB.2.10.1705221325200.30407@chino.kir.corp.google.com> <20170523060534.GA12813@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Mike Snitzer <snitzer@redhat.com>, Junaid Shahid <junaids@google.com>, Alasdair Kergon <agk@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, andreslc@google.com, gthelen@google.com, vbabka@suse.cz, linux-kernel@vger.kernel.org



On Tue, 23 May 2017, Michal Hocko wrote:

> On Mon 22-05-17 13:35:41, David Rientjes wrote:
> > On Mon, 22 May 2017, Mike Snitzer wrote:
> [...]
> > > While adding the __GFP_NOFAIL flag would serve to document expectations
> > > I'm left unconvinced that the memory allocator will _not fail_ for an
> > > order-0 page -- as Mikulas said most ioctls don't need more than 4K.
> > 
> > __GFP_NOFAIL would make no sense in kvmalloc() calls, ever, it would never 
> > fallback to vmalloc :)
> 
> Sorry, I could have been more specific. You would have to opencode
> kvmalloc obviously. It is documented to not support this flag for the
> reasons you have mentioned above.
> 
> > I'm hoping this can get merged during the 4.12 window to fix the broken 
> > commit d224e9381897.
> 
> I obviously disagree. Relying on memory reserves for _correctness_ is
> clearly broken by design, full stop. But it is dm code and you are going
> it is responsibility of the respective maintainers to support this code.

Block loop device is broken in the same way - it converts block requests 
to filesystem reads and writes and those FS reads and writes allocate 
memory.

Network block device needs an userspace daemon to perform I/O.

iSCSI also needs to allocate memory to perform I/O.

NFS and other networking filesystems are also broken in the same way (they 
need to receive a packet to acknowledge a write and packet reception needs 
to allocate memory).

So - what should these *broken* drivers do to reduce the possibility of 
the deadlock?

Mikulas

> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
