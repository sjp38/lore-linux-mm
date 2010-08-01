Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 83DBA6B02C1
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 01:49:35 -0400 (EDT)
Date: Sun, 1 Aug 2010 13:49:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] vmscan: remove wait_on_page_writeback() from pageout()
Message-ID: <20100801054901.GA8043@localhost>
References: <20100728183625.4A7F.A69D9226@jp.fujitsu.com>
 <20100728095058.GF5300@csn.ul.ie>
 <20100728185457.4A82.A69D9226@jp.fujitsu.com>
 <20100801052758.GB7515@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="jRHKVT23PllUwdXP"
Content-Disposition: inline
In-Reply-To: <20100801052758.GB7515@localhost>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andy Whitcroft <apw@shadowen.org>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>


--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

> > Well, "vmscan: raise the bar to PAGEOUT_IO_SYNC stalls" is completely bandaid and
> 
> No joking. The (DEF_PRIORITY-2) is obviously too permissive and shall be fixed.
> 
> > much IO under slow USB flash memory device still cause such problem even if the patch is applied.
> 
> As for this patch, raising the bar to PAGEOUT_IO_SYNC reduces both
> calls to congestion_wait() and wait_on_page_writeback(). So it
> absolutely helps by itself.

To base the discussion on more subjective numbers, I run the attached
debug patch on my desktop. I have 4GB memory without swap. Two
processes are started:

        usemem 3g --sleep 300
        cp /dev/zero /tmp

I didn't get any stall reports with DEF_PRIORITY/3, so I lowered it to
DEF_PRIORITY-2 and get the below reports. The test is a good testimony
for "vmscan: raise the bar to PAGEOUT_IO_SYNC stalls": it's working as
expected and does avoid the stalls. When the priority goes down to 4,
your patch to remove congestion_wait() will come into play. So they
are both good patches to have.

