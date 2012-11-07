Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id C01776B0062
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 05:56:55 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so1226003pbb.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2012 02:56:55 -0800 (PST)
Date: Wed, 7 Nov 2012 02:53:49 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
Message-ID: <20121107105348.GA25549@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

Hi all,

This is the third RFC. As suggested by Minchan Kim, the API is much
simplified now (comparing to vmevent_fd):

- As well as Minchan, KOSAKI Motohiro didn't like the timers, so the
  timers are gone now;
- Pekka Enberg didn't like the complex attributes matching code, and so it
  is no longer there;
- Nobody liked the raw vmstat attributes, and so they were eliminated too.

But, conceptually, it is the exactly the same approach as in v2: three
discrete levels of the pressure -- low, medium and oom. The levels are
based on the reclaimer inefficiency index as proposed by Mel Gorman, but
userland does not see the raw index values. The description why I moved
away from reporting the raw 'reclaimer inefficiency index' can be found in
v2: http://lkml.org/lkml/2012/10/22/177

While the new API is very simple, it is still extensible (i.e. versioned).

As there are a lot of drastic changes in the API itself, I decided to just
add a new files along with vmevent, it is much easier to review it this
way (I can prepare a separate patch that removes vmevent files, if we care
to preserve the history through the vmevent tree).

Thanks,
Anton.

--
 Documentation/sysctl/vm.txt                |  47 +++++
 arch/x86/syscalls/syscall_64.tbl           |   1 +
 include/linux/syscalls.h                   |   2 +
 include/linux/vmpressure.h                 | 128 ++++++++++++
 kernel/sys_ni.c                            |   1 +
 kernel/sysctl.c                            |  31 +++
 mm/Kconfig                                 |  13 ++
 mm/Makefile                                |   1 +
 mm/vmpressure.c                            | 231 +++++++++++++++++++++
 mm/vmscan.c                                |   5 +
 tools/testing/vmpressure/.gitignore        |   1 +
 tools/testing/vmpressure/Makefile          |  30 +++
 tools/testing/vmpressure/vmpressure-test.c |  93 +++++++++
 13 files changed, 584 insertions(+)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
