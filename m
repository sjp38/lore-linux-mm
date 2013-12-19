Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3DCAA6B0036
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 14:19:18 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id i17so1339067qcy.37
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 11:19:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131219182920.GG30640@kvack.org>
References: <20131219040738.GA10316@redhat.com>
	<CA+55aFwweoGs3eGWXFULcqnbRbpDhpj2qrefXB5OpQOiWW8wYA@mail.gmail.com>
	<20131219155313.GA25771@redhat.com>
	<CA+55aFyoXCDNfHb+r5b=CgKQLPA1wrU_Tmh4ROZNEt5TPjpODA@mail.gmail.com>
	<20131219181134.GC25385@kmo-pixel>
	<20131219182920.GG30640@kvack.org>
Date: Fri, 20 Dec 2013 04:19:15 +0900
Message-ID: <CA+55aFzCo_r7ZGHk+zqUjmCW2w7-7z9oxEJjhR66tZ4qZPxnvw@mail.gmail.com>
Subject: Re: bad page state in 3.13-rc4
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Kent Overstreet <kmo@daterainc.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Al Viro <viro@zeniv.linux.org.uk>

On Thu, Dec 19, 2013 at 10:29 AM, Benjamin LaHaise <bcrl@kvack.org> wrote:
>
>> I don't understand this page migration stuff at all, and I actually
>> don't think I understand the refcounting w.r.t. the page cache either.
>> But looking at (say) the aio_free_ring() call at line 409 - we just did
>> one put_page() in aio_setup_ring(), and then _another_ put_page() in
>> aio_free_ring()... ok, one of those corresponds to the get
>> get_user_pages() did, but what's the other correspond to?
>
> The second put_page() should be dropping the page from the page cache.
> Perhaps it would be better to rely on a truncate of the file to remove the
> pages from the page cache.

Yeah, that looks horribly buggy, if that's the intent.

You can't just put_page() to remove something from the page cache. You
need to do the whole "remove from radix tree" rigamarole, see for
example delete_from_page_cache(). And you can't even do that blindly,
because if the page is under writeback or otherwise busy, just
removing it from the page cache and freeing it is wrong too.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
