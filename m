Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC948D0039
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 15:16:36 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1GKFuQF011070
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 12:15:57 -0800
Received: by iyi20 with SMTP id 20so1615480iyi.14
        for <linux-mm@kvack.org>; Wed, 16 Feb 2011 12:15:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
References: <20110216185234.GA11636@tiehlicka.suse.cz> <20110216193700.GA6377@elte.hu>
 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 16 Feb 2011 12:09:35 -0800
Message-ID: <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Feb 16, 2011 at 11:50 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Yup, goodie. It does look like it might be exactly the same thing,
> except now the offset seems to be 0x1e68 instead of 0x1768.

It was 0x1748 in Eric's case. Background for Michal:

  http://lkml.org/lkml/2011/2/14/223

Michal - if you can re-create this, it would be wonderful if you can
enable CONFIG_DEBUG_PAGEALLOC. I didn't find any obvious candidates
yet.

Also, what is a bit surprising is that the x86-32 offset is bigger
than the x86-64 one. Normally the x86-64 structures are much bigger
due to the obvious 64-bit fields.

I wonder if it's something counting backwards from the top. IOW, it
could be a "list_init()" on the kernel stack (which is 8kB - see
THREAD_ORDER) after the stack has been released. That would explain
why the offset is bigger on x86-32, because it's simply closer to the
top-of-stack.

The other possibility is that the offset is much smaller on x86, and
is just 0xe68 (with just one pte error, it's hard to tell how many
significant bits there are - there's no pattern as in Eric's case).

That said, neither 0x1e68 nor 0xe68 seems to be in the main vmlinux
file. But I haven't checked modules yet.

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
