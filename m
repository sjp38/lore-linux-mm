Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 61D2A6B0007
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 21:55:30 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id m2-v6so8873373qti.2
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 18:55:30 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k10-v6si429524qtb.84.2018.06.25.18.55.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jun 2018 18:55:29 -0700 (PDT)
Date: Tue, 26 Jun 2018 04:55:26 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v33 1/4] mm: add a function to get free page blocks
Message-ID: <20180626045118-mutt-send-email-mst@kernel.org>
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
 <1529037793-35521-2-git-send-email-wei.w.wang@intel.com>
 <CA+55aFzhuGKinEq5udPsk_uYHShkQxJYqcPO=tLCkT-oxpsgPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzhuGKinEq5udPsk_uYHShkQxJYqcPO=tLCkT-oxpsgPg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, Rik van Riel <riel@redhat.com>, peterx@redhat.com

On Sat, Jun 16, 2018 at 08:08:53AM +0900, Linus Torvalds wrote:
> On Fri, Jun 15, 2018 at 2:08 PM Wei Wang <wei.w.wang@intel.com> wrote:
> >
> > This patch adds a function to get free pages blocks from a free page
> > list. The obtained free page blocks are hints about free pages, because
> > there is no guarantee that they are still on the free page list after
> > the function returns.

...

> > +uint32_t get_from_free_page_list(int order, __le64 buf[], uint32_t size)

...

> 
> Ack. This is the kind of simple interface where I don't need to worry
> about the MM code calling out to random drivers or subsystems.
> 
> I think that "order" should be checked for validity, but from a MM
> standpoint I think this is fine.
> 
>                 Linus

The only issue seems to be getting hold of buf that's large enough -
and we don't really know what the size is, or whether one
buf would be enough.

Linus, do you think it would be ok to have get_from_free_page_list
actually pop entries from the free list and use them as the buffer
to store PAs?

Caller would be responsible for freeing the returned entries.

-- 
MST
