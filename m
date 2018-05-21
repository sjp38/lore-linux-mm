Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 032AA6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 18:07:50 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s2-v6so13131467ioa.22
        for <linux-mm@kvack.org>; Mon, 21 May 2018 15:07:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g20-v6sor8288640iob.41.2018.05.21.15.07.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 15:07:49 -0700 (PDT)
MIME-Version: 1.0
From: Daniel Colascione <dancol@google.com>
Date: Mon, 21 May 2018 15:07:36 -0700
Message-ID: <CAKOZuetOD6MkGPVvYFLj5RXh200FaDyu3sQqZviVRhTFFS3fjA@mail.gmail.com>
Subject: Why do we let munmap fail?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>

Right now, we have this system knob max_map_count that caps the number of
VMAs we can have in a single address space. Put aside for the moment of
whether this knob should exist: even if it does, enforcing it for munmap,
mprotect, etc. produces weird and counter-intuitive situations in which
it's possible to fail to return resources (address space and commit charge)
to the system. At a deep philosophical level, that's the kind of operation
that should never fail. A library that does all the right things can still
experience a failure to deallocate resources it allocated itself if it gets
unlucky with VMA merging. Why should we allow that to happen?

Now let's return to max_map_count itself: what is it supposed to achieve?
If we want to limit application kernel memory resource consumption, let's
limit application kernel memory resource consumption, accounting for it on
a byte basis the same way we account for other kernel objects allocated on
behalf of userspace. Why should we have a separate cap just for the VMA
count?

I propose the following changes:

1) Let -1 mean "no VMA count limit".
2) Default max_map_count to -1.
3) Do not enforce max_map_count on munmap and mprotect.

Alternatively, can we account VMAs toward max_map_count on a page count
basis instead of a VMA basis? This way, no matter how you split and merge
your VMAs, you'll never see a weird failure to release resources. We'd have
to bump the default value of max_map_count to compensate for its new
interpretation.
