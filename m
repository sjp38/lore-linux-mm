Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id E32BB6B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 16:58:48 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id h80so3291854lfe.7
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 13:58:48 -0700 (PDT)
Received: from forwardcorp1o.cmail.yandex.net (forwardcorp1o.cmail.yandex.net. [2a02:6b8:0:1a72::290])
        by mx.google.com with ESMTPS id 92si1377691lfq.90.2017.10.02.13.58.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 13:58:47 -0700 (PDT)
Subject: Re: [PATCH RFC] mm: implement write-behind policy for sequential file
 writes
References: <150693809463.587641.5712378065494786263.stgit@buzz>
 <CA+55aFyXrxN8Dqw9QK9NPWk+ZD52fT=q2y7ByPt9pooOrio3Nw@mail.gmail.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <dcb23e5d-81b9-9a6c-b7ac-bbad2ef77fd8@yandex-team.ru>
Date: Mon, 2 Oct 2017 23:58:45 +0300
MIME-Version: 1.0
In-Reply-To: <CA+55aFyXrxN8Dqw9QK9NPWk+ZD52fT=q2y7ByPt9pooOrio3Nw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 02.10.2017 22:54, Linus Torvalds wrote:
> On Mon, Oct 2, 2017 at 2:54 AM, Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru> wrote:
>>
>> This patch implements write-behind policy which tracks sequential writes
>> and starts background writeback when have enough dirty pages in a row.
> 
> This looks lovely to me.
> 
> I do wonder if you also looked at finishing the background
> write-behind at close() time, because it strikes me that once you
> start doing that async writeout, it would probably be good to make
> sure you try to do the whole file.

Smaller files or tails is lesser problem and forced writeback here
might add bigger overhead due to small requests or too random IO.
Also open+append+close pattern could generate too much IO.

> 
> I'm thinking of filesystems that do delayed allocation etc - I'd
> expect that you'd want the whole file to get allocated on disk
> together, rather than have the "first 256kB aligned chunks" allocated
> thanks to write-behind, and then the final part allocated much later
> (after other files may have triggered their own write-behind). Think
> loads like copying lots of pictures around, for example.

As far as I know ext4 preallocates space beyond file end for writing
patterns like append + fsync. Thus allocated extents should be bigger
than 256k. I haven't looked into this yet.

> 
> I don't have any particularly strong feelings about this, but I do
> suspect that once you have started that IO, you do want to finish it
> all up as the file write is done. No?

I'm aiming into continuous file operations like downloading huge file
or writing verbose log. Original motivation came from low-latency server
workloads which suffers from parallel bulk operations which generates
tons of dirty pages. Probably for general-purpose usage thresholds
should be increased significantly to cover only really bulky patterns.

> 
> It would also be really nice to see some numbers. Perhaps a comparison
> of "vmstat 1" or similar when writing a big file to some slow medium
> like a USB stick (which is something we've done very very badly at,
> and this should help smooth out)?

I'll try to find out some real cases with numbers.

For now I see that massive write + fdatasync (dd conf=fdatasync, fio)
always ends earlier because writeback now starts earlier too.
Without fdatasync it's obviously slower.

Cp to usb stick + umount should show same result, plus cp could be
interrupted at any point without contaminating cache with dirty pages.

Kernel compilation tooks almost the same time because most files are
smaller than 256k.

> 
>                  Linus
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
