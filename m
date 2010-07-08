Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 07CF96B006A
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 05:02:52 -0400 (EDT)
Subject: Re: FYI: mmap_sem OOM patch
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100707231134.GA26555@google.com>
References: <20100707231134.GA26555@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 08 Jul 2010 11:02:48 +0200
Message-ID: <1278579768.1900.14.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Divyesh Shah <dpshah@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-07-07 at 16:11 -0700, Michel Lespinasse wrote:

> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index f627779..4b3a1c7 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -1062,7 +1062,10 @@ do_page_fault(struct pt_regs *regs, unsigned long =
error_code)
>  			bad_area_nosemaphore(regs, error_code, address);
>  			return;
>  		}
> -		down_read(&mm->mmap_sem);
> +		if (test_thread_flag(TIF_MEMDIE))
> +			down_read_unfair(&mm->mmap_sem);
> +		else
> +			down_read(&mm->mmap_sem);
>  	} else {
>  		/*
>  		 * The above down_read_trylock() might have succeeded in

I still think adding that _unfair interface is asking for trouble.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
