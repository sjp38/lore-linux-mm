Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 028766B02D7
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 09:32:22 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id y2-v6so297473pll.16
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 06:32:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id x63-v6si12471101pfb.352.2018.07.09.06.32.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Jul 2018 06:32:20 -0700 (PDT)
Date: Mon, 9 Jul 2018 06:32:12 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: BUG: corrupted list in cpu_stop_queue_work
Message-ID: <20180709133212.GA2662@bombadil.infradead.org>
References: <00000000000032412205706753b5@google.com>
 <000000000000693c7d057087caf3@google.com>
 <1271c58e-876b-0df3-3224-319d82634663@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1271c58e-876b-0df3-3224-319d82634663@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: syzbot <syzbot+d8a8e42dfba0454286ff@syzkaller.appspotmail.com>, bigeasy@linutronix.de, linux-kernel@vger.kernel.org, matt@codeblueprint.co.uk, mingo@kernel.org, peterz@infradead.org, syzkaller-bugs@googlegroups.com, tglx@linutronix.de, linux-mm <linux-mm@kvack.org>

On Mon, Jul 09, 2018 at 09:55:17PM +0900, Tetsuo Handa wrote:
> Hello Matthew,
> 
> It seems to me that there are other locations which do not check xas_store()
> failure. Is that really OK? If they are OK, I think we want a comment like
> /* This never fails. */ or /* Failure is OK because ... */
> for each call without failure check.

Good grief, no, I'm not adding a comment to all 50 calls to
xas_store().  Here are some rules:

 - xas_store(NULL) cannot fail.
 - xas_store(p) cannot fail if we know something was already in
   that slot beforehand (ie a replace operation).
 - xas_store(p) cannot fail if xas_create_range() was previously
   successful.
 - xas_store(p) can fail, but it's OK if the only things after that are
   other xas_*() calls.  Because every xas_*() call checks xas_error().
   So this is fine:

	do {
		xas_store(&xas, p);
		xas_set_tag(&xas, XA_TAG_0);
	} while (xas_nomem(&xas, GFP_KERNEL));

> >From d6f24d6eecd79836502527624f8086f4e3e4c331 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Mon, 9 Jul 2018 15:58:44 +0900
> Subject: [PATCH] shmem: Fix crash upon xas_store() failure.
> 
> syzbot is reporting list corruption [1]. This is because xas_store() from
> shmem_add_to_page_cache() is not handling memory allocation failure. Fix
> this by checking xas_error() after xas_store().

I have no idea why you wrote this patch on Monday when I already said
I knew what the problem was on Friday, fixed the problem and pushed it
out to my git tree on Saturday.
