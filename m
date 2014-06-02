Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 494DD6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 10:20:31 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pn19so2629864lab.34
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 07:20:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id et8si21772830wib.78.2014.06.02.07.20.24
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 07:20:25 -0700 (PDT)
Message-ID: <538c8829.e863b40a.0787.ffff96f4SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/3] mm: introduce fincore()
Date: Mon,  2 Jun 2014 10:19:17 -0400
In-Reply-To: <20140602064226.GA31675@infradead.org>
References: <20140521193336.5df90456.akpm@linux-foundation.org> <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1401686699-9723-3-git-send-email-n-horiguchi@ah.jp.nec.com> <20140602064226.GA31675@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

On Sun, Jun 01, 2014 at 11:42:26PM -0700, Christoph Hellwig wrote:
> Please also provide a man page for the system call.

Yes, I'll do it.

> I'm also very unhappy about the crazy different interpretation of the
> return value depending on flags, which probably becomes more obvious if
> you try to document it.

The meaning of the return value doesn't change due to flags, it's always
"the number of valid entries passed to userspace,"  not dependent on the
mode (unlike the size of data for example.)

The reason why I did this is skip hole mode, where fincore() could end scanning
before filling up the userspace buffer. So then the caller wants to know where
is the end point of valid data. I thought that the simplest way is to return
it as the return value. It's also possible to to let userspace know it by doing
like below:
- a userspace application zeroes the whole range of the buffer before calling
  fincore(FINCORE_SKIP_HOLE)
- after the fincore() returns, it finds the first hole entry then the index
  of the hole entry gives the number of valid entries.

Yes, we can do it without the return value, but it takes some costs so I
didn't like it.

> That being said I think fincore is useful, but why not stick to the
> same simple interface as mincore?

mincore() gives only 8-bit field for each page, so we can easily guess that
in the future we will face the need of more information to be passed and we
don't have enough room for it.

Another reason is that currently we have some interfaces to expose page status
information to userspace like /proc/kpageflags, /proc/kpagecount, and
/proc/pid/pagemap. People (including me) tried to add a new interface when they
need a new infomation, but this is not good direction in a long run (too many
/proc/kpage* interfaces). I think fincore() provides a unified way to do it.
One benefit of it is that we can get the data you want in a single call, no need
to call (for example) /proc/pid/pagemap and then /proc/kpageflags separately,
which results in less overhead.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
