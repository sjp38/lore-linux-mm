Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D1CEB6B002C
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 15:23:38 -0400 (EDT)
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.4/8.14.4) with SMTP id p96JJagL032234
	for <linux-mm@kvack.org>; Thu, 6 Oct 2011 12:23:34 -0700
Received: from mail.thefacebook.com (corpout1.snc1.tfbnw.net [66.220.144.38])
	by m0004348.ppops.net with ESMTP id 109g7h05us-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Oct 2011 12:23:34 -0700
Message-ID: <4E8E0033.70602@fb.com>
Date: Thu, 6 Oct 2011 12:23:31 -0700
From: Arun Sharma <asharma@fb.com>
MIME-Version: 1.0
Subject: Accounting for "missing RAM"
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


I wrote a script to parse /proc/zoneinfo to figure out how memory on my 
server was getting used.

On many machines this is able to account for RAM +/- 10MB (which I 
consider within the margin of error).

But on many machines, there is 2-3GB of RAM that's unaccounted for and 
mysteriously missing from zoneinfo as well as /proc/meminfo.

When I parse /proc/kpageflags, pages with flags==0 correspond to 
nr_free_pages and pages with flags=KPF_BUDDY correspond to the number of 
"missing ram pages".

As far as I understand, KPF_BUDDY is set only on the first page of a 
higher order page. So if for some reason, we were counting an order=3 
page as 7 pages instead of 8, it'd explain what I am seeing.

  -Arun

#!/usr/bin/env python

import sys, re, string, os

class NestedDict(dict):
     """Implementation of perl's autovivification feature."""
     def __getitem__(self, item):
         try:
             return dict.__getitem__(self, item)
         except KeyError:
             value = self[item] = type(self)()
             return value

sep = re.compile('^Node (.*)')
pages = re.compile('.*nr.*pages.*')
slab = re.compile('.*nr.*slab.*')
present = re.compile('.*present.*')
pcpu_pageset_count = re.compile('.*count:.*')
zone = None
page_size = os.sysconf('SC_PAGESIZE')

zones = NestedDict()
for line in open('/proc/zoneinfo').readlines():
     m = sep.match(line)
     if m:
         zone = m.group(1)
         zones[zone]['pcpu_pageset'] = 0
         # Old kernels don't have this in /proc/zoneinfo
         zones[zone]['nr_free_pages'] = 0
     m1 = pages.match(line)
     m2 = slab.match(line)
     m3 = present.match(line)
     if m1 or m2 or m3:
         name, val = string.split(line)
         val = int(val)
         zones[zone][name] = val
         continue
     m4 = pcpu_pageset_count.match(line)
     if m4:
         name, val = string.split(line)
         val = int(val)
         zones[zone]['pcpu_pageset'] += val

global_diff = 0L
for z in zones.keys():
     allocated = zones[z]['present'] - zones[z]['nr_free_pages']
     if allocated < 0: continue
     print '##############'
     print z
     accounted = 0
     for k in ('nr_file_pages', 'nr_anon_pages',
               'nr_slab_reclaimable', 'nr_slab_unreclaimable',
               'nr_page_table_pages', 'pcpu_pageset'):
         val = zones[z][k]
         print k, val
         accounted += val
     print "allocated", "accounted", "diff"
     print allocated, accounted, allocated - accounted
     global_diff += (allocated - accounted)

vmalloc = 0L
vmalloc_re = re.compile('.*VmallocUsed:\s+(\d+).*')
for line in open('/proc/meminfo').readlines():
     m = vmalloc_re.match(line)
     if m:
         vmalloc_kb = int(m.group(1))
vmalloc = vmalloc_kb * 1024/page_size

print '##############'
print 'vmalloc',  vmalloc
print "missing ram: ", (global_diff - vmalloc) * page_size

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
