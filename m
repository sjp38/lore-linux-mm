Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 94F6D6B026A
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 19:38:55 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 140-v6so9249369itg.4
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 16:38:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z64sor3917005ioz.158.2018.03.30.16.38.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Mar 2018 16:38:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180330174209.4cb77003@gandalf.local.home>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <20180330102038.2378925b@gandalf.local.home> <20180330205356.GA13332@bombadil.infradead.org>
 <20180330173031.257a491a@gandalf.local.home> <20180330174209.4cb77003@gandalf.local.home>
From: Joel Fernandes <joelaf@google.com>
Date: Fri, 30 Mar 2018 16:38:52 -0700
Message-ID: <CAJWu+orx=NZrkAf7x_HqttnrMssmW7DPZOL1fxR=N6D_-fbmtw@mail.gmail.com>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Matthew Wilcox <willy@infradead.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>

Hi Steven,

On Fri, Mar 30, 2018 at 2:42 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> On Fri, 30 Mar 2018 17:30:31 -0400
> Steven Rostedt <rostedt@goodmis.org> wrote:
>
>> I'll take a look at si_mem_available() that Joel suggested and see if
>> we can make that work.
>
> Wow, this appears to work great! Joel and Zhaoyang, can you test this?
>
> -- Steve
>
> diff --git a/kernel/trace/ring_buffer.c b/kernel/trace/ring_buffer.c
> index a2fd3893cc02..32a803626ee2 100644
> --- a/kernel/trace/ring_buffer.c
> +++ b/kernel/trace/ring_buffer.c
> @@ -1164,6 +1164,11 @@ static int __rb_allocate_pages(long nr_pages, struct list_head *pages, int cpu)
>         struct buffer_page *bpage, *tmp;
>         long i;
>
> +       /* Check if the available memory is there first */
> +       i = si_mem_available();
> +       if (i < nr_pages)

Does it make sense to add a small margin here so that after ftrace
finishes allocating, we still have some memory left for the system?
But then then we have to define a magic number :-|

> +               return -ENOMEM;
> +

I tested in Qemu with 1GB memory, I am always able to get it to fail
allocation even without this patch without causing an OOM. Maybe I am
not running enough allocations in parallel or something :)

The patch you shared using si_mem_available is working since I'm able
to allocate till the end without a page allocation failure:

bash-4.3# echo 237800 > /d/tracing/buffer_size_kb
bash: echo: write error: Cannot allocate memory
bash-4.3# echo 237700 > /d/tracing/buffer_size_kb
bash-4.3# free -m
             total         used         free       shared      buffers
Mem:           985          977            7           10            0
-/+ buffers:                977            7
Swap:            0            0            0
bash-4.3#

I think this patch is still good to have, since IMO we should not go
and get page allocation failure (even if its a non-OOM) and subsequent
stack dump from mm's allocator, if we can avoid it.

Tested-by: Joel Fernandes <joelaf@google.com>

thanks,

- Joel
