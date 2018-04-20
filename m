Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD0866B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 16:54:55 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l19so6376716qkk.11
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 13:54:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h45-v6si5995899qta.264.2018.04.20.13.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 13:54:54 -0700 (PDT)
Date: Fri, 20 Apr 2018 16:54:53 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
In-Reply-To: <20180420130852.GC16083@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com> <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com> <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com> <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <20180420130852.GC16083@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Fri, 20 Apr 2018, Michal Hocko wrote:

> On Thu 19-04-18 12:12:38, Mikulas Patocka wrote:
> [...]
> > From: Mikulas Patocka <mpatocka@redhat.com>
> > Subject: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
> > 
> > The kvmalloc function tries to use kmalloc and falls back to vmalloc if
> > kmalloc fails.
> > 
> > Unfortunatelly, some kernel code has bugs - it uses kvmalloc and then
> > uses DMA-API on the returned memory or frees it with kfree. Such bugs were
> > found in the virtio-net driver, dm-integrity or RHEL7 powerpc-specific
> > code.
> > 
> > These bugs are hard to reproduce because vmalloc falls back to kmalloc
> > only if memory is fragmented.
> > 
> > In order to detect these bugs reliably I submit this patch that changes
> > kvmalloc to always use vmalloc if CONFIG_DEBUG_VM is turned on.
> 
> No way. This is just wrong! First of all, you will explode most likely
> on many allocations of small sizes. Second, CONFIG_DEBUG_VM tends to be
> enabled quite often.

You're an evil person who doesn't want to fix bugs.

You refused to fix vmalloc(GFP_NOIO) misbehavior a year ago (did you make 
some progress with it since that time?) and you refuse to fix kvmalloc 
misuses.

I tried this patch on text-only virtual machine and /proc/vmallocinfo 
shows 614kB more memory. I tried it on a desktop machine with the chrome 
browser open and /proc/vmallocinfo space is increased by 7MB. So no - this 
won't exhaust memory and kill the machine.

Arguing that this increases memory consumption is as bogus as arguing that 
CONFIG_LOCKDEP increses memory consumption. No one is forcing you to 
enable CONFIG_LOCKDEP and no one is forcing you to enable this kvmalloc 
test too.

Mikulas
