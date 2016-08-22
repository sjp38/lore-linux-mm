Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 94B386B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 05:32:55 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id e7so70512757lfe.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 02:32:55 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id y62si15333303wmb.132.2016.08.22.02.32.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 02:32:54 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q128so12548761wma.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 02:32:54 -0700 (PDT)
Date: Mon, 22 Aug 2016 11:32:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: OOM detection regressions since 4.7
Message-ID: <20160822093249.GA14916@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, greg@suse.cz, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi, 
there have been multiple reports [1][2][3][4][5] about pre-mature OOM
killer invocations since 4.7 which contains oom detection rework. All of
them were for order-2 (kernel stack) alloaction requests failing because
of a high fragmentation and compaction failing to make any forward
progress. While investigating this we have found out that the compaction
just gives up too early. Vlastimil has been working on compaction
improvement for quite some time and his series [6] is already sitting
in mmotm tree. This already helps a lot because it drops some heuristics
which are more aimed at lower latencies for high orders rather than
reliability. Joonsoo has then identified further problem with too many
blocks being marked as unmovable [7] and Vlastimil has prepared a patch
on top of his series [8] which is also in the mmotm tree now.

That being said, the regression is real and should be fixed for 4.7
stable users. [6][8] was reported to help and ooms are no longer
reproducible. I know we are quite late (rc3) in 4.8 but I would vote
for mergeing those patches and have them in 4.8. For 4.7 I would go
with a partial revert of the detection rework for high order requests
(see patch below). This patch is really trivial. If those compaction
improvements are just too large for 4.8 then we can use the same patch
as for 4.7 stable for now and revert it in 4.9 after compaction changes
are merged.

Thoughts?

[1] http://lkml.kernel.org/r/20160731051121.GB307@x4
[2] http://lkml.kernel.org/r/201608120901.41463.a.miskiewicz@gmail.com
[3] http://lkml.kernel.org/r/20160801192620.GD31957@dhcp22.suse.cz
[4] https://lists.opensuse.org/opensuse-kernel/2016-08/msg00021.html
[5] https://bugzilla.opensuse.org/show_bug.cgi?id=994066
[6] http://lkml.kernel.org/r/20160810091226.6709-1-vbabka@suse.cz
[7] http://lkml.kernel.org/r/20160816031222.GC16913@js1304-P5Q-DELUXE
[8] http://lkml.kernel.org/r/f7a9ea9d-bb88-bfd6-e340-3a933559305a@suse.cz

---
