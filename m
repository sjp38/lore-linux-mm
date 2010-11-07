Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7346D6B0071
	for <linux-mm@kvack.org>; Sun,  7 Nov 2010 05:20:03 -0500 (EST)
Received: by iwn9 with SMTP id 9so4737513iwn.14
        for <linux-mm@kvack.org>; Sun, 07 Nov 2010 02:20:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTino-GJTpmved=SjmN2O_dN=fhrS+vVfHAPoKQ6y@mail.gmail.com>
References: <AANLkTino-GJTpmved=SjmN2O_dN=fhrS+vVfHAPoKQ6y@mail.gmail.com>
Date: Sun, 7 Nov 2010 13:20:01 +0300
Message-ID: <AANLkTimb3aKzMUHOHMXfsFhjd23Ab=y3-1uB_zYJRKRN@mail.gmail.com>
Subject: Re: Low priority writers make realtime processes thrashing
From: Evgeniy Ivanov <lolkaantimat@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi again,

I played some more time with writebacks and discovered, that problem
is really not related to the writeback.
What I found is that cache size always changes (min -> + 10mb -> +
10mb -> + 10mb -> min), and it's caused by 3 dd processes, which copy
300 mb in a loop from /dev/zero. It looks like RT process thrashing
when we come to min. In the mailing list I found a presentation, which
points to the page reclaim slow path, which I will try to check
tomorrow. Also I think to try to profile kernel, to see the difference
between normal work and work when RT processes are thrashing.
Filesystem is ext3 with default mount options. But I doubt fs code is
related, since we always write to the same files (append) and hence
it's mostly about getting and dirtying pages.
Any thoughts?

On Tue, Nov 2, 2010 at 7:32 PM, Evgeniy Ivanov <lolkaantimat@gmail.com> wrote:
> Hi,
>
> When I run few "hard-writers" I get problems with my 15 realtime
> processes (do some very small writes, just 2 pages per-time): they
> start thrashing. I thought it's caused by write-back and was waiting
> for Greg Tellen's per-cgroup dirty page accounting patch. Before
> testing it I tried to change threshold in
> page-writeback.c:get_dirty_limits(), I set dirty_ratio for RT process
> 80% (instead of just extra dirty / 4), but it didn't help me. What
> else can cause problems?
> I'm linux kernel newbie and will appreciate any addvices.
>
> --
> Evgeniy Ivanov
>



-- 
Evgeniy Ivanov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
