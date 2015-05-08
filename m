Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D3DA66B0032
	for <linux-mm@kvack.org>; Fri,  8 May 2015 09:23:53 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so81099969pdb.1
        for <linux-mm@kvack.org>; Fri, 08 May 2015 06:23:53 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id tg11si7168273pac.21.2015.05.08.06.22.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 06:22:52 -0700 (PDT)
Date: Fri, 8 May 2015 16:22:42 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH v4 0/3] idle memory tracking
Message-ID: <20150508132242.GQ31732@esperanza>
References: <cover.1431002699.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <cover.1431002699.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, May 07, 2015 at 05:09:39PM +0300, Vladimir Davydov wrote:
> ---- SCRIPT FOR COUNTING IDLE PAGES PER CGROUP ----

Oops, this script is stale. The correct one is here:
---
#! /usr/bin/python
#

import os
import stat
import errno
import struct

CGROUP_MOUNT = "/sys/fs/cgroup/memory"
BUFSIZE = 8 * 1024  # must be multiple of 8


def set_idle():
    f = open("/proc/kpageidle", "wb", BUFSIZE)
    while True:
        try:
            f.write(struct.pack("Q", pow(2, 64) - 1))
        except IOError as err:
            if err.errno == errno.ENXIO:
                break
            raise
    f.close()


def count_idle():
    f_flags = open("/proc/kpageflags", "rb", BUFSIZE)
    f_cgroup = open("/proc/kpagecgroup", "rb", BUFSIZE)
    f_idle = open("/proc/kpageidle", "rb", BUFSIZE)

    pfn = 0
    nr_idle = {}
    while True:
        s = f_flags.read(8)
        if not s:
            break

        flags, = struct.unpack('Q', s)
        cgino, = struct.unpack('Q', f_cgroup.read(8))

        bit = pfn % 64
        if not bit:
            idle_bitmap, = struct.unpack('Q', f_idle.read(8))

        idle = idle_bitmap >> bit & 1
        pfn += 1

        unevictable = flags >> 18 & 1
        huge = flags >> 22 & 1

        if idle and not unevictable:
            nr_idle[cgino] = nr_idle.get(cgino, 0) + (512 if huge else 1)

    f_flags.close()
    f_cgroup.close()
    f_idle.close()
    return nr_idle


print "Setting the idle flag for each page..."
set_idle()

raw_input("Wait until the workload accesses its working set, then press Enter")

print "Counting idle pages..."
nr_idle = count_idle()

for dir, subdirs, files in os.walk(CGROUP_MOUNT):
    ino = os.stat(dir)[stat.ST_INO]
    print dir + ": " + str(nr_idle.get(ino, 0) * 4) + " KB"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
