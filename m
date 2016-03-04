Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6AAE86B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 04:35:47 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fl4so32110826pad.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 01:35:47 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id n21si4710206pfi.104.2016.03.04.01.35.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 01:35:46 -0800 (PST)
Date: Fri, 4 Mar 2016 12:35:30 +0300
From: Roman Kagan <rkagan@virtuozzo.com>
Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Message-ID: <20160304093529.GA2479@rkaganb.sw.ru>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160303174615.GF2115@work-vm>
 <20160304075538.GC9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E037714DA@SHSMSX101.ccr.corp.intel.com>
 <20160304083550.GE9100@rkaganb.sw.ru>
 <20160304090820.GA2149@work-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160304090820.GA2149@work-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: "Li, Liang Z" <liang.z.li@intel.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

On Fri, Mar 04, 2016 at 09:08:20AM +0000, Dr. David Alan Gilbert wrote:
> * Roman Kagan (rkagan@virtuozzo.com) wrote:
> > On Fri, Mar 04, 2016 at 08:23:09AM +0000, Li, Liang Z wrote:
> > > The unmapped/zero mapped pages can be detected by parsing /proc/self/pagemap,
> > > but the free pages can't be detected by this. Imaging an application allocates a large amount
> > > of memory , after using, it frees the memory, then live migration happens. All these free pages
> > > will be process and sent to the destination, it's not optimal.
> > 
> > First, the likelihood of such a situation is marginal, there's no point
> > optimizing for it specifically.
> > 
> > And second, even if that happens, you inflate the balloon right before
> > the migration and the free memory will get umapped very quickly, so this
> > case is covered nicely by the same technique that works for more
> > realistic cases, too.
> 
> Although I wonder which is cheaper; that would be fairly expensive for
> the guest wouldn't it?

For the guest -- generally it wouldn't if you have a good estimate of
available memory (i.e. the amount you can balloon out without forcing
the guest to swap).

And yes you need certain cost estimates for choosing the best migration
strategy: e.g. if your network bandwidth is unlimited you may be better
off transferring the zeros to the destination rather than optimizing
them away.

> And you'd somehow have to kick the guest
> before migration to do the ballooning - and how long would you wait
> for it to finish?

It's a matter for fine-tuning with all the inputs at hand, like network
bandwidth, costs of delaying the migration, etc.  And you don't need to
wait for it to finish, i.e. reach the balloon size target: you can start
the migration as soon as it's good enough (for whatever definition of
"enough" is found appropriate by that fine-tuning).

Roman.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
