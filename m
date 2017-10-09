Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A483C6B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 02:48:17 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t63so18514688pfi.5
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 23:48:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z123si5661146pgb.142.2017.10.08.23.48.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 08 Oct 2017 23:48:16 -0700 (PDT)
Date: Mon, 9 Oct 2017 08:48:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: shm: round up tmpfs size to huge page size when
 huge=always
Message-ID: <20171009064811.lmotdeuewfbznhzq@dhcp22.suse.cz>
References: <1507321330-22525-1-git-send-email-yang.s@alibaba-inc.com>
 <20171008125651.3mxiayuvuqi2hiku@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171008125651.3mxiayuvuqi2hiku@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Yang Shi <yang.s@alibaba-inc.com>, kirill.shutemov@linux.intel.com, hughd@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 08-10-17 15:56:51, Kirill A. Shutemov wrote:
> On Sat, Oct 07, 2017 at 04:22:10AM +0800, Yang Shi wrote:
> > When passing "huge=always" option for mounting tmpfs, THP is supposed to
> > be allocated all the time when it can fit, but when the available space is
> > smaller than the size of THP (2MB on x86), shmem fault handler still tries
> > to allocate huge page every time, then fallback to regular 4K page
> > allocation, i.e.:
> > 
> > 	# mount -t tmpfs -o huge,size=3000k tmpfs /tmp
> > 	# dd if=/dev/zero of=/tmp/test bs=1k count=2048
> > 	# dd if=/dev/zero of=/tmp/test1 bs=1k count=2048
> > 
> > The last dd command will handle 952 times page fault handler, then exit
> > with -ENOSPC.
> > 
> > Rounding up tmpfs size to THP size in order to use THP with "always"
> > more efficiently. And, it will not wast too much memory (just allocate
> > 511 extra pages in worst case).
> 
> Hm. I don't think it's good idea to silently increase size of fs.

Agreed!

> Maybe better just refuse to mount with huge=always for too small fs?

We cannot we simply have the remaining page !THP? What is the actual
problem?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
