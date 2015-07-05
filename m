Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 442D8280291
	for <linux-mm@kvack.org>; Sun,  5 Jul 2015 11:44:49 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so264536965wiw.0
        for <linux-mm@kvack.org>; Sun, 05 Jul 2015 08:44:48 -0700 (PDT)
Received: from johanna2.inet.fi (mta-out1.inet.fi. [62.71.2.229])
        by mx.google.com with ESMTP id df4si47477753wib.111.2015.07.05.08.44.46
        for <linux-mm@kvack.org>;
        Sun, 05 Jul 2015 08:44:47 -0700 (PDT)
Date: Sun, 5 Jul 2015 18:44:41 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: avoid setting up anonymous pages into file mapping
Message-ID: <20150705154441.GA4682@node.dhcp.inet.fi>
References: <1435932447-84377-1-git-send-email-kirill.shutemov@linux.intel.com>
 <55994A08.3030308@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55994A08.3030308@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Sun, Jul 05, 2015 at 06:15:20PM +0300, Boaz Harrosh wrote:
> On 07/03/2015 05:07 PM, Kirill A. Shutemov wrote:
> > Reading page fault handler code I've noticed that under right
> > circumstances kernel would map anonymous pages into file mappings:
> > if the VMA doesn't have vm_ops->fault() and the VMA wasn't fully
> > populated on ->mmap(), kernel would handle page fault to not populated
> > pte with do_anonymous_page().
> > 
> > There's chance that it was done intentionally, but I don't see good
> > justification for this. We just hide bugs in broken drivers.
> > 
> 
> Have you done a preliminary audit for these broken drivers? If they actually
> exist in-tree then this patch is a regression for them.

No, I didn't check drivers.

On other hand, if such driver exists it has security issue. If you're
able to setup zero page into file mapping, you can make it writable with
security implications.

> We need to look for vm_ops without an .fault = . Perhaps define a
> map_annonimous() for those to revert to the old behavior, if any
> actually exist.

No. Drivers should be fixed properly.

> > Let's change page fault handler to use do_anonymous_page() only on
> > anonymous VMA (->vm_ops == NULL).
> > 
> > For file mappings without vm_ops->fault() page fault on pte_none() entry
> > would lead to SIGBUS.
> > 
> 
> Again that could mean a theoretical regression for some in-tree driver,
> do you know of any such driver?

I did very little testing with the patch: boot kvm with Fedora and run
trinity there for a while. More testing is required.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
