Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 31DCC6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 12:21:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r12so81948064wme.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 09:21:32 -0700 (PDT)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id ub9si9440560lbb.87.2016.05.02.09.21.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 09:21:31 -0700 (PDT)
Received: by mail-lf0-x22b.google.com with SMTP id y84so193546464lfc.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 09:21:30 -0700 (PDT)
Date: Mon, 2 May 2016 19:21:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: GUP guarantees wrt to userspace mappings redesign
Message-ID: <20160502162128.GF24419@node.shutemov.name>
References: <20160428125808.29ad59e5@t450s.home>
 <20160428232127.GL11700@redhat.com>
 <20160429005106.GB2847@node.shutemov.name>
 <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
 <20160502104119.GA23305@node.shutemov.name>
 <20160502111513.GA4079@gmail.com>
 <20160502121402.GB23305@node.shutemov.name>
 <20160502141538.GA5961@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160502141538.GA5961@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 02, 2016 at 04:15:38PM +0200, Oleg Nesterov wrote:
> I am sure I missed the problem, but...
> 
> On 05/02, Kirill A. Shutemov wrote:
> >
> > Quick look around:
> >
> >  - I don't see any check page_count() around __replace_page() in uprobes,
> >    so it can easily replace pinned page.
> 
> Why it should? even if it races with get_user_pages_fast()... this doesn't
> differ from the case when an application writes to MAP_PRIVATE non-anonymous
> region, no?

< I know nothing about uprobes or ptrace in general >

I think the difference is that the write is initiated by the process
itself, but IIUC __replace_page() can be initiated by other process, so
it's out of control of the application.

So we have pages pinned by a driver and the driver expects the pinned
pages to be mapped into userspace, then __replace_page() kicks in and put
different page there -- driver's expectation is broken.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
