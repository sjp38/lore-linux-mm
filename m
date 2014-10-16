Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 33E7D6B006C
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 10:12:14 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id q1so2964022lam.18
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 07:12:13 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id lv8si34965376lac.74.2014.10.16.07.12.11
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 07:12:12 -0700 (PDT)
Date: Thu, 16 Oct 2014 14:12:06 +0000 (UTC)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Message-ID: <837939598.10389.1413468726146.JavaMail.zimbra@efficios.com>
In-Reply-To: <20141016135903.GA11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com> <1411677218-29146-7-git-send-email-matthew.r.wilcox@intel.com> <20141016133355.GT19075@thinkos.etherlink> <20141016135903.GA11522@wil.cx>
Subject: Re: [PATCH v11 06/21] vfs: Add copy_to_iter(), copy_from_iter() and
 iov_iter_zero()
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

----- Original Message -----
> From: "Matthew Wilcox" <willy@linux.intel.com>
> To: "Mathieu Desnoyers" <mathieu.desnoyers@efficios.com>
> Cc: "Matthew Wilcox" <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
> linux-kernel@vger.kernel.org, "Matthew Wilcox" <willy@linux.intel.com>
> Sent: Thursday, October 16, 2014 3:59:03 PM
> Subject: Re: [PATCH v11 06/21] vfs: Add copy_to_iter(), copy_from_iter() and iov_iter_zero()
> 
> On Thu, Oct 16, 2014 at 03:33:55PM +0200, Mathieu Desnoyers wrote:
> > > +static size_t copy_to_iter_iovec(void *from, size_t bytes, struct
> > > iov_iter *i)
> > > +{
> [...]
> > > +	left = __copy_to_user(buf, from, copy);
> > 
> > How comes this function uses __copy_to_user without any access_ok()
> > check ? This has security implications.
> 
> The access_ok() check is done higher up the call-chain if it's appropriate.
> These functions can be (intentionally) called to access kernel addresses,
> so it wouldn't be appropriate to do that here.

If the access_ok() are expected to be already done higher in the call-chain,
we might want to rename e.g. copy_to_iter_iovec to
__copy_to_iter_iovec(). It helps clarifying the check expectations for the
caller.

> 
> > > +static size_t copy_page_to_iter_bvec(struct page *page, size_t offset,
> > > +					size_t bytes, struct iov_iter *i)
> > > +{
> > > +	void *kaddr = kmap_atomic(page);
> > > +	size_t wanted = copy_to_iter_bvec(kaddr + offset, bytes, i);
> > 
> > missing newline.
> > 
> > > +	kunmap_atomic(kaddr);
> > > +	return wanted;
> > > +}
> 
> Are you seriously suggesting that:
> 
> static size_t copy_page_to_iter_bvec(struct page *page, size_t offset,
>                                         size_t bytes, struct iov_iter *i)
> {
>         void *kaddr = kmap_atomic(page);
>         size_t wanted = copy_to_iter_bvec(kaddr + offset, bytes, i);
> 
>         kunmap_atomic(kaddr);
>         return wanted;
> }
> 
> is more readable than without the newline?  I can see the point of the
> rule for functions with a lot of variables, or a lot of lines, but I
> don't see the point of it for such a small function.

I usually find it easier to read when variables and code are split,
but I don't feel strongly about this in this particular case.

> 
> In any case, this patch is now upstream, so I shan't be proposing any
> stylistic changes for it.

The leading __ prefix before the function names appears to be important
enough though, since it allows future changes of this code to take into
account the specific check expectations of those functions.

Thanks,

Mathieu


-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
