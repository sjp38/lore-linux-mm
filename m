Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C20F56B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 03:36:04 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id 4so31647032pfd.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 00:36:04 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rl12si4338893pab.136.2016.03.04.00.36.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 00:36:04 -0800 (PST)
Date: Fri, 4 Mar 2016 11:35:51 +0300
From: Roman Kagan <rkagan@virtuozzo.com>
Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Message-ID: <20160304083550.GE9100@rkaganb.sw.ru>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160303174615.GF2115@work-vm>
 <20160304075538.GC9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E037714DA@SHSMSX101.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E037714DA@SHSMSX101.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

On Fri, Mar 04, 2016 at 08:23:09AM +0000, Li, Liang Z wrote:
> > On Thu, Mar 03, 2016 at 05:46:15PM +0000, Dr. David Alan Gilbert wrote:
> > > * Liang Li (liang.z.li@intel.com) wrote:
> > > > The current QEMU live migration implementation mark the all the
> > > > guest's RAM pages as dirtied in the ram bulk stage, all these pages
> > > > will be processed and that takes quit a lot of CPU cycles.
> > > >
> > > > From guest's point of view, it doesn't care about the content in
> > > > free pages. We can make use of this fact and skip processing the
> > > > free pages in the ram bulk stage, it can save a lot CPU cycles and
> > > > reduce the network traffic significantly while speed up the live
> > > > migration process obviously.
> > > >
> > > > This patch set is the QEMU side implementation.
> > > >
> > > > The virtio-balloon is extended so that QEMU can get the free pages
> > > > information from the guest through virtio.
> > > >
> > > > After getting the free pages information (a bitmap), QEMU can use it
> > > > to filter out the guest's free pages in the ram bulk stage. This
> > > > make the live migration process much more efficient.
> > >
> > > Hi,
> > >   An interesting solution; I know a few different people have been
> > > looking at how to speed up ballooned VM migration.
> > >
> > >   I wonder if it would be possible to avoid the kernel changes by
> > > parsing /proc/self/pagemap - if that can be used to detect
> > > unmapped/zero mapped pages in the guest ram, would it achieve the
> > same result?
> > 
> > Yes I was about to suggest the same thing: it's simple and makes use of the
> > existing infrastructure.  And you wouldn't need to care if the pages were
> > unmapped by ballooning or anything else (alternative balloon
> > implementations, not yet touched by the guest, etc.).  Besides, you wouldn't
> > need to synchronize with the guest.
> > 
> > Roman.
> 
> The unmapped/zero mapped pages can be detected by parsing /proc/self/pagemap,
> but the free pages can't be detected by this. Imaging an application allocates a large amount
> of memory , after using, it frees the memory, then live migration happens. All these free pages
> will be process and sent to the destination, it's not optimal.

First, the likelihood of such a situation is marginal, there's no point
optimizing for it specifically.

And second, even if that happens, you inflate the balloon right before
the migration and the free memory will get umapped very quickly, so this
case is covered nicely by the same technique that works for more
realistic cases, too.

Roman.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
