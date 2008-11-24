Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id mAOK2qdx021141
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 12:02:53 -0800
Received: from rv-out-0708.google.com (rvfb17.prod.google.com [10.140.179.17])
	by spaceape11.eur.corp.google.com with ESMTP id mAOK2crj027121
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 12:02:51 -0800
Received: by rv-out-0708.google.com with SMTP id b17so2440089rvf.40
        for <linux-mm@kvack.org>; Mon, 24 Nov 2008 12:02:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <604427e00811211731l40898486r1a58e4940f3859e9@mail.gmail.com>
References: <604427e00811211731l40898486r1a58e4940f3859e9@mail.gmail.com>
Date: Mon, 24 Nov 2008 12:02:50 -0800
Message-ID: <6599ad830811241202o74312a18m84ed86a5f4393086@mail.gmail.com>
Subject: Re: [PATCH][V3]Make get_user_pages interruptible
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 21, 2008 at 5:31 PM, Ying Han <yinghan@google.com> wrote:
> From: Paul Menage <menage@google.com>

This patch is getting further and further from my original internal
changes, so I'm not sure that a From: line from me is appropriate.

>                         */
> -                       if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE)))
> -                               return i ? i : -ENOMEM;
> +                       if (unlikely(sigkill_pending(tsk)))
> +                               return i ? i : -ERESTARTSYS;

You've changed the check from sigkill_pending(current) to sigkill_pending(tsk).

I originally made that sigkill_pending(current) since we want to avoid
tasks entering an unkillable state just because they're doing
get_user_pages() on a system that's short of memory. Admittedly for
the main case that we care about, mlock() (or an mmap() with
MCL_FUTURE set) then tsk==current, but philosophically it seems to me
to be more correct to do the check against current than tsk, since
current is the thing that's actually allocating the memory. But maybe
it would be better to check both?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
