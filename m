Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id D448A8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 17:54:59 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id m52so17873081otc.13
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 14:54:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k203sor26180708oib.16.2019.01.05.14.54.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 14:54:58 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
In-Reply-To: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
From: Jann Horn <jannh@google.com>
Date: Sat, 5 Jan 2019 23:54:32 +0100
Message-ID: <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Sat, Jan 5, 2019 at 6:27 PM Jiri Kosina <jikos@kernel.org> wrote:
> There are possibilities [1] how mincore() could be used as a converyor of
> a sidechannel information about pagecache metadata.
>
> Provide vm.mincore_privileged sysctl, which makes it possible to mincore()
> start returning -EPERM in case it's invoked by a process lacking
> CAP_SYS_ADMIN.
>
> The default behavior stays "mincore() can be used by anybody" in order to
> be conservative with respect to userspace behavior.
>
> [1] https://www.theregister.co.uk/2019/01/05/boffins_beat_page_cache/

Just checking: I guess /proc/$pid/pagemap (iow, the pagemap_read()
handler) is less problematic because it only returns data about the
state of page tables, and doesn't query the address_space? In other
words, it permits monitoring evictions, but non-intrusively detecting
that something has been loaded into memory by another process is
harder?
