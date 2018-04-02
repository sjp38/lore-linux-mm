Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D22626B0003
	for <linux-mm@kvack.org>; Sun,  1 Apr 2018 20:52:51 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id n7so6899296wrb.0
        for <linux-mm@kvack.org>; Sun, 01 Apr 2018 17:52:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor3197314edi.55.2018.04.01.17.52.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Apr 2018 17:52:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180330174209.4cb77003@gandalf.local.home>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <20180330102038.2378925b@gandalf.local.home> <20180330205356.GA13332@bombadil.infradead.org>
 <20180330173031.257a491a@gandalf.local.home> <20180330174209.4cb77003@gandalf.local.home>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Mon, 2 Apr 2018 08:52:49 +0800
Message-ID: <CAGWkznE_ff0mf+=+5KjKXJmavw9pv2+1+d4_ktYpjsg4ugGOwA@mail.gmail.com>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>

On Sat, Mar 31, 2018 at 5:42 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
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
> +               return -ENOMEM;
> +
>         for (i = 0; i < nr_pages; i++) {
>                 struct page *page;
>                 /*
Hi Steve, It works as my previous patch does.
