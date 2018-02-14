Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75F9E6B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 06:51:24 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id t6so7259785wrc.12
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 03:51:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p18si6715592wmb.159.2018.02.14.03.51.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Feb 2018 03:51:23 -0800 (PST)
Date: Wed, 14 Feb 2018 12:51:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WARNING in kvmalloc_node
Message-ID: <20180214115119.GA3443@dhcp22.suse.cz>
References: <001a1144c4ca5dc9d6056520c7b7@google.com>
 <20180214025533.GA28811@bombadil.infradead.org>
 <20180214084308.GX3443@dhcp22.suse.cz>
 <f3fda93e-b223-3c94-3213-43cad4346716@iogearbox.net>
 <24351362-a099-3317-2b96-8cdc6835eb1e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <24351362-a099-3317-2b96-8cdc6835eb1e@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Wang <jasowang@redhat.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, Matthew Wilcox <willy@infradead.org>, syzbot <syzbot+1a240cdb1f4cc88819df@syzkaller.appspotmail.com>, akpm@linux-foundation.org, dhowells@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, rppt@linux.vnet.ibm.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, viro@zeniv.linux.org.uk, Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org, brouer@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>

On Wed 14-02-18 19:47:30, Jason Wang wrote:
> 
> 
> On 2018a1'02ae??14ae?JPY 17:28, Daniel Borkmann wrote:
> > [ +Jason, +Jesper ]
> > 
> > On 02/14/2018 09:43 AM, Michal Hocko wrote:
> > > On Tue 13-02-18 18:55:33, Matthew Wilcox wrote:
> > > > On Tue, Feb 13, 2018 at 03:59:01PM -0800, syzbot wrote:
> > > [...]
> > > > >   kvmalloc include/linux/mm.h:541 [inline]
> > > > >   kvmalloc_array include/linux/mm.h:557 [inline]
> > > > >   __ptr_ring_init_queue_alloc include/linux/ptr_ring.h:474 [inline]
> > > > >   ptr_ring_init include/linux/ptr_ring.h:492 [inline]
> > > > >   __cpu_map_entry_alloc kernel/bpf/cpumap.c:359 [inline]
> > > > >   cpu_map_update_elem+0x3c3/0x8e0 kernel/bpf/cpumap.c:490
> > > > >   map_update_elem kernel/bpf/syscall.c:698 [inline]
> > > > Blame the BPF people, not the MM people ;-)
> > Heh, not really. ;-)
> > 
> > > Yes. kvmalloc (the vmalloc part) doesn't support GFP_ATOMIC semantic.
> > Agree, that doesn't work.
> > 
> > Bug was added in commit 0bf7800f1799 ("ptr_ring: try vmalloc() when kmalloc() fails").
> > 
> > Jason, please take a look at fixing this, thanks!
> 
> It looks to me the only solution is to revert that commit.

Do you really need this to be GFP_ATOMIC? I can see some callers are
under RCU read lock but can we perhaps do the allocation outside of this
section?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
