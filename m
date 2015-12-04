Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5EAB16B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 03:50:03 -0500 (EST)
Received: by wmec201 with SMTP id c201so63605253wme.0
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 00:50:02 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id l11si17109417wjw.184.2015.12.04.00.50.02
        for <linux-mm@kvack.org>;
        Fri, 04 Dec 2015 00:50:02 -0800 (PST)
Date: Fri, 4 Dec 2015 09:50:00 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: [PATCH net] atl1c: Improve driver not to do order 4 GFP_ATOMIC
 allocation
Message-ID: <20151204085000.GA30233@amd>
References: <20151126163413.GA3816@amd>
 <20151127082010.GA2500@dhcp22.suse.cz>
 <20151128145113.GB4135@amd>
 <20151203155905.GA31974@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151203155905.GA31974@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, davem@davemloft.net, Andrew Morton <akpm@osdl.org>
Cc: kernel list <linux-kernel@vger.kernel.org>, jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

atl1c driver is doing order-4 allocation with GFP_ATOMIC
priority. That often breaks  networking after resume. Switch to
GFP_KERNEL. Still not ideal, but should be significantly better.

atl1c_setup_ring_resources() is called from .open() function, and
already uses GFP_KERNEL, so this change is safe.
    
Signed-off-by: Pavel Machek <pavel@ucw.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: stable <stable@vger.kernel.org>

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 2795d6d..8b5988e 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1016,13 +1016,12 @@ static int atl1c_setup_ring_resources(struct atl1c_adapter *adapter)
 		sizeof(struct atl1c_recv_ret_status) * rx_desc_count +
 		8 * 4;
 
-	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
-				&ring_header->dma);
+	ring_header->desc = dma_zalloc_coherent(&pdev->dev, ring_header->size,
+						&ring_header->dma, GFP_KERNEL);
 	if (unlikely(!ring_header->desc)) {
-		dev_err(&pdev->dev, "pci_alloc_consistend failed\n");
+		dev_err(&pdev->dev, "could not get memory for DMA buffer\n");
 		goto err_nomem;
 	}
-	memset(ring_header->desc, 0, ring_header->size);
 	/* init TPD ring */
 
 	tpd_ring[0].dma = roundup(ring_header->dma, 8);

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
