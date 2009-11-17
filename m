Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 77C1E6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 02:16:08 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAH7G54H012022
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 17 Nov 2009 16:16:05 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 694AB45DE4D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:16:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 470EB45DE54
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:16:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D1B81DB8043
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:16:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BC49D1DB8042
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:16:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 0/7] Kill PF_MEMALLOC abuse
Message-Id: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 17 Nov 2009 16:16:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


PF_MEMALLOC have following effects.
  (1) Ignore zone watermark
  (2) Don't call reclaim although allocation failure, instead return ENOMEM
  (3) Don't invoke OOM Killer
  (4) Don't retry internally in page alloc

Some subsystem paid attention (1) only, and start to use PF_MEMALLOC abuse.
But, the fact is, PF_MEMALLOC is the promise of "I have lots freeable memory.
if I allocate few memory, I can return more much meory to the system!".
Non MM subsystem must not use PF_MEMALLOC. Memory reclaim
need few memory, anyone must not prevent it. Otherwise the system cause
mysterious hang-up and/or OOM Killer invokation.

if many subsystem will be able to use emergency memory without any
usage rule, it isn't for emergency. it can become empty easily.

Plus, characteristics (2)-(4) mean PF_MEMALLOC don't fit to general
high priority memory allocation.

Thus, We kill all PF_MEMALLOC usage in no MM subsystem.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
