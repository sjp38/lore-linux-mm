Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4766B0088
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 08:54:01 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so8506689pdi.2
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 05:54:01 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id s3si20162533pbo.2.2014.03.11.05.53.59
        for <linux-mm@kvack.org>;
        Tue, 11 Mar 2014 05:53:59 -0700 (PDT)
Date: Tue, 11 Mar 2014 08:53:57 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v6 06/22] Replace XIP read and write with DAX I/O
Message-ID: <20140311125357.GA7580@linux.intel.com>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
 <1393337918-28265-7-git-send-email-matthew.r.wilcox@intel.com>
 <1394497958.6784.204.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394497958.6784.204.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, Mar 10, 2014 at 06:32:38PM -0600, Toshi Kani wrote:
> On Tue, 2014-02-25 at 09:18 -0500, Matthew Wilcox wrote:
> > Use the generic AIO infrastructure instead of custom read and write
> > methods.  In addition to giving us support for AIO, this adds the missing
> > locking between read() and truncate().
> > 
>  :
> > +static void dax_new_buf(void *addr, unsigned size, unsigned first,
> > +					loff_t offset, loff_t end, int rw)
> > +{
> > +	loff_t final = end - offset;	/* The final byte in this buffer */
> 
> I may be missing something, but shouldn't it take first into account?
> 
> 	loff_t final = end - offset + first;

Yes it should.  Thanks!  (Fortunately, this is only a performance problem
as we'll end up zeroing more than we ought to, which is fine as it will
be overwritten by the copy_from_user later)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
