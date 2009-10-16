Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7294B6B004D
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 13:22:28 -0400 (EDT)
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
From: reinette chatre <reinette.chatre@intel.com>
In-Reply-To: <200910152142.02876.elendil@planet.nl>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera>
	 <200910150402.03953.elendil@planet.nl> <1255620567.21134.162.camel@rc-desk>
	 <200910152142.02876.elendil@planet.nl>
Content-Type: text/plain
Date: Fri, 16 Oct 2009 10:21:56 -0700
Message-Id: <1255713716.21134.186.camel@rc-desk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, "Abbas, Mohamed" <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-10-15 at 12:41 -0700, Frans Pop wrote:
> On Thursday 15 October 2009, reinette chatre wrote:
> > > The log file timestamps don't tell much as the logging gets delayed,
> > > so they all end up at the same time. Maybe I should enable the kernel
> > > timestamps so we can see how far apart these failures are.
> >
> > If you can get accurate timing it will be very useful. I am interested
> > to see how quickly it goes from "48 free buffers" to "0 free buffers".
> 
> Attached the dmesg for three consecutive test runs (i.e. without 
> rebooting). Not that the 2nd one includes only "0 free buffers" messages, 
> even though the behavior (point where desktop freezes and music stops) 
> looked similar.

Thank you very much. I am studying it.


> Not sure if you can tell all that much from the data.
> 
> N.B. You may want to clean this up in iwlwifi code:
> iwl-dev.h:#include "iwl-fh.h"
> iwl-dev.h:#define RX_LOW_WATERMARK 8
> iwl-fh.h:#define RX_LOW_WATERMARK 8
> 
> I.e: RX_LOW_WATERMARK is defined in iwl-dev.h even though that includes 
> iwl-fh.h where it's also defined. The same may be true for other defines.

Sorry about that. The patch below will fix that. I will send it
separately to wireless list.

>From 7cc8e6482b359eef5ce099457037a237d355b5b1 Mon Sep 17 00:00:00 2001
From: Reinette Chatre <reinette.chatre@intel.com>
Date: Fri, 16 Oct 2009 10:11:10 -0700
Subject: [PATCH] iwlwifi: remove duplicate defines

RX_FREE_BUFFERS and RX_LOW_WATERMARK are currently defined in four places.
Based on how files are included we only need the definition in iwl-fh.h

Signed-off-by: Reinette Chatre <reinette.chatre@intel.com>
Reported-by: Frans Pop <elendil@planet.nl>
---
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h |    6 ------
 drivers/net/wireless/iwlwifi/iwl-3945.h    |    6 ------
 drivers/net/wireless/iwlwifi/iwl-dev.h     |    6 ------
 3 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-hw.h b/drivers/net/wireless/iwlwifi/iwl-3945-hw.h
index ccdac69..6fd10d4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-hw.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-hw.h
@@ -248,12 +248,6 @@ struct iwl3945_eeprom {
 #define TFD_CTL_PAD_SET(n)         (n << 28)
 #define TFD_CTL_PAD_GET(ctl)       (ctl >> 28)
 
-/*
- * RX related structures and functions
- */
-#define RX_FREE_BUFFERS 64
-#define RX_LOW_WATERMARK 8
-
 /* Sizes and addresses for instruction and data memory (SRAM) in
  * 3945's embedded processor.  Driver access is via HBUS_TARG_MEM_* regs. */
 #define IWL39_RTC_INST_LOWER_BOUND		(0x000000)
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.h b/drivers/net/wireless/iwlwifi/iwl-3945.h
index f3907c1..84fa0d7 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.h
@@ -130,12 +130,6 @@ struct iwl3945_frame {
 #define SN_TO_SEQ(ssn) (((ssn) << 4) & IEEE80211_SCTL_SEQ)
 #define MAX_SN ((IEEE80211_SCTL_SEQ) >> 4)
 
-/*
- * RX related structures and functions
- */
-#define RX_FREE_BUFFERS 64
-#define RX_LOW_WATERMARK 8
-
 #define SUP_RATE_11A_MAX_NUM_CHANNELS  8
 #define SUP_RATE_11B_MAX_NUM_CHANNELS  4
 #define SUP_RATE_11G_MAX_NUM_CHANNELS  12
diff --git a/drivers/net/wireless/iwlwifi/iwl-dev.h b/drivers/net/wireless/iwlwifi/iwl-dev.h
index 1378654..0fa0cf5 100644
--- a/drivers/net/wireless/iwlwifi/iwl-dev.h
+++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
@@ -406,12 +406,6 @@ struct iwl_host_cmd {
 	u8 id;
 };
 
-/*
- * RX related structures and functions
- */
-#define RX_FREE_BUFFERS 64
-#define RX_LOW_WATERMARK 8
-
 #define SUP_RATE_11A_MAX_NUM_CHANNELS  8
 #define SUP_RATE_11B_MAX_NUM_CHANNELS  4
 #define SUP_RATE_11G_MAX_NUM_CHANNELS  12
-- 
1.5.6.3



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
