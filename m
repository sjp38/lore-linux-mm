Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFB716B000D
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 18:44:10 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a64-v6so6222326pfg.16
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 15:44:10 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f25-v6si11462725pgb.170.2018.10.10.15.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 15:44:09 -0700 (PDT)
Date: Wed, 10 Oct 2018 16:40:51 -0600
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 1/6] mm/gup_benchmark: Time put_page
Message-ID: <20181010224051.GB11034@localhost.localdomain>
References: <20181010195605.10689-1-keith.busch@intel.com>
 <20181010152655.8510270e5db753f6666f12d3@linux-foundation.org>
 <20181010222843.GA11034@localhost.localdomain>
 <20181010154111.e3b37422f31dcf3d6b73ebe0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010154111.e3b37422f31dcf3d6b73ebe0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Oct 10, 2018 at 03:41:11PM -0700, Andrew Morton wrote:
> On Wed, 10 Oct 2018 16:28:43 -0600 Keith Busch <keith.busch@intel.com> wrote:
> 
> > > >  struct gup_benchmark {
> > > > -	__u64 delta_usec;
> > > > +	__u64 get_delta_usec;
> > > > +	__u64 put_delta_usec;
> > > >  	__u64 addr;
> > > >  	__u64 size;
> > > >  	__u32 nr_pages_per_call;
> > > 
> > > If we move put_delta_usec to the end of this struct, the ABI remains
> > > back-compatible?
> > 
> > If the kernel writes to a new value appended to the end of the struct,
> > and the application allocated the older sized struct, wouldn't that
> > corrupt the user memory?
> 
> Looks like it.  How about we do this while we're breaking it?

Yep, that sounds good to me!
 
> --- a/mm/gup_benchmark.c~mm-gup_benchmark-time-put_page-fix
> +++ a/mm/gup_benchmark.c
> @@ -14,6 +14,7 @@ struct gup_benchmark {
>  	__u64 size;
>  	__u32 nr_pages_per_call;
>  	__u32 flags;
> +	__u64 expansion[10];	/* For future use */
>  };
>  
>  static int __gup_benchmark_ioctl(unsigned int cmd,
> 
