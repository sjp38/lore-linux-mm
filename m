Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 12/34] powerpc/cell: move dma direct window setup out of dma_configure
In-Reply-To: <20181212143604.GA5137@lst.de>
References: <20181114082314.8965-1-hch@lst.de> <20181114082314.8965-13-hch@lst.de> <871s6r3sno.fsf@concordia.ellerman.id.au> <20181212143604.GA5137@lst.de>
Date: Sat, 15 Dec 2018 00:29:11 +1100
Message-ID: <87mup8uti0.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig <hch@lst.de> writes:
> On Sun, Dec 09, 2018 at 09:23:39PM +1100, Michael Ellerman wrote:
>> Christoph Hellwig <hch@lst.de> writes:
>> 
>> > Configure the dma settings at device setup time, and stop playing games
>> > with get_pci_dma_ops.  This prepares for using the common dma_configure
>> > code later on.
>> >
>> > Signed-off-by: Christoph Hellwig <hch@lst.de>
>> > ---
>> >  arch/powerpc/platforms/cell/iommu.c | 20 +++++++++++---------
>> >  1 file changed, 11 insertions(+), 9 deletions(-)
>> 
>> This one's crashing, haven't dug into why yet:
>
> Can you provide a gdb assembly of the exact crash site?  This looks
> like for some odd reason the DT structures aren't fully setup by the
> time we are probing the device, which seems odd.

It's dev->of_node which is NULL.

Because we were passed a platform_device which doesn't have an of_node.

It's the cbe-mic device created in cell_publish_devices().

I can fix that by simply checking for a NULL node, then the system boots
but then I have no network devices, due to:

  tg3 0000:00:01.0: enabling device (0140 -> 0142)
  tg3 0000:00:01.0: DMA engine test failed, aborting
  tg3: probe of 0000:00:01.0 failed with error -12
  tg3 0000:00:01.1: enabling device (0140 -> 0142)
  tg3 0000:00:01.1: DMA engine test failed, aborting
  tg3: probe of 0000:00:01.1 failed with error -12


I think the problem is that we don't want to set iommu_bypass_supported
unless cell_iommu_fixed_mapping_init() succeeds.

Yep. This makes it work for me on cell on top of your v5.

cheers


diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index 348a815779c1..8329fda17cc8 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -813,6 +813,10 @@ static u64 cell_iommu_get_fixed_address(struct device *dev)
 	int i, len, best, naddr, nsize, pna, range_size;
 
 	np = of_node_get(dev->of_node);
+	if (!np)
+		/* We can be called for platform devices that have no of_node */
+		goto out;
+
 	while (1) {
 		naddr = of_n_addr_cells(np);
 		nsize = of_n_size_cells(np);
@@ -1065,8 +1069,11 @@ static int __init cell_iommu_init(void)
 	/* Setup various callbacks */
 	cell_pci_controller_ops.dma_dev_setup = cell_pci_dma_dev_setup;
 
-	if (!iommu_fixed_disabled && cell_iommu_fixed_mapping_init() == 0)
+	if (!iommu_fixed_disabled && cell_iommu_fixed_mapping_init() == 0) {
+		cell_pci_controller_ops.iommu_bypass_supported =
+			cell_pci_iommu_bypass_supported;
 		goto done;
+	}
 
 	/* Create an iommu for each /axon node.  */
 	for_each_node_by_name(np, "axon") {
@@ -1085,10 +1092,6 @@ static int __init cell_iommu_init(void)
 	}
  done:
 	/* Setup default PCI iommu ops */
-	if (!iommu_fixed_disabled) {
-		cell_pci_controller_ops.iommu_bypass_supported =
-				cell_pci_iommu_bypass_supported;
-	}
 	set_pci_dma_ops(&dma_iommu_ops);
 	cell_iommu_enabled = true;
  bail:
