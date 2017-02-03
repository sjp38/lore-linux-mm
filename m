Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1FF576B0033
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 10:53:42 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 14so26573470pgg.4
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 07:53:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m22si25817247pli.290.2017.02.03.07.53.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 07:53:41 -0800 (PST)
Date: Fri, 3 Feb 2017 07:53:26 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Avoid returning VM_FAULT_RETRY from ->page_mkwrite
 handlers
Message-ID: <20170203155326.GE2267@bombadil.infradead.org>
References: <20170203150729.15863-1-jack@suse.cz>
 <20170203151356.GB2267@bombadil.infradead.org>
 <20170203154640.GA25586@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170203154640.GA25586@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, lustre-devel@lists.lustre.org, cluster-devel@redhat.com

On Fri, Feb 03, 2017 at 04:46:40PM +0100, Jan Kara wrote:
> On Fri 03-02-17 07:13:59, Matthew Wilcox wrote:
> > On Fri, Feb 03, 2017 at 04:07:29PM +0100, Jan Kara wrote:
> > > Some ->page_mkwrite handlers may return VM_FAULT_RETRY as its return
> > > code (GFS2 or Lustre can definitely do this). However VM_FAULT_RETRY
> > > from ->page_mkwrite is completely unhandled by the mm code and results
> > > in locking and writeably mapping the page which definitely is not what
> > > the caller wanted. Fix Lustre and block_page_mkwrite_ret() used by other
> > > filesystems (notably GFS2) to return VM_FAULT_NOPAGE instead which
> > > results in bailing out from the fault code, the CPU then retries the
> > > access, and we fault again effectively doing what the handler wanted.
> > 
> > Reading this commit message makes me wonder if this is the best fix.
> > It would seem logical that if I want the fault to be retried that I should
> > return VM_FAULT_RETRY, not VM_FAULT_NOPAGE.  Why don't we have the MM
> > treat VM_FAULT_RETRY the same way that it treats VM_FAULT_NOPAGE and give
> > driver / filesystem writers one fewer way to shoot themselves in the foot?
> 
> VM_FAULT_RETRY is special, it may be used only if FAULT_FLAG_ALLOW_RETRY
> was set in page fault flags and it means - we have dropped mmap_sem, we
> loaded page needed to satisfy the fault and now we need to try again (have
> a look at __lock_page_or_retry()). I have my reservations about this
> interface but it works...

Oh, I understand what it's *supposed* to be used for ;-)  It's just
a bit of an attractive nuisance.  Maybe renaming it to something like
VM_FAULT_PAGE_RETRY would stop people from thinking that it meant "retry
the fault".  And we could #define VM_FAULT_RETRY VM_FAULT_NOPAGE so that
people who want to retry the fault in a normal way could use a return
value that sounds like it does what they want instead of a return value
that is supposed to be used to indicate that we put a PFN into the
page table?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
