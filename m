Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m1DGHGu1028315
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 11:17:28 -0500
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m1DGHFli000745
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 11:17:15 -0500
Received: from 192.168.1.105 (IDENT:U2FsdGVkX19Sns0kDo6u5gSX7bft1tnGEmoe8PT9JA4@vpn-248-145.boston.redhat.com [10.13.248.145])
	by mail.boston.redhat.com (8.13.1/8.13.1) with ESMTP id m1DGHBEa028046
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 11:17:12 -0500
Subject: Problem with /proc/sys/vm/lowmem_reserve_ratio
From: Larry Woodman <lwoodman@redhat.com>
Content-Type: text/plain
Date: Wed, 13 Feb 2008 11:09:34 -0500
Message-Id: <1202918974.4838.41.camel@dhcp83-56.boston.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

balance_pgdat() calls zone_watermark_ok() three times, the first call
passes a zero(0) in as the 4th argument.  This 4th argument is the
classzone_idx which is used as the index into the 
zone->lowmem_reserve[] array.  Since setup_per_zone_lowmem_reserve()
always sets the zone->lowmem_reserve[0] = 0(because there is nothing
below the DMA zone), zone_watermark_ok() will not consider the
lowmem_reserve pages when zero is passed as the 4th arg.  Shouldnt this
4th argument be either "i" or "nr_zones - 1" ???

-------------------------------------------------------------------------
--- linux-2.6.24.noarch/mm/vmscan.c.orig        2008-02-13
11:14:55.000000000 -0500
+++ linux-2.6.24.noarch/mm/vmscan.c     2008-02-13 11:15:02.000000000
-0500
@@ -1375,7 +1375,7 @@ loop_again:
                                continue;

                        if (!zone_watermark_ok(zone, order, zone-
>pages_high,
-                                              0, 0)) {
+                                              i, 0)) {
                                end_zone = i;
                                break;
-------------------------------------------------------------------------
--- linux-2.6.24.noarch/mm/vmscan.c.orig        2008-02-13
11:14:55.000000000 -0500
+++ linux-2.6.24.noarch/mm/vmscan.c     2008-02-13 11:16:35.000000000
-0500
@@ -1375,7 +1375,7 @@ loop_again:
                                continue;

                        if (!zone_watermark_ok(zone, order, zone-
>pages_high,
-                                              0, 0)) {
+                                              nr_zones - 1, 0)) {
                                end_zone = i;
                                break;
                        }
-------------------------------------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
