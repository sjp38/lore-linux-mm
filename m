Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 581106B002C
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 18:17:51 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id 36-v6so3197303oth.17
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 15:17:51 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id w108-v6si6492550otb.188.2018.04.25.15.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Apr 2018 15:17:47 -0700 (PDT)
Message-ID: <1524694663.4100.21.camel@HansenPartnership.com>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc
 fallback options
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 25 Apr 2018 15:17:43 -0700
In-Reply-To: <alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180421144757.GC14610@bombadil.infradead.org>
	 <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
	 <20180423151545.GU17484@dhcp22.suse.cz>
	 <alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com>
	 <20180424125121.GA17484@dhcp22.suse.cz>
	 <alpine.LRH.2.02.1804241142340.15660@file01.intranet.prod.int.rdu2.redhat.com>
	 <20180424162906.GM17484@dhcp22.suse.cz>
	 <alpine.LRH.2.02.1804241250350.28995@file01.intranet.prod.int.rdu2.redhat.com>
	 <20180424170349.GQ17484@dhcp22.suse.cz>
	 <alpine.LRH.2.02.1804241319390.28995@file01.intranet.prod.int.rdu2.redhat.com>
	 <20180424173836.GR17484@dhcp22.suse.cz>
	 <alpine.LRH.2.02.1804251556060.30569@file01.intranet.prod.int.rdu2.redhat.com>
	 <1114eda5-9b1f-4db8-2090-556b4a37c532@infradead.org>
	 <alpine.LRH.2.02.1804251656300.9428@file01.intranet.prod.int.rdu2.redhat.com>
	 <alpine.DEB.2.21.1804251417470.166306@chino.kir.corp.google.com>
	 <alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>, David Rientjes <rientjes@google.com>
Cc: dm-devel@redhat.com, eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, edumazet@google.com, Andrew Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, Vlastimil Babka <vbabka@suse.cz>

On Wed, 2018-04-25 at 17:22 -0400, Mikulas Patocka wrote:
> 
> On Wed, 25 Apr 2018, David Rientjes wrote:
> 
> > On Wed, 25 Apr 2018, Mikulas Patocka wrote:
> > 
> > > From: Mikulas Patocka <mpatocka@redhat.com>
> > > Subject: [PATCH] fault-injection: introduce kvmalloc fallback
> > > options
> > > 
> > > This patch introduces a fault-injection option
> > > "kvmalloc_fallback". This option makes kvmalloc randomly fall
> > > back to vmalloc.
> > > 
> > > Unfortunately, some kernel code has bugs - it uses kvmalloc and
> > > then uses DMA-API on the returned memory or frees it with kfree.
> > > Such bugs were found in the virtio-net driver, dm-integrity or
> > > RHEL7 powerpc-specific code. This options helps to test for these
> > > bugs.
> > > 
> > > The patch introduces a config option
> > > FAIL_KVMALLOC_FALLBACK_PROBABILITY.
> > > It can be enabled in distribution debug kernels, so that kvmalloc
> > > abuse can be tested by the users. The default can be overridden
> > > with "kvmalloc_fallback" parameter or in
> > > /sys/kernel/debug/kvmalloc_fallback/.
> > > 
> > 
> > Do we really need the new config option?A A This could just be
> > manuallyA  tunable via fault injection IIUC.
> 
> We do, because we want to enable it in RHEL and Fedora debugging
> kernels,A so that it will be tested by the users.
> 
> The users won't use some extra magic kernel options or debugfs files.

If it can be enabled via a tunable, then the distro can turn it on
without the user having to do anything.  If you want to present the
user with a different boot option, you can (just have the tunable set
on the command line), but being tunable driven means that you don't
have to choose that option, you could automatically enable it under a
range of circumstances.  I think most sane distributions would want
that flexibility.

Kconfig proliferation, conversely, is a bit of a nightmare from both
the user and the tester's point of view, so we're trying to avoid it
unless absolutely necessary.

James
