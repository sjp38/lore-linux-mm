Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id E7B646B0038
	for <linux-mm@kvack.org>; Sat, 13 Jun 2015 14:59:36 -0400 (EDT)
Received: by qcxj20 with SMTP id j20so2130711qcx.2
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 11:59:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k109si7717587qgf.32.2015.06.13.11.59.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Jun 2015 11:59:36 -0700 (PDT)
Date: Sat, 13 Jun 2015 20:58:28 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: why do we need vmalloc_sync_all?
Message-ID: <20150613185828.GA32376@redhat.com>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434188955-31397-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

I didn't read v2 yet, but I'd like to ask a question.

Why do we need vmalloc_sync_all()?

It has a single caller, register_die_notifier() which calls it without
any explanation. IMO, this needs a comment at least.

I am not sure I understand the changelog in 101f12af correctly, but
at first glance vmalloc_sync_all() is no longer needed at least on x86,
do_page_fault() no longer does notify_die(DIE_PAGE_FAULT). And btw
DIE_PAGE_FAULT has no users. DIE_MNI too...

Perhaps we can simply kill it on x86?

As for other architectures I am not sure. arch/tile implements
vmalloc_sync_all() and uses notify_die() in do_page_fault().

And in any case register_die_notifier()->vmalloc_sync() looks strange.
If (say) arch/tile needs this to fix the problem with modules, perhaps
it should do vmalloc_sync_all() in do_init_module() paths?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
