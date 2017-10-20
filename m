Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3986B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:08:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p87so10025307pfj.21
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:08:23 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id i85si704365pfj.398.2017.10.20.05.08.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:08:21 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v1 0/3] Virtio-balloon Improvement
Date: Fri, 20 Oct 2017 19:54:23 +0800
Message-Id: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org
Cc: Wei Wang <wei.w.wang@intel.com>

This patch series intends to summarize the recent contributions made by
Michael S. Tsirkin, Tetsuo Handa, Michal Hocko etc. via reporting and
discussing the related deadlock issues on the mailinglist. Please check
each patch for details.

>From a high-level point of view, this patch series achieves:
1) eliminate the deadlock issue fundamentally caused by the inability
to run leak_balloon and fill_balloon concurrently;
2) enable OOM to release more than 256 inflated pages; and
3) stop inflating when the guest is under severe memory pressure
(i.e. OOM).

Here is an example of the benefit brought by this patch series:
The guest sets virtio_balloon.oom_pages=100000. When the host requests
to inflate 7.9G of an 8G idle guest, the guest can still run normally
since OOM can guarantee at least 100000 pages (400MB) for the guest.
Without the above patches, the guest will kill all the killable
processes and fall into kernel panic finally.

Wei Wang (3):
  virtio-balloon: replace the coarse-grained balloon_lock
  virtio-balloon: deflate up to oom_pages on OOM
  virtio-balloon: stop inflating when OOM occurs

 drivers/virtio/virtio_balloon.c | 149 ++++++++++++++++++++++++----------------
 1 file changed, 91 insertions(+), 58 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
