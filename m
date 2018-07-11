Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 00B406B000A
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 00:04:09 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o18-v6so13642452qtm.11
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 21:04:09 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r76-v6si12186179qkl.279.2018.07.10.21.04.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 21:04:09 -0700 (PDT)
Date: Wed, 11 Jul 2018 07:04:01 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v35 1/5] mm: support to get hints of free page blocks
Message-ID: <20180711070318-mutt-send-email-mst@kernel.org>
References: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com>
 <1531215067-35472-2-git-send-email-wei.w.wang@intel.com>
 <CA+55aFz9a=D-kquM=sG5uhV_HrBAw+VAhcJmtPNz+howy4j9ow@mail.gmail.com>
 <20180711064709-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180711064709-mutt-send-email-mst@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, Rik van Riel <riel@redhat.com>, peterx@redhat.com

On Wed, Jul 11, 2018 at 07:00:37AM +0300, Michael S. Tsirkin wrote:
> On Tue, Jul 10, 2018 at 10:33:08AM -0700, Linus Torvalds wrote:
> > NAK.
> > 
> > On Tue, Jul 10, 2018 at 2:56 AM Wei Wang <wei.w.wang@intel.com> wrote:
> > >
> > > +
> > > +       buf_page = list_first_entry_or_null(pages, struct page, lru);
> > > +       if (!buf_page)
> > > +               return -EINVAL;
> > > +       buf = (__le64 *)page_address(buf_page);
> > 
> > Stop this garbage.
> > 
> > Why the hell would you pass in some crazy "liost of pages" that uses
> > that lru list?
> > 
> > That's just insane shit.
> > 
> > Just pass in a an array to fill in.
> > No idiotic games like this with
> > odd list entries (what's the locking?) and crazy casting to
> > 
> > So if you want an array of page addresses, pass that in as such. If
> > you want to do it in a page, do it with
> > 
> >     u64 *array = page_address(page);
> >     int nr = PAGE_SIZE / sizeof(u64);
> > 
> > and now you pass that array in to the thing. None of this completely
> > insane crazy crap interfaces.
> 
> Question was raised what to do if there are so many free
> MAX_ORDER pages that their addresses don't fit in a single MAX_ORDER
> page.

Oh you answered already, I spoke too soon. Nevermind, pls ignore me.
