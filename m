Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id D02B46B00DE
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 06:10:43 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id m15so1364656wgh.15
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 03:10:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1364192494-22185-1-git-send-email-minchan@kernel.org>
References: <1364192494-22185-1-git-send-email-minchan@kernel.org>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Wed, 3 Apr 2013 12:10:22 +0200
Message-ID: <CAHO5Pa0srsWS6ukpxUo=EqCOxRmYa7c_7PDg1YPh7gcMGWPpaw@mail.gmail.com>
Subject: Re: [RFC 1/4] mm: Per process reclaim
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sangseok Lee <sangseok.lee@lge.com>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>

Hello Minchan,

On Mon, Mar 25, 2013 at 7:21 AM, Minchan Kim <minchan@kernel.org> wrote:
> These day, there are many platforms avaiable in the embedded market
> and they are smarter than kernel which has very limited information
> about working set so they want to involve memory management more heavily
> like android's lowmemory killer and ashmem or recent many lowmemory
> notifier(there was several trial for various company NOKIA, SAMSUNG,
> Linaro, Google ChromeOS, Redhat).
>
> One of the simple imagine scenario about userspace's intelligence is that
> platform can manage tasks as forground and backgroud so it would be
> better to reclaim background's task pages for end-user's *responsibility*
> although it has frequent referenced pages.
>
> This patch adds new knob "reclaim under proc/<pid>/" so task manager
> can reclaim any target process anytime, anywhere. It could give another
> method to platform for using memory efficiently.
>
> It can avoid process killing for getting free memory, which was really
> terrible experience because I lost my best score of game I had ever
> after I switch the phone call while I enjoyed the game.
>
> Writing 1 to /proc/pid/reclaim reclaims only file pages.
> Writing 2 to /proc/pid/reclaim reclaims only anonymous pages.
> Writing 3 to /proc/pid/reclaim reclaims all pages from target process.

This interface seems to work as advertized, at least from some light
testing that I've done.

However, the interface is a quite blunt instrument. Would there be any
virtue in extending it so that an address range could be written to
/proc/PID/reclaim? Used in conjunction with /proc/PID/maps, a manager
process might then choose to trigger reclaim of just selected regions
of a processes address space. Thus, one might reclaim file backed
pages in a range using:

    echo '2 start-address end-address' > /proc/PID/reclaim

What do you think?

Thanks,

Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
