Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 082A06B0260
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:01:13 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id r101so307480183ioi.3
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:01:13 -0800 (PST)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id 32si45098616ios.116.2016.11.29.10.01.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 10:01:11 -0800 (PST)
Received: by mail-io0-x241.google.com with SMTP id j92so31071860ioi.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:01:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161129174019.fywddwo5h4pyix7r@merlins.org>
References: <20161121215639.GF13371@merlins.org> <20161122160629.uzt2u6m75ash4ved@merlins.org>
 <48061a22-0203-de54-5a44-89773bff1e63@suse.cz> <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
 <20161123063410.GB2864@dhcp22.suse.cz> <20161128072315.GC14788@dhcp22.suse.cz>
 <20161129155537.f6qgnfmnoljwnx6j@merlins.org> <20161129160751.GC9796@dhcp22.suse.cz>
 <20161129163406.treuewaqgt4fy4kh@merlins.org> <CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com>
 <20161129174019.fywddwo5h4pyix7r@merlins.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 Nov 2016 10:01:10 -0800
Message-ID: <CA+55aFz04aMBurHuME5A1NuhumMECD5iROhn06GB4=ceA+s6mw@mail.gmail.com>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc MERLIN <marc@merlins.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue, Nov 29, 2016 at 9:40 AM, Marc MERLIN <marc@merlins.org> wrote:
>
> In my case, it is a 5x 4TB HDD with
> software raid 5 < bcache < dmcrypt < btrfs

It doesn't sound like the nasty situations I have seen (particularly
with large USB flash storage - often high momentary speed for
benchmarks, but slows down to a crawl after you've written a bit to
it, and doesn't have the smart garbage collection that modern "real"
SSDs have).

But while it doesn't sound like that nasty case, RAID5 will certainly
not help your write speed, and with spinning rust that potentially up
to 4GB (in fact, almost 5GB) of dirty pending data is going to take a
long time to write out if it's not all nice and contiguous (which it
won't be).

And btrfs might be weak on that case - I remember complaining about
fsync stuttering all IO a few years ago, exactly because it would
force-flush everything else too (ie you were doing non-synchronous
writes in one session, and then the browser did a "fsync" on the small
writes it did to the mysql database, and suddenly the browser paused
for ten seconds or more, because the fsync wasn't just waiting for the
small database update, but for _everythinig_ to be written back).

Your backtrace isn't for fsync, but it looks superficially similar:
"wait for write data to flush".

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
