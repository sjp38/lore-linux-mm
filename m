Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id DC9066B0253
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 10:55:44 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b81so102748688lfe.1
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 07:55:44 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id n75si19091624lfi.173.2016.10.17.07.55.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 07:55:43 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id l131so24212851lfl.0
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 07:55:43 -0700 (PDT)
Date: Mon, 17 Oct 2016 17:55:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] shmem: avoid huge pages for small files
Message-ID: <20161017145539.GA26930@node.shutemov.name>
References: <20161017121809.189039-1-kirill.shutemov@linux.intel.com>
 <20161017123021.rlyz44dsf4l4xnve@black.fi.intel.com>
 <20161017141245.GC27459@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161017141245.GC27459@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 17, 2016 at 04:12:46PM +0200, Michal Hocko wrote:
> On Mon 17-10-16 15:30:21, Kirill A. Shutemov wrote:
> [...]
> > >From fd0b01b9797ddf2bef308c506c42d3dd50f11793 Mon Sep 17 00:00:00 2001
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Date: Mon, 17 Oct 2016 14:44:47 +0300
> > Subject: [PATCH] shmem: avoid huge pages for small files
> > 
> > Huge pages are detrimental for small file: they causes noticible
> > overhead on both allocation performance and memory footprint.
> > 
> > This patch aimed to address this issue by avoiding huge pages until file
> > grown to specified size. This would cover most of the cases where huge
> > pages causes regressions in performance.
> > 
> > By default the minimal file size to allocate huge pages is equal to size
> > of huge page.
> 
> ok
> 
> > We add two handle to specify minimal file size for huge pages:
> > 
> >   - mount option 'huge_min_size';
> > 
> >   - sysfs file /sys/kernel/mm/transparent_hugepage/shmem_min_size for
> >     in-kernel tmpfs mountpoint;
> 
> Could you explain who might like to change the minimum value (other than
> disable the feautre for the mount point) and for what reason?

Depending on how well CPU microarchitecture deals with huge pages, you
might need to set it higher in order to balance out overhead with benefit
of huge pages.

In other case, if it's known in advance that specific mount would be
populated with large files, you might want to set it to zero to get huge
pages allocated from the beginning.

> > @@ -238,6 +238,12 @@ values:
> >    - "force":
> >      Force the huge option on for all - very useful for testing;
> >  
> > +Tehre's limit on minimal file size before kenrel starts allocate huge
> > +pages for it. By default it's size of huge page.
> 
> Smoe tyopse

Wlil fxi!

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
