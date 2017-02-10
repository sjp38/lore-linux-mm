Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 722336B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:53:06 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id b145so31642825pfb.3
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 06:53:06 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 23si1876861pfi.14.2017.02.10.06.53.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 06:53:05 -0800 (PST)
Date: Fri, 10 Feb 2017 06:51:58 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCHv6 11/37] HACK: readahead: alloc huge pages, if allowed
Message-ID: <20170210145158.GA2267@bombadil.infradead.org>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
 <20170126115819.58875-12-kirill.shutemov@linux.intel.com>
 <20170209233436.GZ2267@bombadil.infradead.org>
 <7D35EB8E-29F8-41DA-BB46-8BCF7B6C5A72@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7D35EB8E-29F8-41DA-BB46-8BCF7B6C5A72@dilger.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Feb 09, 2017 at 05:23:31PM -0700, Andreas Dilger wrote:
> On Feb 9, 2017, at 4:34 PM, Matthew Wilcox <willy@infradead.org> wrote:
> > Well ... what if we made readahead 2 hugepages in size for inodes which
> > are using huge pages?  That's only 8x our current readahead window, and
> > if you're asking for hugepages, you're accepting that IOs are going to
> > be larger, and you probably have the kind of storage system which can
> > handle doing larger IOs.
> 
> It would be nice if the bdi had a parameter for the maximum readahead size.
> Currently, readahead is capped at 2MB chunks by force_page_cache_readahead()
> even if bdi->ra_pages and bdi->io_pages are much larger.
> 
> It should be up to the filesystem to decide how large the readahead chunks
> are rather than imposing some policy in the MM code.  For high-speed (network)
> storage access it is better to have at least 4MB read chunks, for RAID storage
> it is desirable to have stripe-aligned readahead to avoid read inflation when
> verifying the parity.  Any fixed size will eventually be inadequate as disks
> and filesystems change, so it may as well be a per-bdi tunable that can be set
> by the filesystem as needed, or possibly with a mount option if needed.

I think the filesystem should provide a hint, but ultimately it needs to
be up to the MM to decide how far to readahead.  The filesystem doesn't
(and shouldn't) have the global view into how much memory is available
for readahead, nor should it be tracking how well this app is being
served by readahead.

That 2MB chunk restriction is allegedly there "so that we don't pin too
much memory at once".  Maybe that should be scaled with the amount of
memory in the system (pinning 2MB of a 256MB system is a bit different
from pinning 2MB of a 1TB memory system).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
