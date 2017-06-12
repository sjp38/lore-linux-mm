Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CCA296B0292
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 12:28:09 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n40so44796856qtb.4
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 09:28:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d81si6198227qke.262.2017.06.12.09.28.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 09:28:08 -0700 (PDT)
Date: Mon, 12 Jun 2017 19:28:03 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v11 4/6] mm: function to offer a page block on the free
 list
Message-ID: <20170612181354-mutt-send-email-mst@kernel.org>
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-5-git-send-email-wei.w.wang@intel.com>
 <b92af473-f00e-b956-ea97-eb4626601789@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b92af473-f00e-b956-ea97-eb4626601789@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On Mon, Jun 12, 2017 at 07:10:12AM -0700, Dave Hansen wrote:
> Please stop cc'ing me on things also sent to closed mailing lists
> (virtio-dev@lists.oasis-open.org).  I'm happy to review things on open
> lists, but I'm not fond of the closed lists bouncing things at me.
> 
> On 06/09/2017 03:41 AM, Wei Wang wrote:
> > Add a function to find a page block on the free list specified by the
> > caller. Pages from the page block may be used immediately after the
> > function returns. The caller is responsible for detecting or preventing
> > the use of such pages.
> 
> This description doesn't tell me very much about what's going on here.
> Neither does the comment.
> 
> "Pages from the page block may be used immediately after the
>  function returns".
> 
> Used by who?  Does the "may" here mean that it is OK, or is it a warning
> that the contents will be thrown away immediately?

I agree here. Don't tell callers what they should do, say what does the
function does. "offer" also confuses. Here's a better comment

--->
mm: support reporting free page blocks

This adds support for reporting blocks of pages on the free list
specified by the caller.

As pages can leave the free list during this call or immediately
afterwards, they are not guaranteed to be free after the function
returns. The only guarantee this makes is that the page was on the free
list at some point in time after the function has been invoked.

Therefore, it is not safe for caller to use any pages on the returned
block or to discard data that is put there after the function returns.
However, it is safe for caller to discard data that was in one of these
pages before the function was invoked.

---

And repeat the last part in a code comment:

 * Note: it is not safe for caller to use any pages on the returned
 * block or to discard data that is put there after the function returns.
 * However, it is safe for caller to discard data that was in one of these
 * pages before the function was invoked.


> The hypervisor is going to throw away the contents of these pages,
> right?

It should be careful and only throw away contents that was there before
report_unused_page_block was invoked.  Hypervisor is responsible for not
corrupting guest memory.  But that's not something an mm patch should
worry about.

>  As soon as the spinlock is released, someone can allocate a
> page, and put good data in it.  What keeps the hypervisor from throwing
> away good data?

API should require this explicitly. Hopefully above answers this question.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
