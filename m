Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id C3B1D6B00FB
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 16:27:22 -0400 (EDT)
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by acsinet15.oracle.com (Sentrion-MTA-4.2.2/Sentrion-MTA-4.2.2) with ESMTP id q3RKRKqb030643
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 20:27:20 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id q3RKRJe6011875
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 20:27:20 GMT
Received: from abhmt103.oracle.com (abhmt103.oracle.com [141.146.116.55])
	by acsmt357.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id q3RKRJsm016303
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:27:19 -0500
MIME-Version: 1.0
Message-ID: <f0b2f4a3-f6d4-41e9-943b-d083eec9e106@default>
Date: Fri, 27 Apr 2012 13:27:10 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: swapcache size oddness
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

In continuing digging through the swap code (with the
overall objective of improving zcache policy), I was
looking at the size of the swapcache.

My understanding was that the swapcache is simply a
buffer cache for pages that are actively in the process
of being swapped in or swapped out.  And keeping pages
around in the swapcache is inefficient because every
process access to a page in the swapcache causes a
minor page fault.

So I was surprised to see that, under a memory intensive
workload, the swapcache can grow quite large.  I have
seen it grow to almost half of the size of RAM.

Digging into this oddity, I re-discovered the definition
for "vm_swap_full()" which, in scan_swap_map() is a
pre-condition for calling __try_to_reclaim_swap().
But vm_swap_full() compares how much free swap space
there is "on disk", with the total swap space available
"on disk" with no regard to how much RAM there is.
So on my system, which is running with 1GB RAM and
10GB swap, I think this is the reason that swapcache
is growing so large.

Am I misunderstanding something?  Or is this code
making some (possibly false) assumptions about how
swap is/should be sized relative to RAM?  Or maybe the
size of swapcache is harmless as long as it doesn't
approach total "on disk" size?

(Sorry if this is a silly question again...)

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
