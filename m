Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 61D4B6B0082
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 07:04:53 -0500 (EST)
Received: by wibhj13 with SMTP id hj13so1571862wib.14
        for <linux-mm@kvack.org>; Thu, 16 Feb 2012 04:04:51 -0800 (PST)
MIME-Version: 1.0
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH] extend prefault helpers to fault in more than PAGE_SIZE
Date: Thu, 16 Feb 2012 13:01:35 +0100
Message-Id: <1329393696-4802-1-git-send-email-daniel.vetter@ffwll.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Daniel Vetter <daniel.vetter@ffwll.ch>

Hi all,

drm/i915 has write/read paths to upload/download data to/from gpu buffer
objects. For a bunch of reasons we have special fastpaths with decent setup
costs, so when we fall back to the slow-path we don't fully recover to the
fastest fast-path when grabbing our locks again. This is also in parts due to
that we have multiple fallbacks to slower paths, so control-flow in our code
would get really ugly.

As part of a larger rewrite and re-tuning of these functions we've noticed that
the prefault helpers in pagemap.h only prefault up to PAGE_SIZE because that's
all the other users need. The follow-up patch extends this to abritary sizes so
that we can fully exploit our special fastpaths in more cases (we typically see
reads and writes of a few pages up to a few mb).

I'd like to get this in for 3.4. There's no functional dependency between this
patch and the drm/i915 rework (only performance effects), so this can go in
through -mm without causing merge issues.

If this or something similar isn't acceptable, plan B is to hand-roll these 2
functions in drm/i915. But I don't like nih these things in driver code much.

Comments highly welcome.

Yours, Daniel

For reference, the drm/i915 read/write rework is avaialable at:

http://cgit.freedesktop.org/~danvet/drm/log/?h=pwrite-pread

Unfortunately cgit.fd.o is currently on hiatus.

Daniel Vetter (1):
  mm: extend prefault helpers to fault in more than PAGE_SIZE

 include/linux/pagemap.h |   28 ++++++++++++++++++----------
 1 files changed, 18 insertions(+), 10 deletions(-)

-- 
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
