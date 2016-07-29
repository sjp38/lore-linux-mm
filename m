Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 408786B0265
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 15:48:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w128so133535151pfd.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 12:48:29 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id u9si19820227pfi.142.2016.07.29.12.48.28
        for <linux-mm@kvack.org>;
        Fri, 29 Jul 2016 12:48:28 -0700 (PDT)
Subject: Re: [virtio-dev] Re: [PATCH v2 repost 4/7] virtio-balloon: speed up
 inflate/deflate process
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
 <5798DB49.7030803@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E04213CCB@shsmsx102.ccr.corp.intel.com>
 <20160728044000-mutt-send-email-mst@kernel.org>
 <F2CBF3009FA73547804AE4C663CAB28E04214103@shsmsx102.ccr.corp.intel.com>
 <20160729003759-mutt-send-email-mst@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <579BB30B.2040704@intel.com>
Date: Fri, 29 Jul 2016 12:48:27 -0700
MIME-Version: 1.0
In-Reply-To: <20160729003759-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, "Li, Liang Z" <liang.z.li@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

On 07/28/2016 02:51 PM, Michael S. Tsirkin wrote:
>> > If 1MB is too big, how about 512K, or 256K?  32K seems too small.
>> > 
> It's only small because it makes you rescan the free list.
> So maybe you should do something else.
> I looked at it a bit. Instead of scanning the free list, how about
> scanning actual page structures? If page is unused, pass it to host.
> Solves the problem of rescanning multiple times, does it not?

FWIW, I think the new data structure needs some work.

Before, we had a potentially very long list of 4k areas.  Now, we've
just got a very large bitmap.  The bitmap might not even be very dense
if we are ballooning relatively few things.

Can I suggest an alternate scheme?  I think you actually need a hybrid
scheme that has bitmaps but also allows more flexibility in the pfn
ranges.  The payload could be a number of records each containing 3 things:

	pfn, page order, length of bitmap (maybe in powers of 2)

Each record is followed by the bitmap.  Or, if the bitmap length is 0,
immediately followed by another record.  A bitmap length of 0 implies a
bitmap with the least significant bit set.  Page order specifies how
many pages each bit represents.

This scheme could easily encode the new data structure you are proposing
by just setting pfn=0, order=0, and a very long bitmap length.  But, it
could handle sparse bitmaps much better *and* represent large pages much
more efficiently.

There's plenty of space to fit a whole record in 64 bits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
