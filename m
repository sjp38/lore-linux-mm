Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 309DC6B002F
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 18:43:00 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id x2-v6so7180483qto.10
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 15:43:00 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m15-v6si6120836qtm.248.2018.04.25.15.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 15:42:59 -0700 (PDT)
Date: Wed, 25 Apr 2018 18:42:57 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc fallback
 options
In-Reply-To: <1524694663.4100.21.camel@HansenPartnership.com>
Message-ID: <alpine.LRH.2.02.1804251830540.25124@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180421144757.GC14610@bombadil.infradead.org>  <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>  <20180423151545.GU17484@dhcp22.suse.cz>  <alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com>
  <20180424125121.GA17484@dhcp22.suse.cz>  <alpine.LRH.2.02.1804241142340.15660@file01.intranet.prod.int.rdu2.redhat.com>  <20180424162906.GM17484@dhcp22.suse.cz>  <alpine.LRH.2.02.1804241250350.28995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424170349.GQ17484@dhcp22.suse.cz>  <alpine.LRH.2.02.1804241319390.28995@file01.intranet.prod.int.rdu2.redhat.com>  <20180424173836.GR17484@dhcp22.suse.cz>  <alpine.LRH.2.02.1804251556060.30569@file01.intranet.prod.int.rdu2.redhat.com>
 <1114eda5-9b1f-4db8-2090-556b4a37c532@infradead.org>  <alpine.LRH.2.02.1804251656300.9428@file01.intranet.prod.int.rdu2.redhat.com>  <alpine.DEB.2.21.1804251417470.166306@chino.kir.corp.google.com>  <alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com>
 <1524694663.4100.21.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="185206533-1203068836-1524696178=:25124"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: David Rientjes <rientjes@google.com>, dm-devel@redhat.com, eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, edumazet@google.com, Andrew Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, Vlastimil Babka <vbabka@suse.cz>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--185206533-1203068836-1524696178=:25124
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT



On Wed, 25 Apr 2018, James Bottomley wrote:

> On Wed, 2018-04-25 at 17:22 -0400, Mikulas Patocka wrote:
> > 
> > On Wed, 25 Apr 2018, David Rientjes wrote:
> > > 
> > > Do we really need the new config option?A A This could just be
> > > manuallyA  tunable via fault injection IIUC.
> > 
> > We do, because we want to enable it in RHEL and Fedora debugging
> > kernels,A so that it will be tested by the users.
> > 
> > The users won't use some extra magic kernel options or debugfs files.
> 
> If it can be enabled via a tunable, then the distro can turn it on
> without the user having to do anything.

You need to enable it on boot. Enabling it when the kernel starts to 
execute userspace code is already too late (because you would miss 
kvmalloc calls in the kernel boot path).

These are files in the kernel-debug rpm package. Where would you put the 
extra kernel parameter to enable this feature? None of these files contain 
kernel parameters.

kernel-debug              /boot/.vmlinuz-3.10.0-693.21.1.el7.x86_64.debug.hmac
kernel-debug              /boot/System.map-3.10.0-693.21.1.el7.x86_64.debug
kernel-debug              /boot/config-3.10.0-693.21.1.el7.x86_64.debug
kernel-debug              /boot/initramfs-3.10.0-693.21.1.el7.x86_64.debug.img
kernel-debug              /boot/symvers-3.10.0-693.21.1.el7.x86_64.debug.gz
kernel-debug              /boot/vmlinuz-3.10.0-693.21.1.el7.x86_64.debug
kernel-debug              /etc/ld.so.conf.d/kernel-3.10.0-693.21.1.el7.x86_64.debug.conf
kernel-debug              /lib/modules/3.10.0-693.21.1.el7.x86_64.debug

> If you want to present the user with a different boot option, you can 
> (just have the tunable set on the command line), but being tunable 
> driven means that you don't have to choose that option, you could 
> automatically enable it under a range of circumstances.  I think most 
> sane distributions would want that flexibility.
> 
> Kconfig proliferation, conversely, is a bit of a nightmare from both
> the user and the tester's point of view, so we're trying to avoid it
> unless absolutely necessary.
> 
> James

I already offered that we don't need to introduce a new kernel option and 
we can bind this feature to any other kernel option, that is enabled in 
the debug kernel, for example CONFIG_DEBUG_SG. Michal said no and he said 
that he wants a new kernel option instead.

Mikulas
--185206533-1203068836-1524696178=:25124--
