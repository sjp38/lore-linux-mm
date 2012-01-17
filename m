Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 0A5DE6B00B1
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 08:23:19 -0500 (EST)
From: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
Subject: [PATCH v2 0/2] Memory notification pseudo-device module 
Date: Tue, 17 Jan 2012 15:22:09 +0200
Message-Id: <cover.1326803859.git.leonid.moiseichuk@nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, gregkh@suse.de, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

Hello,

That is a continuation of Used Memory Meter (UMM) started as [1] and re-designed
according to inputs I can implement. 

The main idea of memnotify is to provide low-cost interface for user-space to
update with specified granularity and timeout required memory usulization values
in specified moment of time. It is not a low memory interface as [2] nor OOM killer
but it could be used for situations related to "close-to-OOM" handling. The examples
of usage could be discovered in libmemnotify [3] or test case code below this intro.

During the previous discussion two biggest disappointments were discovered:
1. hooking MM -- now it is removed, the new solution has 0 MM changes, only extra
   shrinker added to re-enforce timer to re-check memory situation as soon as possible
2. extendability -- to add any other tracked value you need to modify 2 places in 
   code (memtypes[] and get_memory_status() function).

As Kosaki-san said for activity tracking I added "active" page set. You can subscribe
for one or several values for tracking simultaneously.

To periodic re-read vm_stat (using global_page_state() interface) I use deferred timer,
expecting if cpu sleeps timer could be delayed and use-time will be not affected. 
If this assumption is not correct I can add register_cpu_notifier() call. Otherwise,
when no clients connected - no activity or subscription in module performed.

The number of module parameters could be specified to adjust reaction time or
granularity of changes. The interface pseudo-device hardcoded as /dev/memnotify.

As in previous time module tested using arm, x86-32 and x86-64 for typical (10 clients)
and stress (10K clients) cases.

With Best Regards,
Leonid

References:
1. https://lkml.org/lkml/2012/1/4/208
2. https://lkml.org/lkml/2012/1/17/34
3. http://maemo.gitorious.org/maemo-tools/libmemnotify

Leonid Moiseichuk (2):
  Making si_swapinfo exportable
  Memory notification pseudo-device module

 drivers/misc/Kconfig     |   11 +
 drivers/misc/Makefile    |    1 +
 drivers/misc/memnotify.c |  582 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/swapfile.c            |    3 +
 4 files changed, 597 insertions(+), 0 deletions(-)
 create mode 100644 drivers/misc/memnotify.c

-- 
1.7.7.3

/*
 * mn_test.c - test for system-wide memory notification/meter implementation
 * 
 * Usage:
 *    $gcc -o mn_test mn_test.c
 *    $mn_test
 *  or with pointing pages as threshold(s)
 *    $mn_test "used 5000"
 *  or
 *    $mn_test "active 8000 used 16000"
 *
 * Copyright (C) 2012 Nokia Corporation.
 *      Leonid Moiseichuk
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed "as is" WITHOUT ANY WARRANTY of any
 * kind, whether express or implied; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <poll.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

int main(const int argc, const char* argv[])
{
	const char *dev = "/dev/memnotify";
	const int fd = open(dev,O_RDWR);
	const char *lim = (2 == argc && argv[1] ? argv[1] : NULL);
	ssize_t ret;
	struct pollfd fds[1];
	char tmp[256];

	printf ("%s -- test for system-wide memory notification/meter %s\n", argv[0], dev);
	if (lim && 0 == strcmp(lim, "--help")) {
		printf ("usage: %s [threshold(s)_in_pages]\n", argv[0]);
		printf ("example of threshold(s) available in %s\n", dev);
		return -1;
	}

	if (fd < 0) {
		printf ("cannot open device %s, do you have memnotify.ko loaded?\n", dev);
		return -1;
	} else {
		printf ("device %s opened successfuly with fd = %d\n", dev, fd);
	}

	if ((ret = read(fd, tmp, sizeof(tmp))) < 0) {
		printf ("reading from %s failed\n", dev);
		return -1;
	}
	tmp[ret - 1] = 0;
	printf ("read from %s %d bytes: '%s'\n", dev, ret, tmp);

	/* do we have a threshold? */
	if ( !lim )
		return 0;

	printf ("establishing threshold '%s' and waiting\n", lim);
	if ((ret = write(fd, argv[1], strlen(argv[1]))) < 0) {
		printf ("cannot set threshold '%s' for device %s\n", lim, dev);
		return -1;
	}
	
	printf ("polling for threshold '%s' to be changed to up/down\n", lim);
	fds->fd      = fd;
	fds->events  = POLLIN;
	fds->revents = 0;
	ret = poll(fds, 1, -1);
	printf ("poll(%d) returned %d\n", fd, ret);

	if ((ret = read(fd, tmp, sizeof(tmp))) < 0) {
		printf ("reading from %s failed\n", dev);
		return -1;
	}
	tmp[ret - 1] = 0;
	printf ("--> memory figures reached '%s'\n", tmp);

	return 0;
}
/* ---< end of mn_test.c >---- */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
