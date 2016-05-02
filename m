Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA6EF6B0005
	for <linux-mm@kvack.org>; Mon,  2 May 2016 14:03:07 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 68so146946653lfq.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 11:03:07 -0700 (PDT)
Received: from mail-lf0-x236.google.com (mail-lf0-x236.google.com. [2a00:1450:4010:c07::236])
        by mx.google.com with ESMTPS id p10si13269906lfi.16.2016.05.02.11.03.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 11:03:06 -0700 (PDT)
Received: by mail-lf0-x236.google.com with SMTP id y84so196842825lfc.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 11:03:06 -0700 (PDT)
Date: Mon, 2 May 2016 21:03:03 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: GUP guarantees wrt to userspace mappings redesign
Message-ID: <20160502180303.GA26252@node.shutemov.name>
References: <20160429005106.GB2847@node.shutemov.name>
 <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
 <20160502104119.GA23305@node.shutemov.name>
 <20160502111513.GA4079@gmail.com>
 <20160502121402.GB23305@node.shutemov.name>
 <20160502141538.GA5961@redhat.com>
 <20160502162128.GF24419@node.shutemov.name>
 <20160502162211.GA11678@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160502162211.GA11678@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 02, 2016 at 06:22:11PM +0200, Oleg Nesterov wrote:
> On 05/02, Kirill A. Shutemov wrote:
> >
> > On Mon, May 02, 2016 at 04:15:38PM +0200, Oleg Nesterov wrote:
> > > >
> > > >  - I don't see any check page_count() around __replace_page() in uprobes,
> > > >    so it can easily replace pinned page.
> > >
> > > Why it should? even if it races with get_user_pages_fast()... this doesn't
> > > differ from the case when an application writes to MAP_PRIVATE non-anonymous
> > > region, no?
> >
> > < I know nothing about uprobes or ptrace in general >
> >
> > I think the difference is that the write is initiated by the process
> > itself, but IIUC __replace_page() can be initiated by other process, so
> > it's out of control of the application.
> 
> Yes. Just like gdb can insert a breakpoint into the read-only executable vma.
> 
> > So we have pages pinned by a driver and the driver expects the pinned
> > pages to be mapped into userspace, then __replace_page() kicks in and put
> > different page there -- driver's expectation is broken.
> 
> Yes... but I don't understand the problem space. I mean, I do not know why
> this driver should expect this, how it can be broken, etc.
> 
> I do not even understand why "initiated by other process" can make any
> difference... Unless this driver somehow controls all threads which could
> have this page mapped.

Okay, my understanding is following:

Some drivers (i.e. vfio) rely on get_user_page{,_fast}() to pin the memory
and expect pinned pages to be mapped into userspace until the pin is gone.
This memory is used to communicate between kernel and userspace.

This kinda works unless an application does something that can change page
tables in the area: fork() (due CoW), mremap(), munmap(), MADV_DONTNEED,
etc.

This model is really fragile, but the application has (kinda) control over
the situation: if it's very careful, it can keep the mapping intact.

With __replace_page() situation is different: it can be triggered from
outside of process and therefore out of control of the application.

I don't think there's something to fix on uprobe side. It's part of
debugging interface. Debuggers can be destructive, nothing new there.
I just tried to find the cases why this usage of GUP is not correct...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
