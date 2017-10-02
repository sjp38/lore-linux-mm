Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7DA6B0069
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 15:54:56 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id c76so2008485vkd.14
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 12:54:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k88sor4410952ioo.76.2017.10.02.12.54.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 12:54:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <150693809463.587641.5712378065494786263.stgit@buzz>
References: <150693809463.587641.5712378065494786263.stgit@buzz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 2 Oct 2017 12:54:53 -0700
Message-ID: <CA+55aFyXrxN8Dqw9QK9NPWk+ZD52fT=q2y7ByPt9pooOrio3Nw@mail.gmail.com>
Subject: Re: [PATCH RFC] mm: implement write-behind policy for sequential file writes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Oct 2, 2017 at 2:54 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
>
> This patch implements write-behind policy which tracks sequential writes
> and starts background writeback when have enough dirty pages in a row.

This looks lovely to me.

I do wonder if you also looked at finishing the background
write-behind at close() time, because it strikes me that once you
start doing that async writeout, it would probably be good to make
sure you try to do the whole file.

I'm thinking of filesystems that do delayed allocation etc - I'd
expect that you'd want the whole file to get allocated on disk
together, rather than have the "first 256kB aligned chunks" allocated
thanks to write-behind, and then the final part allocated much later
(after other files may have triggered their own write-behind). Think
loads like copying lots of pictures around, for example.

I don't have any particularly strong feelings about this, but I do
suspect that once you have started that IO, you do want to finish it
all up as the file write is done. No?

It would also be really nice to see some numbers. Perhaps a comparison
of "vmstat 1" or similar when writing a big file to some slow medium
like a USB stick (which is something we've done very very badly at,
and this should help smooth out)?

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
