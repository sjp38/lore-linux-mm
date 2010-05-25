Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B63006B01AD
	for <linux-mm@kvack.org>; Tue, 25 May 2010 12:01:53 -0400 (EDT)
Date: Wed, 26 May 2010 02:01:49 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: page_mkwrite vs pte dirty race in fb_defio
Message-ID: <20100525160149.GE20853@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Albert Herranz <albert_herranz@yahoo.es>, aya Kumar <jayakumar.lkml@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

I couldn't find where this patch (49bbd815fd8) was discussed, so I'll
make my own thread. Adding a few lists to cc because it might be of
interest to driver and filesystem writers.

The old ->page_mkwrite calling convention was causing problems exactly
because of this race, and we solved it by allowing page_mkwrite to
return with the page locked, and the lock will be held until the
pte is marked dirty. See commit b827e496c893de0c0f142abfaeb8730a2fd6b37f.

I hope that should provide a more elegant solution to your problem. I
would really like you to take a look at that, because we already have
filesystem code (NFS) relying on it, and more code we have relying on
this synchronization, the more chance we would find a subtle problem
with it (also it should be just nicer).

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
