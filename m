Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 399B36B0038
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 10:14:04 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d123so26096071pfd.0
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 07:14:04 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id l33si25751008pld.26.2017.02.03.07.14.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 07:14:03 -0800 (PST)
Date: Fri, 3 Feb 2017 07:13:59 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Avoid returning VM_FAULT_RETRY from ->page_mkwrite
 handlers
Message-ID: <20170203151356.GB2267@bombadil.infradead.org>
References: <20170203150729.15863-1-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170203150729.15863-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, lustre-devel@lists.lustre.org, cluster-devel@redhat.com

On Fri, Feb 03, 2017 at 04:07:29PM +0100, Jan Kara wrote:
> Some ->page_mkwrite handlers may return VM_FAULT_RETRY as its return
> code (GFS2 or Lustre can definitely do this). However VM_FAULT_RETRY
> from ->page_mkwrite is completely unhandled by the mm code and results
> in locking and writeably mapping the page which definitely is not what
> the caller wanted. Fix Lustre and block_page_mkwrite_ret() used by other
> filesystems (notably GFS2) to return VM_FAULT_NOPAGE instead which
> results in bailing out from the fault code, the CPU then retries the
> access, and we fault again effectively doing what the handler wanted.

Reading this commit message makes me wonder if this is the best fix.
It would seem logical that if I want the fault to be retried that I should
return VM_FAULT_RETRY, not VM_FAULT_NOPAGE.  Why don't we have the MM
treat VM_FAULT_RETRY the same way that it treats VM_FAULT_NOPAGE and give
driver / filesystem writers one fewer way to shoot themselves in the foot?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
