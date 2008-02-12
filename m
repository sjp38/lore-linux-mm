Date: Mon, 11 Feb 2008 18:12:54 -0800
From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: [2.6.24 REGRESSION] BUG: Soft lockup - with VFS
Message-Id: <20080211181254.5029b8b4.zaitcev@redhat.com>
In-Reply-To: <20080212104612S.fujita.tomonori@lab.ntt.co.jp>
References: <6101e8c40802051348w2250e593x54f777bb771bd903@mail.gmail.com>
	<20080205140506.c6354490.akpm@linux-foundation.org>
	<20080208234619.385bcab9.zaitcev@redhat.com>
	<20080212104612S.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: akpm@linux-foundation.org, oliver.pntr@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, jmorris@namei.org, linux-usb@vger.kernel.org, zaitcev@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008 10:46:12 +0900, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> On a serious note, it seems that two scatter lists per request leaded
> to this bug. Can the scatter list in struct ub_request be removed?

Good question. It's an eyesore to be sure. The duplication exists
for the sake of retries combined with the separation of requests
from commands.

Please bear with me, if you're curious: commands can be launched
without requests (at probe time, for instance, or when sense is
requested). So, they need an s/g table. But then, the lifetime of
a request is greater than than of a command, in case of a retry
especially. Therefore a request needs the s/g table too.

So, one way to kill this duplication is to mandate that a
request existed for every command. It seemed like way more code
than just one memcpy() when I wrote it.

Another way would be to make commands flexible, e.g. sometimes with
just a virtual address and size, sometimes with an s/g table.
If you guys make struct scatterlist illegal to copy with memcpy
one day, this is probably what I'll do.

-- Pete

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
