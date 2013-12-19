Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f52.google.com (mail-qe0-f52.google.com [209.85.128.52])
	by kanga.kvack.org (Postfix) with ESMTP id AF8586B0036
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 14:38:27 -0500 (EST)
Received: by mail-qe0-f52.google.com with SMTP id ne12so1451838qeb.25
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 11:38:27 -0800 (PST)
Date: Thu, 19 Dec 2013 12:17:40 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: bad page state in 3.13-rc4
Message-ID: <20131219171740.GA881@redhat.com>
References: <20131219040738.GA10316@redhat.com>
 <CA+55aFwweoGs3eGWXFULcqnbRbpDhpj2qrefXB5OpQOiWW8wYA@mail.gmail.com>
 <20131219155313.GA25771@redhat.com>
 <CA+55aFyoXCDNfHb+r5b=CgKQLPA1wrU_Tmh4ROZNEt5TPjpODA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyoXCDNfHb+r5b=CgKQLPA1wrU_Tmh4ROZNEt5TPjpODA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Benjamin LaHaise <bcrl@kvack.org>, Kent Overstreet <kmo@daterainc.com>, Al Viro <viro@zeniv.linux.org.uk>

On Thu, Dec 19, 2013 at 09:07:27AM -0800, Linus Torvalds wrote:
 > On Thu, Dec 19, 2013 at 7:53 AM, Dave Jones <davej@redhat.com> wrote:
 > >
 > > Interesting that CPU2 was doing sys_io_setup again. Different trace though.
 > 
 > Well, it was once again in aio_free_ring() - double free or freeing
 > while already in use? And this time the other end of the complaint was
 > allocating a new page that definitely was still busily in use (it's
 > locked).
 > 
 > And there's no sign of migration, although obviously that could have
 > happened or be in progress on another CPU and just didn't notice the
 > mess. But yes, based on the two traces, fs/aio.c:io_setup() would seem
 > to be the main point of interest.
 > 
 > Have you started doing something new in trinity wrt AIO, and
 > io_setup() in particular? Or anything else different that might have
 > started triggering this?

Nothing special for aio, it's always had support for creating things that
look like iovecs, though now maybe it's filling those iovec's with mmaps
that it created (including potentially huge pages) instead of just mallocs.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
