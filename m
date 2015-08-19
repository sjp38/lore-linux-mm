Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 58DCE6B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 18:38:13 -0400 (EDT)
Received: by pawq9 with SMTP id q9so12450529paw.3
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 15:38:13 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id kn4si3850273pdb.200.2015.08.19.15.38.12
        for <linux-mm@kvack.org>;
        Wed, 19 Aug 2015 15:38:12 -0700 (PDT)
From: "Patil, Kiran" <kiran.patil@intel.com>
Subject: RE: [Intel-wired-lan] [Patch V3 5/9] i40e: Use numa_mem_id() to
 better	support memoryless node
Date: Wed, 19 Aug 2015 22:38:09 +0000
Message-ID: <4197C471DCF8714FBA1FE32565271C148FFFF4D3@ORSMSX103.amr.corp.intel.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
 <1439781546-7217-6-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1439781546-7217-6-git-send-email-jiang.liu@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter
 Zijlstra <peterz@infradead.org>, "Wysocki, Rafael J" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, "Nelson, Shannon" <shannon.nelson@intel.com>, "Wyborny, Carolyn" <carolyn.wyborny@intel.com>, "Skidmore, Donald C" <donald.c.skidmore@intel.com>, "Vick, Matthew" <matthew.vick@intel.com>, "Ronciak, John" <john.ronciak@intel.com>, "Williams, Mitch A" <mitch.a.williams@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>

Acked-by: Kiran Patil <kiran.patil@intel.com>

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
Subject: [Intel-wired-lan] [Patch V3 5/9] i40e: Use numa_mem_id() to better=
 support memoryless node

Function i40e_clean_rx_irq() tries to reuse memory pages allocated from the=
 nearest node. To better support memoryless node, use
numa_mem_id() instead of numa_node_id() to get the nearest node with memory=
.

This change should only affect performance.

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethe=
rnet/intel/i40e/i40e_txrx.c
index 9a4f2bc70cd2..a8f618cb8eb0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1516,7 +1516,7 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_=
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
