Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 0242D6B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 06:14:07 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so2990731pad.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2012 03:14:07 -0700 (PDT)
Date: Fri, 12 Oct 2012 03:11:15 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [RFC 0/3] mm: vmevent: Stats accuracy improvements
Message-ID: <20121012101115.GA11825@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

Hi all,

Some time ago KOSAKI Motohiro noticed[1] that vmevent might be very
inaccurate (up to 2GB inaccuracy on a very large machines) since per CPU
stats synchronization happens either on time basis or when we hit stat
thresholds.

KOSAKI also told that perf API might be a good inspirations for further
improvements, but I must admit I didn't fully get the idea, although I'm
open to investigate this route too, but I guess it needs a bit more
explanations.

Also note that this is just an RFC, I just show some ideas and wonder how
you feel about it. Since we now use memory pressure factor bolted into the
reclaimer code path, we don't desperately need the accurate stats, but
it's still nice thing to have/fix.

Anyway, here we take two approaches:

- Asynchronously sum vm_stat diffs and global stats. This is very similar
  to what we already have for per-zone stats, implemented in
  zone_page_state_snapshot(). The values still could be inaccurate, but
  overall this makes things better;

- Implement configurable per CPU vmstat thresholds. This is much more
  powerful tool to get accurate statistics, but it comes with a price: it
  might cause some performance penalty as we'd update global stats more
  frequently (in a fast path), so users have to be careful.

The two items are independent, so we might implement one or another, or
both, or none, if desired. ;-)

Thanks,
Anton.

p.s. Note that the patches are against my vmevent tree, i.e.:

	git://git.infradead.org/users/cbou/linux-vmevent.git

[1] http://lkml.indiana.edu/hypermail/linux/kernel/1205.1/00062.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
