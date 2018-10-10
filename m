Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 94E526B000A
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 18:41:13 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e6-v6so4764236pge.5
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 15:41:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gn7si24710063plb.264.2018.10.10.15.41.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 15:41:12 -0700 (PDT)
Date: Wed, 10 Oct 2018 15:41:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/6] mm/gup_benchmark: Time put_page
Message-Id: <20181010154111.e3b37422f31dcf3d6b73ebe0@linux-foundation.org>
In-Reply-To: <20181010222843.GA11034@localhost.localdomain>
References: <20181010195605.10689-1-keith.busch@intel.com>
	<20181010152655.8510270e5db753f6666f12d3@linux-foundation.org>
	<20181010222843.GA11034@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, 10 Oct 2018 16:28:43 -0600 Keith Busch <keith.busch@intel.com> wrote:

> > >  struct gup_benchmark {
> > > -	__u64 delta_usec;
> > > +	__u64 get_delta_usec;
> > > +	__u64 put_delta_usec;
> > >  	__u64 addr;
> > >  	__u64 size;
> > >  	__u32 nr_pages_per_call;
> > 
> > If we move put_delta_usec to the end of this struct, the ABI remains
> > back-compatible?
> 
> If the kernel writes to a new value appended to the end of the struct,
> and the application allocated the older sized struct, wouldn't that
> corrupt the user memory?

Looks like it.  How about we do this while we're breaking it?

--- a/mm/gup_benchmark.c~mm-gup_benchmark-time-put_page-fix
+++ a/mm/gup_benchmark.c
@@ -14,6 +14,7 @@ struct gup_benchmark {
 	__u64 size;
 	__u32 nr_pages_per_call;
 	__u32 flags;
+	__u64 expansion[10];	/* For future use */
 };
 
 static int __gup_benchmark_ioctl(unsigned int cmd,
