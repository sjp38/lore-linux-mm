Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id AC4F86B005A
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 03:31:24 -0500 (EST)
Received: by mail-gh0-f178.google.com with SMTP id g24so1938397ghb.9
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 00:31:23 -0800 (PST)
Date: Fri, 4 Jan 2013 00:27:52 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 0/2] Mempressure cgroup
Message-ID: <20130104082751.GA22227@lizard.gateway.2wire.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

Hi all,

Here is another round of the mempressure cgroup. This time I dared to
remove the RFC tag. :)

In this revision:

- Addressed most of Kirill Shutemov's comments. I didn't bother
  implementing per-level lists, though. It would needlessly complicate the
  logic, and the gain would be only visible with lots of watchers (which
  we don't have for our use-cases). But it is always an option to add the
  feature;

- I've split the pach into two: 'shrinker' and 'levels' parts. While the
  full-fledged userland shrinker is an interesting idea, we don't have any
  users ready for it, so I won't advocate for it too much.

  And since at least Kirill has some concerns about it, I don't want the
  shrinker to block the pressure levels.

  So, these are now separate. At some point, I'd like to both of them
  merged, but if anything, let's discuss them separately;

- Rebased onto v3.8-rc2.

RFC v2 (http://lkml.org/lkml/2012/12/10/128):

 - Added documentation, describes APIs and the purpose;
 - Implemented shrinker interface, this is based on Andrew's idea and
   supersedes my "balance" level idea;
 - The shrinker interface comes with a stress-test utility, that is what
   Andrew was also asking for. A simple app that we can run and see if the
   thing works as expected;
 - Added reclaimer's target_mem_cgroup handling;
 - As promised, added support for multiple listeners, and fixed some other
   comments on the previous RFC.

RFC v1 (http://lkml.org/lkml/2012/11/28/109)

--
 Documentation/cgroups/mempressure.txt    |  97 +++++
 Documentation/cgroups/mempressure_test.c | 213 ++++++++++
 include/linux/cgroup_subsys.h            |   6 +
 include/linux/vmstat.h                   |  11 +
 init/Kconfig                             |  13 +
 mm/Makefile                              |   1 +
 mm/mempressure.c                         | 487 +++++++++++++++++++++++
 mm/vmscan.c                              |   4 +
 8 files changed, 832 insertions(+)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
