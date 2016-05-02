Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 581786B0005
	for <linux-mm@kvack.org>; Mon,  2 May 2016 14:43:11 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id a5so8995861vkg.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 11:43:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c111si15622397qge.21.2016.05.02.11.43.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 11:43:10 -0700 (PDT)
Date: Mon, 2 May 2016 19:41:14 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: GUP guarantees wrt to userspace mappings redesign
Message-ID: <20160502174114.GA15417@redhat.com>
References: <20160428204542.5f2053f7@ul30vt.home> <20160429070611.GA4990@node.shutemov.name> <20160429163444.GM11700@redhat.com> <20160502104119.GA23305@node.shutemov.name> <20160502111513.GA4079@gmail.com> <20160502121402.GB23305@node.shutemov.name> <20160502141538.GA5961@redhat.com> <20160502162128.GF24419@node.shutemov.name> <20160502162211.GA11678@redhat.com> <20160502180303.GA26252@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160502180303.GA26252@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jerome Glisse <j.glisse@gmail.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 05/02, Kirill A. Shutemov wrote:
>
> On Mon, May 02, 2016 at 06:22:11PM +0200, Oleg Nesterov wrote:

> > > So we have pages pinned by a driver and the driver expects the pinned
> > > pages to be mapped into userspace, then __replace_page() kicks in and put
> > > different page there -- driver's expectation is broken.
> >
> > Yes... but I don't understand the problem space. I mean, I do not know why
> > this driver should expect this, how it can be broken, etc.
> >
> > I do not even understand why "initiated by other process" can make any
> > difference... Unless this driver somehow controls all threads which could
> > have this page mapped.
>
> Okay, my understanding is following:
>
> Some drivers (i.e. vfio) rely on get_user_page{,_fast}() to pin the memory
> and expect pinned pages to be mapped into userspace until the pin is gone.
> This memory is used to communicate between kernel and userspace.

Thanks Kirill.

Then I think uprobes should be fine,

> I don't think there's something to fix on uprobe side. It's part of
> debugging interface. Debuggers can be destructive, nothing new there.

Yes, exactly. And as for uprobes in particular, __replace_page() can
only be called of vma->vm_file and and the mapping is private/executable,
VM_MAYSHARE must not be set.

Unlikely userspace can read or write to this memory to communicate with
kernel or something else.

Thanks,

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
