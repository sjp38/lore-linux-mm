Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D21DA828ED
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:36:27 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id ho8so28799896pac.2
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:36:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u16si8057724pfa.225.2016.01.08.15.36.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 15:36:27 -0800 (PST)
Date: Fri, 8 Jan 2016 15:36:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1] mm: soft-offline: check return value in second
 __get_any_page() call
Message-Id: <20160108153626.16332573d71cdfcdbc1637cd@linux-foundation.org>
In-Reply-To: <20160108075158.GA28640@hori1.linux.bs1.fc.nec.co.jp>
References: <1452237748-10822-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20160108075158.GA28640@hori1.linux.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, 8 Jan 2016 07:51:59 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> >   [   52.600579]  [<ffffffff811bd18c>] SyS_madvise+0x6bc/0x6f0
> >   [   52.600579]  [<ffffffff8104d0ac>] ? fpu__restore_sig+0xcc/0x320
> >   [   52.600579]  [<ffffffff810a0003>] ? do_sigaction+0x73/0x1b0
> >   [   52.600579]  [<ffffffff8109ceb2>] ? __set_task_blocked+0x32/0x70
> >   [   52.600579]  [<ffffffff81652757>] entry_SYSCALL_64_fastpath+0x12/0x6a
> >   [   52.600579] Code: 8b fc ff ff 5b 5d c3 48 89 df e8 b0 fa ff ff 48 89 df 31 f6 e8 c6 7d ff ff 5b 5d c3 48 c7 c6 08 54 a2 81 48 89 df e8 a4 c5 01 00 <0f> 0b 66 90 66 66 66 66 90 55 48 89 e5 41 55 41 54 53 48 8b 47
> >   [   52.600579] RIP  [<ffffffff8118998c>] put_page+0x5c/0x60
> >   [   52.600579]  RSP <ffff88007c213e00>
> > 
> > The root cause resides in get_any_page() which retries to get a refcount of
> > the page to be soft-offlined. This function calls put_hwpoison_page(), expecting
> > that the target page is putback to LRU list. But it can be also freed to buddy.
> > So the second check need to care about such case.
> > 
> > Fixes: af8fae7c0886 ("mm/memory-failure.c: clean up soft_offline_page()")
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: stable@vger.kernel.org # v3.9+

Please don't top-post.  I manually fixed it here.

> Sorry, I forgot to notice that this specific problem is already fixed in
> mmotm with patch "mm: hwpoison: adjust for new thp refcounting", but
> considering backporting to -stable, it's easier to handle this separately.
> 
> So Andrew, could you separate out the code of this patch from
> "mm: hwpoison: adjust for new thp refcounting"?

I don't understand what you're asking for.  Please be very
specific and carefully identify patches by filename or Subject:.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
