Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id ED2EC8D0039
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 16:00:24 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1GKxoie023697
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 12:59:50 -0800
Received: by iyi20 with SMTP id 20so1655423iyi.14
        for <linux-mm@kvack.org>; Wed, 16 Feb 2011 12:59:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
References: <20110216185234.GA11636@tiehlicka.suse.cz> <20110216193700.GA6377@elte.hu>
 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com> <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 16 Feb 2011 12:51:21 -0800
Message-ID: <AANLkTikgTsktn3DBEweQd1bH=NKoSsXwNai92F_zM_H1@mail.gmail.com>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Feb 16, 2011 at 12:09 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> That said, neither 0x1e68 nor 0xe68 seems to be in the main vmlinux
> file. But I haven't checked modules yet.

There's no obvious clues in modules either. Sad. I was really hoping
for some "oh, there's a list_head at offset 0x1e68 of structure 'xyz',
that's obviously it".

So maybe it really is something like a pointer to some on-stack data,
and the 0x1e68 offset is just a random offset off the beginning of the
stack (it's in the right range). The stack is still one of the few
obvious 8kB allocations we have...

CONFIG_DEBUG_PAGEALLOC really should catch it in that case, though.

                            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
