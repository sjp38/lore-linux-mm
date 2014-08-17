Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7A6CC6B003A
	for <linux-mm@kvack.org>; Sun, 17 Aug 2014 19:53:03 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so6292426pdj.40
        for <linux-mm@kvack.org>; Sun, 17 Aug 2014 16:53:03 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id gy1si18987337pbd.29.2014.08.17.16.53.01
        for <linux-mm@kvack.org>;
        Sun, 17 Aug 2014 16:53:02 -0700 (PDT)
Date: Mon, 18 Aug 2014 08:53:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/3] zram: add mem_used_max via sysfs
Message-ID: <20140817235324.GE11367@bbox>
References: <1407978746-20587-1-git-send-email-minchan@kernel.org>
 <1407978746-20587-3-git-send-email-minchan@kernel.org>
 <CALZtONDB5q56f1TUHgqbiJ4ZaP6Yk=GcNQw9DhvLhNyExdfQ4w@mail.gmail.com>
 <CAFdhcLQ11MnF7Py+X1wrJMiu0L15-JrV883oYGopdz1oag0njQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAFdhcLQ11MnF7Py+X1wrJMiu0L15-JrV883oYGopdz1oag0njQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Horner <ds2horner@gmail.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>

On Thu, Aug 14, 2014 at 11:32:36AM -0400, David Horner wrote:
> On Thu, Aug 14, 2014 at 11:09 AM, Dan Streetman <ddstreet@ieee.org> wrote:
> > On Wed, Aug 13, 2014 at 9:12 PM, Minchan Kim <minchan@kernel.org> wrote:
> >> -       if (zram->limit_bytes &&
> >> -               zs_get_total_size_bytes(meta->mem_pool) > zram->limit_bytes) {
> >> +       total_bytes = zs_get_total_size_bytes(meta->mem_pool);
> >> +       if (zram->limit_bytes && total_bytes > zram->limit_bytes) {
> >
> > do you need to take the init_lock to read limit_bytes here?  It could
> > be getting changed between these checks...
> 
> There is no real danger in freeing with an error.
> It is more timing than a race.
> 
> The max calculation is still ok because committed allocations are
> added atomically.

There is one problem in below code piece.

zram->max_used_bytes = max(zram->max_used_bytes, total_bytes);

so we should consider this case.

if (zram->max_used_bytes < total_bytes)
        zram->max_used_bytes = total_bytes;

And we could make the situation like this.


if (zram->max_used_bytes < total_bytes)
        IRQ happen;
        zram->max_used_bytes = total_bytes

During IRQ, other CPU could consume a lot of zsmalloc memory so that
zram->max_used_bytes would be increased under the foot so when IRQ is
finshed, zram->max_used_bytes could be reset with old total_bytes.

To prevent it, we should use the lock I posted RFC version or retry
logic with atomic opeartion(ie, cmpxchg) and my approach makes it simple
first and fix it if we see the trouble in future so my preference is
new spin lock at the moment.

Any comments?



> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
