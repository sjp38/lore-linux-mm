Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6766B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 19:30:28 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so5196272pbc.2
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 16:30:28 -0700 (PDT)
Subject: Re: [PATCH v5 1/6] rwsem: check the lock before cpmxchg in
 down_write_trylock
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <CAGQ1y=7okjk0AZaH-WNn33vkpyhT8Z-eNDJr1CiqW4jK9OnVFw@mail.gmail.com>
References: <cover.1380057198.git.tim.c.chen@linux.intel.com>
	 <1380061346.3467.50.camel@schen9-DESK>
	 <CAGQ1y=7okjk0AZaH-WNn33vkpyhT8Z-eNDJr1CiqW4jK9OnVFw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 24 Sep 2013 16:30:19 -0700
Message-ID: <1380065419.3467.59.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Low <jason.low2@hp.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Tue, 2013-09-24 at 16:22 -0700, Jason Low wrote:
> Should we do something similar with __down_read_trylock, such as
> the following?
> 
> 
> Signed-off-by: Jason Low <jason.low2@hp.com>
> ---
>  include/asm-generic/rwsem.h |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/include/asm-generic/rwsem.h b/include/asm-generic/rwsem.h
> index bb1e2cd..47990dc 100644
> --- a/include/asm-generic/rwsem.h
> +++ b/include/asm-generic/rwsem.h
> @@ -42,6 +42,9 @@ static inline int __down_read_trylock(struct
> rw_semaphore *sem)
>         long tmp;
> 
>         while ((tmp = sem->count) >= 0) {
> +               if (sem->count != tmp)
> +                       continue;
> +

Considering that tmp has just been assigned the value of sem->count, the
added if check failure is unlikely and probably not needed.  We should
proceed to cmpxchg below.

>                 if (tmp == cmpxchg(&sem->count, tmp,
>                                    tmp + RWSEM_ACTIVE_READ_BIAS)) {
>                         return 1;

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
