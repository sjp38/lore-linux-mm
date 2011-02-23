Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A2EF18D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 17:35:04 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1NMYEbW015064
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 14:34:14 -0800
Received: by iwl42 with SMTP id 42so5449897iwl.14
        for <linux-mm@kvack.org>; Wed, 23 Feb 2011 14:34:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <E1PsEA7-0007G0-29@pomaz-ex.szeredi.hu>
References: <E1PsEA7-0007G0-29@pomaz-ex.szeredi.hu>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 23 Feb 2011 14:33:54 -0800
Message-ID: <AANLkTimeihuzjgR2f7Avq2PJrCw1vZxtjh=wBPXO3aHP@mail.gmail.com>
Subject: Re: [PATCH] mm: prevent concurrent unmap_mapping_range() on the same inode
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, hughd@google.com, gurudas.pai@oracle.com, lkml20101129@newton.leun.net, rjw@sisk.pl, florian@mickler.org, trond.myklebust@fys.uio.no, maciej.rutecki@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 23, 2011 at 4:49 AM, Miklos Szeredi <miklos@szeredi.hu> wrote:
>
> This resolves Bug 25822 listed in the regressions since 2.6.36 (though
> it's a bug much older than that, for some reason it only started
> triggering for people recently).

Gaah. I hate this patch. It is, in fact, a patch that makes me finally
think that the mm preemptibility is actually worth it, because then
i_mmap_lock turns into a mutex and makes the whole "drop the lock"
thing hopefully a thing of the past (see the patch "mm: Remove
i_mmap_mutex lockbreak").

Because as far as I can see, the only thing that makes this thing
needed in the first place is that horribly ugly "we drop i_mmap_lock
in the middle of random operations that really still need it".

That said, I don't really see any alternatives - I guess we can't
really just say "remove that crazy lock dropping". Even though I
really really really would like to.

Of course, we could also just decide that we should apply the mm
preemptibility series instead. Can people confirm that that fixes the
bug too?

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
