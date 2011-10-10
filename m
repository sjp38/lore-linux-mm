Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3826B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 14:52:19 -0400 (EDT)
Received: by ggdk5 with SMTP id k5so6438242ggd.14
        for <linux-mm@kvack.org>; Mon, 10 Oct 2011 11:52:17 -0700 (PDT)
Subject: Re: [PATCH 0/9] skb fragment API: convert network drivers (part V)
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20111010.142040.2267571270586671416.davem@davemloft.net>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
	 <20111010.142040.2267571270586671416.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 10 Oct 2011 20:52:11 +0200
Message-ID: <1318272731.2567.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: Ian.Campbell@citrix.com, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

Le lundi 10 octobre 2011 A  14:20 -0400, David Miller a A(C)crit :
> From: Ian Campbell <Ian.Campbell@citrix.com>
> Date: Mon, 10 Oct 2011 12:11:16 +0100
> 
> > I think "struct subpage" is a generally useful tuple I added to a
> > central location (mm_types.h) rather than somewhere networking or driver
> > specific but I can trivially move if preferred.
> 
> I'm fine with the patch series, but this generic datastructure
> addition needs some feedback first.

I was planning to send a patch to abstract frag->size manipulation and
ease upcoming truesize certification work.

static inline int skb_frag_size(const skb_frag_t *frag)
{
	return frag->size;
}

static inline void skb_frag_size_set(skb_frag_t *frag, int size)
{
	frag->size = size;
}

static inline void skb_frag_size_add(skb_frag_t *frag, int size)
{
	frag->size += size;
}

static inline void skb_frag_size_sub(skb_frag_t *frag, int size)
{
	frag->size -= size;
}

Is it OK if I send a single patch right now ?

I am asking because it might clash a bit with Ian work.


 drivers/atm/eni.c                                    |    2 
 drivers/infiniband/hw/amso1100/c2.c                  |    4 
 drivers/infiniband/hw/nes/nes_nic.c                  |   10 -
 drivers/infiniband/ulp/ipoib/ipoib_cm.c              |    2 
 drivers/infiniband/ulp/ipoib/ipoib_ib.c              |   18 +-
 drivers/net/ethernet/3com/3c59x.c                    |    6 
 drivers/net/ethernet/3com/typhoon.c                  |    6 
 drivers/net/ethernet/adaptec/starfire.c              |    8 -
 drivers/net/ethernet/aeroflex/greth.c                |    8 -
 drivers/net/ethernet/alteon/acenic.c                 |   10 -
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c      |    2 
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c      |    6 
 drivers/net/ethernet/atheros/atlx/atl1.c             |   12 -
 drivers/net/ethernet/broadcom/bnx2.c                 |   12 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c      |   14 -
 drivers/net/ethernet/broadcom/tg3.c                  |    8 -
 drivers/net/ethernet/brocade/bna/bnad.c              |    6 
 drivers/net/ethernet/chelsio/cxgb/sge.c              |   10 -
 drivers/net/ethernet/chelsio/cxgb3/sge.c             |   12 -
 drivers/net/ethernet/chelsio/cxgb4/sge.c             |   26 +--
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c           |   26 +--
 drivers/net/ethernet/cisco/enic/enic_main.c          |   12 -
 drivers/net/ethernet/emulex/benet/be_main.c          |   18 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c            |    8 -
 drivers/net/ethernet/ibm/emac/core.c                 |    2 
 drivers/net/ethernet/ibm/ibmveth.c                   |    6 
 drivers/net/ethernet/intel/e1000/e1000_main.c        |    6 
 drivers/net/ethernet/intel/e1000e/netdev.c           |    6 
 drivers/net/ethernet/intel/igb/igb_main.c            |    2 
 drivers/net/ethernet/intel/igbvf/netdev.c            |    4 
 drivers/net/ethernet/intel/ixgb/ixgb_main.c          |    4 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c        |    4 
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c    |    6 
 drivers/net/ethernet/jme.c                           |    4 
 drivers/net/ethernet/marvell/mv643xx_eth.c           |    9 -
 drivers/net/ethernet/marvell/skge.c                  |    8 -
 drivers/net/ethernet/marvell/sky2.c                  |   16 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c           |   14 -
 drivers/net/ethernet/mellanox/mlx4/en_tx.c           |   12 -
 drivers/net/ethernet/micrel/ksz884x.c                |    2 
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c     |   14 -
 drivers/net/ethernet/natsemi/ns83820.c               |    4 
 drivers/net/ethernet/neterion/s2io.c                 |   12 -
 drivers/net/ethernet/neterion/vxge/vxge-main.c       |   12 -
 drivers/net/ethernet/nvidia/forcedeth.c              |   18 +-
 drivers/net/ethernet/pasemi/pasemi_mac.c             |    8 -
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |    6 
 drivers/net/ethernet/qlogic/qla3xxx.c                |    6 
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c     |    6 
 drivers/net/ethernet/qlogic/qlge/qlge_main.c         |    6 
 drivers/net/ethernet/realtek/8139cp.c                |    4 
 drivers/net/ethernet/realtek/r8169.c                 |    4 
 drivers/net/ethernet/sfc/rx.c                        |    2 
 drivers/net/ethernet/sfc/tx.c                        |    8 -
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |    4 
 drivers/net/ethernet/sun/cassini.c                   |    8 -
 drivers/net/ethernet/sun/niu.c                       |    6 
 drivers/net/ethernet/sun/sungem.c                    |    4 
 drivers/net/ethernet/sun/sunhme.c                    |    4 
 drivers/net/ethernet/tehuti/tehuti.c                 |    6 
 drivers/net/ethernet/tile/tilepro.c                  |    2 
 drivers/net/ethernet/tundra/tsi108_eth.c             |    6 
 drivers/net/ethernet/via/via-velocity.c              |    6 
 drivers/net/ethernet/xilinx/ll_temac_main.c          |    4 
 drivers/net/virtio_net.c                             |    8 -
 drivers/net/vmxnet3/vmxnet3_drv.c                    |   12 -
 drivers/net/xen-netback/netback.c                    |    4 
 drivers/net/xen-netfront.c                           |    4 
 drivers/scsi/cxgbi/libcxgbi.c                        |   10 -
 drivers/scsi/fcoe/fcoe_transport.c                   |    2 
 drivers/staging/hv/netvsc_drv.c                      |    4 
 include/linux/skbuff.h                               |   28 +++
 net/appletalk/ddp.c                                  |    5 
 net/core/datagram.c                                  |   16 +-
 net/core/dev.c                                       |    6 
 net/core/pktgen.c                                    |   12 -
 net/core/skbuff.c                                    |   72 +++++-----
 net/core/user_dma.c                                  |    4 
 net/ipv4/inet_lro.c                                  |    8 -
 net/ipv4/ip_fragment.c                               |    4 
 net/ipv4/ip_output.c                                 |    6 
 net/ipv4/tcp.c                                       |    9 -
 net/ipv4/tcp_output.c                                |    8 -
 net/ipv6/ip6_output.c                                |    5 
 net/ipv6/netfilter/nf_conntrack_reasm.c              |    4 
 net/ipv6/reassembly.c                                |    4 
 net/xfrm/xfrm_ipcomp.c                               |    2 
 87 files changed, 389 insertions(+), 359 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
