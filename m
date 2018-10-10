Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0C26B000A
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 18:31:48 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m4-v6so4741118pgv.15
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 15:31:48 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p188-v6si28274473pfg.197.2018.10.10.15.31.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 15:31:47 -0700 (PDT)
Date: Wed, 10 Oct 2018 16:28:43 -0600
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 1/6] mm/gup_benchmark: Time put_page
Message-ID: <20181010222843.GA11034@localhost.localdomain>
References: <20181010195605.10689-1-keith.busch@intel.com>
 <20181010152655.8510270e5db753f6666f12d3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010152655.8510270e5db753f6666f12d3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Oct 10, 2018 at 03:26:55PM -0700, Andrew Morton wrote:
> On Wed, 10 Oct 2018 13:56:00 -0600 Keith Busch <keith.busch@intel.com> wrote:
> 
> > We'd like to measure time to unpin user pages, so this adds a second
> > benchmark timer on put_page, separate from get_page.
> > 
> > Adding the field will breaks this ioctl ABI, but should be okay since
> > this an in-tree kernel selftest.
> > 
> > ...
> >
> > --- a/mm/gup_benchmark.c
> > +++ b/mm/gup_benchmark.c
> > @@ -8,7 +8,8 @@
> >  #define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
> >  
> >  struct gup_benchmark {
> > -	__u64 delta_usec;
> > +	__u64 get_delta_usec;
> > +	__u64 put_delta_usec;
> >  	__u64 addr;
> >  	__u64 size;
> >  	__u32 nr_pages_per_call;
> 
> If we move put_delta_usec to the end of this struct, the ABI remains
> back-compatible?

If the kernel writes to a new value appended to the end of the struct,
and the application allocated the older sized struct, wouldn't that
corrupt the user memory?
