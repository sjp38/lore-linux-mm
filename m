Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17ZQUE-0007jp-00
	for <linux-mm@kvack.org>; Mon, 29 Jul 2002 23:28:02 -0700
Date: Mon, 29 Jul 2002 23:28:02 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: watching bloated slabs
Message-ID: <20020730062802.GB29537@holomorphy.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="yNb1oOkm5a9FJOVX"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--yNb1oOkm5a9FJOVX
Content-Type: text/plain; charset=us-ascii
Content-Description: bloated message
Content-Disposition: inline

I got to wondering about how bloated various slabs were, and how
perhaps to track their bloatedness over time. So I brewed up a couple
of scripts to help more closely observe their humongous bloatedness.

bloatmon just cooks some slab stats so it grinds out lines with the
cache name, amount of space granted to callers, amount of space parked
in the slab, and percent utilization.

bloatmeter drives bloatmon in a loop, sorts its output by %util, and
chops off the output at 22 lines to put the most underutilized (and
hence bloated) slabs up top.

Cheers,
Bill

--yNb1oOkm5a9FJOVX
Content-Type: text/plain; charset=us-ascii
Content-Description: bloatmon
Content-Disposition: attachment; filename=bloatmon

#!/usr/bin/awk -f
BEGIN {
	printf "%18s    %8s %8s %8s\n", "cache", "active", "alloc", "%util";
}

{
	if ($3 != 0.0) {
		pct  = 100.0 * $2 / $3;
		frac = (10000.0 * $2 / $3) % 100;
	} else {
		pct  = 100.0;
		frac = 0.0;
	}
	active = ($2 * $4)/1024;
	alloc  = ($3 * $4)/1024;
	if ((alloc - active) < 1.0) {
		pct  = 100.0;
		frac = 0.0;
	}
	printf "%18s: %8dKB %8dKB  %3d.%-2d\n", $1, active, alloc, pct, frac;
}

--yNb1oOkm5a9FJOVX
Content-Type: text/plain; charset=us-ascii
Content-Description: bloatmeter
Content-Disposition: attachment; filename=bloatmeter

#!/bin/sh
while : ; do
	grep -v '^slabinfo' /proc/slabinfo	\
		| bloatmon			\
		| sort -n -k 4,4		\
		| head -22
	sleep 5
	echo
done

--yNb1oOkm5a9FJOVX--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
