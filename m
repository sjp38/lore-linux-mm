Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 432746B0006
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 17:32:28 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g26-v6so5096359pfo.7
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 14:32:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n34-v6si8939070pld.91.2018.07.06.14.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 14:32:27 -0700 (PDT)
Date: Fri, 6 Jul 2018 14:32:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/sparse.c: fix error path in sparse_add_one_section
Message-Id: <20180706143225.1cf9569f240dccf91bdc3788@linux-foundation.org>
In-Reply-To: <20180706190658.6873-1-ross.zwisler@linux.intel.com>
References: <CAOxpaSVkLh23jN_=0GpZ77EhKdAYaiWKkppnxWwf_MRa5FvopA@mail.gmail.com>
	<20180706190658.6873-1-ross.zwisler@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: pasha.tatashin@oracle.com, linux-nvdimm@lists.01.org, osalvador@techadventures.net, bhe@redhat.com, Dave Hansen <dave.hansen@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, osalvador@suse.de

On Fri,  6 Jul 2018 13:06:58 -0600 Ross Zwisler <ross.zwisler@linux.intel.com> wrote:

> commit 054620849110 ("mm/sparse.c: make sparse_init_one_section void and
> remove check")
> 
> changed how the error handling in sparse_add_one_section() works.
> 
> Previously sparse_index_init() could return -EEXIST, and the function would
> continue on happily.  'ret' would get unconditionally overwritten by the
> result from sparse_init_one_section() and the error code after the 'out:'
> label wouldn't be triggered.
> 
> With the above referenced commit, though, an -EEXIST error return from
> sparse_index_init() now takes us through the function and into the error
> case after 'out:'.  This eventually causes a kernel BUG, probably because
> we've just freed a memory section that we successfully set up and marked as
> present:

Thanks.

And gee it would be nice if some of this code was commented.  I
*assume* what's happening with that -EEXIST is that
sparse_add_one_section() is discovering that the root mem_section was
already initialized so things are OK.  Maybe.  My mind-reading skills
aren't so good on Fridays.

And sparse_index_init() sure looks like it needs locking to avoid races
around mem_section[root].  Or perhaps we're known to be single-threaded
here.
