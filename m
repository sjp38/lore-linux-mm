Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id CDD906B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 15:03:47 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so114235456pac.2
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 12:03:47 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id tk5si25863616pbc.229.2015.08.17.12.03.46
        for <linux-mm@kvack.org>;
        Mon, 17 Aug 2015 12:03:46 -0700 (PDT)
From: "Patil, Kiran" <kiran.patil@intel.com>
Subject: RE: [Intel-wired-lan] [Patch V3 6/9] i40evf: Use numa_mem_id() to
	better support memoryless node
Date: Mon, 17 Aug 2015 19:03:44 +0000
Message-ID: <4197C471DCF8714FBA1FE32565271C148FFF786A@ORSMSX103.amr.corp.intel.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
 <1439781546-7217-7-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1439781546-7217-7-git-send-email-jiang.liu@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter
 Zijlstra <peterz@infradead.org>, "Wysocki, Rafael J" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, "Nelson, Shannon" <shannon.nelson@intel.com>, "Wyborny, Carolyn" <carolyn.wyborny@intel.com>, "Skidmore, Donald C" <donald.c.skidmore@intel.com>, "Vick, Matthew" <matthew.vick@intel.com>, "Ronciak, John" <john.ronciak@intel.com>, "Williams, Mitch A" <mitch.a.williams@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>

ACK.

Thanks,
-- Kiran P.

-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On =
Behalf Of Jiang Liu
Sent: Sunday, August 16, 2015 8:19 PM
To: Andrew Morton; Mel Gorman; David Rientjes; Mike Galbraith; Peter Zijlst=
ra; Wysocki, Rafael J; Tang Chen; Tejun Heo; Kirsher, Jeffrey T; Brandeburg=
, Jesse; Nelson, Shannon; Wyborny, Carolyn; Skidmore, Donald C; Vick, Matth=
ew; Ronciak, John; Williams, Mitch A
Cc: Luck, Tony; netdev@vger.kernel.org; x86@kernel.org; linux-hotplug@vger.=
kernel.org; linux-kernel@vger.kernel.org; linux-mm@kvack.org; intel-wired-l=
an@lists.osuosl.org; Jiang Liu
Subject: [Intel-wired-lan] [Patch V3 6/9] i40evf: Use numa_mem_id() to bett=
er support memoryless node

Function i40e_clean_rx_irq() tries to reuse memory pages allocated from the=
 nearest node. To better support memoryless node, use
numa_mem_id() instead of numa_node_id() to get the nearest node with memory=
.

This change should only affect performance.

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/et=
hernet/intel/i40evf/i40e_txrx.c
index 395f32f226c0..19ca96d8bd97 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1003,7 +1003,7 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_=
ring, int budget)
 	unsigned int total_rx_bytes =3D 0, total_rx_packets =3D 0;
 	u16 rx_packet_len, rx_header_len, rx_sph, rx_hbo;
 	u16 cleaned_count =3D I40E_DESC_UNUSED(rx_ring);
-	const int current_node =3D numa_node_id();
+	const int current_node =3D numa_mem_id();
 	struct i40e_vsi *vsi =3D rx_ring->vsi;
 	u16 i =3D rx_ring->next_to_clean;
 	union i40e_rx_desc *rx_desc;
--
1.7.10.4

_______________________________________________
Intel-wired-lan mailing list
Intel-wired-lan@lists.osuosl.org
http://lists.osuosl.org/mailman/listinfo/intel-wired-lan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
