Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2650C6B00EE
	for <linux-mm@kvack.org>; Sat, 30 Jul 2011 14:33:03 -0400 (EDT)
Received: from mail-ww0-f45.google.com (mail-ww0-f45.google.com [74.125.82.45])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p6UIWU7S002942
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sat, 30 Jul 2011 11:32:31 -0700
Received: by wwj40 with SMTP id 40so3781733wwj.26
        for <linux-mm@kvack.org>; Sat, 30 Jul 2011 11:32:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzut1tF6CLAPJUUh2H_7M4wcDpp2+Zb85Lqvofe+3v_jQ@mail.gmail.com>
References: <alpine.DEB.2.00.1107290145080.3279@tiger> <CA+55aFzut1tF6CLAPJUUh2H_7M4wcDpp2+Zb85Lqvofe+3v_jQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 30 Jul 2011 08:32:10 -1000
Message-ID: <CA+55aFw9V-VM5TBwqdKiP0E_g8urth+08nX-_inZ8N1_gFQF4w@mail.gmail.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Jul 30, 2011 at 8:27 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Do we allocate the page map array sufficiently aligned that we
> actually don't ever have the case of straddling a cacheline? I didn't
> check.

Oh, and another thing worth checking: did somebody actually check the
timings for:

 - *just* the alignment change?

   IOW, maybe some of the netperf improvement isn't from the lockless
path, but exactly from 'struct page' always being in a single
cacheline?

 - check performance with cmpxchg16b *without* the alignment.

   Sometimes especially intel is so good at unaligned accesses that
you wouldn't see an issue. Now, locked ops are usually special (and
crossing cachelines with a locked op is dubious at best), so there may
actually be correctness issues involved too, but it would be
interesting to hear if anybody actually just tried it.

Hmm?

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
