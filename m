Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 800536B002B
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 23:58:36 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so6215958pad.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 20:58:35 -0700 (PDT)
Date: Mon, 15 Oct 2012 20:58:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: mpol_to_str revisited.
In-Reply-To: <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com>
References: <20121008150949.GA15130@redhat.com> <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, bhutchings@solarflare.com, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 15 Oct 2012, KOSAKI Motohiro wrote:

> I don't think 80de7c3138ee9fd86a98696fd2cf7ad89b995d0a is right fix.

It's certainly not a complete fix, but I think it's a much better result 
of the race, i.e. we don't panic anymore, we simply fail the read() 
instead.

> we should
> close a race (or kill remain ref count leak) if we still have.

As I mentioned earlier in the thread, the read() is done here on a task 
while only a reference to the task_struct is taken and we do not hold 
task_lock() which is required for task->mempolicy.  Once that is fixed, 
mpol_to_str() should never be called for !task->mempolicy so it will never 
need to return -EINVAL in such a condition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