[Sorry I cannot afford to add more stresses to test your patch.
 My remote test box was stressed to death yesterday and asks for
 some physical reset tomorrow. My desktop has already corrupted the
 .zsh_history file twice and can't risk losing more data..]

Thanks,
Fengguang

[ 1113.740511] reclaim stall: priority 9
[ 1113.844288] reclaim stall: priority 9
[ 1113.944292] reclaim stall: priority 9
[ 1114.048274] reclaim stall: priority 9
[ 1114.252816] reclaim stall: priority 9
[ 1114.352293] reclaim stall: priority 9
[ 1114.452265] reclaim stall: priority 9
[ 1114.552258] reclaim stall: priority 9
[ 1114.652259] reclaim stall: priority 9
[ 1114.752259] reclaim stall: priority 9
[ 1114.852252] reclaim stall: priority 9
[ 1114.952254] reclaim stall: priority 9
[ 1115.052251] reclaim stall: priority 9
[ 1115.152254] reclaim stall: priority 9
[ 1115.252242] reclaim stall: priority 9
[ 1115.452251] reclaim stall: priority 8
[ 1115.552250] reclaim stall: priority 8
[ 1116.403126] reclaim stall: priority 9
[ 1116.440364] reclaim stall: priority 9
[ 1116.478632] reclaim stall: priority 9
[ 1116.500230] reclaim stall: priority 9
[ 1116.540243] reclaim stall: priority 9
[ 1116.576266] reclaim stall: priority 9
[ 1116.600223] reclaim stall: priority 9
[ 1116.640221] reclaim stall: priority 9
[ 1116.676219] reclaim stall: priority 9
[ 1116.740233] reclaim stall: priority 9
[ 1116.776222] reclaim stall: priority 9
[ 1116.840218] reclaim stall: priority 9
[ 1116.876239] reclaim stall: priority 9
[ 1116.940217] reclaim stall: priority 9
[ 1116.976212] reclaim stall: priority 9
[ 1117.040213] reclaim stall: priority 9
[ 1117.076214] reclaim stall: priority 9
[ 1117.140212] reclaim stall: priority 9
[ 1117.604362] reclaim stall: priority 9
[ 1117.704192] writeback stall: page ffffea00009243e0
[ 1118.187369] writeback stall: page ffffea0000924418
[ 1118.187600] writeback stall: page ffffea00009244c0
[ 1118.187878] writeback stall: page ffffea00009245a0
[ 1118.188117] writeback stall: page ffffea0000924648
[ 1118.188351] writeback stall: page ffffea00009246f0
[ 1118.188717] writeback stall: page ffffea0000924760
[ 1118.188889] writeback stall: page ffffea0000924798
[ 1118.189175] writeback stall: page ffffea0000924840
[ 1118.189382] writeback stall: page ffffea0000924878
[ 1118.189607] writeback stall: page ffffea00009248e8
[ 1118.189949] writeback stall: page ffffea0000924990
[ 1118.190019] writeback stall: page ffffea00009249c8
[ 1118.190245] writeback stall: page ffffea0000924a00
[ 1118.190462] writeback stall: page ffffea0000924a70
[ 1119.732285] reclaim stall: priority 9
[ 1119.832174] reclaim stall: priority 9
[ 1119.932156] reclaim stall: priority 9
[ 1120.032214] reclaim stall: priority 9
[ 1120.132161] reclaim stall: priority 9
[ 1120.232153] reclaim stall: priority 9
[ 1120.332157] reclaim stall: priority 9
[ 1121.628321] reclaim stall: priority 9
[ 1121.728124] writeback stall: page ffffea0000884f00
[ 1122.180295] reclaim stall: priority 9
[ 1122.280151] reclaim stall: priority 9
[ 1122.820258] reclaim stall: priority 9
[ 1122.920117] reclaim stall: priority 9
[ 1123.020112] reclaim stall: priority 9
[ 1123.120114] reclaim stall: priority 9
[ 1123.220112] reclaim stall: priority 9
[ 1123.320105] reclaim stall: priority 9
[ 1124.388223] reclaim stall: priority 9
[ 1124.488088] reclaim stall: priority 9
[ 1124.588086] reclaim stall: priority 9
[ 1124.688081] reclaim stall: priority 9
[ 1124.788082] reclaim stall: priority 9
[ 1124.888108] reclaim stall: priority 9
[ 1125.352232] reclaim stall: priority 9
[ 1125.452081] reclaim stall: priority 9
[ 1125.552062] reclaim stall: priority 9
[ 1125.652064] reclaim stall: priority 9
[ 1125.752058] reclaim stall: priority 9
[ 1125.852065] reclaim stall: priority 9
[ 1126.580188] reclaim stall: priority 9
[ 1126.680054] reclaim stall: priority 9
[ 1126.780049] reclaim stall: priority 9
[ 1126.880046] reclaim stall: priority 9
[ 1126.980035] reclaim stall: priority 9
[ 1127.080057] reclaim stall: priority 9
[ 1128.904276] reclaim stall: priority 9
[ 1129.008027] reclaim stall: priority 9
[ 1129.108025] reclaim stall: priority 9
[ 1129.212002] reclaim stall: priority 9
[ 1129.311995] reclaim stall: priority 9
[ 1129.412006] reclaim stall: priority 9
[ 1129.511995] reclaim stall: priority 9
[ 1130.168119] reclaim stall: priority 9
[ 1130.268000] reclaim stall: priority 9
[ 1130.368001] reclaim stall: priority 9
[ 1130.468013] reclaim stall: priority 9
[ 1130.568022] reclaim stall: priority 9
[ 1130.668001] reclaim stall: priority 9
[ 1131.152175] reclaim stall: priority 9
[ 1131.256038] reclaim stall: priority 9
[ 1131.359971] reclaim stall: priority 9
[ 1131.459967] reclaim stall: priority 9
[ 1131.559958] reclaim stall: priority 9
[ 1131.660036] reclaim stall: priority 9
[ 1132.248287] reclaim stall: priority 9
[ 1132.348079] reclaim stall: priority 9
[ 1132.447956] reclaim stall: priority 9
[ 1132.547962] reclaim stall: priority 9
[ 1132.652008] reclaim stall: priority 9
[ 1132.755940] reclaim stall: priority 9
[ 1132.859931] reclaim stall: priority 9
[ 1132.963945] reclaim stall: priority 9
[ 1133.167944] reclaim stall: priority 8
[ 1133.267944] reclaim stall: priority 8
[ 1133.912054] reclaim stall: priority 9
[ 1134.015934] reclaim stall: priority 9
[ 1134.116134] reclaim stall: priority 9
[ 1134.220318] reclaim stall: priority 9
[ 1134.320860] reclaim stall: priority 9
[ 1134.332669] reclaim stall: priority 9
[ 1134.419914] reclaim stall: priority 9
[ 1134.435900] reclaim stall: priority 9
[ 1134.519933] reclaim stall: priority 9
[ 1134.727904] reclaim stall: priority 8
[ 1134.827919] reclaim stall: priority 8
[ 1135.196197] reclaim stall: priority 9
[ 1136.104040] reclaim stall: priority 9
[ 1136.203907] reclaim stall: priority 9
[ 1136.303883] reclaim stall: priority 9
[ 1136.403880] reclaim stall: priority 9
[ 1136.503875] reclaim stall: priority 9
[ 1136.603877] reclaim stall: priority 9
[ 1136.703878] reclaim stall: priority 9
[ 1136.903906] reclaim stall: priority 8
[ 1137.003878] reclaim stall: priority 8
[ 1137.103906] reclaim stall: priority 8
[ 1137.203875] reclaim stall: priority 8
[ 1137.303886] reclaim stall: priority 8
[ 1137.403870] reclaim stall: priority 8
[ 1137.555979] reclaim stall: priority 9
[ 1137.655858] reclaim stall: priority 9
[ 1137.755857] reclaim stall: priority 9
[ 1137.855907] reclaim stall: priority 9
[ 1138.380061] reclaim stall: priority 9
[ 1138.479843] reclaim stall: priority 9
[ 1138.891937] reclaim stall: priority 9
[ 1138.991837] reclaim stall: priority 9
[ 1139.091834] reclaim stall: priority 9
[ 1139.191836] reclaim stall: priority 9
[ 1139.291831] reclaim stall: priority 9
[ 1139.321243] reclaim stall: priority 9
[ 1139.391816] reclaim stall: priority 9
[ 1139.419826] reclaim stall: priority 9
[ 1139.519827] reclaim stall: priority 9
[ 1139.592157] reclaim stall: priority 8
[ 1139.619845] reclaim stall: priority 9
[ 1139.691853] reclaim stall: priority 8
[ 1139.719901] reclaim stall: priority 9
[ 1139.791847] reclaim stall: priority 8
[ 1140.373738] reclaim stall: priority 9
[ 1140.475803] reclaim stall: priority 9
[ 1141.079895] reclaim stall: priority 9
[ 1141.180178] reclaim stall: priority 9
[ 1141.283798] reclaim stall: priority 9
[ 1141.383833] reclaim stall: priority 9
[ 1141.483796] reclaim stall: priority 9
[ 1141.583790] reclaim stall: priority 9
[ 1141.783930] reclaim stall: priority 8
[ 1141.883856] reclaim stall: priority 8
[ 1141.983778] reclaim stall: priority 8
[ 1142.343862] reclaim stall: priority 9
[ 1142.443768] reclaim stall: priority 9
[ 1142.959951] reclaim stall: priority 9
[ 1143.059825] reclaim stall: priority 9
[ 1144.095916] reclaim stall: priority 9
[ 1144.195742] reclaim stall: priority 9
[ 1144.295747] reclaim stall: priority 9
[ 1144.395732] reclaim stall: priority 9
[ 1144.495739] reclaim stall: priority 9
[ 1144.595777] reclaim stall: priority 9
[ 1145.487848] reclaim stall: priority 9
[ 1145.587744] reclaim stall: priority 9
[ 1145.687715] reclaim stall: priority 9
[ 1145.943870] reclaim stall: priority 9
[ 1145.956733] reclaim stall: priority 9
[ 1146.043732] reclaim stall: priority 9
[ 1146.055828] reclaim stall: priority 9
[ 1146.143705] reclaim stall: priority 9
[ 1146.155908] reclaim stall: priority 9
[ 1146.243759] reclaim stall: priority 9
[ 1146.255824] reclaim stall: priority 9
[ 1146.355714] reclaim stall: priority 9
[ 1146.459719] reclaim stall: priority 9
[ 1146.603878] reclaim stall: priority 9
[ 1146.703730] reclaim stall: priority 9
[ 1146.855804] reclaim stall: priority 9
[ 1146.959689] writeback stall: page ffffea0003ba1780
[ 1147.290356] reclaim stall: priority 9
[ 1147.387697] reclaim stall: priority 9
[ 1148.103793] reclaim stall: priority 9
[ 1148.203692] reclaim stall: priority 9
[ 1148.307703] reclaim stall: priority 9
[ 1148.407744] reclaim stall: priority 9
[ 1148.507692] reclaim stall: priority 9

--jRHKVT23PllUwdXP
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="debug-vmscan-stall.patch"

Subject: 
From: Wu Fengguang <fengguang.wu@intel.com>
Date: Sun Aug 01 13:04:58 CST 2010


Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

--- linux-2.6.orig/mm/vmscan.c	2010-08-01 13:04:37.000000000 +0800
+++ linux-2.6/mm/vmscan.c	2010-08-01 13:04:46.000000000 +0800
@@ -391,8 +391,10 @@ static pageout_t pageout(struct page *pa
 		 * direct reclaiming a large contiguous area and the
 		 * first attempt to free a range of pages fails.
 		 */
-		if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
+		if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC) {
+			printk("pageout stall: page %p\n", page);
 			wait_on_page_writeback(page);
+		}
 
 		if (!PageWriteback(page)) {
 			/* synchronous write or broken a_ops? */
@@ -672,9 +674,10 @@ static unsigned long shrink_page_list(st
 			 * for any page for which writeback has already
 			 * started.
 			 */
-			if (sync_writeback == PAGEOUT_IO_SYNC && may_enter_fs)
+			if (sync_writeback == PAGEOUT_IO_SYNC && may_enter_fs) {
+				printk("writeback stall: page %p\n", page);
 				wait_on_page_writeback(page);
-			else
+			} else
 				goto keep_locked;
 		}
 
@@ -1244,6 +1248,7 @@ static unsigned long shrink_inactive_lis
 
 		/* Check if we should syncronously wait for writeback */
 		if (should_reclaim_stall(nr_taken, nr_freed, priority, sc)) {
+			printk("reclaim stall: priority %d\n", priority);
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 			/*

--jRHKVT23PllUwdXP--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
