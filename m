Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A45BC6B000C
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 04:13:20 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12-v6so10525294edi.12
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 01:13:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i12-v6si2976943edk.208.2018.07.12.01.13.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 01:13:19 -0700 (PDT)
Date: Thu, 12 Jul 2018 10:13:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v35 1/5] mm: support to get hints of free page blocks
Message-ID: <20180712081317.GD32648@dhcp22.suse.cz>
References: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com>
 <1531215067-35472-2-git-send-email-wei.w.wang@intel.com>
 <CA+55aFz9a=D-kquM=sG5uhV_HrBAw+VAhcJmtPNz+howy4j9ow@mail.gmail.com>
 <5B455D50.90902@intel.com>
 <CA+55aFzqj8wxXnHAdUTiOomipgFONVbqKMjL_tfk7e5ar1FziQ@mail.gmail.com>
 <20180711092152.GE20050@dhcp22.suse.cz>
 <CA+55aFwku2tDH4+rfaC67xc4-cEwSrXgnQaci=e2id5ZCRE9JQ@mail.gmail.com>
 <5B46BB46.2080802@intel.com>
 <CA+55aFxyv=EUAJFUSio=k+pm3ddteojshP7Radjia5ZRgm53zQ@mail.gmail.com>
 <5B46C258.40601@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5B46C258.40601@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Michael S. Tsirkin" <mst@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, Rik van Riel <riel@redhat.com>, peterx@redhat.com

On Thu 12-07-18 10:52:08, Wei Wang wrote:
> On 07/12/2018 10:30 AM, Linus Torvalds wrote:
> > On Wed, Jul 11, 2018 at 7:17 PM Wei Wang <wei.w.wang@intel.com> wrote:
> > > Would it be better to remove __GFP_THISNODE? We actually want to get all
> > > the guest free pages (from all the nodes).
> > Maybe. Or maybe it would be better to have the memory balloon logic be
> > per-node? Maybe you don't want to remove too much memory from one
> > node? I think it's one of those "play with it" things.
> > 
> > I don't think that's the big issue, actually. I think the real issue
> > is how to react quickly and gracefully to "oops, I'm trying to give
> > memory away, but now the guest wants it back" while you're in the
> > middle of trying to create that 2TB list of pages.
> 
> OK. virtio-balloon has already registered an oom notifier
> (virtballoon_oom_notify). I plan to add some control there. If oom happens,
> - stop the page allocation;
> - immediately give back the allocated pages to mm.

Please don't. Oom notifier is an absolutely hideous interface which
should go away sooner or later (I would much rather like the former) so
do not build a new logic on top of it. I would appreciate if you
actually remove the notifier much more.

You can give memory back from the standard shrinker interface. If we are
reaching low reclaim priorities then we are struggling to reclaim memory
and then you can start returning pages back.
-- 
Michal Hocko
SUSE Labs
