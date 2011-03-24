Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BF1848D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 19:45:45 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p2ONjgHB009965
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 16:45:42 -0700
Received: from ywa8 (ywa8.prod.google.com [10.192.1.8])
	by wpaz33.hot.corp.google.com with ESMTP id p2ONjK9a014733
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 16:45:40 -0700
Received: by ywa8 with SMTP id 8so225151ywa.9
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 16:45:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110324174311.GA31576@infradead.org>
References: <081DDE43F61F3D43929A181B477DCA95639B52FD@MSXAOA6.twosigma.com>
	<081DDE43F61F3D43929A181B477DCA95639B5327@MSXAOA6.twosigma.com>
	<20110324174311.GA31576@infradead.org>
Date: Thu, 24 Mar 2011 16:45:40 -0700
Message-ID: <AANLkTikwwRm6FHFtEdUg54NvmKdswQw-NPH5dtq1mXBK@mail.gmail.com>
Subject: Re: XFS memory allocation deadlock in 2.6.38
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Sean Noonan <Sean.Noonan@twosigma.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Martin Bligh <Martin.Bligh@twosigma.com>, Trammell Hudson <Trammell.Hudson@twosigma.com>, Christos Zoulas <Christos.Zoulas@twosigma.com>, "linux-xfs@oss.sgi.com" <linux-xfs@oss.sgi.com>, Stephen Degler <Stephen.Degler@twosigma.com>, linux-mm@kvack.org

On Thu, Mar 24, 2011 at 10:43 AM, Christoph Hellwig <hch@infradead.org> wro=
te:
> Michel,
>
> can you take a look at this bug report? =A0It looks like a regression
> in your mlock handling changes.

I had a quick look and at this point I can describe how the patch will
affect behavior of this test, but not why this causes a deadlock with
xfs.

The test creates a writable, shared mapping of a file that does not
have data blocks allocated on disk, and also uses the MAP_POPULATE
flag.

Before 5ecfda041e4b4bd858d25bbf5a16c2a6c06d7272, make_pages_present
during the mmap would cause data blocks to get allocated on disk with
an xfs_vm_page_mkwrite call, and then the file pages would get mapped
as writable ptes.

After 5ecfda041e4b4bd858d25bbf5a16c2a6c06d7272, make_pages_present
does NOT cause data blocks to get allocated on disk. Instead,
xfs_vm_readpages is called, which (I suppose) does not allocate the
data blocks and returns zero filled pages instead, which get mapped as
readonly ptes. Later, the test tries writing into the mmap'ed block,
causing minor page faults, xfs_vm_page_mkwrite calls and data block
allocations to occur.


Regarding the deadlock: I am curious to see if it could be made to
happen before 5ecfda041e4b4bd858d25bbf5a16c2a6c06d7272. Could you test
what happens if you remove the MAP_POPULATE flag from your mmap call,
and instead read all pages from userspace right after the mmap ? I
expect you would then be able to trigger the deadlock before
5ecfda041e4b4bd858d25bbf5a16c2a6c06d7272.


This leaves the issue of the change of behavior for MAP_POPULATE on
ftruncated file holes. I'm not sure what to say there though, because
MAP_POPULATE is documented to cause file read-ahead (and it still does
after 5ecfda041e4b4bd858d25bbf5a16c2a6c06d7272), but that doesn't say
anything about block allocation.


Hope this helps,

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
