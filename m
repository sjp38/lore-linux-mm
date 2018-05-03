Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B7DEB6B0009
	for <linux-mm@kvack.org>; Thu,  3 May 2018 00:14:19 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id m68so14398627pfm.20
        for <linux-mm@kvack.org>; Wed, 02 May 2018 21:14:19 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a3si1369912pff.43.2018.05.02.21.14.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 21:14:15 -0700 (PDT)
Date: Thu, 3 May 2018 12:14:50 +0800
From: kernel test robot <shun.hao@intel.com>
Subject: [lkp-robot] 486ad79630 [   15.532543] BUG: unable to handle kernel
 NULL pointer dereference at 0000000000000004
Message-ID: <20180503041450.pq2njvkssxtay64o@shao2-debian>
Reply-To: kernel test robot <lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="g4n64py7ydqsqxql"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, LKP <lkp@01.org>


--g4n64py7ydqsqxql
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.cmpxchg.org/linux-mmotm.git master

commit 486ad79630d0ba0b7205a8db9fe15ba392f5ee32
Author:     Andrew Morton <akpm@linux-foundation.org>
AuthorDate: Fri Apr 20 22:00:53 2018 +0000
Commit:     Johannes Weiner <hannes@cmpxchg.org>
CommitDate: Fri Apr 20 22:00:53 2018 +0000

    origin
    
    GIT a9e5b73288cf1595ac2e05cf1acd1924ceea05fa
    
    commit a9e5b73288cf1595ac2e05cf1acd1924ceea05fa
    Author: David Howells <dhowells@redhat.com>
    Date:   Fri Apr 20 13:35:02 2018 +0100
    
        vfs: Undo an overly zealous MS_RDONLY -> SB_RDONLY conversion
    
        In do_mount() when the MS_* flags are being converted to MNT_* flags,
        MS_RDONLY got accidentally convered to SB_RDONLY.
    
        Undo this change.
    
        Fixes: e462ec50cb5f ("VFS: Differentiate mount flags (MS_*) from internal superblock flags")
        Signed-off-by: David Howells <dhowells@redhat.com>
        Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
    
    commit 660625922b3d9fcb376e5870299bc5c1086e1d32
    Author: David Howells <dhowells@redhat.com>
    Date:   Wed Apr 18 09:38:34 2018 +0100
    
        afs: Fix server record deletion
    
        AFS server records get removed from the net->fs_servers tree when
        they're deleted, but not from the net->fs_addresses{4,6} lists, which
        can lead to an oops in afs_find_server() when a server record has been
        removed, for instance during rmmod.
    
        Fix this by deleting the record from the by-address lists before posting
        it for RCU destruction.
    
        The reason this hasn't been noticed before is that the fileserver keeps
        probing the local cache manager, thereby keeping the service record
        alive, so the oops would only happen when a fileserver eventually gets
        bored and stops pinging or if the module gets rmmod'd and a call comes
        in from the fileserver during the window between the server records
        being destroyed and the socket being closed.
    
        The oops looks something like:
    
          BUG: unable to handle kernel NULL pointer dereference at 000000000000001c
          ...
          Workqueue: kafsd afs_process_async_call [kafs]
          RIP: 0010:afs_find_server+0x271/0x36f [kafs]
          ...
          Call Trace:
           afs_deliver_cb_init_call_back_state3+0x1f2/0x21f [kafs]
           afs_deliver_to_call+0x1ee/0x5e8 [kafs]
           afs_process_async_call+0x5b/0xd0 [kafs]
           process_one_work+0x2c2/0x504
           worker_thread+0x1d4/0x2ac
           kthread+0x11f/0x127
           ret_from_fork+0x24/0x30
    
        Fixes: d2ddc776a458 ("afs: Overhaul volume and server record caching and fileserver rotation")
        Signed-off-by: David Howells <dhowells@redhat.com>
        Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
    
    commit 16a34adb9392b2fe4195267475ab5b472e55292c
    Author: Al Viro <viro@zeniv.linux.org.uk>
    Date:   Thu Apr 19 22:03:08 2018 -0400
    
        Don't leak MNT_INTERNAL away from internal mounts
    
        We want it only for the stuff created by SB_KERNMOUNT mounts, *not* for
        their copies.  As it is, creating a deep stack of bindings of /proc/*/ns/*
        somewhere in a new namespace and exiting yields a stack overflow.
    
        Cc: stable@kernel.org
        Reported-by: Alexander Aring <aring@mojatatu.com>
        Bisected-by: Kirill Tkhai <ktkhai@virtuozzo.com>
        Tested-by: Kirill Tkhai <ktkhai@virtuozzo.com>
        Tested-by: Alexander Aring <aring@mojatatu.com>
        Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
    
    commit 1255fcb2a655f05e02f3a74675a6d6525f187afd
    Author: Ursula Braun <ubraun@linux.vnet.ibm.com>
    Date:   Thu Apr 19 15:56:40 2018 +0200
    
        net/smc: fix shutdown in state SMC_LISTEN
    
        Calling shutdown with SHUT_RD and SHUT_RDWR for a listening SMC socket
        crashes, because
           commit 127f49705823 ("net/smc: release clcsock from tcp_listen_worker")
        releases the internal clcsock in smc_close_active() and sets smc->clcsock
        to NULL.
        For SHUT_RD the smc_close_active() call is removed.
        For SHUT_RDWR the kernel_sock_shutdown() call is omitted, since the
        clcsock is already released.
    
        Fixes: 127f49705823 ("net/smc: release clcsock from tcp_listen_worker")
        Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
        Reported-by: Stephen Hemminger <stephen@networkplumber.org>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit a60faa60da891e311e19fd3e88d611863f431130
    Author: Vasundhara Volam <vasundhara-v.volam@broadcom.com>
    Date:   Thu Apr 19 03:16:16 2018 -0400
    
        bnxt_en: Fix memory fault in bnxt_ethtool_init()
    
        In some firmware images, the length of BNX_DIR_TYPE_PKG_LOG nvram type
        could be greater than the fixed buffer length of 4096 bytes allocated by
        the driver.  This was causing HWRM_NVM_READ to copy more data to the buffer
        than the allocated size, causing general protection fault.
    
        Fix the issue by allocating the exact buffer length returned by
        HWRM_NVM_FIND_DIR_ENTRY, instead of 4096.  Move the kzalloc() call
        into the bnxt_get_pkgver() function.
    
        Fixes: 3ebf6f0a09a2 ("bnxt_en: Add installed-package firmware version reporting via Ethtool GDRVINFO")
        Signed-off-by: Vasundhara Volam <vasundhara-v.volam@broadcom.com>
        Signed-off-by: Michael Chan <michael.chan@broadcom.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit f4ee703ace847f299da00944d57db7ff91786d0b
    Author: Michael S. Tsirkin <mst@redhat.com>
    Date:   Thu Apr 19 08:30:50 2018 +0300
    
        virtio_net: sparse annotation fix
    
        offloads is a buffer in virtio format, should use
        the __virtio64 tag.
    
        Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
        Acked-by: Jason Wang <jasowang@redhat.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit d7fad4c840f33a6bd333dd7fbb3006edbcf0017a
    Author: Michael S. Tsirkin <mst@redhat.com>
    Date:   Thu Apr 19 08:30:49 2018 +0300
    
        virtio_net: fix adding vids on big-endian
    
        Programming vids (adding or removing them) still passes
        guest-endian values in the DMA buffer. That's wrong
        if guest is big-endian and when virtio 1 is enabled.
    
        Note: this is on top of a previous patch:
                virtio_net: split out ctrl buffer
    
        Fixes: 9465a7a6f ("virtio_net: enable v1.0 support")
        Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
        Acked-by: Jason Wang <jasowang@redhat.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 12e571693837d6164bda61e316b1944972ee0d97
    Author: Michael S. Tsirkin <mst@redhat.com>
    Date:   Thu Apr 19 08:30:48 2018 +0300
    
        virtio_net: split out ctrl buffer
    
        When sending control commands, virtio net sets up several buffers for
        DMA. The buffers are all part of the net device which means it's
        actually allocated by kvmalloc so it's in theory (on extreme memory
        pressure) possible to get a vmalloc'ed buffer which on some platforms
        means we can't DMA there.
    
        Fix up by moving the DMA buffers into a separate structure.
    
        Reported-by: Mikulas Patocka <mpatocka@redhat.com>
        Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
        Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
        Acked-by: Jason Wang <jasowang@redhat.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit f4ea89110df237da6fbcaab76af431e85f07d904
    Author: dann frazier <dann.frazier@canonical.com>
    Date:   Wed Apr 18 21:55:41 2018 -0600
    
        net: hns: Avoid action name truncation
    
        When longer interface names are used, the action names exposed in
        /proc/interrupts and /proc/irq/* maybe truncated. For example, when
        using the predictable name algorithm in systemd on a HiSilicon D05,
        I see:
    
          ubuntu@d05-3:~$  grep enahisic2i0-tx /proc/interrupts | sed 's/.* //'
          enahisic2i0-tx0
          enahisic2i0-tx1
          [...]
          enahisic2i0-tx8
          enahisic2i0-tx9
          enahisic2i0-tx1
          enahisic2i0-tx1
          enahisic2i0-tx1
          enahisic2i0-tx1
          enahisic2i0-tx1
          enahisic2i0-tx1
    
        Increase the max ring name length to allow for an interface name
        of IFNAMSIZE. After this change, I now see:
    
          $ grep enahisic2i0-tx /proc/interrupts | sed 's/.* //'
          enahisic2i0-tx0
          enahisic2i0-tx1
          enahisic2i0-tx2
          [...]
          enahisic2i0-tx8
          enahisic2i0-tx9
          enahisic2i0-tx10
          enahisic2i0-tx11
          enahisic2i0-tx12
          enahisic2i0-tx13
          enahisic2i0-tx14
          enahisic2i0-tx15
    
        Signed-off-by: dann frazier <dann.frazier@canonical.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit ab913455dd59b81204b6a0d387a44697b0e0bd85
    Author: Olivier Gayot <olivier.gayot@sigexec.com>
    Date:   Wed Apr 18 22:03:06 2018 +0200
    
        docs: ip-sysctl.txt: fix name of some ipv6 variables
    
        The name of the following proc/sysctl entries were incorrectly
        documented:
    
            /proc/sys/net/ipv6/conf/<interface>/max_dst_opts_number
            /proc/sys/net/ipv6/conf/<interface>/max_hbt_opts_number
            /proc/sys/net/ipv6/conf/<interface>/max_dst_opts_length
            /proc/sys/net/ipv6/conf/<interface>/max_hbt_length
    
        Their name was set to the name of the symbol in the .data field of the
        control table instead of their .proc name.
    
        Signed-off-by: Olivier Gayot <olivier.gayot@sigexec.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 65ec0bd1c7c14522670a5294de35710fb577a7fd
    Author: Ronak Doshi <doshir@vmware.com>
    Date:   Wed Apr 18 12:48:04 2018 -0700
    
        vmxnet3: fix incorrect dereference when rxvlan is disabled
    
        vmxnet3_get_hdr_len() is used to calculate the header length which in
        turn is used to calculate the gso_size for skb. When rxvlan offload is
        disabled, vlan tag is present in the header and the function references
        ip header from sizeof(ethhdr) and leads to incorrect pointer reference.
    
        This patch fixes this issue by taking sizeof(vlan_ethhdr) into account
        if vlan tag is present and correctly references the ip hdr.
    
        Signed-off-by: Ronak Doshi <doshir@vmware.com>
        Acked-by: Guolin Yang <gyang@vmware.com>
        Acked-by: Louis Luo <llouis@vmware.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit f7e43672683b097bb074a8fe7af9bc600a23f231
    Author: Cong Wang <xiyou.wangcong@gmail.com>
    Date:   Wed Apr 18 11:51:56 2018 -0700
    
        llc: hold llc_sap before release_sock()
    
        syzbot reported we still access llc->sap in llc_backlog_rcv()
        after it is freed in llc_sap_remove_socket():
    
        Call Trace:
         __dump_stack lib/dump_stack.c:77 [inline]
         dump_stack+0x1b9/0x294 lib/dump_stack.c:113
         print_address_description+0x6c/0x20b mm/kasan/report.c:256
         kasan_report_error mm/kasan/report.c:354 [inline]
         kasan_report.cold.7+0x242/0x2fe mm/kasan/report.c:412
         __asan_report_load1_noabort+0x14/0x20 mm/kasan/report.c:430
         llc_conn_ac_send_sabme_cmd_p_set_x+0x3a8/0x460 net/llc/llc_c_ac.c:785
         llc_exec_conn_trans_actions net/llc/llc_conn.c:475 [inline]
         llc_conn_service net/llc/llc_conn.c:400 [inline]
         llc_conn_state_process+0x4e1/0x13a0 net/llc/llc_conn.c:75
         llc_backlog_rcv+0x195/0x1e0 net/llc/llc_conn.c:891
         sk_backlog_rcv include/net/sock.h:909 [inline]
         __release_sock+0x12f/0x3a0 net/core/sock.c:2335
         release_sock+0xa4/0x2b0 net/core/sock.c:2850
         llc_ui_release+0xc8/0x220 net/llc/af_llc.c:204
    
        llc->sap is refcount'ed and llc_sap_remove_socket() is paired
        with llc_sap_add_socket(). This can be amended by holding its refcount
        before llc_sap_remove_socket() and releasing it after release_sock().
    
        Reported-by: <syzbot+6e181fc95081c2cf9051@syzkaller.appspotmail.com>
        Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 02b94fc70ffe320a7799c35e09372809e40b7131
    Author: Jonathan Corbet <corbet@lwn.net>
    Date:   Wed Apr 18 10:14:13 2018 -0600
    
        MAINTAINERS: Direct networking documentation changes to netdev
    
        Networking docs changes go through the networking tree, so patch the
        MAINTAINERS file to direct authors to the right place.
    
        Signed-off-by: Jonathan Corbet <corbet@lwn.net>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit f3335545b34315fc42cc03a83165bdd26d956584
    Author: Colin Ian King <colin.king@canonical.com>
    Date:   Wed Apr 18 16:55:05 2018 +0100
    
        atm: iphase: fix spelling mistake: "Tansmit" -> "Transmit"
    
        Trivial fix to spelling mistake in message text.
    
        Signed-off-by: Colin Ian King <colin.king@canonical.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 4ec7eb3ff6eb5c9af3a84288a8d808a857fbc22b
    Author: Pawel Dembicki <paweldembicki@gmail.com>
    Date:   Wed Apr 18 16:03:24 2018 +0200
    
        net: qmi_wwan: add Wistron Neweb D19Q1
    
        This modem is embedded on dlink dwr-960 router.
        The oem configuration states:
    
        T: Bus=01 Lev=01 Prnt=01 Port=00 Cnt=01 Dev#= 2 Spd=480 MxCh= 0
        D: Ver= 2.10 Cls=00(>ifc ) Sub=00 Prot=00 MxPS=64 #Cfgs= 1
        P: Vendor=1435 ProdID=d191 Rev=ff.ff
        S: Manufacturer=Android
        S: Product=Android
        S: SerialNumber=0123456789ABCDEF
        C:* #Ifs= 6 Cfg#= 1 Atr=80 MxPwr=500mA
        I:* If#= 0 Alt= 0 #EPs= 2 Cls=ff(vend.) Sub=ff Prot=ff Driver=(none)
        E: Ad=81(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
        E: Ad=01(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
        I:* If#= 1 Alt= 0 #EPs= 2 Cls=ff(vend.) Sub=42 Prot=01 Driver=(none)
        E: Ad=02(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
        E: Ad=82(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
        I:* If#= 2 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=00 Prot=00 Driver=(none)
        E: Ad=84(I) Atr=03(Int.) MxPS= 10 Ivl=32ms
        E: Ad=83(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
        E: Ad=03(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
        I:* If#= 3 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=00 Prot=00 Driver=(none)
        E: Ad=86(I) Atr=03(Int.) MxPS= 10 Ivl=32ms
        E: Ad=85(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
        E: Ad=04(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
        I:* If#= 4 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=ff Prot=ff Driver=qmi_wwan
        E: Ad=88(I) Atr=03(Int.) MxPS= 8 Ivl=32ms
        E: Ad=87(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
        E: Ad=05(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
        I:* If#= 5 Alt= 0 #EPs= 2 Cls=08(stor.) Sub=06 Prot=50 Driver=(none)
        E: Ad=89(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
        E: Ad=06(O) Atr=02(Bulk) MxPS= 512 Ivl=125us
    
        Tested on openwrt distribution
    
        Signed-off-by: Pawel Dembicki <paweldembicki@gmail.com>
        Acked-by: BjA,rn Mork <bjorn@mork.no>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 5e84b38b07e676fcd3ab6e296780b4f77a29d09f
    Author: Colin Ian King <colin.king@canonical.com>
    Date:   Wed Apr 18 12:00:08 2018 +0100
    
        net: caif: fix spelling mistake "UKNOWN" -> "UNKNOWN"
    
        Trivial fix to spelling mistake
    
        Signed-off-by: Colin Ian King <colin.king@canonical.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 565020aaeebfa7c8b3ec077bee38f4c15acc9905
    Author: Jose Abreu <Jose.Abreu@synopsys.com>
    Date:   Wed Apr 18 10:57:55 2018 +0100
    
        net: stmmac: Disable ACS Feature for GMAC >= 4
    
        ACS Feature is currently enabled for GMAC >= 4 but the llc_snap status
        is never checked in descriptor rx_status callback. This will cause
        stmmac to always strip packets even that ACS feature is already
        stripping them.
    
        Lets be safe and disable the ACS feature for GMAC >= 4 and always strip
        the packets for this GMAC version.
    
        Fixes: 477286b53f55 ("stmmac: add GMAC4 core support")
        Signed-off-by: Jose Abreu <joabreu@synopsys.com>
        Cc: David S. Miller <davem@davemloft.net>
        Cc: Joao Pinto <jpinto@synopsys.com>
        Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
        Cc: Alexandre Torgue <alexandre.torgue@st.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit da42bb271305d68df6cbf99eed90542f1f1ee1c9
    Author: Maxime Chevallier <maxime.chevallier@bootlin.com>
    Date:   Wed Apr 18 11:14:44 2018 +0200
    
        net: mvpp2: Fix DMA address mask size
    
        PPv2 TX/RX descriptors uses 40bits DMA addresses, but 41 bits masks were
        used (GENMASK_ULL(40, 0)).
    
        This commit fixes that by using the correct mask.
    
        Fixes: e7c5359f2eed ("net: mvpp2: introduce PPv2.2 HW descriptors and adapt accessors")
        Signed-off-by: Maxime Chevallier <maxime.chevallier@bootlin.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit bb9aaaa1849eed763c6b7f20227a8a03300d4421
    Author: sunlianwen <sunlw.fnst@cn.fujitsu.com>
    Date:   Wed Apr 18 09:22:39 2018 +0800
    
        net: change the comment of dev_mc_init
    
        The comment of dev_mc_init() is wrong. which use dev_mc_flush
        instead of dev_mc_init.
    
        Signed-off-by: Lianwen Sun <sunlw.fnst@cn.fujitsu.com
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit b658912cb023cd6f8e46963d29779903d3c10538
    Author: Jiri Kosina <jkosina@suse.cz>
    Date:   Thu Apr 19 09:25:15 2018 +0200
    
        HID: i2c-hid: fix inverted return value from i2c_hid_command()
    
        i2c_hid_command() returns non-zero in error cases (the actual
        errno). Error handling in for I2C_HID_QUIRK_RESEND_REPORT_DESCR
        case in i2c_hid_resume() had the check inverted; fix that.
    
        Fixes: 3e83eda467 ("HID: i2c-hid: Fix resume issue on Raydium touchscreen device")
        Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
        Signed-off-by: Jiri Kosina <jkosina@suse.cz>
    
    commit 56376c5864f8ff4ba7c78a80ae857eee3b1d23d8
    Author: Michael Ellerman <mpe@ellerman.id.au>
    Date:   Thu Apr 19 16:22:20 2018 +1000
    
        powerpc/kvm: Fix lockups when running KVM guests on Power8
    
        When running KVM guests on Power8 we can see a lockup where one CPU
        stops responding. This often leads to a message such as:
    
          watchdog: CPU 136 detected hard LOCKUP on other CPUs 72
          Task dump for CPU 72:
          qemu-system-ppc R  running task    10560 20917  20908 0x00040004
    
        And then backtraces on other CPUs, such as:
    
          Task dump for CPU 48:
          ksmd            R  running task    10032  1519      2 0x00000804
          Call Trace:
            ...
            --- interrupt: 901 at smp_call_function_many+0x3c8/0x460
                LR = smp_call_function_many+0x37c/0x460
            pmdp_invalidate+0x100/0x1b0
            __split_huge_pmd+0x52c/0xdb0
            try_to_unmap_one+0x764/0x8b0
            rmap_walk_anon+0x15c/0x370
            try_to_unmap+0xb4/0x170
            split_huge_page_to_list+0x148/0xa30
            try_to_merge_one_page+0xc8/0x990
            try_to_merge_with_ksm_page+0x74/0xf0
            ksm_scan_thread+0x10ec/0x1ac0
            kthread+0x160/0x1a0
            ret_from_kernel_thread+0x5c/0x78
    
        This is caused by commit 8c1c7fb0b5ec ("powerpc/64s/idle: avoid sync
        for KVM state when waking from idle"), which added a check in
        pnv_powersave_wakeup() to see if the kvm_hstate.hwthread_state is
        already set to KVM_HWTHREAD_IN_KERNEL, and if so to skip the store and
        test of kvm_hstate.hwthread_req.
    
        The problem is that the primary does not set KVM_HWTHREAD_IN_KVM when
        entering the guest, so it can then come out to cede with
        KVM_HWTHREAD_IN_KERNEL set. It can then go idle in kvm_do_nap after
        setting hwthread_req to 1, but because hwthread_state is still
        KVM_HWTHREAD_IN_KERNEL we will skip the test of hwthread_req when we
        wake up from idle and won't go to kvm_start_guest. From there the
        thread will return somewhere garbage and crash.
    
        Fix it by skipping the store of hwthread_state, but not the test of
        hwthread_req, when coming out of idle. It's OK to skip the sync in
        that case because hwthread_req will have been set on the same thread,
        so there is no synchronisation required.
    
        Fixes: 8c1c7fb0b5ec ("powerpc/64s/idle: avoid sync for KVM state when waking from idle")
        Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
    
    commit 13a83eac373c49c0a081cbcd137e79210fe78acd
    Author: Michael Neuling <mikey@neuling.org>
    Date:   Wed Apr 11 13:37:58 2018 +1000
    
        powerpc/eeh: Fix enabling bridge MMIO windows
    
        On boot we save the configuration space of PCIe bridges. We do this so
        when we get an EEH event and everything gets reset that we can restore
        them.
    
        Unfortunately we save this state before we've enabled the MMIO space
        on the bridges. Hence if we have to reset the bridge when we come back
        MMIO is not enabled and we end up taking an PE freeze when the driver
        starts accessing again.
    
        This patch forces the memory/MMIO and bus mastering on when restoring
        bridges on EEH. Ideally we'd do this correctly by saving the
        configuration space writes later, but that will have to come later in
        a larger EEH rewrite. For now we have this simple fix.
    
        The original bug can be triggered on a boston machine by doing:
          echo 0x8000000000000000 > /sys/kernel/debug/powerpc/PCI0001/err_injct_outbound
        On boston, this PHB has a PCIe switch on it.  Without this patch,
        you'll see two EEH events, 1 expected and 1 the failure we are fixing
        here. The second EEH event causes the anything under the PHB to
        disappear (i.e. the i40e eth).
    
        With this patch, only 1 EEH event occurs and devices properly recover.
    
        Fixes: 652defed4875 ("powerpc/eeh: Check PCIe link after reset")
        Cc: stable@vger.kernel.org # v3.11+
        Reported-by: Pridhiviraj Paidipeddi <ppaidipe@linux.vnet.ibm.com>
        Signed-off-by: Michael Neuling <mikey@neuling.org>
        Acked-by: Russell Currey <ruscur@russell.cc>
        Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
    
    commit 64e86fec54069266ba32be551d7b7f75e88ab60c
    Author: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
    Date:   Tue Apr 17 17:40:00 2018 -0600
    
        net: qualcomm: rmnet: Fix warning seen with fill_info
    
        When the last rmnet device attached to a real device is removed, the
        real device is unregistered from rmnet. As a result, the real device
        lookup fails resulting in a warning when the fill_info handler is
        called as part of the rmnet device unregistration.
    
        Fix this by returning the rmnet flags as 0 when no real device is
        present.
    
        WARNING: CPU: 0 PID: 1779 at net/core/rtnetlink.c:3254
        rtmsg_ifinfo_build_skb+0xca/0x10d
        Modules linked in:
        CPU: 0 PID: 1779 Comm: ip Not tainted 4.16.0-11872-g7ce2367 #1
        Stack:
         7fe655f0 60371ea3 00000000 00000000
         60282bc6 6006b116 7fe65600 60371ee8
         7fe65660 6003a68c 00000000 900000000
        Call Trace:
         [<6006b116>] ? printk+0x0/0x94
         [<6001f375>] show_stack+0xfe/0x158
         [<60371ea3>] ? dump_stack_print_info+0xe8/0xf1
         [<60282bc6>] ? rtmsg_ifinfo_build_skb+0xca/0x10d
         [<6006b116>] ? printk+0x0/0x94
         [<60371ee8>] dump_stack+0x2a/0x2c
         [<6003a68c>] __warn+0x10e/0x13e
         [<6003a82c>] warn_slowpath_null+0x48/0x4f
         [<60282bc6>] rtmsg_ifinfo_build_skb+0xca/0x10d
         [<60282c4d>] rtmsg_ifinfo_event.part.37+0x1e/0x43
         [<60282c2f>] ? rtmsg_ifinfo_event.part.37+0x0/0x43
         [<60282d03>] rtmsg_ifinfo+0x24/0x28
         [<60264e86>] dev_close_many+0xba/0x119
         [<60282cdf>] ? rtmsg_ifinfo+0x0/0x28
         [<6027c225>] ? rtnl_is_locked+0x0/0x1c
         [<6026ca67>] rollback_registered_many+0x1ae/0x4ae
         [<600314be>] ? unblock_signals+0x0/0xae
         [<6026cdc0>] ? unregister_netdevice_queue+0x19/0xec
         [<6026ceec>] unregister_netdevice_many+0x21/0xa1
         [<6027c765>] rtnl_delete_link+0x3e/0x4e
         [<60280ecb>] rtnl_dellink+0x262/0x29c
         [<6027c241>] ? rtnl_get_link+0x0/0x3e
         [<6027f867>] rtnetlink_rcv_msg+0x235/0x274
    
        Fixes: be81a85f5f87 ("net: qualcomm: rmnet: Implement fill_info")
        Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit b3d7e55c3f886493235bfee08e1e5a4a27cbcce8
    Author: Matt Redfearn <matt.redfearn@mips.com>
    Date:   Tue Apr 17 16:40:01 2018 +0100
    
        MIPS: uaccess: Add micromips clobbers to bzero invocation
    
        The micromips implementation of bzero additionally clobbers registers t7
        & t8. Specify this in the clobbers list when invoking bzero.
    
        Fixes: 26c5e07d1478 ("MIPS: microMIPS: Optimise 'memset' core library function.")
        Reported-by: James Hogan <jhogan@kernel.org>
        Signed-off-by: Matt Redfearn <matt.redfearn@mips.com>
        Cc: Ralf Baechle <ralf@linux-mips.org>
        Cc: linux-mips@linux-mips.org
        Cc: <stable@vger.kernel.org> # 3.10+
        Patchwork: https://patchwork.linux-mips.org/patch/19110/
        Signed-off-by: James Hogan <jhogan@kernel.org>
    
    commit c96eebf07692e53bf4dd5987510d8b550e793598
    Author: Matt Redfearn <matt.redfearn@mips.com>
    Date:   Tue Apr 17 16:40:00 2018 +0100
    
        MIPS: memset.S: Fix clobber of v1 in last_fixup
    
        The label .Llast_fixup\@ is jumped to on page fault within the final
        byte set loop of memset (on < MIPSR6 architectures). For some reason, in
        this fault handler, the v1 register is randomly set to a2 & STORMASK.
        This clobbers v1 for the calling function. This can be observed with the
        following test code:
    
        static int __init __attribute__((optimize("O0"))) test_clear_user(void)
        {
          register int t asm("v1");
          char *test;
          int j, k;
    
          pr_info("\n\n\nTesting clear_user\n");
          test = vmalloc(PAGE_SIZE);
    
          for (j = 256; j < 512; j++) {
            t = 0xa5a5a5a5;
            if ((k = clear_user(test + PAGE_SIZE - 256, j)) != j - 256) {
                pr_err("clear_user (%px %d) returned %d\n", test + PAGE_SIZE - 256, j, k);
            }
            if (t != 0xa5a5a5a5) {
               pr_err("v1 was clobbered to 0x%x!\n", t);
            }
          }
    
          return 0;
        }
        late_initcall(test_clear_user);
    
        Which demonstrates that v1 is indeed clobbered (MIPS64):
    
        Testing clear_user
        v1 was clobbered to 0x1!
        v1 was clobbered to 0x2!
        v1 was clobbered to 0x3!
        v1 was clobbered to 0x4!
        v1 was clobbered to 0x5!
        v1 was clobbered to 0x6!
        v1 was clobbered to 0x7!
    
        Since the number of bytes that could not be set is already contained in
        a2, the andi placing a value in v1 is not necessary and actively
        harmful in clobbering v1.
    
        Reported-by: James Hogan <jhogan@kernel.org>
        Signed-off-by: Matt Redfearn <matt.redfearn@mips.com>
        Cc: Ralf Baechle <ralf@linux-mips.org>
        Cc: linux-mips@linux-mips.org
        Cc: stable@vger.kernel.org
        Patchwork: https://patchwork.linux-mips.org/patch/19109/
        Signed-off-by: James Hogan <jhogan@kernel.org>
    
    commit 81c895072d29cd70eea5be1a8587cd6461c3715a
    Author: BjA,rn Mork <bjorn@mork.no>
    Date:   Tue Apr 17 22:46:38 2018 +0200
    
        tun: fix vlan packet truncation
    
        Bogus trimming in tun_net_xmit() causes truncated vlan packets.
    
        skb->len is correct whether or not skb_vlan_tag_present() is true. There
        is no more reason to adjust the skb length on xmit in this driver than
        any other driver. tun_put_user() adds 4 bytes to the total for tagged
        packets because it transmits the tag inline to userspace.  This is
        similar to a nic transmitting the tag inline on the wire.
    
        Reproducing the bug by sending any tagged packet through back-to-back
        connected tap interfaces:
    
         socat TUN,tun-type=tap,iff-up,tun-name=in TUN,tun-type=tap,iff-up,tun-name=out &
         ip link add link in name in.20 type vlan id 20
         ip addr add 10.9.9.9/24 dev in.20
         ip link set in.20 up
         tshark -nxxi in -f arp -c1 2>/dev/null &
         tshark -nxxi out -f arp -c1 2>/dev/null &
         ping -c 1 10.9.9.5 >/dev/null 2>&1
    
        The output from the 'in' and 'out' interfaces are different when the
        bug is present:
    
         Capturing on 'in'
         0000  ff ff ff ff ff ff 76 cf 76 37 d5 0a 81 00 00 14   ......v.v7......
         0010  08 06 00 01 08 00 06 04 00 01 76 cf 76 37 d5 0a   ..........v.v7..
         0020  0a 09 09 09 00 00 00 00 00 00 0a 09 09 05         ..............
    
         Capturing on 'out'
         0000  ff ff ff ff ff ff 76 cf 76 37 d5 0a 81 00 00 14   ......v.v7......
         0010  08 06 00 01 08 00 06 04 00 01 76 cf 76 37 d5 0a   ..........v.v7..
         0020  0a 09 09 09 00 00 00 00 00 00                     ..........
    
        Fixes: aff3d70a07ff ("tun: allow to attach ebpf socket filter")
        Cc: Jason Wang <jasowang@redhat.com>
        Signed-off-by: BjA,rn Mork <bjorn@mork.no>
        Acked-by: Jason Wang <jasowang@redhat.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 36a50a989ee8267588de520b8704b85f045a3220
    Author: Tung Nguyen <tung.q.nguyen@dektech.com.au>
    Date:   Tue Apr 17 21:58:27 2018 +0200
    
        tipc: fix infinite loop when dumping link monitor summary
    
        When configuring the number of used bearers to MAX_BEARER and issuing
        command "tipc link monitor summary", the command enters infinite loop
        in user space.
    
        This issue happens because function tipc_nl_node_dump_monitor() returns
        the wrong 'prev_bearer' value when all potential monitors have been
        scanned.
    
        The correct behavior is to always try to scan all monitors until either
        the netlink message is full, in which case we return the bearer identity
        of the affected monitor, or we continue through the whole bearer array
        until we can return MAX_BEARERS. This solution also caters for the case
        where there may be gaps in the bearer array.
    
        Signed-off-by: Tung Nguyen <tung.q.nguyen@dektech.com.au>
        Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit be47e41d77fba5bc17e9fb5f1c99217bb6691989
    Author: Jon Maloy <jon.maloy@ericsson.com>
    Date:   Tue Apr 17 21:25:42 2018 +0200
    
        tipc: fix use-after-free in tipc_nametbl_stop
    
        When we delete a service item in tipc_nametbl_stop() we loop over
        all service ranges in the service's RB tree, and for each service
        range we loop over its pertaining publications while calling
        tipc_service_remove_publ() for each of them.
    
        However, tipc_service_remove_publ() has the side effect that it also
        removes the comprising service range item when there are no publications
        left. This leads to a "use-after-free" access when the inner loop
        continues to the next iteration, since the range item holding the list
        we are looping no longer exists.
    
        We fix this by moving the delete of the service range item outside
        the said function. Instead, we now let the two functions calling it
        test if the list is empty and perform the removal when that is the
        case.
    
        Reported-by: syzbot+d64b64afc55660106556@syzkaller.appspotmail.com
        Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit b32e56e5a87a1f9243db92bc7a5df0ffb4627cfb
    Author: Benjamin Herrenschmidt <benh@kernel.crashing.org>
    Date:   Wed Apr 11 15:17:59 2018 +1000
    
        powerpc/xive: Fix trying to "push" an already active pool VP
    
        When setting up a CPU, we "push" (activate) a pool VP for it.
    
        However it's an error to do so if it already has an active
        pool VP.
    
        This happens when doing soft CPU hotplug on powernv since we
        don't tear down the CPU on unplug. The HW flags the error which
        gets captured by the diagnostics.
    
        Fix this by making sure to "pull" out any already active pool
        first.
    
        Fixes: 243e25112d06 ("powerpc/xive: Native exploitation of the XIVE interrupt controller")
        Cc: stable@vger.kernel.org # v4.12+
        Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
        Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
    
    commit 44f06ba8297c7e9dfd0e49b40cbe119113cca094
    Author: Jan Kara <jack@suse.cz>
    Date:   Thu Apr 12 17:22:23 2018 +0200
    
        udf: Fix leak of UTF-16 surrogates into encoded strings
    
        OSTA UDF specification does not mention whether the CS0 charset in case
        of two bytes per character encoding should be treated in UTF-16 or
        UCS-2. The sample code in the standard does not treat UTF-16 surrogates
        in any special way but on systems such as Windows which work in UTF-16
        internally, filenames would be treated as being in UTF-16 effectively.
        In Linux it is more difficult to handle characters outside of Base
        Multilingual plane (beyond 0xffff) as NLS framework works with 2-byte
        characters only. Just make sure we don't leak UTF-16 surrogates into the
        resulting string when loading names from the filesystem for now.
    
        CC: stable@vger.kernel.org # >= v4.6
        Reported-by: Mingye Wang <arthur200126@gmail.com>
        Signed-off-by: Jan Kara <jack@suse.cz>
    
    commit 9c438d7a3a52dcc2b9ed095cb87d3a5e83cf7e60
    Author: Eric Biggers <ebiggers@google.com>
    Date:   Tue Apr 17 12:07:06 2018 -0700
    
        KEYS: DNS: limit the length of option strings
    
        Adding a dns_resolver key whose payload contains a very long option name
        resulted in that string being printed in full.  This hit the WARN_ONCE()
        in set_precision() during the printk(), because printk() only supports a
        precision of up to 32767 bytes:
    
            precision 1000000 too large
            WARNING: CPU: 0 PID: 752 at lib/vsprintf.c:2189 vsnprintf+0x4bc/0x5b0
    
        Fix it by limiting option strings (combined name + value) to a much more
        reasonable 128 bytes.  The exact limit is arbitrary, but currently the
        only recognized option is formatted as "dnserror=%lu" which fits well
        within this limit.
    
        Also ratelimit the printks.
    
        Reproducer:
    
            perl -e 'print "#", "A" x 1000000, "\x00"' | keyctl padd dns_resolver desc @s
    
        This bug was found using syzkaller.
    
        Reported-by: Mark Rutland <mark.rutland@arm.com>
        Fixes: 4a2d789267e0 ("DNS: If the DNS server returns an error, allow that to be cached [ver #2]")
        Signed-off-by: Eric Biggers <ebiggers@google.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 89bda97b445bacab68e71507cc08ccacd6694474
    Author: Bert Kenward <bkenward@solarflare.com>
    Date:   Tue Apr 17 13:32:39 2018 +0100
    
        sfc: check RSS is active for filter insert
    
        For some firmware variants - specifically 'capture packed stream' - RSS
        filters are not valid. We must check if RSS is actually active rather
        than merely enabled.
    
        Fixes: 42356d9a137b ("sfc: support RSS spreading of ethtool ntuple filters")
        Signed-off-by: Bert Kenward <bkenward@solarflare.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 7ce2367254e84753bceb07327aaf5c953cfce117
    Author: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
    Date:   Tue Apr 17 18:46:14 2018 +0900
    
        vlan: Fix reading memory beyond skb->tail in skb_vlan_tagged_multi
    
        Syzkaller spotted an old bug which leads to reading skb beyond tail by 4
        bytes on vlan tagged packets.
        This is caused because skb_vlan_tagged_multi() did not check
        skb_headlen.
    
        BUG: KMSAN: uninit-value in eth_type_vlan include/linux/if_vlan.h:283 [inline]
        BUG: KMSAN: uninit-value in skb_vlan_tagged_multi include/linux/if_vlan.h:656 [inline]
        BUG: KMSAN: uninit-value in vlan_features_check include/linux/if_vlan.h:672 [inline]
        BUG: KMSAN: uninit-value in dflt_features_check net/core/dev.c:2949 [inline]
        BUG: KMSAN: uninit-value in netif_skb_features+0xd1b/0xdc0 net/core/dev.c:3009
        CPU: 1 PID: 3582 Comm: syzkaller435149 Not tainted 4.16.0+ #82
        Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
        Call Trace:
          __dump_stack lib/dump_stack.c:17 [inline]
          dump_stack+0x185/0x1d0 lib/dump_stack.c:53
          kmsan_report+0x142/0x240 mm/kmsan/kmsan.c:1067
          __msan_warning_32+0x6c/0xb0 mm/kmsan/kmsan_instr.c:676
          eth_type_vlan include/linux/if_vlan.h:283 [inline]
          skb_vlan_tagged_multi include/linux/if_vlan.h:656 [inline]
          vlan_features_check include/linux/if_vlan.h:672 [inline]
          dflt_features_check net/core/dev.c:2949 [inline]
          netif_skb_features+0xd1b/0xdc0 net/core/dev.c:3009
          validate_xmit_skb+0x89/0x1320 net/core/dev.c:3084
          __dev_queue_xmit+0x1cb2/0x2b60 net/core/dev.c:3549
          dev_queue_xmit+0x4b/0x60 net/core/dev.c:3590
          packet_snd net/packet/af_packet.c:2944 [inline]
          packet_sendmsg+0x7c57/0x8a10 net/packet/af_packet.c:2969
          sock_sendmsg_nosec net/socket.c:630 [inline]
          sock_sendmsg net/socket.c:640 [inline]
          sock_write_iter+0x3b9/0x470 net/socket.c:909
          do_iter_readv_writev+0x7bb/0x970 include/linux/fs.h:1776
          do_iter_write+0x30d/0xd40 fs/read_write.c:932
          vfs_writev fs/read_write.c:977 [inline]
          do_writev+0x3c9/0x830 fs/read_write.c:1012
          SYSC_writev+0x9b/0xb0 fs/read_write.c:1085
          SyS_writev+0x56/0x80 fs/read_write.c:1082
          do_syscall_64+0x309/0x430 arch/x86/entry/common.c:287
          entry_SYSCALL_64_after_hwframe+0x3d/0xa2
        RIP: 0033:0x43ffa9
        RSP: 002b:00007fff2cff3948 EFLAGS: 00000217 ORIG_RAX: 0000000000000014
        RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 000000000043ffa9
        RDX: 0000000000000001 RSI: 0000000020000080 RDI: 0000000000000003
        RBP: 00000000006cb018 R08: 0000000000000000 R09: 0000000000000000
        R10: 0000000000000000 R11: 0000000000000217 R12: 00000000004018d0
        R13: 0000000000401960 R14: 0000000000000000 R15: 0000000000000000
    
        Uninit was created at:
          kmsan_save_stack_with_flags mm/kmsan/kmsan.c:278 [inline]
          kmsan_internal_poison_shadow+0xb8/0x1b0 mm/kmsan/kmsan.c:188
          kmsan_kmalloc+0x94/0x100 mm/kmsan/kmsan.c:314
          kmsan_slab_alloc+0x11/0x20 mm/kmsan/kmsan.c:321
          slab_post_alloc_hook mm/slab.h:445 [inline]
          slab_alloc_node mm/slub.c:2737 [inline]
          __kmalloc_node_track_caller+0xaed/0x11c0 mm/slub.c:4369
          __kmalloc_reserve net/core/skbuff.c:138 [inline]
          __alloc_skb+0x2cf/0x9f0 net/core/skbuff.c:206
          alloc_skb include/linux/skbuff.h:984 [inline]
          alloc_skb_with_frags+0x1d4/0xb20 net/core/skbuff.c:5234
          sock_alloc_send_pskb+0xb56/0x1190 net/core/sock.c:2085
          packet_alloc_skb net/packet/af_packet.c:2803 [inline]
          packet_snd net/packet/af_packet.c:2894 [inline]
          packet_sendmsg+0x6444/0x8a10 net/packet/af_packet.c:2969
          sock_sendmsg_nosec net/socket.c:630 [inline]
          sock_sendmsg net/socket.c:640 [inline]
          sock_write_iter+0x3b9/0x470 net/socket.c:909
          do_iter_readv_writev+0x7bb/0x970 include/linux/fs.h:1776
          do_iter_write+0x30d/0xd40 fs/read_write.c:932
          vfs_writev fs/read_write.c:977 [inline]
          do_writev+0x3c9/0x830 fs/read_write.c:1012
          SYSC_writev+0x9b/0xb0 fs/read_write.c:1085
          SyS_writev+0x56/0x80 fs/read_write.c:1082
          do_syscall_64+0x309/0x430 arch/x86/entry/common.c:287
          entry_SYSCALL_64_after_hwframe+0x3d/0xa2
    
        Fixes: 58e998c6d239 ("offloading: Force software GSO for multiple vlan tags.")
        Reported-and-tested-by: syzbot+0bbe42c764feafa82c5a@syzkaller.appspotmail.com
        Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit daf70d89f80c6e1772233da9e020114b1254e7e0
    Author: Matt Redfearn <matt.redfearn@mips.com>
    Date:   Tue Apr 17 15:52:21 2018 +0100
    
        MIPS: memset.S: Fix return of __clear_user from Lpartial_fixup
    
        The __clear_user function is defined to return the number of bytes that
        could not be cleared. From the underlying memset / bzero implementation
        this means setting register a2 to that number on return. Currently if a
        page fault is triggered within the memset_partial block, the value
        loaded into a2 on return is meaningless.
    
        The label .Lpartial_fixup\@ is jumped to on page fault. In order to work
        out how many bytes failed to copy, the exception handler should find how
        many bytes left in the partial block (andi a2, STORMASK), add that to
        the partial block end address (a2), and subtract the faulting address to
        get the remainder. Currently it incorrectly subtracts the partial block
        start address (t1), which has additionally been clobbered to generate a
        jump target in memset_partial. Fix this by adding the block end address
        instead.
    
        This issue was found with the following test code:
              int j, k;
              for (j = 0; j < 512; j++) {
                if ((k = clear_user(NULL, j)) != j) {
                   pr_err("clear_user (NULL %d) returned %d\n", j, k);
                }
              }
        Which now passes on Creator Ci40 (MIPS32) and Cavium Octeon II (MIPS64).
    
        Suggested-by: James Hogan <jhogan@kernel.org>
        Signed-off-by: Matt Redfearn <matt.redfearn@mips.com>
        Cc: Ralf Baechle <ralf@linux-mips.org>
        Cc: linux-mips@linux-mips.org
        Cc: stable@vger.kernel.org
        Patchwork: https://patchwork.linux-mips.org/patch/19108/
        Signed-off-by: James Hogan <jhogan@kernel.org>
    
    commit 77ac725e0c5b27c925e514b999cd46d01eedafd1
    Author: Nicolas Dechesne <nicolas.dechesne@linaro.org>
    Date:   Tue Apr 17 14:03:26 2018 +0200
    
        net: qrtr: add MODULE_ALIAS_NETPROTO macro
    
        To ensure that qrtr can be loaded automatically, when needed, if it is compiled
        as module.
    
        Signed-off-by: Nicolas Dechesne <nicolas.dechesne@linaro.org>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 05e489b1596f0aa1025a1fa572676631cd9665da
    Author: Stefan Hajnoczi <stefanha@redhat.com>
    Date:   Tue Apr 17 14:25:58 2018 +0800
    
        VSOCK: make af_vsock.ko removable again
    
        Commit c1eef220c1760762753b602c382127bfccee226d ("vsock: always call
        vsock_init_tables()") introduced a module_init() function without a
        corresponding module_exit() function.
    
        Modules with an init function can only be removed if they also have an
        exit function.  Therefore the vsock module was considered "permanent"
        and could not be removed.
    
        This patch adds an empty module_exit() function so that "rmmod vsock"
        works.  No explicit cleanup is required because:
    
        1. Transports call vsock_core_exit() upon exit and cannot be removed
           while sockets are still alive.
        2. vsock_diag.ko does not perform any action that requires cleanup by
           vsock.ko.
    
        Fixes: c1eef220c176 ("vsock: always call vsock_init_tables()")
        Reported-by: Xiumei Mu <xmu@redhat.com>
        Cc: Cong Wang <xiyou.wangcong@gmail.com>
        Cc: Jorgen Hansen <jhansen@vmware.com>
        Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
        Reviewed-by: Jorgen Hansen <jhansen@vmware.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit ebf04f331fa15a966262341a7dc6b1a0efd633e4
    Author: Simon Gaiser <simon@invisiblethingslab.com>
    Date:   Thu Mar 15 04:08:03 2018 +0100
    
        xen: xenbus_dev_frontend: Really return response string
    
        xenbus_command_reply() did not actually copy the response string and
        leaked stack content instead.
    
        Fixes: 9a6161fe73bd ("xen: return xenstore command failures via response instead of rc")
        Signed-off-by: Simon Gaiser <simon@invisiblethingslab.com>
        Reviewed-by: Juergen Gross <jgross@suse.com>
        Signed-off-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
    
    commit cd6e992b3aab072cc90839508aaf5573c8f7e066
    Author: Oleksandr Andrushchenko <andr2000@gmail.com>
    Date:   Thu Apr 12 20:26:27 2018 +0300
    
        xen/sndif: Sync up with the canonical definition in Xen
    
        This is the sync up with the canonical definition of the sound
        protocol in Xen:
    
        1. Protocol version was referenced in the protocol description,
           but missed its definition. Fixed by adding a constant
           for current protocol version.
    
        2. Some of the request descriptions have "reserved" fields
           missed: fixed by adding corresponding entries.
    
        3. Extend the size of the requests and responses to 64 octets.
           Bump protocol version to 2.
    
        4. Add explicit back and front synchronization
           In order to provide explicit synchronization between backend and
           frontend the following changes are introduced in the protocol:
            - add new ring buffer for sending asynchronous events from
              backend to frontend to report number of bytes played by the
              frontend (XENSND_EVT_CUR_POS)
            - introduce trigger events for playback control: start/stop/pause/resume
            - add "req-" prefix to event-channel and ring-ref to unify naming
              of the Xen event channels for requests and events
    
        5. Add explicit back and front parameter negotiation
           In order to provide explicit stream parameter negotiation between
           backend and frontend the following changes are introduced in the protocol:
           add XENSND_OP_HW_PARAM_QUERY request to read/update
           configuration space for the parameters given: request passes
           desired parameter's intervals/masks and the response to this request
           returns allowed min/max intervals/masks to be used.
    
        Signed-off-by: Oleksandr Andrushchenko <oleksandr_andrushchenko@epam.com>
        Signed-off-by: Oleksandr Grytsov <oleksandr_grytsov@epam.com>
        Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
        Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
        Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
        Cc: Takashi Iwai <tiwai@suse.de>
        Signed-off-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
    
    commit 3b2c77d000fe9f7d02e9e726e00dccf9f92b256f
    Author: Petr Mladek <pmladek@suse.com>
    Date:   Mon Apr 16 13:36:47 2018 +0200
    
        livepatch: Allow to call a custom callback when freeing shadow variables
    
        We might need to do some actions before the shadow variable is freed.
        For example, we might need to remove it from a list or free some data
        that it points to.
    
        This is already possible now. The user can get the shadow variable
        by klp_shadow_get(), do the necessary actions, and then call
        klp_shadow_free().
    
        This patch allows to do it a more elegant way. The user could implement
        the needed actions in a callback that is passed to klp_shadow_free()
        as a parameter. The callback usually does reverse operations to
        the constructor callback that can be called by klp_shadow_*alloc().
    
        It is especially useful for klp_shadow_free_all(). There we need to do
        these extra actions for each found shadow variable with the given ID.
    
        Note that the memory used by the shadow variable itself is still released
        later by rcu callback. It is needed to protect internal structures that
        keep all shadow variables. But the destructor is called immediately.
        The shadow variable must not be access anyway after klp_shadow_free()
        is called. The user is responsible to protect this any suitable way.
    
        Be aware that the destructor is called under klp_shadow_lock. It is
        the same as for the contructor in klp_shadow_alloc().
    
        Signed-off-by: Petr Mladek <pmladek@suse.com>
        Acked-by: Josh Poimboeuf <jpoimboe@redhat.com>
        Acked-by: Miroslav Benes <mbenes@suse.cz>
        Signed-off-by: Jiri Kosina <jkosina@suse.cz>
    
    commit e91c2518a5d22a07642f35d85f39001ad379dae4
    Author: Petr Mladek <pmladek@suse.com>
    Date:   Mon Apr 16 13:36:46 2018 +0200
    
        livepatch: Initialize shadow variables safely by a custom callback
    
        The existing API allows to pass a sample data to initialize the shadow
        data. It works well when the data are position independent. But it fails
        miserably when we need to set a pointer to the shadow structure itself.
    
        Unfortunately, we might need to initialize the pointer surprisingly
        often because of struct list_head. It is even worse because the list
        might be hidden in other common structures, for example, struct mutex,
        struct wait_queue_head.
    
        For example, this was needed to fix races in ALSA sequencer. It required
        to add mutex into struct snd_seq_client. See commit b3defb791b26ea06
        ("ALSA: seq: Make ioctls race-free") and commit d15d662e89fc667b9
        ("ALSA: seq: Fix racy pool initializations")
    
        This patch makes the API more safe. A custom constructor function and data
        are passed to klp_shadow_*alloc() functions instead of the sample data.
    
        Note that ctor_data are no longer a template for shadow->data. It might
        point to any data that might be necessary when the constructor is called.
    
        Also note that the constructor is called under klp_shadow_lock. It is
        an internal spin_lock that synchronizes alloc() vs. get() operations,
        see klp_shadow_get_or_alloc(). On one hand, this adds a risk of ABBA
        deadlocks. On the other hand, it allows to do some operations safely.
        For example, we could add the new structure into an existing list.
        This must be done only once when the structure is allocated.
    
        Reported-by: Nicolai Stange <nstange@suse.de>
        Signed-off-by: Petr Mladek <pmladek@suse.com>
        Acked-by: Josh Poimboeuf <jpoimboe@redhat.com>
        Acked-by: Miroslav Benes <mbenes@suse.cz>
        Signed-off-by: Jiri Kosina <jkosina@suse.cz>
    
    commit 9dfbf78e4114fcaf4ef61c49885c3ab5bad40d0b
    Author: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
    Date:   Thu Jan 18 00:33:36 2018 +0530
    
        powerpc/64s: Default l1d_size to 64K in RFI fallback flush
    
        If there is no d-cache-size property in the device tree, l1d_size could
        be zero. We don't actually expect that to happen, it's only been seen
        on mambo (simulator) in some configurations.
    
        A zero-size l1d_size leads to the loop in the asm wrapping around to
        2^64-1, and then walking off the end of the fallback area and
        eventually causing a page fault which is fatal.
    
        Just default to 64K which is correct on some CPUs, and sane enough to
        not cause a crash on others.
    
        Fixes: aa8a5e0062ac9 ('powerpc/64s: Add support for RFI flush of L1-D cache')
        Signed-off-by: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
        [mpe: Rewrite comment and change log]
        Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
    
    commit fae764912153065ea55eda47f834e0764a54df94
    Author: Martin Schwidefsky <schwidefsky@de.ibm.com>
    Date:   Thu Apr 12 13:48:25 2018 +0200
    
        s390/signal: cleanup uapi struct sigaction
    
        The struct sigaction for user space in arch/s390/include/uapi/asm/signal.h
        is ill defined. The kernel uses two structures 'struct sigaction' and
        'struct old_sigaction', the correlation in the kernel for both 31 and
        64 bit is as follows
    
            sys_sigaction -> struct old_sigaction
            sys_rt_sigaction -> struct sigaction
    
        The correlation of the (single) uapi definition for 'struct sigaction'
        under '#ifndef __KERNEL__':
    
            31-bit: sys_sigaction -> uapi struct sigaction
            31-bit: sys_rt_sigaction -> no structure available
    
            64-bit: sys_sigaction -> no structure available
            64-bit: sys_rt_sigaction -> uapi struct sigaction
    
        This is quite confusing. To make it a bit less confusing make the
        uapi definition of 'struct sigaction' usable for sys_rt_sigaction for
        both 31-bit and 64-bit.
    
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit 5968a70d7af5f2abbd9d9f9c8e86da51f0a6b16d
    Author: Randy Dunlap <rdunlap@infradead.org>
    Date:   Mon Apr 16 12:32:55 2018 -0700
    
        textsearch: fix kernel-doc warnings and add kernel-api section
    
        Make lib/textsearch.c usable as kernel-doc.
        Add textsearch() function family to kernel-api documentation.
        Fix kernel-doc warnings in <linux/textsearch.h>:
          ../include/linux/textsearch.h:65: warning: Incorrect use of kernel-doc format:
                * get_next_block - fetch next block of data
          ../include/linux/textsearch.h:82: warning: Incorrect use of kernel-doc format:
                * finish - finalize/clean a series of get_next_block() calls
    
        Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit c6404122cb18f1fbd2a6dc85ab687f6fa2e454cf
    Author: Eric Dumazet <edumazet@google.com>
    Date:   Mon Apr 16 08:29:43 2018 -0700
    
        tipc: fix possible crash in __tipc_nl_net_set()
    
        syzbot reported a crash in __tipc_nl_net_set() caused by NULL dereference.
    
        We need to check that both TIPC_NLA_NET_NODEID and TIPC_NLA_NET_NODEID_W1
        are present.
    
        We also need to make sure userland provided u64 attributes.
    
        Fixes: d50ccc2d3909 ("tipc: add 128-bit node identifier")
        Signed-off-by: Eric Dumazet <edumazet@google.com>
        Cc: Jon Maloy <jon.maloy@ericsson.com>
        Cc: Ying Xue <ying.xue@windriver.com>
        Reported-by: syzbot <syzkaller@googlegroups.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit ec518f21cb1a1b1f8a516499ea05c60299e04963
    Author: Eric Dumazet <edumazet@google.com>
    Date:   Mon Apr 16 08:29:42 2018 -0700
    
        tipc: add policy for TIPC_NLA_NET_ADDR
    
        Before syzbot/KMSAN bites, add the missing policy for TIPC_NLA_NET_ADDR
    
        Fixes: 27c21416727a ("tipc: add net set to new netlink api")
        Signed-off-by: Eric Dumazet <edumazet@google.com>
        Cc: Jon Maloy <jon.maloy@ericsson.com>
        Cc: Ying Xue <ying.xue@windriver.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 8a8158c85e1e774a44fbe81106fa41138580dfd1
    Author: Matt Redfearn <matt.redfearn@mips.com>
    Date:   Thu Mar 29 10:28:23 2018 +0100
    
        MIPS: memset.S: EVA & fault support for small_memset
    
        The MIPS kernel memset / bzero implementation includes a small_memset
        branch which is used when the region to be set is smaller than a long (4
        bytes on 32bit, 8 bytes on 64bit). The current small_memset
        implementation uses a simple store byte loop to write the destination.
        There are 2 issues with this implementation:
    
        1. When EVA mode is active, user and kernel address spaces may overlap.
        Currently the use of the sb instruction means kernel mode addressing is
        always used and an intended write to userspace may actually overwrite
        some critical kernel data.
    
        2. If the write triggers a page fault, for example by calling
        __clear_user(NULL, 2), instead of gracefully handling the fault, an OOPS
        is triggered.
    
        Fix these issues by replacing the sb instruction with the EX() macro,
        which will emit EVA compatible instuctions as required. Additionally
        implement a fault fixup for small_memset which sets a2 to the number of
        bytes that could not be cleared (as defined by __clear_user).
    
        Reported-by: Chuanhua Lei <chuanhua.lei@intel.com>
        Signed-off-by: Matt Redfearn <matt.redfearn@mips.com>
        Cc: Ralf Baechle <ralf@linux-mips.org>
        Cc: linux-mips@linux-mips.org
        Cc: stable@vger.kernel.org
        Patchwork: https://patchwork.linux-mips.org/patch/18975/
        Signed-off-by: James Hogan <jhogan@kernel.org>
    
    commit e86281e700cca8a773f9a572fa406adf2784ba5c
    Author: Tyler Hicks <tyhicks@canonical.com>
    Date:   Wed Mar 28 23:41:52 2018 +0000
    
        eCryptfs: don't pass up plaintext names when using filename encryption
    
        Both ecryptfs_filldir() and ecryptfs_readlink_lower() use
        ecryptfs_decode_and_decrypt_filename() to translate lower filenames to
        upper filenames. The function correctly passes up lower filenames,
        unchanged, when filename encryption isn't in use. However, it was also
        passing up lower filenames when the filename wasn't encrypted or
        when decryption failed. Since 88ae4ab9802e, eCryptfs refuses to lookup
        lower plaintext names when filename encryption is enabled so this
        resulted in a situation where userspace would see lower plaintext
        filenames in calls to getdents(2) but then not be able to lookup those
        filenames.
    
        An example of this can be seen when enabling filename encryption on an
        eCryptfs mount at the root directory of an Ext4 filesystem:
    
        $ ls -1i /lower
        12 ECRYPTFS_FNEK_ENCRYPTED.FWYZD8TcW.5FV-TKTEYOHsheiHX9a-w.NURCCYIMjI8pn5BDB9-h3fXwrE--
        11 lost+found
        $ ls -1i /upper
        ls: cannot access '/upper/lost+found': No such file or directory
         ? lost+found
        12 test
    
        With this change, the lower lost+found dentry is ignored:
    
        $ ls -1i /lower
        12 ECRYPTFS_FNEK_ENCRYPTED.FWYZD8TcW.5FV-TKTEYOHsheiHX9a-w.NURCCYIMjI8pn5BDB9-h3fXwrE--
        11 lost+found
        $ ls -1i /upper
        12 test
    
        Additionally, some potentially noisy error/info messages in the related
        code paths are turned into debug messages so that the logs can't be
        easily filled.
    
        Fixes: 88ae4ab9802e ("ecryptfs_lookup(): try either only encrypted or plaintext name")
        Reported-by: Guenter Roeck <linux@roeck-us.net>
        Cc: Al Viro <viro@zeniv.linux.org.uk>
        Signed-off-by: Tyler Hicks <tyhicks@canonical.com>
    
    commit e6f39e87b6439939a14cb7fdd94086a082b63b87
    Author: Joerg Roedel <jroedel@suse.de>
    Date:   Mon Apr 16 11:43:57 2018 +0200
    
        x86/ldt: Fix support_pte_mask filtering in map_ldt_struct()
    
        The |= operator will let us end up with an invalid PTE. Use
        the correct &= instead.
    
        [ The bug was also independently reported by Shuah Khan ]
    
        Fixes: fb43d6cb91ef ('x86/mm: Do not auto-massage page protections')
        Acked-by: Andy Lutomirski <luto@kernel.org>
        Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
        Signed-off-by: Joerg Roedel <jroedel@suse.de>
        Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
    
    commit 9783ccd0f2507cbe3c5ff1cb84bf6ae3a512d17d
    Author: Gao Feng <gfree.wind@vip.163.com>
    Date:   Mon Apr 16 10:16:45 2018 +0800
    
        net: Fix one possible memleak in ip_setup_cork
    
        It would allocate memory in this function when the cork->opt is NULL. But
        the memory isn't freed if failed in the latter rt check, and return error
        directly. It causes the memleak if its caller is ip_make_skb which also
        doesn't free the cork->opt when meet a error.
    
        Now move the rt check ahead to avoid the memleak.
    
        Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit d5edb7f8e7ab9fd5fd54a77d957b1733f117a813
    Author: Paolo Bonzini <pbonzini@redhat.com>
    Date:   Tue Mar 27 22:46:11 2018 +0200
    
        kvm: selftests: add vmx_tsc_adjust_test
    
        The test checks the behavior of setting MSR_IA32_TSC in a nested guest,
        and the TSC_OFFSET VMCS field in general.  It also introduces the testing
        infrastructure for Intel nested virtualization.
    
        Signed-off-by: Paolo Bonzini <pbonzini@redhat.com>
    
    commit dd259935e4eec844dc3e5b8a7cd951cd658b4fb6
    Author: Paolo Bonzini <pbonzini@redhat.com>
    Date:   Fri Apr 13 11:38:35 2018 +0200
    
        kvm: x86: move MSR_IA32_TSC handling to x86.c
    
        This is not specific to Intel/AMD anymore.  The TSC offset is available
        in vcpu->arch.tsc_offset.
    
        Signed-off-by: Paolo Bonzini <pbonzini@redhat.com>
    
    commit e79f245ddec17bbd89d73cd0169dba4be46c9b55
    Author: KarimAllah Ahmed <karahmed@amazon.de>
    Date:   Sat Apr 14 05:10:52 2018 +0200
    
        X86/KVM: Properly update 'tsc_offset' to represent the running guest
    
        Update 'tsc_offset' on vmentry/vmexit of L2 guests to ensure that it always
        captures the TSC_OFFSET of the running guest whether it is the L1 or L2
        guest.
    
        Cc: Paolo Bonzini <pbonzini@redhat.com>
        Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
        Cc: kvm@vger.kernel.org
        Cc: linux-kernel@vger.kernel.org
        Reviewed-by: Jim Mattson <jmattson@google.com>
        Suggested-by: Paolo Bonzini <pbonzini@redhat.com>
        Signed-off-by: KarimAllah Ahmed <karahmed@amazon.de>
        [AMD changes, fix update_ia32_tsc_adjust_msr. - Paolo]
        Signed-off-by: Paolo Bonzini <pbonzini@redhat.com>
    
    commit 5171b37d959641bbc619781caf62e61f7b940871
    Author: Eric Dumazet <edumazet@google.com>
    Date:   Sun Apr 15 17:52:04 2018 -0700
    
        net: af_packet: fix race in PACKET_{R|T}X_RING
    
        In order to remove the race caught by syzbot [1], we need
        to lock the socket before using po->tp_version as this could
        change under us otherwise.
    
        This means lock_sock() and release_sock() must be done by
        packet_set_ring() callers.
    
        [1] :
        BUG: KMSAN: uninit-value in packet_set_ring+0x1254/0x3870 net/packet/af_packet.c:4249
        CPU: 0 PID: 20195 Comm: syzkaller707632 Not tainted 4.16.0+ #83
        Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
        Call Trace:
         __dump_stack lib/dump_stack.c:17 [inline]
         dump_stack+0x185/0x1d0 lib/dump_stack.c:53
         kmsan_report+0x142/0x240 mm/kmsan/kmsan.c:1067
         __msan_warning_32+0x6c/0xb0 mm/kmsan/kmsan_instr.c:676
         packet_set_ring+0x1254/0x3870 net/packet/af_packet.c:4249
         packet_setsockopt+0x12c6/0x5a90 net/packet/af_packet.c:3662
         SYSC_setsockopt+0x4b8/0x570 net/socket.c:1849
         SyS_setsockopt+0x76/0xa0 net/socket.c:1828
         do_syscall_64+0x309/0x430 arch/x86/entry/common.c:287
         entry_SYSCALL_64_after_hwframe+0x3d/0xa2
        RIP: 0033:0x449099
        RSP: 002b:00007f42b5307ce8 EFLAGS: 00000246 ORIG_RAX: 0000000000000036
        RAX: ffffffffffffffda RBX: 000000000070003c RCX: 0000000000449099
        RDX: 0000000000000005 RSI: 0000000000000107 RDI: 0000000000000003
        RBP: 0000000000700038 R08: 000000000000001c R09: 0000000000000000
        R10: 00000000200000c0 R11: 0000000000000246 R12: 0000000000000000
        R13: 000000000080eecf R14: 00007f42b53089c0 R15: 0000000000000001
    
        Local variable description: ----req_u@packet_setsockopt
        Variable was created at:
         packet_setsockopt+0x13f/0x5a90 net/packet/af_packet.c:3612
         SYSC_setsockopt+0x4b8/0x570 net/socket.c:1849
    
        Fixes: f6fb8f100b80 ("af-packet: TPACKET_V3 flexible buffer implementation.")
        Signed-off-by: Eric Dumazet <edumazet@google.com>
        Reported-by: syzbot <syzkaller@googlegroups.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit f23e0643cd0b53e68e283b6f26194d56c28a2eb1
    Author: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
    Date:   Sun Apr 15 18:53:36 2018 -0500
    
        ibmvnic: Clear pending interrupt after device reset
    
        Due to a firmware bug, the hypervisor can send an interrupt to a
        transmit or receive queue just prior to a partition migration, not
        allowing the device enough time to handle it and send an EOI. When
        the partition migrates, the interrupt is lost but an "EOI-pending"
        flag for the interrupt line is still set in firmware. No further
        interrupts will be sent until that flag is cleared, effectively
        freezing that queue. To workaround this, the driver will disable the
        hardware interrupt and send an H_EOI signal prior to re-enabling it.
        This will flush the pending EOI and allow the driver to continue
        operation.
    
        Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit bffd168c3fc5cc7d2bad4c668fa90e7a9010db4b
    Author: Soheil Hassas Yeganeh <soheil@google.com>
    Date:   Sat Apr 14 20:44:46 2018 -0400
    
        tcp: clear tp->packets_out when purging write queue
    
        Clear tp->packets_out when purging the write queue, otherwise
        tcp_rearm_rto() mistakenly assumes TCP write queue is not empty.
        This results in NULL pointer dereference.
    
        Also, remove the redundant `tp->packets_out = 0` from
        tcp_disconnect(), since tcp_disconnect() calls
        tcp_write_queue_purge().
    
        Fixes: a27fd7a8ed38 (tcp: purge write queue upon RST)
        Reported-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
        Reported-by: Sami Farin <hvtaifwkbgefbaei@gmail.com>
        Tested-by: Sami Farin <hvtaifwkbgefbaei@gmail.com>
        Signed-off-by: Eric Dumazet <edumazet@google.com>
        Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
        Acked-by: Yuchung Cheng <ycheng@google.com>
        Acked-by: Neal Cardwell <ncardwell@google.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 4fb0534fb7bbc2346ba7d3a072b538007f4135a5
    Author: Paolo Abeni <pabeni@redhat.com>
    Date:   Fri Apr 13 13:59:25 2018 +0200
    
        team: avoid adding twice the same option to the event list
    
        When parsing the options provided by the user space,
        team_nl_cmd_options_set() insert them in a temporary list to send
        multiple events with a single message.
        While each option's attribute is correctly validated, the code does
        not check for duplicate entries before inserting into the event
        list.
    
        Exploiting the above, the syzbot was able to trigger the following
        splat:
    
        kernel BUG at lib/list_debug.c:31!
        invalid opcode: 0000 [#1] SMP KASAN
        Dumping ftrace buffer:
            (ftrace buffer empty)
        Modules linked in:
        CPU: 0 PID: 4466 Comm: syzkaller556835 Not tainted 4.16.0+ #17
        Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
        Google 01/01/2011
        RIP: 0010:__list_add_valid+0xaa/0xb0 lib/list_debug.c:29
        RSP: 0018:ffff8801b04bf248 EFLAGS: 00010286
        RAX: 0000000000000058 RBX: ffff8801c8fc7a90 RCX: 0000000000000000
        RDX: 0000000000000058 RSI: ffffffff815fbf41 RDI: ffffed0036097e3f
        RBP: ffff8801b04bf260 R08: ffff8801b0b2a700 R09: ffffed003b604f90
        R10: ffffed003b604f90 R11: ffff8801db027c87 R12: ffff8801c8fc7a90
        R13: ffff8801c8fc7a90 R14: dffffc0000000000 R15: 0000000000000000
        FS:  0000000000b98880(0000) GS:ffff8801db000000(0000) knlGS:0000000000000000
        CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
        CR2: 000000000043fc30 CR3: 00000001afe8e000 CR4: 00000000001406f0
        DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
        DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
        Call Trace:
          __list_add include/linux/list.h:60 [inline]
          list_add include/linux/list.h:79 [inline]
          team_nl_cmd_options_set+0x9ff/0x12b0 drivers/net/team/team.c:2571
          genl_family_rcv_msg+0x889/0x1120 net/netlink/genetlink.c:599
          genl_rcv_msg+0xc6/0x170 net/netlink/genetlink.c:624
          netlink_rcv_skb+0x172/0x440 net/netlink/af_netlink.c:2448
          genl_rcv+0x28/0x40 net/netlink/genetlink.c:635
          netlink_unicast_kernel net/netlink/af_netlink.c:1310 [inline]
          netlink_unicast+0x58b/0x740 net/netlink/af_netlink.c:1336
          netlink_sendmsg+0x9f0/0xfa0 net/netlink/af_netlink.c:1901
          sock_sendmsg_nosec net/socket.c:629 [inline]
          sock_sendmsg+0xd5/0x120 net/socket.c:639
          ___sys_sendmsg+0x805/0x940 net/socket.c:2117
          __sys_sendmsg+0x115/0x270 net/socket.c:2155
          SYSC_sendmsg net/socket.c:2164 [inline]
          SyS_sendmsg+0x29/0x30 net/socket.c:2162
          do_syscall_64+0x29e/0x9d0 arch/x86/entry/common.c:287
          entry_SYSCALL_64_after_hwframe+0x42/0xb7
        RIP: 0033:0x4458b9
        RSP: 002b:00007ffd1d4a7278 EFLAGS: 00000213 ORIG_RAX: 000000000000002e
        RAX: ffffffffffffffda RBX: 000000000000001b RCX: 00000000004458b9
        RDX: 0000000000000010 RSI: 0000000020000d00 RDI: 0000000000000004
        RBP: 00000000004a74ed R08: 0000000000000000 R09: 0000000000000000
        R10: 0000000000000000 R11: 0000000000000213 R12: 00007ffd1d4a7348
        R13: 0000000000402a60 R14: 0000000000000000 R15: 0000000000000000
        Code: 75 e8 eb a9 48 89 f7 48 89 75 e8 e8 d1 85 7b fe 48 8b 75 e8 eb bb 48
        89 f2 48 89 d9 4c 89 e6 48 c7 c7 a0 84 d8 87 e8 ea 67 28 fe <0f> 0b 0f 1f
        40 00 48 b8 00 00 00 00 00 fc ff df 55 48 89 e5 41
        RIP: __list_add_valid+0xaa/0xb0 lib/list_debug.c:29 RSP: ffff8801b04bf248
    
        This changeset addresses the avoiding list_add() if the current
        option is already present in the event list.
    
        Reported-and-tested-by: syzbot+4d4af685432dc0e56c91@syzkaller.appspotmail.com
        Signed-off-by: Paolo Abeni <pabeni@redhat.com>
        Fixes: 2fcdb2c9e659 ("team: allow to send multiple set events in one message")
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit b8858581febb050688e276b956796bc4a78299ed
    Author: Michael Ellerman <mpe@ellerman.id.au>
    Date:   Mon Apr 16 23:25:19 2018 +1000
    
        powerpc/lib: Fix off-by-one in alternate feature patching
    
        When we patch an alternate feature section, we have to adjust any
        relative branches that branch out of the alternate section.
    
        But currently we have a bug if we have a branch that points to past
        the last instruction of the alternate section, eg:
    
          FTR_SECTION_ELSE
          1:     b       2f
                 or      6,6,6
          2:
          ALT_FTR_SECTION_END(...)
                 nop
    
        This will result in a relative branch at 1 with a target that equals
        the end of the alternate section.
    
        That branch does not need adjusting when it's moved to the non-else
        location. Currently we do adjust it, resulting in a branch that goes
        off into the link-time location of the else section, which is junk.
    
        The fix is to not patch branches that have a target == end of the
        alternate section.
    
        Fixes: d20fe50a7b3c ("KVM: PPC: Book3S HV: Branch inside feature section")
        Fixes: 9b1a735de64c ("powerpc: Add logic to patch alternative feature sections")
        Cc: stable@vger.kernel.org # v2.6.27+
        Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
    
    commit de3d01fd8549ec0444fc917aab711b3f884930c5
    Author: Jia-Ju Bai <baijiaju1990@gmail.com>
    Date:   Wed Apr 11 09:15:31 2018 +0800
    
        xen: xen-pciback: Replace GFP_ATOMIC with GFP_KERNEL in pcistub_reg_add
    
        pcistub_reg_add() is never called in atomic context.
    
        pcistub_reg_add() is only called by pcistub_quirk_add, which is
        only set in DRIVER_ATTR().
    
        Despite never getting called from atomic context,
        pcistub_reg_add() calls kzalloc() with GFP_ATOMIC,
        which does not sleep for allocation.
        GFP_ATOMIC is not necessary and can be replaced with GFP_KERNEL,
        which can sleep and improve the possibility of sucessful allocation.
    
        This is found by a static analysis tool named DCNS written by myself.
        And I also manually check it.
    
        Signed-off-by: Jia-Ju Bai <baijiaju1990@gmail.com>
        Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
        Signed-off-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
    
    commit 230d211472d2779253e5a8383353fc44783dd038
    Author: Jia-Ju Bai <baijiaju1990@gmail.com>
    Date:   Mon Apr 9 23:04:25 2018 +0800
    
        xen: xen-pciback: Replace GFP_ATOMIC with GFP_KERNEL in xen_pcibk_config_quirks_init
    
        xen_pcibk_config_quirks_init() is never called in atomic context.
    
        The call chains ending up at xen_pcibk_config_quirks_init() are:
        [1] xen_pcibk_config_quirks_init() <- xen_pcibk_config_init_dev() <-
                pcistub_init_device() <- pcistub_seize() <- pcistub_probe()
        [2] xen_pcibk_config_quirks_init() <- xen_pcibk_config_init_dev() <-
                pcistub_init_device() <- pcistub_init_devices_late() <-
                xen_pcibk_init()
        pcistub_probe() is only set as ".probe" in struct pci_driver.
        xen_pcibk_init() is is only set as a parameter of module_init().
        These functions are not called in atomic context.
    
        Despite never getting called from atomic context,
        xen_pcibk_config_quirks_init() calls kzalloc() with GFP_ATOMIC,
        which does not sleep for allocation.
        GFP_ATOMIC is not necessary and can be replaced with GFP_KERNEL,
        which can sleep and improve the possibility of sucessful allocation.
    
        Signed-off-by: Jia-Ju Bai <baijiaju1990@gmail.com>
        Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
        Signed-off-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
    
    commit 9eb5f15b47b69847bfceb94350bd68fbdbf829e3
    Author: Jia-Ju Bai <baijiaju1990@gmail.com>
    Date:   Mon Apr 9 23:04:12 2018 +0800
    
        xen: xen-pciback: Replace GFP_ATOMIC with GFP_KERNEL in pcistub_device_alloc
    
        pcistub_device_alloc() is never called in atomic context.
    
        The call chain ending up at pcistub_device_alloc() is:
        [1] pcistub_device_alloc() <- pcistub_seize() <- pcistub_probe()
        pcistub_probe() is only set as ".probe" in struct pci_driver.
        This function is not called in atomic context.
    
        Despite never getting called from atomic context,
        pcistub_device_alloc() calls kzalloc() with GFP_ATOMIC,
        which does not sleep for allocation.
        GFP_ATOMIC is not necessary and can be replaced with GFP_KERNEL,
        which can sleep and improve the possibility of sucessful allocation.
    
        Signed-off-by: Jia-Ju Bai <baijiaju1990@gmail.com>
        Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
        Signed-off-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
    
    commit bb52e3169cb7dd5a9deea39b94342fce36235a5b
    Author: Jia-Ju Bai <baijiaju1990@gmail.com>
    Date:   Mon Apr 9 23:03:53 2018 +0800
    
        xen: xen-pciback: Replace GFP_ATOMIC with GFP_KERNEL in pcistub_init_device
    
        pcistub_init_device() is never called in atomic context.
    
        The call chain ending up at pcistub_init_device() is:
        [1] pcistub_init_device() <- pcistub_seize() <- pcistub_probe()
        [2] pcistub_init_device() <- pcistub_init_devices_late() <-
                xen_pcibk_init()
        pcistub_probe() is only set as ".probe" in struct pci_driver.
        xen_pcibk_init() is is only set as a parameter of module_init().
        These functions are not called in atomic context.
    
        Despite never getting called from atomic context,
        pcistub_init_device() calls kzalloc() with GFP_ATOMIC,
        which does not sleep for allocation.
        GFP_ATOMIC is not necessary and can be replaced with GFP_KERNEL,
        which can sleep and improve the possibility of sucessful allocation.
    
        This is found by a static analysis tool named DCNS written by myself.
        And I also manually check it.
    
        Signed-off-by: Jia-Ju Bai <baijiaju1990@gmail.com>
        Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
        Signed-off-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
    
    commit cc5cd5079699c7831fdc58e74352736706c3df3c
    Author: Jia-Ju Bai <baijiaju1990@gmail.com>
    Date:   Mon Apr 9 23:03:36 2018 +0800
    
        xen: xen-pciback: Replace GFP_ATOMIC with GFP_KERNEL in pcistub_probe
    
        pcistub_probe() is never called in atomic context.
        This function is only set as ".probe" in struct pci_driver.
    
        Despite never getting called from atomic context,
        pcistub_probe() calls kmalloc() with GFP_ATOMIC,
        which does not sleep for allocation.
        GFP_ATOMIC is not necessary and can be replaced with GFP_KERNEL,
        which can sleep and improve the possibility of sucessful allocation.
    
        This is found by a static analysis tool named DCNS written by myself.
        And I also manually check it.
    
        Signed-off-by: Jia-Ju Bai <baijiaju1990@gmail.com>
        Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
        Signed-off-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
    
    commit 982e05001c472066ab288e4269ad6cab48889f0d
    Author: Maxime Chevallier <maxime.chevallier@bootlin.com>
    Date:   Mon Apr 16 10:07:23 2018 +0200
    
        net: mvpp2: Fix TCAM filter reserved range
    
        Marvell's PPv2 controller has a Packet Header parser, which uses a
        fixed-size TCAM array of filter entries.
    
        The mvpp2 driver reserves some ranges among the 256 TCAM entries to
        perform MAC and VID filtering. The rest of the TCAM ids are freely usable
        for other features, such as IPv4 proto matching.
    
        This commit fixes the MVPP2_PE_LAST_FREE_TID define that sets the end of
        the "free range", which included the MAC range. This could therefore allow
        some other features to use entries dedicated to MAC filtering,
        lowering the number of unicast/multicast addresses that could be allowed
        before switching to promiscuous mode.
    
        Fixes: 10fea26ce2aa ("net: mvpp2: Add support for unicast filtering")
        Signed-off-by: Maxime Chevallier <maxime.chevallier@bootlin.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit bd28899dd34f9283c567f7eeb31bb546f10820b5
    Author: Dan Carpenter <dan.carpenter@oracle.com>
    Date:   Mon Apr 16 13:17:50 2018 +0300
    
        Revert "macsec: missing dev_put() on error in macsec_newlink()"
    
        This patch is just wrong, sorry.  I was trying to fix a static checker
        warning and misread the code.  The reference taken in macsec_newlink()
        is released in macsec_free_netdev() when the netdevice is destroyed.
    
        This reverts commit 5dcd8400884cc4a043a6d4617e042489e5d566a9.
    
        Reported-by: Laura Abbott <labbott@redhat.com>
        Fixes: 5dcd8400884c ("macsec: missing dev_put() on error in macsec_newlink()")
        Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
        Acked-by: Sabrina Dubroca <sd@queasysnail.net>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 2c2bf522ed8cbfaac666f7dc65cfd38de2b89f0f
    Author: Matt Redfearn <matt.redfearn@mips.com>
    Date:   Fri Apr 13 09:50:44 2018 +0100
    
        MIPS: dts: Boston: Fix PCI bus dtc warnings:
    
        dtc recently (v1.4.4-8-g756ffc4f52f6) added PCI bus checks. Fix the
        warnings now emitted:
    
        arch/mips/boot/dts/img/boston.dtb: Warning (pci_bridge): /pci@10000000: missing bus-range for PCI bridge
        arch/mips/boot/dts/img/boston.dtb: Warning (pci_bridge): /pci@12000000: missing bus-range for PCI bridge
        arch/mips/boot/dts/img/boston.dtb: Warning (pci_bridge): /pci@14000000: missing bus-range for PCI bridge
    
        Signed-off-by: Matt Redfearn <matt.redfearn@mips.com>
        Cc: Ralf Baechle <ralf@linux-mips.org>
        Cc: Paul Burton <paul.burton@mips.com>
        Cc: Rob Herring <robh+dt@kernel.org>
        Cc: Mark Rutland <mark.rutland@arm.com>
        Cc: linux-mips@linux-mips.org
        Cc: devicetree@vger.kernel.org
        Patchwork: https://patchwork.linux-mips.org/patch/19070/
        Signed-off-by: James Hogan <jhogan@kernel.org>
    
    commit 49d23a851d62c03daebae2d245dcc9b07dbfa89f
    Author: Heiko Carstens <heiko.carstens@de.ibm.com>
    Date:   Thu Apr 12 11:01:07 2018 +0200
    
        s390: rename default_defconfig to debug_defconfig
    
        The name debug_defconfig reflects what the config is actually good
        for and should be less confusing.
    
        Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit cd7cf57f18be4196306997d4325b8ebf895ab318
    Author: Heiko Carstens <heiko.carstens@de.ibm.com>
    Date:   Thu Apr 12 11:00:31 2018 +0200
    
        s390: remove gcov defconfig
    
        This config is not needed anymore.
    
        Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit de2011197d15746307e709687401397fe52bea83
    Author: Martin Schwidefsky <schwidefsky@de.ibm.com>
    Date:   Mon Nov 20 08:48:02 2017 +0100
    
        s390: update defconfig
    
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit 06856938112b84ff3c6b0594d017f59cfda2a43d
    Author: Souptick Joarder <jrdr.linux@gmail.com>
    Date:   Sun Apr 15 01:03:42 2018 +0530
    
        fs: ext2: Adding new return type vm_fault_t
    
        Use new return type vm_fault_t for page_mkwrite,
        pfn_mkwrite and fault handler.
    
        Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
        Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
        Signed-off-by: Jan Kara <jack@suse.cz>
    
    commit 4f34a5130a471f32f2fe7750769ab4057dc3eaa0
    Author: Chengguang Xu <cgxu519@gmx.com>
    Date:   Sat Apr 14 20:16:06 2018 +0800
    
        isofs: fix potential memory leak in mount option parsing
    
        When specifying string type mount option (e.g., iocharset)
        several times in a mount, current option parsing may
        cause memory leak. Hence, call kfree for previous one
        in this case. Meanwhile, check memory allocation result
        for it.
    
        Signed-off-by: Chengguang Xu <cgxu519@gmx.com>
        Signed-off-by: Jan Kara <jack@suse.cz>
    
    commit d93605407af34eb0b7eb8aff6b1eae2cde3cdd22
    Author: Ilya Dryomov <idryomov@gmail.com>
    Date:   Fri Mar 23 06:14:47 2018 +0100
    
        rbd: notrim map option
    
        Add an option to turn off discard and write zeroes offload support to
        avoid deprovisioning a fully provisioned image.  When enabled, discard
        requests will fail with -EOPNOTSUPP, write zeroes requests will fall
        back to manually zeroing.
    
        Signed-off-by: Ilya Dryomov <idryomov@gmail.com>
        Tested-by: Hitoshi Kamei <hitoshi.kamei.xm@hitachi.com>
    
    commit 420efbdf4d2358dc12913298ad44d041c6ac0ed6
    Author: Ilya Dryomov <idryomov@gmail.com>
    Date:   Mon Apr 16 09:32:18 2018 +0200
    
        rbd: adjust queue limits for "fancy" striping
    
        In order to take full advantage of merging in ceph_file_to_extents(),
        allow object set sized I/Os.  If the layout is not "fancy", an object
        set consists of just one object.
    
        Signed-off-by: Ilya Dryomov <idryomov@gmail.com>
    
    commit c6244b3b23771b258656445dcd212be759265b84
    Author: Arnd Bergmann <arnd@arndb.de>
    Date:   Wed Apr 4 14:53:39 2018 +0200
    
        rbd: avoid Wreturn-type warnings
    
        In some configurations gcc cannot see that rbd_assert(0) leads to an
        unreachable code path:
    
          drivers/block/rbd.c: In function 'rbd_img_is_write':
          drivers/block/rbd.c:1397:1: error: control reaches end of non-void function [-Werror=return-type]
          drivers/block/rbd.c: In function '__rbd_obj_handle_request':
          drivers/block/rbd.c:2499:1: error: control reaches end of non-void function [-Werror=return-type]
          drivers/block/rbd.c: In function 'rbd_obj_handle_write':
          drivers/block/rbd.c:2471:1: error: control reaches end of non-void function [-Werror=return-type]
    
        As the rbd_assert() here shows has no extra information beyond the verbose
        BUG(), we can simply use BUG() directly in its place.  This is reliably
        detected as not returning on any architecture, since it doesn't depend
        on the unlikely() comparison that confused gcc.
    
        Fixes: 3da691bf4366 ("rbd: new request handling code")
        Signed-off-by: Arnd Bergmann <arnd@arndb.de>
        Reviewed-by: Ilya Dryomov <idryomov@gmail.com>
        Signed-off-by: Ilya Dryomov <idryomov@gmail.com>
    
    commit ffdeec7aa41aa61ca4ee68fddf4669df9ce661d1
    Author: Yan, Zheng <zyan@redhat.com>
    Date:   Mon Mar 26 16:46:39 2018 +0800
    
        ceph: always update atime/mtime/ctime for new inode
    
        For new inode, atime/mtime/ctime are uninitialized.  Don't compare
        against them.
    
        Cc: stable@kernel.org
        Signed-off-by: "Yan, Zheng" <zyan@redhat.com>
        Reviewed-by: Ilya Dryomov <idryomov@gmail.com>
        Signed-off-by: Ilya Dryomov <idryomov@gmail.com>
    
    commit 34f55d0b3a0a39c95134c0c89173893b846d4c80
    Author: Dongsheng Yang <dongsheng.yang@easystack.cn>
    Date:   Mon Mar 26 10:22:55 2018 -0400
    
        rbd: support timeout in rbd_wait_state_locked()
    
        currently, the rbd_wait_state_locked() will wait forever if we
        can't get our state locked. Example:
    
        rbd map --exclusive test1  --> /dev/rbd0
        rbd map test1  --> /dev/rbd1
        dd if=/dev/zero of=/dev/rbd1 bs=1M count=1 --> IO blocked
    
        To avoid this problem, this patch introduce a timeout design
        in rbd_wait_state_locked(). Then rbd_wait_state_locked() will
        return error when we reach a timeout.
    
        This patch allow user to set the lock_timeout in rbd mapping.
    
        Signed-off-by: Dongsheng Yang <dongsheng.yang@easystack.cn>
        Reviewed-by: Ilya Dryomov <idryomov@gmail.com>
        Signed-off-by: Ilya Dryomov <idryomov@gmail.com>
    
    commit 2f18d46683cb3047c41229d57cf7c6e2ee48676f
    Author: Ilya Dryomov <idryomov@gmail.com>
    Date:   Wed Apr 4 10:15:38 2018 +0200
    
        rbd: refactor rbd_wait_state_locked()
    
        In preparation for lock_timeout option, make rbd_wait_state_locked()
        return error codes.
    
        Signed-off-by: Ilya Dryomov <idryomov@gmail.com>
    
    commit 451239eb3d397bd197a79cc3aab943da41ba0905
    Author: Heiko Carstens <heiko.carstens@de.ibm.com>
    Date:   Fri Apr 13 14:04:24 2018 +0200
    
        s390: add support for IBM z14 Model ZR1
    
        Just add the new machine type number to the two places that matter.
    
        Cc: <stable@vger.kernel.org> # v4.14+
        Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit f43c426a581f04272a852f0486ae431acff6d87e
    Author: Vasily Gorbik <gor@linux.ibm.com>
    Date:   Fri Apr 13 10:57:27 2018 +0200
    
        s390: remove couple of duplicate includes
    
        Removing couple of duplicate includes, found by "make includecheck".
        That leaves 1 duplicate include in arch/s390/kernel/entry.S, which is
        there for a reason (it includes generated asm/syscall_table.h twice).
    
        Signed-off-by: Vasily Gorbik <gor@linux.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit c65bbb51c6e98a1956c08faab81941ec558ef0ba
    Author: Vasily Gorbik <gor@linux.ibm.com>
    Date:   Wed Apr 11 10:24:29 2018 +0200
    
        s390/boot: remove unused COMPILE_VERSION and ccflags-y
    
        ccflags-y has no effect (no code is built in that directory,
        arch/s390/boot/compressed/Makefile defines its own KBUILD_CFLAGS).
        Removing ccflags-y together with COMPILE_VERSION.
    
        Reviewed-by: Heiko Carstens <heiko.carstens@de.ibm.com>
        Signed-off-by: Vasily Gorbik <gor@linux.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit 232acdff21fb02f0ccd538cd29c9ee7e028b6101
    Author: Sebastian Ott <sebott@linux.ibm.com>
    Date:   Tue Apr 10 12:39:34 2018 +0200
    
        s390/nospec: include cpu.h
    
        Fix the following sparse warnings:
        symbol 'cpu_show_spectre_v1' was not declared. Should it be static?
        symbol 'cpu_show_spectre_v2' was not declared. Should it be static?
    
        Signed-off-by: Sebastian Ott <sebott@linux.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit 701e188c6560d6abeba508f530c4224b4e830fb5
    Author: Thomas Richter <tmricht@linux.ibm.com>
    Date:   Thu Apr 12 08:42:48 2018 +0100
    
        s390/decompressor: Ignore file vmlinux.bin.full
    
        Commit 81796a3c6a4a ("s390/decompressor: trim uncompressed
        image head during the build") introduced a new
        file named vmlinux.bin.full in directory
        arch/s390/boot/compressed.
    
        Add this file to the list of ignored files so it does
        not show up on git status.
    
        Signed-off-by: Thomas Richter <tmricht@linux.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit de66b2429100c85b72db5c409526351d3ffc5faa
    Author: Heiko Carstens <heiko.carstens@de.ibm.com>
    Date:   Thu Apr 12 13:45:52 2018 +0200
    
        s390/kexec_file: add generated files to .gitignore
    
        Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit bdea9f6f7a707301878573a5c35e39e4fe817378
    Author: Philipp Rudo <prudo@linux.vnet.ibm.com>
    Date:   Tue Mar 27 13:14:12 2018 +0200
    
        s390/Kconfig: Move kexec config options to "Processor type and features"
    
        The config options for kexec are currently not under any menu directory. Up
        until now this was not a problem as standard kexec is always compiled in
        and thus does not create a menu entry. This changed when kexec_file_load
        was enabled. Its config option requires a menu entry which, when added
        beneath standard kexec option, appears on the main directory above "General
        Setup". Thus move the whole block further down such that the entry in now
        in "Processor type and features".
    
        While at it also update the help text for kexec file.
    
        Signed-off-by: Philipp Rudo <prudo@linux.vnet.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit 8be018827154666d1fe5904cb7a43b6706e01c87
    Author: Philipp Rudo <prudo@linux.vnet.ibm.com>
    Date:   Mon Sep 11 15:15:29 2017 +0200
    
        s390/kexec_file: Add ELF loader
    
        Add an ELF loader for kexec_file. The main task here is to do proper sanity
        checks on the ELF file. Basically all other functionality was already
        implemented for the image loader.
    
        Signed-off-by: Philipp Rudo <prudo@linux.vnet.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit ee337f5469fd67f22d231e520ec4189ce0589d92
    Author: Philipp Rudo <prudo@linux.vnet.ibm.com>
    Date:   Tue Sep 5 11:55:23 2017 +0200
    
        s390/kexec_file: Add crash support to image loader
    
        Add support to load a crash kernel to the image loader. This requires
        extending the purgatory.
    
        Signed-off-by: Philipp Rudo <prudo@linux.vnet.ibm.com>
        Reviewed-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit e49bb0a27fa3c6ec45cc13e2102a6ec13c4ae697
    Author: Philipp Rudo <prudo@linux.vnet.ibm.com>
    Date:   Wed Aug 30 14:03:38 2017 +0200
    
        s390/kexec_file: Add image loader
    
        Add an image loader for kexec_file_load. For simplicity first skip crash
        support. The functions defined in machine_kexec_file will later be shared
        with the ELF loader.
    
        Signed-off-by: Philipp Rudo <prudo@linux.vnet.ibm.com>
        Reviewed-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit 71406883fd35794d573b3085433c41d0a3bf6c21
    Author: Philipp Rudo <prudo@linux.vnet.ibm.com>
    Date:   Mon Jun 19 10:45:33 2017 +0200
    
        s390/kexec_file: Add kexec_file_load system call
    
        This patch adds the kexec_file_load system call to s390 as well as the arch
        specific functions common code requires to work. Loaders for the different
        file types will be added later.
    
        Signed-off-by: Philipp Rudo <prudo@linux.vnet.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit 840798a1f52994c172270893bd2ec6013cc92e40
    Author: Philipp Rudo <prudo@linux.vnet.ibm.com>
    Date:   Mon Aug 28 15:32:36 2017 +0200
    
        s390/kexec_file: Add purgatory
    
        The common code expects the architecture to have a purgatory that runs
        between the two kernels. Add it now. For simplicity first skip crash
        support.
    
        Signed-off-by: Philipp Rudo <prudo@linux.vnet.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit 15ceb8c936d13d940ca9e53996fbd05a26ce96db
    Author: Philipp Rudo <prudo@linux.vnet.ibm.com>
    Date:   Tue Jun 27 12:44:11 2017 +0200
    
        s390/kexec_file: Prepare setup.h for kexec_file_load
    
        kexec_file_load needs to prepare the new kernels before they are loaded.
        For that it has to know the offsets in head.S, e.g. to register the new
        command line. Unfortunately there are no macros right now defining those
        offsets. Define them now.
    
        Signed-off-by: Philipp Rudo <prudo@linux.vnet.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit 760dd0eeaec1689430243ead14e5a429613d8c52
    Author: Martin Schwidefsky <schwidefsky@de.ibm.com>
    Date:   Tue Apr 3 11:08:52 2018 +0200
    
        s390/smsgiucv: disable SMSG on module unload
    
        The module exit function of the smsgiucv module uses the incorrect CP
        command to disable SMSG messages. The correct command is "SET SMSG OFF".
        Use it.
    
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit dccccd332d028f57358a8b64ca88e691fc8be5b7
    Author: Vasily Gorbik <gor@linux.ibm.com>
    Date:   Fri Apr 13 18:22:14 2018 +0200
    
        s390/sclp: avoid potential usage of uninitialized value
    
        sclp_early_printk could be used before .bss section is zeroed
        (i.e. from als.c during the decompressor phase), therefore values used
        by sclp_early_printk should be located in the .data section.
    
        Another reason for that is to avoid potential initrd corruption, if some
        code in future would use sclp_early_printk before initrd is moved from
        possibly overlapping with .bss section region to a safe location.
    
        Fixes: 0b0d1173d8ae ("s390/sclp: 32 bit event mask compatibility mode")
        Signed-off-by: Vasily Gorbik <gor@linux.ibm.com>
        Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
        Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
    
    commit 8e04944f0ea8b838399049bdcda920ab36ae3b04
    Author: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
    Date:   Wed Apr 4 19:53:07 2018 +0900
    
        mm,vmscan: Allow preallocating memory for register_shrinker().
    
        syzbot is catching so many bugs triggered by commit 9ee332d99e4d5a97
        ("sget(): handle failures of register_shrinker()"). That commit expected
        that calling kill_sb() from deactivate_locked_super() without successful
        fill_super() is safe, but the reality was different; some callers assign
        attributes which are needed for kill_sb() after sget() succeeds.
    
        For example, [1] is a report where sb->s_mode (which seems to be either
        FMODE_READ | FMODE_EXCL | FMODE_WRITE or FMODE_READ | FMODE_EXCL) is not
        assigned unless sget() succeeds. But it does not worth complicate sget()
        so that register_shrinker() failure path can safely call
        kill_block_super() via kill_sb(). Making alloc_super() fail if memory
        allocation for register_shrinker() failed is much simpler. Let's avoid
        calling deactivate_locked_super() from sget_userns() by preallocating
        memory for the shrinker and making register_shrinker() in sget_userns()
        never fail.
    
        [1] https://syzkaller.appspot.com/bug?id=588996a25a2587be2e3a54e8646728fb9cae44e7
    
        Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
        Reported-by: syzbot <syzbot+5a170e19c963a2e0df79@syzkaller.appspotmail.com>
        Cc: Al Viro <viro@zeniv.linux.org.uk>
        Cc: Michal Hocko <mhocko@suse.com>
        Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
    
    commit 4a3877c4cedd95543f8726b0a98743ed8db0c0fb
    Author: Al Viro <viro@zeniv.linux.org.uk>
    Date:   Tue Apr 3 01:15:46 2018 -0400
    
        rpc_pipefs: fix double-dput()
    
        if we ever hit rpc_gssd_dummy_depopulate() dentry passed to
        it has refcount equal to 1.  __rpc_rmpipe() drops it and
        dput() done after that hits an already freed dentry.
    
        Cc: stable@kernel.org
        Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
    
    commit 659038428cb43a66e3eff71e2c845c9de3611a98
    Author: Al Viro <viro@zeniv.linux.org.uk>
    Date:   Tue Apr 3 00:13:17 2018 -0400
    
        orangefs_kill_sb(): deal with allocation failures
    
        orangefs_fill_sb() might've failed to allocate ORANGEFS_SB(s); don't
        oops in that case.
    
        Cc: stable@kernel.org
        Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
    
    commit c66b23c2840446a82c389e4cb1a12eb2a71fa2e4
    Author: Al Viro <viro@zeniv.linux.org.uk>
    Date:   Mon Apr 2 23:56:44 2018 -0400
    
        jffs2_kill_sb(): deal with failed allocations
    
        jffs2_fill_super() might fail to allocate jffs2_sb_info;
        jffs2_kill_sb() must survive that.
    
        Cc: stable@kernel.org
        Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
    
    commit a24cd490739586a7d2da3549a1844e1d7c4f4fc4
    Author: Al Viro <viro@zeniv.linux.org.uk>
    Date:   Mon Apr 2 23:50:31 2018 -0400
    
        hypfs_kill_super(): deal with failed allocations
    
        hypfs_fill_super() might fail to allocate sbi; hypfs_kill_super()
        should not oops on that.
    
        Cc: stable@vger.kernel.org
        Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
    
    commit c246fd333f84e6a0a8572f991637aa102f5e1865
    Author: Wang Sheng-Hui <shhuiw@foxmail.com>
    Date:   Sun Apr 15 16:07:12 2018 +0800
    
        filter.txt: update 'tools/net/' to 'tools/bpf/'
    
        The tools are located at tootls/bpf/ instead of tools/net/.
        Update the filter.txt doc.
    
        Signed-off-by: Wang Sheng-Hui <shhuiw@foxmail.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit f993740ee05821307eca03d23d468895740450f8
    Author: Edward Cree <ecree@solarflare.com>
    Date:   Fri Apr 13 19:18:09 2018 +0100
    
        sfc: limit ARFS workitems in flight per channel
    
        A misconfigured system (e.g. with all interrupts affinitised to all CPUs)
         may produce a storm of ARFS steering events.  With the existing sfc ARFS
         implementation, that could create a backlog of workitems that grinds the
         system to a halt.  To prevent this, limit the number of workitems that
         may be in flight for a given SFC device to 8 (EFX_RPS_MAX_IN_FLIGHT), and
         return EBUSY from our ndo_rx_flow_steer method if the limit is reached.
        Given this limit, also store the workitems in an array of slots within the
         struct efx_nic, rather than dynamically allocating for each request.
        The limit should not negatively impact performance, because it is only
         likely to be hit in cases where ARFS will be ineffective anyway.
    
        Signed-off-by: Edward Cree <ecree@solarflare.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit a7f80189e41c96c0c6210e9198a31859c91eb3e5
    Author: Edward Cree <ecree@solarflare.com>
    Date:   Fri Apr 13 19:17:49 2018 +0100
    
        sfc: pass the correctly bogus filter_id to rps_may_expire_flow()
    
        When we inserted an ARFS filter for ndo_rx_flow_steer(), we didn't know
         what the filter ID would be, so we just returned 0.  Thus, we must also
         pass 0 as the filter ID when calling rps_may_expire_flow() for it, and
         rely on the flow_id to identify what we're talking about.
    
        Fixes: 3af0f34290f6 ("sfc: replace asynchronous filter operations")
        Signed-off-by: Edward Cree <ecree@solarflare.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 494bef4c2a087876e75f3e95f7f63b06d6a65921
    Author: Edward Cree <ecree@solarflare.com>
    Date:   Fri Apr 13 19:17:22 2018 +0100
    
        sfc: insert ARFS filters with replace_equal=true
    
        Necessary to allow redirecting a flow when the application moves.
    
        Fixes: 3af0f34290f6 ("sfc: replace asynchronous filter operations")
        Signed-off-by: Edward Cree <ecree@solarflare.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit c7cd882469fc5042a5c84122b4062d7f53076db7
    Author: Helge Deller <deller@gmx.de>
    Date:   Fri Apr 13 21:54:37 2018 +0200
    
        parisc: Fix missing binfmt_elf32.o build error
    
        Commit 71d577db01a5 ("parisc: Switch to generic COMPAT_BINFMT_ELF")
        removed the binfmt_elf32.c source file, but missed to drop the object
        file from the list of object files the Makefile, which then results in a
        build error.
    
        Fixes: 71d577db01a5 ("parisc: Switch to generic COMPAT_BINFMT_ELF")
        Reported-by: Guenter Roeck <linux@roeck-us.net>
        Tested-by: Guenter Roeck <linux@roeck-us.net>
        Signed-off-by: Helge Deller <deller@gmx.de>
    
    commit a1cc7034e33d12dc17d13fbcd7d597d552889097
    Author: Sinan Kaya <okaya@codeaurora.org>
    Date:   Thu Apr 12 22:30:44 2018 -0400
    
        MIPS: io: Add barrier after register read in readX()
    
        While a barrier is present in the writeX() functions before the register
        write, a similar barrier is missing in the readX() functions after the
        register read. This could allow memory accesses following readX() to
        observe stale data.
    
        Signed-off-by: Sinan Kaya <okaya@codeaurora.org>
        Reported-by: Arnd Bergmann <arnd@arndb.de>
        Cc: Ralf Baechle <ralf@linux-mips.org>
        Cc: Paul Burton <paul.burton@mips.com>
        Cc: linux-mips@linux-mips.org
        Patchwork: https://patchwork.linux-mips.org/patch/19069/
        [jhogan@kernel.org: Tidy commit message]
        Signed-off-by: James Hogan <jhogan@kernel.org>
    
    commit f726214d9b23e5fce8c11937577a289a3202498f
    Author: Guillaume Nault <g.nault@alphalink.fr>
    Date:   Thu Apr 12 20:50:35 2018 +0200
    
        l2tp: hold reference on tunnels printed in l2tp/tunnels debugfs file
    
        Use l2tp_tunnel_get_nth() instead of l2tp_tunnel_find_nth(), to be safe
        against concurrent tunnel deletion.
    
        Use the same mechanism as in l2tp_ppp.c for dropping the reference
        taken by l2tp_tunnel_get_nth(). That is, drop the reference just
        before looking up the next tunnel. In case of error, drop the last
        accessed tunnel in l2tp_dfs_seq_stop().
    
        That was the last use of l2tp_tunnel_find_nth().
    
        Fixes: 0ad6614048cf ("l2tp: Add debugfs files for dumping l2tp debug info")
        Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 0e0c3fee3a59a387aeecc4fca6f3a2e9615a5443
    Author: Guillaume Nault <g.nault@alphalink.fr>
    Date:   Thu Apr 12 20:50:34 2018 +0200
    
        l2tp: hold reference on tunnels printed in pppol2tp proc file
    
        Use l2tp_tunnel_get_nth() instead of l2tp_tunnel_find_nth(), to be safe
        against concurrent tunnel deletion.
    
        Unlike sessions, we can't drop the reference held on tunnels in
        pppol2tp_seq_show(). Tunnels are reused across several calls to
        pppol2tp_seq_start() when iterating over sessions. These iterations
        need the tunnel for accessing the next session. Therefore the only safe
        moment for dropping the reference is just before searching for the next
        tunnel.
    
        Normally, the last invocation of pppol2tp_next_tunnel() doesn't find
        any new tunnel, so it drops the last tunnel without taking any new
        reference. However, in case of error, pppol2tp_seq_stop() is called
        directly, so we have to drop the reference there.
    
        Fixes: fd558d186df2 ("l2tp: Split pppol2tp patch into separate l2tp and ppp parts")
        Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 5846c131c39b6d0add36ec19dc8650700690f930
    Author: Guillaume Nault <g.nault@alphalink.fr>
    Date:   Thu Apr 12 20:50:33 2018 +0200
    
        l2tp: hold reference on tunnels in netlink dumps
    
        l2tp_tunnel_find_nth() is unsafe: no reference is held on the returned
        tunnel, therefore it can be freed whenever the caller uses it.
        This patch defines l2tp_tunnel_get_nth() which works similarly, but
        also takes a reference on the returned tunnel. The caller then has to
        drop it after it stops using the tunnel.
    
        Convert netlink dumps to make them safe against concurrent tunnel
        deletion.
    
        Fixes: 309795f4bec2 ("l2tp: Add netlink control API for L2TP")
        Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 9267c430c6b6f4c0120e3c6bb847313d633f02a6
    Author: Jason Wang <jasowang@redhat.com>
    Date:   Fri Apr 13 14:58:25 2018 +0800
    
        virtio-net: add missing virtqueue kick when flushing packets
    
        We tends to batch submitting packets during XDP_TX. This requires to
        kick virtqueue after a batch, we tried to do it through
        xdp_do_flush_map() which only makes sense for devmap not XDP_TX. So
        explicitly kick the virtqueue in this case.
    
        Reported-by: Kimitoshi Takahashi <ktaka@nii.ac.jp>
        Tested-by: Kimitoshi Takahashi <ktaka@nii.ac.jp>
        Cc: Daniel Borkmann <daniel@iogearbox.net>
        Fixes: 186b3c998c50 ("virtio-net: support XDP_REDIRECT")
        Signed-off-by: Jason Wang <jasowang@redhat.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 96348e49366c6e2a5a2e62ba0350f66ef5d67ea7
    Author: Amir Goldstein <amir73il@gmail.com>
    Date:   Thu Apr 5 16:18:05 2018 +0300
    
        MAINTAINERS: add an entry for FSNOTIFY infrastructure
    
        There is alreay an entry for all the backends, but those entries do
        not cover all the fsnotify files.
    
        Signed-off-by: Amir Goldstein <amir73il@gmail.com>
        Signed-off-by: Jan Kara <jack@suse.cz>
    
    commit 8e984f8667ff4225092af734eef28a3d7bae8626
    Author: Amir Goldstein <amir73il@gmail.com>
    Date:   Thu Apr 5 16:18:04 2018 +0300
    
        fsnotify: fix typo in a comment about mark->g_list
    
        Signed-off-by: Amir Goldstein <amir73il@gmail.com>
        Signed-off-by: Jan Kara <jack@suse.cz>
    
    commit 92183a42898dc400b89da35685d1814ac6acd3d8
    Author: Amir Goldstein <amir73il@gmail.com>
    Date:   Thu Apr 5 16:18:03 2018 +0300
    
        fsnotify: fix ignore mask logic in send_to_group()
    
        The ignore mask logic in send_to_group() does not match the logic
        in fanotify_should_send_event(). In the latter, a vfsmount mark ignore
        mask precedes an inode mark mask and in the former, it does not.
    
        That difference may cause events to be sent to fanotify backend for no
        reason. Fix the logic in send_to_group() to match that of
        fanotify_should_send_event().
    
        Signed-off-by: Amir Goldstein <amir73il@gmail.com>
        Signed-off-by: Jan Kara <jack@suse.cz>
    
    commit 2290482379278e0254e6edfdb681d88359143fd1
    Author: Richard Cochran <richardcochran@gmail.com>
    Date:   Mon Apr 9 00:03:14 2018 -0700
    
        net: dsa: mv88e6xxx: Fix receive time stamp race condition.
    
        The DSA stack passes received PTP frames to this driver via
        mv88e6xxx_port_rxtstamp() for deferred delivery.  The driver then
        queues the frame and kicks the worker thread.  The work callback reads
        out the latched receive time stamp and then works through the queue,
        delivering any non-matching frames without a time stamp.
    
        If a new frame arrives after the worker thread has read out the time
        stamp register but enters the queue before the worker finishes
        processing the queue, that frame will be delivered without a time
        stamp.
    
        This patch fixes the race by moving the queue onto a list on the stack
        before reading out the latched time stamp value.
    
        Fixes: c6fe0ad2c3499 ("net: dsa: mv88e6xxx: add rx/tx timestamping support")
        Signed-off-by: Richard Cochran <richardcochran@gmail.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 53b76cdf7e8fecec1d09e38aad2f8579882591a8
    Author: Wolfgang Bumiller <w.bumiller@proxmox.com>
    Date:   Thu Apr 12 10:46:55 2018 +0200
    
        net: fix deadlock while clearing neighbor proxy table
    
        When coming from ndisc_netdev_event() in net/ipv6/ndisc.c,
        neigh_ifdown() is called with &nd_tbl, locking this while
        clearing the proxy neighbor entries when eg. deleting an
        interface. Calling the table's pndisc_destructor() with the
        lock still held, however, can cause a deadlock: When a
        multicast listener is available an IGMP packet of type
        ICMPV6_MGM_REDUCTION may be sent out. When reaching
        ip6_finish_output2(), if no neighbor entry for the target
        address is found, __neigh_create() is called with &nd_tbl,
        which it'll want to lock.
    
        Move the elements into their own list, then unlock the table
        and perform the destruction.
    
        Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=199289
        Fixes: 6fd6ce2056de ("ipv6: Do not depend on rt->n in ip6_finish_output2().")
        Signed-off-by: Wolfgang Bumiller <w.bumiller@proxmox.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 1071ec9d453a38023579714b64a951a2fb982071
    Author: Xin Long <lucien.xin@gmail.com>
    Date:   Thu Apr 12 14:24:31 2018 +0800
    
        sctp: do not check port in sctp_inet6_cmp_addr
    
        pf->cmp_addr() is called before binding a v6 address to the sock. It
        should not check ports, like in sctp_inet_cmp_addr.
    
        But sctp_inet6_cmp_addr checks the addr by invoking af(6)->cmp_addr,
        sctp_v6_cmp_addr where it also compares the ports.
    
        This would cause that setsockopt(SCTP_SOCKOPT_BINDX_ADD) could bind
        multiple duplicated IPv6 addresses after Commit 40b4f0fd74e4 ("sctp:
        lack the check for ports in sctp_v6_cmp_addr").
    
        This patch is to remove af->cmp_addr called in sctp_inet6_cmp_addr,
        but do the proper check for both v6 addrs and v4mapped addrs.
    
        v1->v2:
          - define __sctp_v6_cmp_addr to do the common address comparison
            used for both pf and af v6 cmp_addr.
    
        Fixes: 40b4f0fd74e4 ("sctp: lack the check for ports in sctp_v6_cmp_addr")
        Reported-by: Jianwen Ji <jiji@redhat.com>
        Signed-off-by: Xin Long <lucien.xin@gmail.com>
        Acked-by: Neil Horman <nhorman@tuxdriver.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit cf2cbadc20f5651c3dde9f5ac2ee52fb43aa4ddd
    Author: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
    Date:   Wed Apr 11 16:47:38 2018 -0700
    
        nfp: flower: split and limit cmsg skb lists
    
        Introduce a second skb list for handling control messages and limit the
        number of allowed messages. Some control messages are considered more
        crucial than others, resulting in the need for a second skb list. By
        splitting the list into a separate high and low priority list we can
        ensure that messages on the high list get added to the head of the list
        that gets processed, this however has no functional impact. Previously
        there was no limit on the number of messages allowed on the queue, this
        could result in the queue growing boundlessly and eventually the host
        running out of memory.
    
        Fixes: b985f870a5f0 ("nfp: process control messages in workqueue in flower app")
        Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
        Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
        Reviewed-by: Simon Horman <simon.horman@netronome.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 0b1a989ef5a751b5992842d1934e22de861a848e
    Author: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
    Date:   Wed Apr 11 16:47:37 2018 -0700
    
        nfp: flower: move route ack control messages out of the workqueue
    
        Previously we processed the route ack control messages in the workqueue,
        this unnecessarily loads the workqueue. We can deal with these messages
        sooner as we know we are going to drop them.
    
        Fixes: 8e6a9046b66a ("nfp: flower vxlan neighbour offload")
        Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
        Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
        Reviewed-by: Simon Horman <simon.horman@netronome.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit bc05f9bcd8cb62f935625850e535da183b4a07c0
    Author: Jakub Kicinski <jakub.kicinski@netronome.com>
    Date:   Wed Apr 11 16:47:36 2018 -0700
    
        nfp: print a message when mutex wait is interrupted
    
        When waiting for an NFP mutex is interrupted print a message
        to make root causing later error messages easier.
    
        Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
        Reviewed-by: Dirk van der Merwe <dirk.vandermerwe@netronome.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 5496295aefe86995e41398b0f76de601308fc3f5
    Author: Jakub Kicinski <jakub.kicinski@netronome.com>
    Date:   Wed Apr 11 16:47:35 2018 -0700
    
        nfp: ignore signals when communicating with management FW
    
        We currently allow signals to interrupt the wait for management FW
        commands.  Exiting the wait should not cause trouble, the FW will
        just finish executing the command in the background and new commands
        will wait for the old one to finish.
    
        However, this may not be what users expect (Ctrl-C not actually stopping
        the command).  Moreover some systems routinely request link information
        with signals pending (Ubuntu 14.04 runs a landscape-sysinfo python tool
        from MOTD) worrying users with errors like these:
    
        nfp 0000:04:00.0: nfp_nsp: Error -512 waiting for code 0x0007 to start
        nfp 0000:04:00.0: nfp: reading port table failed -512
    
        Make the wait for management FW responses non-interruptible.
    
        Fixes: 1a64821c6af7 ("nfp: add support for service processor access")
        Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
        Reviewed-by: Dirk van der Merwe <dirk.vandermerwe@netronome.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 335b929b28aeb5bfc0698adb21deaf685b2982d1
    Author: Jon Maloy <jon.maloy@ericsson.com>
    Date:   Thu Apr 12 01:15:48 2018 +0200
    
        tipc: fix missing initializer in tipc_sendmsg()
    
        The stack variable 'dnode' in __tipc_sendmsg() may theoretically
        end up tipc_node_get_mtu() as an unitilalized variable.
    
        We fix this by intializing the variable at declaration. We also add
        a default else clause to the two conditional ones already there, so
        that we never end up in the named function if the given address
        type is illegal.
    
        Reported-by: syzbot+b0975ce9355b347c1546@syzkaller.appspotmail.com
        Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 9d0c75bf6e03d9bf80c55b0f677dc9b982958fd5
    Author: Doron Roberts-Kedes <doronrk@fb.com>
    Date:   Wed Apr 11 15:05:16 2018 -0700
    
        strparser: Fix incorrect strp->need_bytes value.
    
        strp_data_ready resets strp->need_bytes to 0 if strp_peek_len indicates
        that the remainder of the message has been received. However,
        do_strp_work does not reset strp->need_bytes to 0. If do_strp_work
        completes a partial message, the value of strp->need_bytes will continue
        to reflect the needed bytes of the previous message, causing
        future invocations of strp_data_ready to return early if
        strp->need_bytes is less than strp_peek_len. Resetting strp->need_bytes
        to 0 in __strp_recv on handing a full message to the upper layer solves
        this problem.
    
        __strp_recv also calculates strp->need_bytes using stm->accum_len before
        stm->accum_len has been incremented by cand_len. This can cause
        strp->need_bytes to be equal to the full length of the message instead
        of the full length minus the accumulated length. This, in turn, causes
        strp_data_ready to return early, even when there is sufficient data to
        complete the partial message. Incrementing stm->accum_len before using
        it to calculate strp->need_bytes solves this problem.
    
        Found while testing net/tls_sw recv path.
    
        Fixes: 43a0c6751a322847 ("strparser: Stream parser for messages")
        Signed-off-by: Doron Roberts-Kedes <doronrk@fb.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 5ff9c1a3dd92d2d8eeea6bb15b3502cfcc0e26fa
    Author: Anders Roxell <anders.roxell@linaro.org>
    Date:   Wed Apr 11 17:17:34 2018 +0200
    
        selftests: net: add in_netns.sh to TEST_PROGS
    
        Script in_netns.sh isn't installed.
        --------------------
        running psock_fanout test
        --------------------
        ./run_afpackettests: line 12: ./in_netns.sh: No such file or directory
        [FAIL]
        --------------------
        running psock_tpacket test
        --------------------
        ./run_afpackettests: line 22: ./in_netns.sh: No such file or directory
        [FAIL]
    
        In current code added in_netns.sh to be installed.
    
        Fixes: cc30c93fa020 ("selftests/net: ignore background traffic in psock_fanout")
        Signed-off-by: Anders Roxell <anders.roxell@linaro.org>
    
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit ebc701b796a67a5785399dcbc83d90e3b5f1e02f
    Author: Nathan Fontenot <nfont@linux.vnet.ibm.com>
    Date:   Wed Apr 11 10:09:38 2018 -0500
    
        ibmvnic: Do not notify peers on parameter change resets
    
        When attempting to change the driver parameters, such as the MTU
        value or number of queues, do not call netdev_notify_peers().
        Doing so will deadlock on the rtnl_lock.
    
        Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 64d92aa2c9fe490ceffc440d7648ce369cd6cc3c
    Author: Nathan Fontenot <nfont@linux.vnet.ibm.com>
    Date:   Wed Apr 11 10:09:32 2018 -0500
    
        ibmvnic: Handle all login error conditions
    
        There is a bug in handling the possible return codes from sending the
        login CRQ. The current code treats any non-success return value,
        minus failure to send the crq and a timeout waiting for a login response,
        as a need to re-send the login CRQ. This can put the drive in an
        infinite loop of trying to login when getting return values other
        that a partial success such as a return code of aborted. For these
        scenarios the login will not ever succeed at this point and the
        driver would need to be reset again.
    
        To resolve this loop trying to login is updated to only retry the
        login if the driver gets a return code of a partial success. Other
        return codes are treated as an error and the driver returns an error
        from ibmvnic_login().
    
        To avoid infinite looping in the partial success return cases, the
        number of retries is capped at the maximum number of supported
        queues. This value was chosen because the driver does a renegotiation
        of capabilities which sets the number of queues possible and allows
        the driver to attempt a login for possible value for the number
        of queues supported.
    
        Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 7dd07c143a4b54d050e748bee4b4b9e94a7b1744
    Author: Eric Dumazet <edumazet@google.com>
    Date:   Wed Apr 11 14:46:00 2018 -0700
    
        net: validate attribute sizes in neigh_dump_table()
    
        Since neigh_dump_table() calls nlmsg_parse() without giving policy
        constraints, attributes can have arbirary size that we must validate
    
        Reported by syzbot/KMSAN :
    
        BUG: KMSAN: uninit-value in neigh_master_filtered net/core/neighbour.c:2292 [inline]
        BUG: KMSAN: uninit-value in neigh_dump_table net/core/neighbour.c:2348 [inline]
        BUG: KMSAN: uninit-value in neigh_dump_info+0x1af0/0x2250 net/core/neighbour.c:2438
        CPU: 1 PID: 3575 Comm: syzkaller268891 Not tainted 4.16.0+ #83
        Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
        Call Trace:
         __dump_stack lib/dump_stack.c:17 [inline]
         dump_stack+0x185/0x1d0 lib/dump_stack.c:53
         kmsan_report+0x142/0x240 mm/kmsan/kmsan.c:1067
         __msan_warning_32+0x6c/0xb0 mm/kmsan/kmsan_instr.c:676
         neigh_master_filtered net/core/neighbour.c:2292 [inline]
         neigh_dump_table net/core/neighbour.c:2348 [inline]
         neigh_dump_info+0x1af0/0x2250 net/core/neighbour.c:2438
         netlink_dump+0x9ad/0x1540 net/netlink/af_netlink.c:2225
         __netlink_dump_start+0x1167/0x12a0 net/netlink/af_netlink.c:2322
         netlink_dump_start include/linux/netlink.h:214 [inline]
         rtnetlink_rcv_msg+0x1435/0x1560 net/core/rtnetlink.c:4598
         netlink_rcv_skb+0x355/0x5f0 net/netlink/af_netlink.c:2447
         rtnetlink_rcv+0x50/0x60 net/core/rtnetlink.c:4653
         netlink_unicast_kernel net/netlink/af_netlink.c:1311 [inline]
         netlink_unicast+0x1672/0x1750 net/netlink/af_netlink.c:1337
         netlink_sendmsg+0x1048/0x1310 net/netlink/af_netlink.c:1900
         sock_sendmsg_nosec net/socket.c:630 [inline]
         sock_sendmsg net/socket.c:640 [inline]
         ___sys_sendmsg+0xec0/0x1310 net/socket.c:2046
         __sys_sendmsg net/socket.c:2080 [inline]
         SYSC_sendmsg+0x2a3/0x3d0 net/socket.c:2091
         SyS_sendmsg+0x54/0x80 net/socket.c:2087
         do_syscall_64+0x309/0x430 arch/x86/entry/common.c:287
         entry_SYSCALL_64_after_hwframe+0x3d/0xa2
        RIP: 0033:0x43fed9
        RSP: 002b:00007ffddbee2798 EFLAGS: 00000213 ORIG_RAX: 000000000000002e
        RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 000000000043fed9
        RDX: 0000000000000000 RSI: 0000000020005000 RDI: 0000000000000003
        RBP: 00000000006ca018 R08: 00000000004002c8 R09: 00000000004002c8
        R10: 00000000004002c8 R11: 0000000000000213 R12: 0000000000401800
        R13: 0000000000401890 R14: 0000000000000000 R15: 0000000000000000
    
        Uninit was created at:
         kmsan_save_stack_with_flags mm/kmsan/kmsan.c:278 [inline]
         kmsan_internal_poison_shadow+0xb8/0x1b0 mm/kmsan/kmsan.c:188
         kmsan_kmalloc+0x94/0x100 mm/kmsan/kmsan.c:314
         kmsan_slab_alloc+0x11/0x20 mm/kmsan/kmsan.c:321
         slab_post_alloc_hook mm/slab.h:445 [inline]
         slab_alloc_node mm/slub.c:2737 [inline]
         __kmalloc_node_track_caller+0xaed/0x11c0 mm/slub.c:4369
         __kmalloc_reserve net/core/skbuff.c:138 [inline]
         __alloc_skb+0x2cf/0x9f0 net/core/skbuff.c:206
         alloc_skb include/linux/skbuff.h:984 [inline]
         netlink_alloc_large_skb net/netlink/af_netlink.c:1183 [inline]
         netlink_sendmsg+0x9a6/0x1310 net/netlink/af_netlink.c:1875
         sock_sendmsg_nosec net/socket.c:630 [inline]
         sock_sendmsg net/socket.c:640 [inline]
         ___sys_sendmsg+0xec0/0x1310 net/socket.c:2046
         __sys_sendmsg net/socket.c:2080 [inline]
         SYSC_sendmsg+0x2a3/0x3d0 net/socket.c:2091
         SyS_sendmsg+0x54/0x80 net/socket.c:2087
         do_syscall_64+0x309/0x430 arch/x86/entry/common.c:287
         entry_SYSCALL_64_after_hwframe+0x3d/0xa2
    
        Fixes: 21fdd092acc7 ("net: Add support for filtering neigh dump by master device")
        Signed-off-by: Eric Dumazet <edumazet@google.com>
        Cc: David Ahern <dsa@cumulusnetworks.com>
        Reported-by: syzbot <syzkaller@googlegroups.com>
        Acked-by: David Ahern <dsa@cumulusnetworks.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 7212303268918b9a203aebeacfdbd83b5e87b20d
    Author: Eric Dumazet <edumazet@google.com>
    Date:   Wed Apr 11 14:36:28 2018 -0700
    
        tcp: md5: reject TCP_MD5SIG or TCP_MD5SIG_EXT on established sockets
    
        syzbot/KMSAN reported an uninit-value in tcp_parse_options() [1]
    
        I believe this was caused by a TCP_MD5SIG being set on live
        flow.
    
        This is highly unexpected, since TCP option space is limited.
    
        For instance, presence of TCP MD5 option automatically disables
        TCP TimeStamp option at SYN/SYNACK time, which we can not do
        once flow has been established.
    
        Really, adding/deleting an MD5 key only makes sense on sockets
        in CLOSE or LISTEN state.
    
        [1]
        BUG: KMSAN: uninit-value in tcp_parse_options+0xd74/0x1a30 net/ipv4/tcp_input.c:3720
        CPU: 1 PID: 6177 Comm: syzkaller192004 Not tainted 4.16.0+ #83
        Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
        Call Trace:
         __dump_stack lib/dump_stack.c:17 [inline]
         dump_stack+0x185/0x1d0 lib/dump_stack.c:53
         kmsan_report+0x142/0x240 mm/kmsan/kmsan.c:1067
         __msan_warning_32+0x6c/0xb0 mm/kmsan/kmsan_instr.c:676
         tcp_parse_options+0xd74/0x1a30 net/ipv4/tcp_input.c:3720
         tcp_fast_parse_options net/ipv4/tcp_input.c:3858 [inline]
         tcp_validate_incoming+0x4f1/0x2790 net/ipv4/tcp_input.c:5184
         tcp_rcv_established+0xf60/0x2bb0 net/ipv4/tcp_input.c:5453
         tcp_v4_do_rcv+0x6cd/0xd90 net/ipv4/tcp_ipv4.c:1469
         sk_backlog_rcv include/net/sock.h:908 [inline]
         __release_sock+0x2d6/0x680 net/core/sock.c:2271
         release_sock+0x97/0x2a0 net/core/sock.c:2786
         tcp_sendmsg+0xd6/0x100 net/ipv4/tcp.c:1464
         inet_sendmsg+0x48d/0x740 net/ipv4/af_inet.c:764
         sock_sendmsg_nosec net/socket.c:630 [inline]
         sock_sendmsg net/socket.c:640 [inline]
         SYSC_sendto+0x6c3/0x7e0 net/socket.c:1747
         SyS_sendto+0x8a/0xb0 net/socket.c:1715
         do_syscall_64+0x309/0x430 arch/x86/entry/common.c:287
         entry_SYSCALL_64_after_hwframe+0x3d/0xa2
        RIP: 0033:0x448fe9
        RSP: 002b:00007fd472c64d38 EFLAGS: 00000216 ORIG_RAX: 000000000000002c
        RAX: ffffffffffffffda RBX: 00000000006e5a30 RCX: 0000000000448fe9
        RDX: 000000000000029f RSI: 0000000020a88f88 RDI: 0000000000000004
        RBP: 00000000006e5a34 R08: 0000000020e68000 R09: 0000000000000010
        R10: 00000000200007fd R11: 0000000000000216 R12: 0000000000000000
        R13: 00007fff074899ef R14: 00007fd472c659c0 R15: 0000000000000009
    
        Uninit was created at:
         kmsan_save_stack_with_flags mm/kmsan/kmsan.c:278 [inline]
         kmsan_internal_poison_shadow+0xb8/0x1b0 mm/kmsan/kmsan.c:188
         kmsan_kmalloc+0x94/0x100 mm/kmsan/kmsan.c:314
         kmsan_slab_alloc+0x11/0x20 mm/kmsan/kmsan.c:321
         slab_post_alloc_hook mm/slab.h:445 [inline]
         slab_alloc_node mm/slub.c:2737 [inline]
         __kmalloc_node_track_caller+0xaed/0x11c0 mm/slub.c:4369
         __kmalloc_reserve net/core/skbuff.c:138 [inline]
         __alloc_skb+0x2cf/0x9f0 net/core/skbuff.c:206
         alloc_skb include/linux/skbuff.h:984 [inline]
         tcp_send_ack+0x18c/0x910 net/ipv4/tcp_output.c:3624
         __tcp_ack_snd_check net/ipv4/tcp_input.c:5040 [inline]
         tcp_ack_snd_check net/ipv4/tcp_input.c:5053 [inline]
         tcp_rcv_established+0x2103/0x2bb0 net/ipv4/tcp_input.c:5469
         tcp_v4_do_rcv+0x6cd/0xd90 net/ipv4/tcp_ipv4.c:1469
         sk_backlog_rcv include/net/sock.h:908 [inline]
         __release_sock+0x2d6/0x680 net/core/sock.c:2271
         release_sock+0x97/0x2a0 net/core/sock.c:2786
         tcp_sendmsg+0xd6/0x100 net/ipv4/tcp.c:1464
         inet_sendmsg+0x48d/0x740 net/ipv4/af_inet.c:764
         sock_sendmsg_nosec net/socket.c:630 [inline]
         sock_sendmsg net/socket.c:640 [inline]
         SYSC_sendto+0x6c3/0x7e0 net/socket.c:1747
         SyS_sendto+0x8a/0xb0 net/socket.c:1715
         do_syscall_64+0x309/0x430 arch/x86/entry/common.c:287
         entry_SYSCALL_64_after_hwframe+0x3d/0xa2
    
        Fixes: cfb6eeb4c860 ("[TCP]: MD5 Signature Option (RFC2385) support.")
        Signed-off-by: Eric Dumazet <edumazet@google.com>
        Reported-by: syzbot <syzkaller@googlegroups.com>
        Acked-by: Yuchung Cheng <ycheng@google.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit c3317f4db831b7564ff8d1670326456a7fbbbcb3
    Author: Jon Maloy <jon.maloy@ericsson.com>
    Date:   Wed Apr 11 22:52:09 2018 +0200
    
        tipc: fix unbalanced reference counter
    
        When a topology subscription is created, we may encounter (or KASAN
        may provoke) a failure to create a corresponding service instance in
        the binding table. Instead of letting the tipc_nametbl_subscribe()
        report the failure back to the caller, the function just makes a warning
        printout and returns, without incrementing the subscription reference
        counter as expected by the caller.
    
        This makes the caller believe that the subscription was successful, so
        it will at a later moment try to unsubscribe the item. This involves
        a sub_put() call. Since the reference counter never was incremented
        in the first place, we get a premature delete of the subscription item,
        followed by a "use-after-free" warning.
    
        We fix this by adding a return value to tipc_nametbl_subscribe() and
        make the caller aware of the failure to subscribe.
    
        This bug seems to always have been around, but this fix only applies
        back to the commit shown below. Given the low risk of this happening
        we believe this to be sufficient.
    
        Fixes: commit 218527fe27ad ("tipc: replace name table service range
        array with rb tree")
        Reported-by: syzbot+aa245f26d42b8305d157@syzkaller.appspotmail.com
    
        Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 1c2734b31d72316e3faaad88c0c9c46fa92a4b20
    Author: Raghuram Chary J <raghuramchary.jallipalli@microchip.com>
    Date:   Wed Apr 11 20:36:36 2018 +0530
    
        lan78xx: PHY DSP registers initialization to address EEE link drop issues with long cables
    
        The patch is to configure DSP registers of PHY device
        to handle Gbe-EEE failures with >40m cable length.
    
        Fixes: 55d7de9de6c3 ("Microchip's LAN7800 family USB 2/3 to 10/100/1000 Ethernet device driver")
        Signed-off-by: Raghuram Chary J <raghuramchary.jallipalli@microchip.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 9a4381618262157586051f5ba0db42df3c6ab4b5
    Author: Laura Abbott <labbott@redhat.com>
    Date:   Tue Apr 10 18:04:29 2018 -0700
    
        mISDN: Remove VLAs
    
        There's an ongoing effort to remove VLAs[1] from the kernel to eventually
        turn on -Wvla. Remove the VLAs from the mISDN code by switching to using
        kstrdup in one place and using an upper bound in another.
    
        Signed-off-by: Laura Abbott <labbott@redhat.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit b16520f7493d06d8ef6d4255bdfcf7a803d7874a
    Author: Kees Cook <keescook@chromium.org>
    Date:   Tue Apr 10 17:52:34 2018 -0700
    
        net/tls: Remove VLA usage
    
        In the quest to remove VLAs from the kernel[1], this replaces the VLA
        size with the only possible size used in the code, and adds a mechanism
        to double-check future IV sizes.
    
        [1] https://lkml.kernel.org/r/CA+55aFzCG-zNmZwX4A2FQpadafLfEzK6CC=qPXydAacU1RqZWA@mail.gmail.com
    
        Signed-off-by: Kees Cook <keescook@chromium.org>
        Acked-by: Dave Watson <davejwatson@fb.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit 08ea556e14b56e9a49b19abd8e39f0c9e05582f2
    Author: Kees Cook <keescook@chromium.org>
    Date:   Tue Apr 10 15:26:43 2018 -0700
    
        ibmvnic: Define vnic_login_client_data name field as unsized array
    
        The "name" field of struct vnic_login_client_data is a char array of
        undefined length. This should be written as "char name[]" so the compiler
        can make better decisions about the field (for example, not assuming
        it's a single character). This was noticed while trying to tighten the
        CONFIG_FORTIFY_SOURCE checking.
    
        Signed-off-by: Kees Cook <keescook@chromium.org>
        Signed-off-by: David S. Miller <davem@davemloft.net>
    
    commit f6b7aeee8f167409195fbf1364d02988fecad1d0
    Author: Sinan Kaya <okaya@codeaurora.org>
    Date:   Tue Apr 3 08:55:03 2018 -0400
    
        MIPS: io: Prevent compiler reordering writeX()
    
        writeX() has strong ordering semantics with respect to memory updates.
        In the absence of a write barrier or a compiler barrier, the compiler
        can reorder register and memory update instructions. This breaks the
        writeX() API.
    
        Signed-off-by: Sinan Kaya <okaya@codeaurora.org>
        Cc: Arnd Bergmann <arnd@arndb.de>
        Cc: Ralf Baechle <ralf@linux-mips.org>
        Cc: Paul Burton <paul.burton@mips.com>
        Cc: linux-mips@linux-mips.org
        Patchwork: https://patchwork.linux-mips.org/patch/18997/
        [jhogan@kernel.org: Tidy commit message]
        Signed-off-by: James Hogan <jhogan@kernel.org>
    
    commit 4e1acd7b31a03f24cc6108d37d005e6b1d48c5d3
    Author: Peng Hao <peng.hao2@zte.com.cn>
    Date:   Fri Apr 13 08:36:30 2018 +0800
    
        kvm: selftests: add -std=gnu99 cflags
    
        lib/kvm_util.c: In function a??kvm_memcmp_hva_gvaa??:
        lib/kvm_util.c:332:2: error: a??fora?? loop initial declarations are only allowed in C99 mode
    
        So add -std=gnu99 to CFLAGS
    
        Signed-off-by: Peng Hao <peng.hao2@zte.com.cn>
        Signed-off-by: Paolo Bonzini <pbonzini@redhat.com>
    
    commit f0f4cf5b306620282db0c59ff963012e1973e025
    Author: Krish Sadhukhan <krish.sadhukhan@oracle.com>
    Date:   Wed Apr 11 01:10:16 2018 -0400
    
        x86: Add check for APIC access address for vmentry of L2 guests
    
        According to the sub-section titled 'VM-Execution Control Fields' in the
        section titled 'Basic VM-Entry Checks' in Intel SDM vol. 3C, the following
        vmentry check must be enforced:
    
            If the 'virtualize APIC-accesses' VM-execution control is 1, the
            APIC-access address must satisfy the following checks:
    
                - Bits 11:0 of the address must be 0.
                - The address should not set any bits beyond the processor's
                  physical-address width.
    
        This patch adds the necessary check to conform to this rule. If the check
        fails, we cause the L2 VMENTRY to fail which is what the associated unit
        test (following patch) expects.
    
        Reviewed-by: Mihai Carabas <mihai.carabas@oracle.com>
        Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
        Reviewed-by: Jim Mattson <jmattson@google.com>
        Reviewed-by: Wanpeng Li <wanpengli@tencent.com>
        Signed-off-by: Krish Sadhukhan <krish.sadhukhan@oracle.com>
        Signed-off-by: Paolo Bonzini <pbonzini@redhat.com>
    
    commit 3e83eda467050f13fa69d888993458b76e733de9
    Author: Aaron Ma <aaron.ma@canonical.com>
    Date:   Mon Apr 9 15:41:31 2018 +0800
    
        HID: i2c-hid: Fix resume issue on Raydium touchscreen device
    
        When Rayd touchscreen resumed from S3, it issues too many errors like:
        i2c_hid i2c-RAYD0001:00: i2c_hid_get_input: incomplete report (58/5442)
    
        And all the report data are corrupted, touchscreen is unresponsive.
    
        Fix this by re-sending report description command after resume.
        Add device ID as a quirk.
    
        Cc: stable@vger.kernel.org
        Signed-off-by: Aaron Ma <aaron.ma@canonical.com>
        Signed-off-by: Jiri Kosina <jkosina@suse.cz>
    
    commit 619d3a2922ce623ca2eca443cc936810d328317c
    Author: Aaron Armstrong Skomra <skomra@gmail.com>
    Date:   Wed Apr 4 14:24:11 2018 -0700
    
        HID: wacom: bluetooth: send exit report for recent Bluetooth devices
    
        The code path for recent Bluetooth devices omits an exit report which
        resets all the values of the device.
    
        Fixes: 4922cd26f0 ("HID: wacom: Support 2nd-gen Intuos Pro's Bluetooth classic interface")
        Cc: <stable@vger.kernel.org> # 4.11
        Signed-off-by: Aaron Armstrong Skomra <aaron.skomra@wacom.com>
        Reviewed-by: Ping Cheng <ping.cheng@wacom.com>
        Signed-off-by: Jiri Kosina <jkosina@suse.cz>
    
    commit 2698d82e519413c6ad287e6f14b29e0373ed37f8
    Author: hu huajun <huhuajun@linux.alibaba.com>
    Date:   Wed Apr 11 15:16:40 2018 +0800
    
        KVM: X86: fix incorrect reference of trace_kvm_pi_irte_update
    
        In arch/x86/kvm/trace.h, this function is declared as host_irq the
        first input, and vcpu_id the second, instead of otherwise.
    
        Signed-off-by: hu huajun <huhuajun@linux.alibaba.com>
        Signed-off-by: Paolo Bonzini <pbonzini@redhat.com>
    
    commit 8e9b29b61851ba452e33373743fadb52778e9075
    Author: KarimAllah Ahmed <karahmed@amazon.de>
    Date:   Wed Apr 11 11:16:03 2018 +0200
    
        X86/KVM: Do not allow DISABLE_EXITS_MWAIT when LAPIC ARAT is not available
    
        If the processor does not have an "Always Running APIC Timer" (aka ARAT),
        we should not give guests direct access to MWAIT. The LAPIC timer would
        stop ticking in deep C-states, so any host deadlines would not wakeup the
        host kernel.
    
        The host kernel intel_idle driver handles this by switching to broadcast
        mode when ARAT is not available and MWAIT is issued with a deep C-state
        that would stop the LAPIC timer. When MWAIT is passed through, we can not
        tell when MWAIT is issued.
    
        So just disable this capability when LAPIC ARAT is not available. I am not
        even sure if there are any CPUs with VMX support but no LAPIC ARAT or not.
    
        Cc: Paolo Bonzini <pbonzini@redhat.com>
        Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
        Reported-by: Wanpeng Li <kernellwp@gmail.com>
        Signed-off-by: KarimAllah Ahmed <karahmed@amazon.de>
        Signed-off-by: Paolo Bonzini <pbonzini@redhat.com>
    
    commit 5ac7c2fd6e7102532104907c0df94abca826ec5c
    Author: Kyle Spiers <ksspiers@google.com>
    Date:   Tue Apr 10 17:02:29 2018 -0700
    
        isofs compress: Remove VLA usage
    
        As part of the effort to remove VLAs from the kernel[1], this changes
        the allocation of the bhs and pages arrays from being on the stack to being
        kcalloc()ed. This also allows for the removal of the explicit zeroing
        of bhs.
    
        https://lkml.org/lkml/2018/3/7/621
    
        Signed-off-by: Kyle Spiers <ksspiers@google.com>
        Signed-off-by: Jan Kara <jack@suse.cz>
    
    commit 4d5f26ee310237552a36aa14ceee96d6659153cd
    Author: Colin Ian King <colin.king@canonical.com>
    Date:   Tue Apr 10 13:38:56 2018 +0100
    
        kvm: selftests: fix spelling mistake: "divisable" and "divisible"
    
        Trivial fix to spelling mistakes in comment and message text
    
        Signed-off-by: Colin Ian King <colin.king@canonical.com>
        Signed-off-by: Paolo Bonzini <pbonzini@redhat.com>
    
    commit 386c6ddbda180676b7d9fc375d54a7bdd353d39e
    Author: KarimAllah Ahmed <karahmed@amazon.de>
    Date:   Tue Apr 10 14:15:46 2018 +0200
    
        X86/VMX: Disable VMX preemption timer if MWAIT is not intercepted
    
        The VMX-preemption timer is used by KVM as a way to set deadlines for the
        guest (i.e. timer emulation). That was safe till very recently when
        capability KVM_X86_DISABLE_EXITS_MWAIT to disable intercepting MWAIT was
        introduced. According to Intel SDM 25.5.1:
    
        """
        The VMX-preemption timer operates in the C-states C0, C1, and C2; it also
        operates in the shutdown and wait-for-SIPI states. If the timer counts down
        to zero in any state other than the wait-for SIPI state, the logical
        processor transitions to the C0 C-state and causes a VM exit; the timer
        does not cause a VM exit if it counts down to zero in the wait-for-SIPI
        state. The timer is not decremented in C-states deeper than C2.
        """
    
        Now once the guest issues the MWAIT with a c-state deeper than
        C2 the preemption timer will never wake it up again since it stopped
        ticking! Usually this is compensated by other activities in the system that
        would wake the core from the deep C-state (and cause a VMExit). For
        example, if the host itself is ticking or it received interrupts, etc!
    
        So disable the VMX-preemption timer if MWAIT is exposed to the guest!
    
        Cc: Paolo Bonzini <pbonzini@redhat.com>
        Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
        Cc: kvm@vger.kernel.org
        Signed-off-by: KarimAllah Ahmed <karahmed@amazon.de>
        Fixes: 4d5422cea3b61f158d58924cbb43feada456ba5c
        Signed-off-by: Paolo Bonzini <pbonzini@redhat.com>
    
    commit 1aa3b3e0cbdb32439f04842e88fc7557a0777660
    Author: Jia-Ju Bai <baijiaju1990@gmail.com>
    Date:   Mon Apr 9 22:31:19 2018 +0800
    
        fs: quota: Replace GFP_ATOMIC with GFP_KERNEL in dquot_init
    
        dquot_init() is never called in atomic context.
        This function is only set as a parameter of fs_initcall().
    
        Despite never getting called from atomic context,
        dquot_init() calls __get_free_pages() with GFP_ATOMIC,
        which waits busily for allocation.
        GFP_ATOMIC is not necessary and can be replaced with GFP_KERNEL,
        to avoid busy waiting and improve the possibility of sucessful allocation.
    
        This is found by a static analysis tool named DCNS written by myself.
        And I also manually check it.
    
        Signed-off-by: Jia-Ju Bai <baijiaju1990@gmail.com>
        Signed-off-by: Jan Kara <jack@suse.cz>
    
    commit 54a307ba8d3cd00a3902337ffaae28f436eeb1a4
    Author: Amir Goldstein <amir73il@gmail.com>
    Date:   Wed Apr 4 23:42:18 2018 +0300
    
        fanotify: fix logic of events on child
    
        When event on child inodes are sent to the parent inode mark and
        parent inode mark was not marked with FAN_EVENT_ON_CHILD, the event
        will not be delivered to the listener process. However, if the same
        process also has a mount mark, the event to the parent inode will be
        delivered regadless of the mount mark mask.
    
        This behavior is incorrect in the case where the mount mark mask does
        not contain the specific event type. For example, the process adds
        a mark on a directory with mask FAN_MODIFY (without FAN_EVENT_ON_CHILD)
        and a mount mark with mask FAN_CLOSE_NOWRITE (without FAN_ONDIR).
    
        A modify event on a file inside that directory (and inside that mount)
        should not create a FAN_MODIFY event, because neither of the marks
        requested to get that event on the file.
    
        Fixes: 1968f5eed54c ("fanotify: use both marks when possible")
        Cc: stable <stable@vger.kernel.org>
        Signed-off-by: Amir Goldstein <amir73il@gmail.com>
        Signed-off-by: Jan Kara <jack@suse.cz>
    
    commit a955358d54695e4ad9f7d6489a7ac4d69a8fc711
    Author: Rodrigo Rivas Costa <rodrigorivascosta@gmail.com>
    Date:   Fri Apr 6 01:09:36 2018 +0200
    
        HID: hidraw: Fix crash on HIDIOCGFEATURE with a destroyed device
    
        Doing `ioctl(HIDIOCGFEATURE)` in a tight loop on a hidraw device
        and then disconnecting the device, or unloading the driver, can
        cause a NULL pointer dereference.
    
        When a hidraw device is destroyed it sets 0 to `dev->exist`.
        Most functions check 'dev->exist' before doing its work, but
        `hidraw_get_report()` was missing that check.
    
        Cc: stable@vger.kernel.org
        Signed-off-by: Rodrigo Rivas Costa <rodrigorivascosta@gmail.com>
        Signed-off-by: Jiri Kosina <jkosina@suse.cz>
    
    commit 2e210bbb7429cdcf1a1a3ad00c1bf98bd9bf2452
    Author: Dmitry Torokhov <dmitry.torokhov@gmail.com>
    Date:   Tue Apr 3 10:52:20 2018 -0700
    
        HID: input: fix battery level reporting on BT mice
    
        The commit 581c4484769e ("HID: input: map digitizer battery usage")
        assumed that devices having input (qas opposed to feature) report for
        battery strength would report the data on their own, without the need to
        be polled by the kernel; unfortunately it is not so. Many wireless mice
        do not send unsolicited reports with battery strength data and have to
        be polled explicitly. As a complication, stylus devices on digitizers
        are not normally connected to the base and thus can not be polled - the
        base can only determine battery strength in the stylus when it is in
        proximity.
    
        To solve this issue, we add a special flag that tells the kernel
        to avoid polling the device (and expect unsolicited reports) and set it
        when report field with physical usage of digitizer stylus (HID_DG_STYLUS).
        Unless this flag is set, and we have not seen the unsolicited reports,
        the kernel will attempt to poll the device when userspace attempts to
        read "capacity" and "state" attributes of power_supply object
        corresponding to the devices battery.
    
        Fixes: 581c4484769e ("HID: input: map digitizer battery usage")
        Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=198095
        Cc: stable@vger.kernel.org
        Reported-and-tested-by: Martin van Es <martin@mrvanes.com>
        Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
        Signed-off-by: Jiri Kosina <jkosina@suse.cz>
    
    commit 0136c741ff40e03323419feec05fcd594f36a463
    Author: Anson Huang <Anson.Huang@nxp.com>
    Date:   Wed Mar 28 11:22:38 2018 +0800
    
        clocksource/drivers/imx-tpm: Add different counter width support
    
        Different TPM modules have different width counters which is 16-bit or 32-bit,
        the counter width can be read from TPM_PARAM register bit[23:16], this patch
        adds dynamic check for counter width to support both 16-bit and 32-bit TPM
        modules.
    
        Signed-off-by: Anson Huang <Anson.Huang@nxp.com>
        Signed-off-by: Daniel Lezcano <daniel.lezcano@linaro.org>
    
    commit 506a7be93ff773d5d4cf75a59f342865605b4910
    Author: Anson Huang <Anson.Huang@nxp.com>
    Date:   Wed Mar 28 11:22:37 2018 +0800
    
        clocksource/drivers/imx-tpm: Correct some registers operation flow
    
        According to i.MX7ULP reference manual, TPM_SC_CPWMS can ONLY be written when
        counter is disabled, TPM_SC_TOF is write-1-clear, TPM_C0SC_CHF is also
        write-1-clear, correct these registers initialization flow;
    
        Signed-off-by: Anson Huang <Anson.Huang@nxp.com>
        Signed-off-by: Daniel Lezcano <daniel.lezcano@linaro.org>
    
    commit 16328e7bd428937f557a984d8b3378387c17a930
    Author: Anson Huang <Anson.Huang@nxp.com>
    Date:   Wed Mar 28 11:22:36 2018 +0800
    
        clocksource/drivers/imx-tpm: Fix typo of clock name
    
        The clock name should be ipg instead of igp.
    
        Signed-off-by: Anson Huang <Anson.Huang@nxp.com>
        Signed-off-by: Daniel Lezcano <daniel.lezcano@linaro.org>
    
    commit cc01456a0d9a3cbfec85cf23f2ce53323e8fc973
    Author: Anson Huang <Anson.Huang@nxp.com>
    Date:   Wed Mar 28 11:22:35 2018 +0800
    
        dt-bindings: timer: tpm: fix typo of clock name
    
        The clock name should be ipg instead of igp.
    
        Signed-off-by: Anson Huang <Anson.Huang@nxp.com>
        Reviewed-by: Rob Herring <robh@kernel.org>
        Signed-off-by: Daniel Lezcano <daniel.lezcano@linaro.org>
    
    commit 1c00289ecd12471ba9733e61aaf1d39883a77b16
    Author: Tomer Maimon <tmaimon77@gmail.com>
    Date:   Thu Mar 8 17:24:58 2018 +0200
    
        clocksource/drivers/npcm: Add NPCM7xx timer driver
    
        Add Nuvoton BMC NPCM7xx timer driver.
    
        The clocksource Enable 24-bit TIMER0 and TIMER1 counters,
        while TIMER0 serve as clockevent and TIMER1 serve as clocksource.
    
        Signed-off-by: Tomer Maimon <tmaimon77@gmail.com>
        Reviewed-by: Brendan Higgins <brendanhiggins@xxxxxxxxxx>
        Signed-off-by: Daniel Lezcano <daniel.lezcano@linaro.org>
    
    commit ff2969c479d97c6221a9835ee0ab4c44513badc6
    Author: Tomer Maimon <tmaimon77@gmail.com>
    Date:   Thu Mar 8 17:24:57 2018 +0200
    
        dt-binding: timer: document NPCM7xx timer DT bindings
    
        Added device tree binding documentation for Nuvoton NPCM7xx timer.
    
        Signed-off-by: Tomer Maimon <tmaimon77@gmail.com>
        Acked-by: Rob Herring <robh@kernel.org>
        Reviewed-by: Brendan Higgins <brendanhiggins@google.com>
        Signed-off-by: Daniel Lezcano <daniel.lezcano@linaro.org>
    
    commit f62fd7a77717350e850f3c4a5373fe8e64871025
    Author: Colin Ian King <colin.king@canonical.com>
    Date:   Fri Mar 2 09:07:08 2018 +0000
    
        ecryptfs: fix spelling mistake: "cadidate" -> "candidate"
    
        Trivial fix to spelling mistake in debug message text.
    
        Signed-off-by: Colin Ian King <colin.king@canonical.com>
        Signed-off-by: Tyler Hicks <tyhicks@canonical.com>
    
    commit ab13a9218c9883d1f51940b9e720c63ef54a2c07
    Author: Guenter Roeck <linux@roeck-us.net>
    Date:   Thu Jan 18 18:40:25 2018 -0800
    
        ecryptfs: lookup: Don't check if mount_crypt_stat is NULL
    
        mount_crypt_stat is assigned to
        &ecryptfs_superblock_to_private(ecryptfs_dentry->d_sb)->mount_crypt_stat,
        and mount_crypt_stat is not the first object in struct ecryptfs_sb_info.
        mount_crypt_stat is therefore never NULL. At the same time, no crash
        in ecryptfs_lookup() has been reported, and the lookup functions in
        other file systems don't check if d_sb is NULL either.
        Given that, remove the NULL check.
    
        Signed-off-by: Guenter Roeck <linux@roeck-us.net>
        Signed-off-by: Tyler Hicks <tyhicks@canonical.com>

60cc43fc88  Linux 4.17-rc1
486ad79630  origin
37ee4b8879  pci: test for unexpectedly disabled bridges
+------------------------------------------+-----------+------------+------------+
|                                          | v4.17-rc1 | 486ad79630 | mmotm/v4.1 |
+------------------------------------------+-----------+------------+------------+
| boot_successes                           | 81        | 4          | 0          |
| boot_failures                            | 0         | 11         | 11         |
| BUG:unable_to_handle_kernel              | 0         | 11         | 11         |
| Oops:#[##]                               | 0         | 11         | 11         |
| RIP:llc_ui_release                       | 0         | 11         | 11         |
| Kernel_panic-not_syncing:Fatal_exception | 0         | 11         | 11         |
+------------------------------------------+-----------+------------+------------+

[main] Setsockopt(101 c 1b24000 a) on fd 177 [3:5:240]
[main] Setsockopt(1 2c 1b24000 4) on fd 178 [5:2:0]
[main] Setsockopt(29 8 1b24000 4) on fd 180 [10:1:0]
[main] Setsockopt(1 20 1b24000 4) on fd 181 [26:2:125]
[main] Setsockopt(11 1 1b24000 4) on fd 183 [2:2:17]
[   15.532543] BUG: unable to handle kernel NULL pointer dereference at 0000000000000004
[   15.534143] PGD 800000001734b067 P4D 800000001734b067 PUD 17350067 PMD 0 
[   15.535516] Oops: 0002 [#1] PTI
[   15.536165] Modules linked in:
[   15.536798] CPU: 0 PID: 363 Comm: trinity-main Not tainted 4.17.0-rc1-00001-g486ad79 #2
[   15.538396] RIP: 0010:llc_ui_release+0x3a/0xd0
[   15.539293] RSP: 0018:ffffc9000015bd70 EFLAGS: 00010202
[   15.540345] RAX: 0000000000000001 RBX: ffff88001fa60008 RCX: 0000000000000006
[   15.541802] RDX: 0000000000000006 RSI: ffff88001fdda660 RDI: ffff88001fa60008
[   15.543139] RBP: ffffc9000015bd80 R08: 0000000000000000 R09: 0000000000000000
[   15.544725] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[   15.546287] R13: ffff88001fa61730 R14: ffff88001e130a60 R15: ffff880019bdb3f0
[   15.547962] FS:  00007f2221bb1700(0000) GS:ffffffff82034000(0000) knlGS:0000000000000000
[   15.549848] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   15.551186] CR2: 0000000000000004 CR3: 000000001734e000 CR4: 00000000000006b0
[   15.552671] DR0: 0000000002232000 DR1: 0000000000000000 DR2: 0000000000000000
[   15.554105] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[   15.555534] Call Trace:
[   15.556049]  sock_release+0x14/0x60
[   15.556767]  sock_close+0xd/0x20
[   15.557427]  __fput+0xba/0x1f0
[   15.558058]  ____fput+0x9/0x10
[   15.558682]  task_work_run+0x73/0xa0
[   15.559416]  do_exit+0x231/0xab0
[   15.560079]  do_group_exit+0x3f/0xc0
[   15.560810]  __x64_sys_exit_group+0x13/0x20
[   15.561656]  do_syscall_64+0x58/0x2f0
[   15.562407]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[   15.563360]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   15.564471] RIP: 0033:0x7f2221696408
[   15.565264] RSP: 002b:00007ffe5c544c48 EFLAGS: 00000206 ORIG_RAX: 00000000000000e7
[   15.566924] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f2221696408
[   15.568485] RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
[   15.570046] RBP: 0000000000000000 R08: 00000000000000e7 R09: ffffffffffffffa0
[   15.571603] R10: 00007ffe5c5449e0 R11: 0000000000000206 R12: 0000000000000004
[   15.573160] R13: 00007ffe5c544e30 R14: 0000000000000000 R15: 0000000000000000
[   15.574720] Code: 7b ff 43 78 0f 88 a5 6f 14 00 31 f6 48 89 df e8 ad 33 fb ff 48 89 df e8 55 94 ff ff 85 c0 0f 84 84 00 00 00 4c 8b a3 d8 04 00 00 <41> ff 44 24 04 0f 88 7f 6f 14 00 48 8b 43 58 f6 c4 01 74 58 48 
[   15.578679] RIP: llc_ui_release+0x3a/0xd0 RSP: ffffc9000015bd70
[   15.579874] CR2: 0000000000000004
[   15.580553] ---[ end trace 0dd8fdc6b7182234 ]---
[   15.581491] Kernel panic - not syncing: Fatal exception

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start b309e20d9dc7223f34a55a1a5e573a9b69da3783 60cc43fc888428bb2f18f08997432d426a243338 --
git bisect  bad 74f5796964d2f308c4f065084c2d805101782b2a  # 09:08  B      0    11   26   0  Merge 'stm32/stm32-next' into devel-catchup-201805030716
git bisect  bad da0bab875e8538bd9db5761ec03e431f83fb0019  # 09:16  B      0    11   26   0  Merge 'sailus-media/for-4.18-3' into devel-catchup-201805030716
git bisect  bad ae6b372217655a323c42fddd040be9c27f22dfc3  # 09:26  B      0     2   17   0  Merge 'pinctrl/for-next' into devel-catchup-201805030716
git bisect good 7d12e09a3344e90e00c6a8258cc8c64d4a277daa  # 09:42  G     11     0    0   0  0day base guard for 'devel-catchup-201805030716'
git bisect  bad 23bd6b85a69b1067ebe776b655424eec21932afe  # 09:54  B      0     7   21   0  Merge 'linux-review/Roman-Gushchin/mm-introduce-memory-min/20180503-064145' into devel-catchup-201805030716
git bisect  bad aacc1db1cf5776722a20162c7a33b05ebe68ca89  # 10:01  B      0    11   25   0  prctl: don't compile some of prctl functions when CRUI disabled
git bisect  bad 0e6521e40b9f94fea176cee6038b63e3c7c687d1  # 10:11  B      0     6   20   0  block: restore /proc/partitions to not display non-partitionable removable devices
git bisect  bad 4edeafbad56d4b28e9e7e50c6ccd744c139597fc  # 10:21  B      0     5   19   0  fs, elf: don't complain MAP_FIXED_NOREPLACE unless -EEXIST error
git bisect  bad f138cdd1d1c3aca9a49cf341bcfacc994deecd00  # 10:43  B      0    11   25   0  mm: enable thp migration for shmem thp
git bisect  bad e72831147e882465861aae379241e116ddc01f2c  # 10:52  B      0    11   25   0  fork: unconditionally clear stack on fork
git bisect  bad 059df5489edd250efd0048c95c2b9be42459818f  # 11:03  B      0    11   25   0  I need old gcc
git bisect  bad 486ad79630d0ba0b7205a8db9fe15ba392f5ee32  # 11:13  B      0    11   25   0  origin
# first bad commit: [486ad79630d0ba0b7205a8db9fe15ba392f5ee32] origin
git bisect good 60cc43fc888428bb2f18f08997432d426a243338  # 11:16  G     31     0    0   0  Linux 4.17-rc1
# extra tests with debug options
git bisect  bad 486ad79630d0ba0b7205a8db9fe15ba392f5ee32  # 11:28  B      0    11   25   0  origin
# extra tests on HEAD of linux-devel/devel-catchup-201805030716
git bisect  bad b309e20d9dc7223f34a55a1a5e573a9b69da3783  # 11:28  B      0    13   31   0  0day head guard for 'devel-catchup-201805030716'
# extra tests on tree/branch mmotm/master
git bisect  bad 37ee4b887928911dc6d2dd39a869330511068919  # 11:47  B      0     9   23   0  pci: test for unexpectedly disabled bridges

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--g4n64py7ydqsqxql
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-quantal-vp-22:20180503111253:x86_64-randconfig-u0-05030649:4.17.0-rc1-00001-g486ad79:2.gz"
Content-Transfer-Encoding: base64

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

--g4n64py7ydqsqxql
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="reproduce-quantal-vp-22:20180503111253:x86_64-randconfig-u0-05030649:4.17.0-rc1-00001-g486ad79:2"

#!/bin/bash

kernel=$1
initrd=quantal-core-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/quantal/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu kvm64
	-kernel $kernel
	-initrd $initrd
	-m 512
	-smp 2
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-watchdog-action debug
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null
)

append=(
	root=/dev/ram0
	hung_task_panic=1
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	net.ifnames=0
	printk.devkmsg=on
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	drbd.minor_count=8
	systemd.log_level=err
	ignore_loglevel
	console=tty0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	vga=normal
	rw
	drbd.minor_count=8
	rcuperf.shutdown=0
)

"${kvm[@]}" -append "${append[*]}"

--g4n64py7ydqsqxql
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.17.0-rc1-00001-g486ad79"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.17.0-rc1 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_KERNEL_LZ4=y
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
# CONFIG_POSIX_MQUEUE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_USELIB is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
# CONFIG_GENERIC_IRQ_DEBUGFS is not set
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
CONFIG_NO_HZ=y
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
# CONFIG_TASK_XACCT is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_TINY_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_CGROUP_PIDS=y
CONFIG_CGROUP_RDMA=y
# CONFIG_CGROUP_FREEZER is not set
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
# CONFIG_CGROUP_BPF is not set
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=y
# CONFIG_NAMESPACES is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
# CONFIG_RD_LZ4 is not set
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_MULTIUSER=y
# CONFIG_SGETMASK_SYSCALL is not set
# CONFIG_SYSFS_SYSCALL is not set
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_FHANDLE=y
# CONFIG_POSIX_TIMERS is not set
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
# CONFIG_AIO is not set
CONFIG_ADVISE_SYSCALLS=y
# CONFIG_MEMBARRIER is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT_ALWAYS_ON=y
# CONFIG_USERFAULTFD is not set
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PC104=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
CONFIG_SLAB_MERGE_DEFAULT=y
CONFIG_PROFILING=y
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_KPROBES is not set
CONFIG_JUMP_LABEL=y
CONFIG_STATIC_KEYS_SELFTEST=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_FUNCTION_ERROR_INJECTION=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_FORTIFY_SOURCE=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_HAVE_ARCH_THREAD_STRUCT_WHITELIST=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_HAVE_RCU_TABLE_FREE=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
# CONFIG_GCC_PLUGINS is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
# CONFIG_CC_STACKPROTECTOR_AUTO is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
CONFIG_HAVE_RELIABLE_STACKTRACE=y
CONFIG_ISA_BUS_API=y
CONFIG_HAVE_ARCH_VMAP_STACK=y
CONFIG_VMAP_STACK=y
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
# CONFIG_REFCOUNT_FULL is not set

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
# CONFIG_MODULE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
CONFIG_MODULE_COMPRESS=y
CONFIG_MODULE_COMPRESS_GZIP=y
# CONFIG_MODULE_COMPRESS_XZ is not set
CONFIG_MODULES_TREE_LOOKUP=y
# CONFIG_BLOCK is not set
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
CONFIG_ARCH_HAS_SYSCALL_WRAPPER=y

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
# CONFIG_X86_X2APIC is not set
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
CONFIG_RETPOLINE=y
# CONFIG_INTEL_RDT is not set
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=m
CONFIG_IOSF_MBI_DEBUG=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_JAILHOUSE_GUEST is not set
CONFIG_NO_BOOTMEM=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_DMI is not set
# CONFIG_GART_IOMMU is not set
CONFIG_CALGARY_IOMMU=y
CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=y
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS_RANGE_BEGIN=1
CONFIG_NR_CPUS_RANGE_END=1
CONFIG_NR_CPUS_DEFAULT=1
CONFIG_NR_CPUS=1
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_UP_LATE_INIT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set

#
# Performance monitoring
#
# CONFIG_PERF_EVENTS_INTEL_UNCORE is not set
CONFIG_PERF_EVENTS_INTEL_RAPL=y
# CONFIG_PERF_EVENTS_INTEL_CSTATE is not set
CONFIG_PERF_EVENTS_AMD_POWER=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
CONFIG_MICROCODE=y
# CONFIG_MICROCODE_INTEL is not set
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
# CONFIG_X86_CPUID is not set
# CONFIG_X86_5LEVEL is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_X86_DIRECT_GBPAGES=y
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
# CONFIG_AMD_MEM_ENCRYPT is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_HAVE_GENERIC_GUP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_THP_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_THP_SWAP=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_NEED_PER_CPU_KM=y
CONFIG_CLEANCACHE=y
CONFIG_CMA=y
CONFIG_CMA_DEBUG=y
CONFIG_CMA_DEBUGFS=y
CONFIG_CMA_AREAS=7
# CONFIG_ZPOOL is not set
CONFIG_ZBUD=m
# CONFIG_ZSMALLOC is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_DEFERRED_STRUCT_PAGE_INIT=y
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_FRAME_VECTOR=y
# CONFIG_PERCPU_STATS is not set
CONFIG_GUP_BENCHMARK=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MTRR is not set
# CONFIG_ARCH_RANDOM is not set
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_UMIP=y
# CONFIG_X86_INTEL_MPX is not set
# CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS is not set
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_KEXEC=y
CONFIG_KEXEC_FILE=y
CONFIG_ARCH_HAS_KEXEC_PURGATORY=y
# CONFIG_KEXEC_VERIFY_SIG is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
# CONFIG_MODIFY_LDT_SYSCALL is not set
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_PM_CLK=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SPCR_TABLE=y
CONFIG_ACPI_LPIT=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
# CONFIG_ACPI_CONTAINER is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_DPTF_POWER is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
CONFIG_X86_PM_TIMER=y
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=m
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set

#
# CPU frequency scaling drivers
#
# CONFIG_CPUFREQ_DT is not set
# CONFIG_X86_INTEL_PSTATE is not set
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_P4_CLOCKMOD=m

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=m

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_INTEL_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_MMCONF_FAM10H=y
CONFIG_PCI_CNB20LE_QUIRK=y
# CONFIG_PCIEPORTBUS is not set
CONFIG_PCI_BUS_ADDR_T_64BIT=y
# CONFIG_PCI_MSI is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_STUB is not set
CONFIG_PCI_ATS=y
CONFIG_PCI_LOCKLESS_CONFIG=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
CONFIG_HOTPLUG_PCI=y
# CONFIG_HOTPLUG_PCI_ACPI is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=y

#
# Cadence PCIe controllers support
#
CONFIG_PCIE_CADENCE=y
CONFIG_PCIE_CADENCE_HOST=y

#
# DesignWare PCI Core Support
#

#
# PCI host controller drivers
#

#
# PCI Endpoint
#
# CONFIG_PCI_ENDPOINT is not set

#
# PCI switch controller drivers
#
CONFIG_PCI_SW_SWITCHTEC=m
# CONFIG_ISA_BUS is not set
# CONFIG_ISA_DMA_API is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
# CONFIG_CARDBUS is not set

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
# CONFIG_YENTA_RICOH is not set
# CONFIG_YENTA_TI is not set
# CONFIG_YENTA_TOSHIBA is not set
CONFIG_RAPIDIO=y
CONFIG_RAPIDIO_DISC_TIMEOUT=30
# CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS is not set
CONFIG_RAPIDIO_DMA_ENGINE=y
CONFIG_RAPIDIO_DEBUG=y
# CONFIG_RAPIDIO_ENUM_BASIC is not set
# CONFIG_RAPIDIO_CHMAN is not set
# CONFIG_RAPIDIO_MPORT_CDEV is not set

#
# RapidIO Switch drivers
#
CONFIG_RAPIDIO_TSI57X=m
# CONFIG_RAPIDIO_CPS_XX is not set
# CONFIG_RAPIDIO_TSI568 is not set
# CONFIG_RAPIDIO_CPS_GEN2 is not set
# CONFIG_RAPIDIO_RXS_GEN3 is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
# CONFIG_IA32_EMULATION is not set
# CONFIG_X86_X32 is not set
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y
CONFIG_NET_INGRESS=y
CONFIG_NET_EGRESS=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=m
# CONFIG_TLS is not set
CONFIG_XFRM=y
# CONFIG_XFRM_USER is not set
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
# CONFIG_SYN_COOKIES is not set
# CONFIG_NET_IPVTI is not set
# CONFIG_NET_FOU is not set
# CONFIG_NET_FOU_IP_TUNNELS is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
# CONFIG_INET_RAW_DIAG is not set
# CONFIG_INET_DIAG_DESTROY is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
# CONFIG_IPV6_ILA is not set
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
# CONFIG_IPV6_VTI is not set
CONFIG_IPV6_SIT=y
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
# CONFIG_IPV6_SEG6_HMAC is not set
# CONFIG_NETLABEL is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_ADVANCED is not set

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_INGRESS=y
CONFIG_NETFILTER_NETLINK=m
CONFIG_NETFILTER_NETLINK_LOG=m
CONFIG_NF_CONNTRACK=m
CONFIG_NF_LOG_COMMON=m
# CONFIG_NF_LOG_NETDEV is not set
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_PROCFS=y
CONFIG_NF_CONNTRACK_FTP=m
CONFIG_NF_CONNTRACK_IRC=m
# CONFIG_NF_CONNTRACK_NETBIOS_NS is not set
CONFIG_NF_CONNTRACK_SIP=m
CONFIG_NF_CT_NETLINK=m
# CONFIG_NETFILTER_NETLINK_GLUE_CT is not set
CONFIG_NF_NAT=m
CONFIG_NF_NAT_NEEDED=y
CONFIG_NF_NAT_FTP=m
CONFIG_NF_NAT_IRC=m
CONFIG_NF_NAT_SIP=m
# CONFIG_NF_NAT_REDIRECT is not set
# CONFIG_NF_TABLES is not set
CONFIG_NETFILTER_XTABLES=m

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=m

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=m
CONFIG_NETFILTER_XT_TARGET_LOG=m
CONFIG_NETFILTER_XT_NAT=m
# CONFIG_NETFILTER_XT_TARGET_NETMAP is not set
CONFIG_NETFILTER_XT_TARGET_NFLOG=m
# CONFIG_NETFILTER_XT_TARGET_REDIRECT is not set
CONFIG_NETFILTER_XT_TARGET_SECMARK=m
CONFIG_NETFILTER_XT_TARGET_TCPMSS=m

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=m
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
CONFIG_NETFILTER_XT_MATCH_POLICY=m
CONFIG_NETFILTER_XT_MATCH_STATE=m
# CONFIG_IP_SET is not set
# CONFIG_IP_VS is not set

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=m
CONFIG_NF_CONNTRACK_IPV4=m
# CONFIG_NF_SOCKET_IPV4 is not set
# CONFIG_NF_DUP_IPV4 is not set
CONFIG_NF_LOG_ARP=m
CONFIG_NF_LOG_IPV4=m
CONFIG_NF_REJECT_IPV4=m
CONFIG_NF_NAT_IPV4=m
CONFIG_NF_NAT_MASQUERADE_IPV4=m
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_FILTER=m
CONFIG_IP_NF_TARGET_REJECT=m
CONFIG_IP_NF_NAT=m
CONFIG_IP_NF_TARGET_MASQUERADE=m
CONFIG_IP_NF_MANGLE=m
# CONFIG_IP_NF_RAW is not set

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=m
CONFIG_NF_CONNTRACK_IPV6=m
# CONFIG_NF_SOCKET_IPV6 is not set
# CONFIG_NF_DUP_IPV6 is not set
CONFIG_NF_REJECT_IPV6=m
CONFIG_NF_LOG_IPV6=m
CONFIG_IP6_NF_IPTABLES=m
CONFIG_IP6_NF_MATCH_IPV6HEADER=m
CONFIG_IP6_NF_FILTER=m
CONFIG_IP6_NF_TARGET_REJECT=m
CONFIG_IP6_NF_MANGLE=m
# CONFIG_IP6_NF_RAW is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
CONFIG_ATM=m
# CONFIG_ATM_CLIP is not set
CONFIG_ATM_LANE=m
# CONFIG_ATM_MPOA is not set
# CONFIG_ATM_BR2684 is not set
# CONFIG_L2TP is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
CONFIG_LLC=y
CONFIG_LLC2=y
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=m
CONFIG_IPDDP=m
# CONFIG_IPDDP_ENCAP is not set
CONFIG_X25=y
CONFIG_LAPB=m
# CONFIG_PHONET is not set
# CONFIG_6LOWPAN is not set
CONFIG_IEEE802154=y
# CONFIG_IEEE802154_NL802154_EXPERIMENTAL is not set
# CONFIG_IEEE802154_SOCKET is not set
# CONFIG_MAC802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=m
CONFIG_NET_SCH_HTB=y
# CONFIG_NET_SCH_HFSC is not set
# CONFIG_NET_SCH_ATM is not set
CONFIG_NET_SCH_PRIO=m
CONFIG_NET_SCH_MULTIQ=y
# CONFIG_NET_SCH_RED is not set
CONFIG_NET_SCH_SFB=y
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=m
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_CBS=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
# CONFIG_NET_SCH_NETEM is not set
CONFIG_NET_SCH_DRR=m
CONFIG_NET_SCH_MQPRIO=y
CONFIG_NET_SCH_CHOKE=m
CONFIG_NET_SCH_QFQ=m
# CONFIG_NET_SCH_CODEL is not set
# CONFIG_NET_SCH_FQ_CODEL is not set
# CONFIG_NET_SCH_FQ is not set
CONFIG_NET_SCH_HHF=y
CONFIG_NET_SCH_PIE=m
CONFIG_NET_SCH_INGRESS=y
# CONFIG_NET_SCH_PLUG is not set
CONFIG_NET_SCH_DEFAULT=y
# CONFIG_DEFAULT_SFQ is not set
CONFIG_DEFAULT_PFIFO_FAST=y
CONFIG_DEFAULT_NET_SCH="pfifo_fast"

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=y
# CONFIG_NET_CLS_TCINDEX is not set
# CONFIG_NET_CLS_ROUTE4 is not set
CONFIG_NET_CLS_FW=y
CONFIG_NET_CLS_U32=y
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=y
CONFIG_NET_CLS_RSVP6=y
CONFIG_NET_CLS_FLOW=m
CONFIG_NET_CLS_CGROUP=m
CONFIG_NET_CLS_BPF=m
CONFIG_NET_CLS_FLOWER=m
CONFIG_NET_CLS_MATCHALL=m
# CONFIG_NET_EMATCH is not set
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=m
CONFIG_NET_ACT_GACT=y
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=y
CONFIG_NET_ACT_SAMPLE=y
# CONFIG_NET_ACT_IPT is not set
# CONFIG_NET_ACT_NAT is not set
CONFIG_NET_ACT_PEDIT=m
CONFIG_NET_ACT_SIMP=m
# CONFIG_NET_ACT_SKBEDIT is not set
# CONFIG_NET_ACT_CSUM is not set
# CONFIG_NET_ACT_VLAN is not set
# CONFIG_NET_ACT_BPF is not set
CONFIG_NET_ACT_SKBMOD=y
CONFIG_NET_ACT_IFE=y
CONFIG_NET_ACT_TUNNEL_KEY=y
CONFIG_NET_IFE_SKBMARK=y
# CONFIG_NET_IFE_SKBPRIO is not set
CONFIG_NET_IFE_SKBTCINDEX=m
# CONFIG_NET_CLS_IND is not set
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=m
# CONFIG_BATMAN_ADV_BATMAN_V is not set
CONFIG_BATMAN_ADV_BLA=y
# CONFIG_BATMAN_ADV_DAT is not set
CONFIG_BATMAN_ADV_NC=y
# CONFIG_BATMAN_ADV_MCAST is not set
# CONFIG_BATMAN_ADV_DEBUGFS is not set
# CONFIG_OPENVSWITCH is not set
CONFIG_VSOCKETS=m
CONFIG_VSOCKETS_DIAG=m
# CONFIG_VIRTIO_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=m
CONFIG_MPLS_ROUTING=y
CONFIG_NET_NSH=y
CONFIG_HSR=y
# CONFIG_NET_SWITCHDEV is not set
# CONFIG_NET_L3_MASTER_DEV is not set
# CONFIG_NET_NCSI is not set
CONFIG_CGROUP_NET_PRIO=y
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_BPF_JIT=y
# CONFIG_BPF_STREAM_PARSER is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
CONFIG_AX25=y
CONFIG_AX25_DAMA_SLAVE=y
# CONFIG_NETROM is not set
# CONFIG_ROSE is not set

#
# AX.25 network device drivers
#
CONFIG_MKISS=m
CONFIG_6PACK=m
CONFIG_BPQETHER=y
CONFIG_BAYCOM_SER_FDX=y
# CONFIG_BAYCOM_SER_HDX is not set
# CONFIG_BAYCOM_PAR is not set
# CONFIG_YAM is not set
CONFIG_CAN=y
CONFIG_CAN_RAW=m
# CONFIG_CAN_BCM is not set
# CONFIG_CAN_GW is not set

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
CONFIG_CAN_VXCAN=m
# CONFIG_CAN_SLCAN is not set
CONFIG_CAN_DEV=m
# CONFIG_CAN_CALC_BITTIMING is not set
# CONFIG_CAN_LEDS is not set
# CONFIG_CAN_GRCAN is not set
CONFIG_CAN_JANZ_ICAN3=m
CONFIG_CAN_C_CAN=m
CONFIG_CAN_C_CAN_PLATFORM=m
CONFIG_CAN_C_CAN_PCI=m
# CONFIG_CAN_CC770 is not set
CONFIG_CAN_IFI_CANFD=m
CONFIG_CAN_M_CAN=m
CONFIG_CAN_PEAK_PCIEFD=m
CONFIG_CAN_SJA1000=m
CONFIG_CAN_SJA1000_ISA=m
CONFIG_CAN_SJA1000_PLATFORM=m
CONFIG_CAN_EMS_PCI=m
CONFIG_CAN_PEAK_PCI=m
CONFIG_CAN_PEAK_PCIEC=y
# CONFIG_CAN_KVASER_PCI is not set
CONFIG_CAN_PLX_PCI=m
CONFIG_CAN_SOFTING=m

#
# CAN SPI interfaces
#
CONFIG_CAN_HI311X=m
# CONFIG_CAN_MCP251X is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_BT=m
CONFIG_BT_BREDR=y
# CONFIG_BT_RFCOMM is not set
CONFIG_BT_BNEP=m
# CONFIG_BT_BNEP_MC_FILTER is not set
# CONFIG_BT_BNEP_PROTO_FILTER is not set
# CONFIG_BT_HIDP is not set
CONFIG_BT_HS=y
# CONFIG_BT_LE is not set
CONFIG_BT_LEDS=y
CONFIG_BT_SELFTEST=y
# CONFIG_BT_DEBUGFS is not set

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTSDIO=m
# CONFIG_BT_HCIUART is not set
# CONFIG_BT_HCIVHCI is not set
# CONFIG_BT_MRVL is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_AF_KCM is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
CONFIG_RFKILL=m
CONFIG_RFKILL_LEDS=y
# CONFIG_RFKILL_INPUT is not set
CONFIG_RFKILL_GPIO=m
CONFIG_NET_9P=m
# CONFIG_NET_9P_VIRTIO is not set
# CONFIG_NET_9P_DEBUG is not set
CONFIG_CAIF=m
# CONFIG_CAIF_DEBUG is not set
CONFIG_CAIF_NETDEV=m
CONFIG_CAIF_USB=m
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
CONFIG_PSAMPLE=y
CONFIG_NET_IFE=y
# CONFIG_LWTUNNEL is not set
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
CONFIG_NET_DEVLINK=y
CONFIG_MAY_USE_DEVLINK=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_WANT_DEV_COREDUMP=y
# CONFIG_ALLOW_DEV_COREDUMP is not set
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
CONFIG_TEST_ASYNC_DRIVER_PROBE=m
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_SPMI=m
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_DMA_FENCE_TRACE=y
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=0
CONFIG_CMA_SIZE_PERCENTAGE=0
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
CONFIG_CMA_SIZE_SEL_MIN=y
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
CONFIG_SIMPLE_PM_BUS=m
CONFIG_CONNECTOR=m
CONFIG_MTD=y
CONFIG_MTD_TESTS=m
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED=y
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
CONFIG_MTD_CMDLINE_PARTS=y
# CONFIG_MTD_OF_PARTS is not set
# CONFIG_MTD_AR7_PARTS is not set

#
# Partition parsers
#

#
# User Modules And Translation Layers
#
# CONFIG_MTD_OOPS is not set
CONFIG_MTD_PARTITIONED_MASTER=y

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=m
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
# CONFIG_MTD_CFI_NOSWAP is not set
CONFIG_MTD_CFI_BE_BYTE_SWAP=y
# CONFIG_MTD_CFI_LE_BYTE_SWAP is not set
CONFIG_MTD_CFI_GEOMETRY=y
CONFIG_MTD_MAP_BANK_WIDTH_1=y
# CONFIG_MTD_MAP_BANK_WIDTH_2 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_4 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
# CONFIG_MTD_CFI_I2 is not set
CONFIG_MTD_CFI_I4=y
# CONFIG_MTD_CFI_I8 is not set
# CONFIG_MTD_OTP is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
CONFIG_MTD_CFI_STAA=m
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
# CONFIG_MTD_ROM is not set
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
CONFIG_MTD_PHYSMAP=m
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
CONFIG_MTD_PHYSMAP_OF=m
# CONFIG_MTD_PHYSMAP_OF_VERSATILE is not set
# CONFIG_MTD_PHYSMAP_OF_GEMINI is not set
CONFIG_MTD_SBC_GXX=y
CONFIG_MTD_AMD76XROM=y
CONFIG_MTD_ICHXROM=y
CONFIG_MTD_ESB2ROM=y
# CONFIG_MTD_CK804XROM is not set
CONFIG_MTD_SCB2_FLASH=m
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
CONFIG_MTD_PCI=m
# CONFIG_MTD_GPIO_ADDR is not set
CONFIG_MTD_INTEL_VR_NOR=y
# CONFIG_MTD_PLATRAM is not set
CONFIG_MTD_LATCH_ADDR=m

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_DATAFLASH=y
# CONFIG_MTD_DATAFLASH_WRITE_VERIFY is not set
# CONFIG_MTD_DATAFLASH_OTP is not set
CONFIG_MTD_M25P80=m
# CONFIG_MTD_MCHP23K256 is not set
CONFIG_MTD_SST25L=m
# CONFIG_MTD_SLRAM is not set
CONFIG_MTD_PHRAM=y
CONFIG_MTD_MTDRAM=m
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=m
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
# CONFIG_MTD_ONENAND is not set
# CONFIG_MTD_NAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
CONFIG_MTD_SPI_NOR=y
CONFIG_MTD_MT81xx_NOR=m
# CONFIG_MTD_SPI_NOR_USE_4K_SECTORS is not set
CONFIG_SPI_INTEL_SPI=m
# CONFIG_SPI_INTEL_SPI_PCI is not set
CONFIG_SPI_INTEL_SPI_PLATFORM=m
CONFIG_MTD_UBI=m
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
CONFIG_MTD_UBI_FASTMAP=y
CONFIG_MTD_UBI_GLUEBI=m
CONFIG_OF=y
# CONFIG_OF_UNITTEST is not set
CONFIG_OF_KOBJ=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_IRQ=y
CONFIG_OF_NET=y
# CONFIG_OF_OVERLAY is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=m
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
CONFIG_PARPORT_AX88796=y
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y

#
# NVME Support
#

#
# Misc devices
#
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
CONFIG_PHANTOM=y
CONFIG_SGI_IOC4=m
CONFIG_TIFM_CORE=m
CONFIG_TIFM_7XX1=m
# CONFIG_ICS932S401 is not set
# CONFIG_ENCLOSURE_SERVICES is not set
CONFIG_HP_ILO=m
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=m
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=m
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_LATTICE_ECP3_CONFIG=m
CONFIG_SRAM=y
CONFIG_PCI_ENDPOINT_TEST=m
CONFIG_MISC_RTSX=y
CONFIG_C2PORT=m
CONFIG_C2PORT_DURAMAR_2150=m

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_AT25=m
CONFIG_EEPROM_LEGACY=m
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_93XX46=m
# CONFIG_EEPROM_IDT_89HPESX is not set
CONFIG_CB710_CORE=y
CONFIG_CB710_DEBUG=y
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=y
# CONFIG_INTEL_MEI_ME is not set
CONFIG_INTEL_MEI_TXE=y
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC & related support
#

#
# Intel MIC Bus Driver
#
CONFIG_INTEL_MIC_BUS=m

#
# SCIF Bus Driver
#
CONFIG_SCIF_BUS=m

#
# VOP Bus Driver
#
CONFIG_VOP_BUS=m

#
# Intel MIC Host Driver
#
CONFIG_INTEL_MIC_HOST=m

#
# Intel MIC Card Driver
#
# CONFIG_INTEL_MIC_CARD is not set

#
# SCIF Driver
#
CONFIG_SCIF=m

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#
CONFIG_MIC_COSM=m

#
# VOP Driver
#
CONFIG_VOP=m
CONFIG_VHOST_RING=m
CONFIG_GENWQE=m
CONFIG_GENWQE_PLATFORM_ERROR_RECOVERY=0
CONFIG_ECHO=m
CONFIG_MISC_RTSX_PCI=y
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_FUSION=y
CONFIG_FUSION_MAX_SGE=128
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
CONFIG_FIREWIRE_NOSY=m
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
# CONFIG_IFB is not set
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
# CONFIG_IPVLAN is not set
# CONFIG_VXLAN is not set
# CONFIG_MACSEC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NTB_NETDEV is not set
# CONFIG_RIONET is not set
# CONFIG_TUN is not set
# CONFIG_TUN_VNET_CROSS_LE is not set
# CONFIG_VETH is not set
# CONFIG_VIRTIO_NET is not set
# CONFIG_NLMON is not set
# CONFIG_ARCNET is not set
CONFIG_ATM_DRIVERS=y
# CONFIG_ATM_DUMMY is not set
# CONFIG_ATM_TCP is not set
# CONFIG_ATM_LANAI is not set
# CONFIG_ATM_ENI is not set
# CONFIG_ATM_FIRESTREAM is not set
# CONFIG_ATM_ZATM is not set
# CONFIG_ATM_NICSTAR is not set
# CONFIG_ATM_IDT77252 is not set
# CONFIG_ATM_AMBASSADOR is not set
# CONFIG_ATM_HORIZON is not set
# CONFIG_ATM_IA is not set
# CONFIG_ATM_FORE200E is not set
# CONFIG_ATM_HE is not set
# CONFIG_ATM_SOLOS is not set

#
# CAIF transport drivers
#
# CONFIG_CAIF_TTY is not set
# CONFIG_CAIF_SPI_SLAVE is not set
# CONFIG_CAIF_HSI is not set
# CONFIG_CAIF_VIRTIO is not set

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=m
CONFIG_NET_VENDOR_3COM=y
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALACRITECH=y
# CONFIG_SLICOSS is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMAZON=y
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
# CONFIG_AMD_XGBE is not set
CONFIG_NET_VENDOR_AQUANTIA=y
# CONFIG_AQTION is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
# CONFIG_NET_VENDOR_AURORA is not set
CONFIG_NET_CADENCE=y
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
# CONFIG_BCMGENET is not set
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2X is not set
# CONFIG_SYSTEMPORT is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_THUNDER_NIC_RGX is not set
CONFIG_CAVIUM_PTP=y
# CONFIG_LIQUIDIO is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
CONFIG_NET_VENDOR_CORTINA=y
# CONFIG_GEMINI_ETHERNET is not set
# CONFIG_CX_ECAT is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EZCHIP=y
# CONFIG_EZCHIP_NPS_MANAGEMENT_ENET is not set
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_HUAWEI=y
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=m
CONFIG_E1000E_HWTS=y
CONFIG_IGB=m
CONFIG_IGB_HWMON=y
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
CONFIG_IXGBE=m
CONFIG_IXGBE_HWMON=y
# CONFIG_IXGBE_DCB is not set
# CONFIG_I40E is not set
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_MLXFW is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8842 is not set
# CONFIG_KS8851 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_ENC28J60 is not set
# CONFIG_ENCX24J600 is not set
# CONFIG_LAN743X is not set
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_NETRONOME=y
CONFIG_NET_VENDOR_NI=y
CONFIG_NET_VENDOR_8390=y
# CONFIG_NE2K_PCI is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_ETHOC is not set
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_QED is not set
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_QCA7000_SPI is not set
# CONFIG_QCA7000_UART is not set
# CONFIG_QCOM_EMAC is not set
# CONFIG_RMNET is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R8169 is not set
CONFIG_NET_VENDOR_RENESAS=y
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
CONFIG_NET_VENDOR_SOLARFLARE=y
# CONFIG_SFC is not set
# CONFIG_SFC_FALCON is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_SOCIONEXT=y
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TI_CPSW_ALE is not set
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_MDIO_DEVICE is not set
# CONFIG_PHYLIB is not set
# CONFIG_MICREL_KS8995MA is not set
# CONFIG_PLIP is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set

#
# Host-side USB support is needed for USB Network Adapter support
#
CONFIG_WLAN=y
# CONFIG_WIRELESS_WDS is not set
CONFIG_WLAN_VENDOR_ADMTEK=y
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH5K_PCI is not set
CONFIG_WLAN_VENDOR_ATMEL=y
CONFIG_WLAN_VENDOR_BROADCOM=y
CONFIG_WLAN_VENDOR_CISCO=y
CONFIG_WLAN_VENDOR_INTEL=y
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_PRISM54 is not set
CONFIG_WLAN_VENDOR_MARVELL=y
CONFIG_WLAN_VENDOR_MEDIATEK=y
CONFIG_WLAN_VENDOR_RALINK=y
CONFIG_WLAN_VENDOR_REALTEK=y
CONFIG_WLAN_VENDOR_RSI=y
CONFIG_WLAN_VENDOR_ST=y
CONFIG_WLAN_VENDOR_TI=y
CONFIG_WLAN_VENDOR_ZYDAS=y
CONFIG_WLAN_VENDOR_QUANTENNA=y

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
CONFIG_IEEE802154_DRIVERS=y
# CONFIG_VMXNET3 is not set
# CONFIG_FUJITSU_ES is not set
# CONFIG_THUNDERBOLT_NET is not set
# CONFIG_NETDEVSIM is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADC is not set
# CONFIG_KEYBOARD_ADP5520 is not set
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_DLINK_DIR685 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_SAMSUNG is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_TC3589X is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
# CONFIG_KEYBOARD_CAP11XX is not set
# CONFIG_KEYBOARD_BCM is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_BYD=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_SYNAPTICS_SMBUS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_PS2_FOCALTECH=y
# CONFIG_MOUSE_PS2_VMMOUSE is not set
CONFIG_MOUSE_PS2_SMBUS=y
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_ELAN_I2C is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_GPIO is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=m
CONFIG_SERIO_PARKBD=m
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_SERIO_APBPS2=m
CONFIG_SERIO_GPIO_PS2=y
CONFIG_USERIO=y
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=m
CONFIG_GAMEPORT_L4=m
CONFIG_GAMEPORT_EMU10K1=y
CONFIG_GAMEPORT_FM801=m

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
CONFIG_NOZOMI=y
CONFIG_N_GSM=m
# CONFIG_TRACE_ROUTER is not set
CONFIG_TRACE_SINK=y
# CONFIG_DEVMEM is not set
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
# CONFIG_SERIAL_8250_DMA is not set
# CONFIG_SERIAL_8250_PCI is not set
CONFIG_SERIAL_8250_MEN_MCB=m
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
# CONFIG_SERIAL_8250_MANY_PORTS is not set
# CONFIG_SERIAL_8250_ASPEED_VUART is not set
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
CONFIG_SERIAL_8250_RSA=y
CONFIG_SERIAL_8250_DW=y
CONFIG_SERIAL_8250_RT288X=y
# CONFIG_SERIAL_8250_LPSS is not set
# CONFIG_SERIAL_8250_MID is not set
# CONFIG_SERIAL_8250_MOXA is not set
CONFIG_SERIAL_OF_PLATFORM=m

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
CONFIG_SERIAL_MAX310X=y
CONFIG_SERIAL_UARTLITE=y
CONFIG_SERIAL_UARTLITE_CONSOLE=y
CONFIG_SERIAL_UARTLITE_NR_UARTS=1
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=y
# CONFIG_SERIAL_SCCNXP_CONSOLE is not set
CONFIG_SERIAL_SC16IS7XX_CORE=y
CONFIG_SERIAL_SC16IS7XX=y
CONFIG_SERIAL_SC16IS7XX_I2C=y
CONFIG_SERIAL_SC16IS7XX_SPI=y
CONFIG_SERIAL_ALTERA_JTAGUART=m
CONFIG_SERIAL_ALTERA_UART=m
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_IFX6X60=m
CONFIG_SERIAL_XILINX_PS_UART=m
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
CONFIG_SERIAL_FSL_LPUART=y
CONFIG_SERIAL_FSL_LPUART_CONSOLE=y
# CONFIG_SERIAL_CONEXANT_DIGICOLOR is not set
# CONFIG_SERIAL_MEN_Z135 is not set
CONFIG_SERIAL_DEV_BUS=m
CONFIG_TTY_PRINTK=m
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
# CONFIG_PPDEV is not set
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
# CONFIG_IPMI_HANDLER is not set
# CONFIG_HW_RANDOM is not set
CONFIG_NVRAM=m
# CONFIG_R3964 is not set
CONFIG_APPLICOM=m
CONFIG_MWAVE=y
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_SPI=y
# CONFIG_TCG_TIS_I2C_ATMEL is not set
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_TIS_I2C_NUVOTON=y
# CONFIG_TCG_NSC is not set
# CONFIG_TCG_ATMEL is not set
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_CRB is not set
# CONFIG_TCG_VTPM_PROXY is not set
CONFIG_TCG_TIS_ST33ZP24=m
CONFIG_TCG_TIS_ST33ZP24_I2C=m
# CONFIG_TCG_TIS_ST33ZP24_SPI is not set
CONFIG_TELCLOCK=m
# CONFIG_DEVPORT is not set
CONFIG_XILLYBUS=m
# CONFIG_XILLYBUS_OF is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_ARB_GPIO_CHALLENGE=y
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_GPMUX=y
# CONFIG_I2C_MUX_LTC4306 is not set
CONFIG_I2C_MUX_PCA9541=m
CONFIG_I2C_MUX_PCA954x=y
CONFIG_I2C_MUX_REG=y
CONFIG_I2C_MUX_MLXCPLD=y
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=m
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
# CONFIG_I2C_ALI1563 is not set
CONFIG_I2C_ALI15X3=y
CONFIG_I2C_AMD756=y
CONFIG_I2C_AMD756_S4882=m
CONFIG_I2C_AMD8111=y
CONFIG_I2C_I801=m
# CONFIG_I2C_ISCH is not set
CONFIG_I2C_ISMT=m
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=y
CONFIG_I2C_NFORCE2_S4985=y
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=y
# CONFIG_I2C_VIA is not set
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_SLAVE is not set
CONFIG_I2C_DESIGNWARE_PCI=m
CONFIG_I2C_EMEV2=y
CONFIG_I2C_GPIO=y
# CONFIG_I2C_GPIO_FAULT_INJECTOR is not set
CONFIG_I2C_KEMPLD=m
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_RK3X is not set
CONFIG_I2C_SIMTEC=m
CONFIG_I2C_XILINX=m

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT=m
# CONFIG_I2C_PARPORT_LIGHT is not set
CONFIG_I2C_TAOS_EVM=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_MLXCPLD=y
# CONFIG_I2C_CROS_EC_TUNNEL is not set
# CONFIG_I2C_STUB is not set
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
CONFIG_SPI_AXI_SPI_ENGINE=m
CONFIG_SPI_BITBANG=y
# CONFIG_SPI_BUTTERFLY is not set
CONFIG_SPI_CADENCE=y
CONFIG_SPI_DESIGNWARE=m
CONFIG_SPI_DW_PCI=m
# CONFIG_SPI_DW_MID_DMA is not set
CONFIG_SPI_DW_MMIO=m
# CONFIG_SPI_GPIO is not set
CONFIG_SPI_LM70_LLP=y
# CONFIG_SPI_FSL_SPI is not set
CONFIG_SPI_OC_TINY=m
CONFIG_SPI_PXA2XX=y
CONFIG_SPI_PXA2XX_PCI=y
CONFIG_SPI_ROCKCHIP=m
CONFIG_SPI_SC18IS602=y
CONFIG_SPI_XCOMM=m
# CONFIG_SPI_XILINX is not set
# CONFIG_SPI_ZYNQMP_GQSPI is not set

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=m
CONFIG_SPI_LOOPBACK_TEST=m
CONFIG_SPI_TLE62X0=y
CONFIG_SPI_SLAVE=y
CONFIG_SPI_SLAVE_TIME=m
CONFIG_SPI_SLAVE_SYSTEM_CONTROL=y
CONFIG_SPMI=m
# CONFIG_HSI is not set
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=m
CONFIG_PPS_CLIENT_LDISC=m
CONFIG_PPS_CLIENT_PARPORT=m
CONFIG_PPS_CLIENT_GPIO=m

#
# PPS generators support
#

#
# PTP clock support
#

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_PINCTRL is not set
CONFIG_GPIOLIB=y
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=m

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_74XX_MMIO is not set
# CONFIG_GPIO_ALTERA is not set
# CONFIG_GPIO_AMDPT is not set
# CONFIG_GPIO_DWAPB is not set
CONFIG_GPIO_FTGPIO010=y
CONFIG_GPIO_GENERIC_PLATFORM=m
# CONFIG_GPIO_GRGPIO is not set
CONFIG_GPIO_HLWD=y
CONFIG_GPIO_ICH=y
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_MB86S7X=m
CONFIG_GPIO_MENZ127=y
CONFIG_GPIO_MOCKUP=y
CONFIG_GPIO_SYSCON=y
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_XILINX is not set

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_104_DIO_48E=y
# CONFIG_GPIO_104_IDIO_16 is not set
CONFIG_GPIO_104_IDI_48=y
CONFIG_GPIO_F7188X=m
# CONFIG_GPIO_GPIO_MM is not set
CONFIG_GPIO_IT87=y
CONFIG_GPIO_SCH=m
CONFIG_GPIO_SCH311X=m
CONFIG_GPIO_WINBOND=m
# CONFIG_GPIO_WS16C48 is not set

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
CONFIG_GPIO_ADP5588_IRQ=y
CONFIG_GPIO_ADNP=m
CONFIG_GPIO_MAX7300=m
CONFIG_GPIO_MAX732X=m
CONFIG_GPIO_PCA953X=m
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_TPIC2810=m

#
# MFD GPIO expanders
#
CONFIG_GPIO_ADP5520=m
CONFIG_GPIO_ARIZONA=m
CONFIG_GPIO_BD9571MWV=m
CONFIG_GPIO_JANZ_TTL=m
CONFIG_GPIO_KEMPLD=m
CONFIG_GPIO_LP3943=y
CONFIG_GPIO_LP873X=m
CONFIG_GPIO_LP87565=m
CONFIG_GPIO_MAX77620=y
CONFIG_GPIO_PALMAS=y
# CONFIG_GPIO_RC5T583 is not set
# CONFIG_GPIO_TC3589X is not set
CONFIG_GPIO_TPS65086=m
CONFIG_GPIO_TPS65218=y
CONFIG_GPIO_TPS65910=y
CONFIG_GPIO_UCB1400=m
# CONFIG_GPIO_WM831X is not set

#
# PCI GPIO expanders
#
CONFIG_GPIO_AMD8111=y
CONFIG_GPIO_BT8XX=m
CONFIG_GPIO_ML_IOH=m
CONFIG_GPIO_PCI_IDIO_16=y
# CONFIG_GPIO_PCIE_IDIO_24 is not set
CONFIG_GPIO_RDC321X=y
# CONFIG_GPIO_SODAVILLE is not set

#
# SPI GPIO expanders
#
CONFIG_GPIO_74X164=m
CONFIG_GPIO_MAX3191X=y
CONFIG_GPIO_MAX7301=m
# CONFIG_GPIO_MC33880 is not set
CONFIG_GPIO_PISOSR=m
CONFIG_GPIO_XRA1403=y
# CONFIG_W1 is not set
# CONFIG_POWER_AVS is not set
# CONFIG_POWER_RESET is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_GENERIC_ADC_BATTERY is not set
# CONFIG_MAX8925_POWER is not set
# CONFIG_WM831X_BACKUP is not set
# CONFIG_WM831X_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_88PM860X is not set
# CONFIG_BATTERY_ACT8945A is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_LEGO_EV3 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_CHARGER_SBS is not set
# CONFIG_MANAGER_SBS is not set
# CONFIG_BATTERY_BQ27XXX is not set
# CONFIG_CHARGER_DA9150 is not set
# CONFIG_BATTERY_DA9150 is not set
# CONFIG_CHARGER_AXP20X is not set
# CONFIG_BATTERY_AXP20X is not set
# CONFIG_AXP20X_POWER is not set
# CONFIG_AXP288_FUEL_GAUGE is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_LTC3651 is not set
# CONFIG_CHARGER_MAX14577 is not set
# CONFIG_CHARGER_DETECTOR_MAX14656 is not set
# CONFIG_CHARGER_MAX77693 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_BQ24257 is not set
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_BQ25890 is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_CHARGER_TPS65217 is not set
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
# CONFIG_BATTERY_RT5033 is not set
# CONFIG_CHARGER_RT9455 is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=m
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
CONFIG_SENSORS_ADT7410=m
# CONFIG_SENSORS_ADT7411 is not set
CONFIG_SENSORS_ADT7462=m
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ASPEED=m
CONFIG_SENSORS_ATXP1=m
# CONFIG_SENSORS_DS620 is not set
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DELL_SMM=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=m
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=m
# CONFIG_SENSORS_MC13783_ADC is not set
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=m
# CONFIG_SENSORS_G760A is not set
CONFIG_SENSORS_G762=m
CONFIG_SENSORS_GPIO_FAN=m
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_IIO_HWMON=m
CONFIG_SENSORS_I5500=m
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=m
# CONFIG_SENSORS_LTC2945 is not set
# CONFIG_SENSORS_LTC2990 is not set
# CONFIG_SENSORS_LTC4151 is not set
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=m
CONFIG_SENSORS_LTC4245=m
CONFIG_SENSORS_LTC4260=m
CONFIG_SENSORS_LTC4261=m
CONFIG_SENSORS_MAX1111=y
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=m
CONFIG_SENSORS_MAX1668=m
CONFIG_SENSORS_MAX197=m
# CONFIG_SENSORS_MAX31722 is not set
CONFIG_SENSORS_MAX6621=y
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
# CONFIG_SENSORS_MAX6650 is not set
CONFIG_SENSORS_MAX6697=m
CONFIG_SENSORS_MAX31790=m
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_TC654=m
CONFIG_SENSORS_MENF21BMC_HWMON=y
CONFIG_SENSORS_ADCXX=m
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM70 is not set
CONFIG_SENSORS_LM73=m
CONFIG_SENSORS_LM75=y
# CONFIG_SENSORS_LM77 is not set
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
# CONFIG_SENSORS_LM83 is not set
CONFIG_SENSORS_LM85=m
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LM95234=m
CONFIG_SENSORS_LM95241=y
# CONFIG_SENSORS_LM95245 is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
CONFIG_SENSORS_NTC_THERMISTOR=m
CONFIG_SENSORS_NCT6683=m
# CONFIG_SENSORS_NCT6775 is not set
CONFIG_SENSORS_NCT7802=y
# CONFIG_SENSORS_NCT7904 is not set
CONFIG_SENSORS_PCF8591=m
# CONFIG_PMBUS is not set
CONFIG_SENSORS_SHT15=m
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SHT3x=y
CONFIG_SENSORS_SHTC1=y
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_STTS751 is not set
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_ADC128D818=y
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=m
# CONFIG_SENSORS_ADS7871 is not set
CONFIG_SENSORS_AMC6821=m
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_INA3221=m
CONFIG_SENSORS_TC74=y
# CONFIG_SENSORS_THMC50 is not set
CONFIG_SENSORS_TMP102=m
CONFIG_SENSORS_TMP103=m
CONFIG_SENSORS_TMP108=y
CONFIG_SENSORS_TMP401=y
# CONFIG_SENSORS_TMP421 is not set
CONFIG_SENSORS_VIA_CPUTEMP=y
CONFIG_SENSORS_VIA686A=y
CONFIG_SENSORS_VT1211=y
CONFIG_SENSORS_VT8231=m
CONFIG_SENSORS_W83773G=y
CONFIG_SENSORS_W83781D=m
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=y
# CONFIG_SENSORS_W83793 is not set
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=m
# CONFIG_SENSORS_W83L786NG is not set
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=m
# CONFIG_SENSORS_WM831X is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_STATISTICS is not set
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
# CONFIG_THERMAL_HWMON is not set
# CONFIG_THERMAL_OF is not set
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR=y
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_GOV_STEP_WISE is not set
# CONFIG_THERMAL_GOV_BANG_BANG is not set
# CONFIG_THERMAL_GOV_USER_SPACE is not set
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
# CONFIG_CLOCK_THERMAL is not set
# CONFIG_DEVFREQ_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
CONFIG_MAX77620_THERMAL=m
# CONFIG_INTEL_POWERCLAMP is not set
CONFIG_INTEL_SOC_DTS_IOSF_CORE=m
CONFIG_INTEL_SOC_DTS_THERMAL=m

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
# CONFIG_INTEL_PCH_THERMAL is not set
CONFIG_QCOM_SPMI_TEMP_ALARM=m
# CONFIG_GENERIC_ADC_THERMAL is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_SILENT is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_SSB_DRIVER_GPIO=y
CONFIG_BCMA_POSSIBLE=y
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_PCI=y
# CONFIG_BCMA_SFLASH is not set
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
CONFIG_BCMA_DRIVER_GPIO=y
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_ACT8945A=m
CONFIG_MFD_AS3711=y
# CONFIG_MFD_AS3722 is not set
CONFIG_PMIC_ADP5520=y
CONFIG_MFD_AAT2870_CORE=y
# CONFIG_MFD_ATMEL_FLEXCOM is not set
# CONFIG_MFD_ATMEL_HLCDC is not set
# CONFIG_MFD_BCM590XX is not set
CONFIG_MFD_BD9571MWV=y
CONFIG_MFD_AXP20X=m
CONFIG_MFD_AXP20X_I2C=m
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_I2C is not set
CONFIG_MFD_CROS_EC_SPI=m
CONFIG_MFD_CROS_EC_CHARDEV=y
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9062 is not set
CONFIG_MFD_DA9063=m
CONFIG_MFD_DA9150=m
CONFIG_MFD_MC13XXX=m
CONFIG_MFD_MC13XXX_SPI=m
CONFIG_MFD_MC13XXX_I2C=m
CONFIG_MFD_HI6421_PMIC=m
CONFIG_HTC_PASIC3=m
# CONFIG_HTC_I2CPLD is not set
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=m
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=m
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_INTEL_SOC_PMIC_CHTWC is not set
# CONFIG_INTEL_SOC_PMIC_CHTDC_TI is not set
CONFIG_MFD_INTEL_LPSS=m
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
CONFIG_MFD_INTEL_LPSS_PCI=m
CONFIG_MFD_JANZ_CMODIO=y
CONFIG_MFD_KEMPLD=m
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
CONFIG_MFD_MAX77620=y
CONFIG_MFD_MAX77686=y
CONFIG_MFD_MAX77693=y
# CONFIG_MFD_MAX77843 is not set
# CONFIG_MFD_MAX8907 is not set
CONFIG_MFD_MAX8925=y
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_MT6397 is not set
CONFIG_MFD_MENF21BMC=y
CONFIG_EZX_PCAP=y
# CONFIG_MFD_CPCAP is not set
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_PCF50633 is not set
CONFIG_UCB1400_CORE=m
CONFIG_MFD_RDC321X=y
CONFIG_MFD_RT5033=m
CONFIG_MFD_RC5T583=y
# CONFIG_MFD_RK808 is not set
CONFIG_MFD_RN5T618=y
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=m
CONFIG_MFD_SM501=y
CONFIG_MFD_SM501_GPIO=y
CONFIG_MFD_SKY81452=m
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
# CONFIG_MFD_TI_LMU is not set
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
CONFIG_MFD_TPS65086=m
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=m
# CONFIG_MFD_TPS68470 is not set
CONFIG_MFD_TI_LP873X=m
CONFIG_MFD_TI_LP87565=m
CONFIG_MFD_TPS65218=y
# CONFIG_MFD_TPS6586X is not set
CONFIG_MFD_TPS65910=y
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS65912_SPI is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
CONFIG_MFD_TC3589X=y
CONFIG_MFD_VX855=m
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
# CONFIG_MFD_ARIZONA_SPI is not set
CONFIG_MFD_CS47L24=y
# CONFIG_MFD_WM5102 is not set
CONFIG_MFD_WM5110=y
CONFIG_MFD_WM8997=y
# CONFIG_MFD_WM8998 is not set
# CONFIG_MFD_WM8400 is not set
CONFIG_MFD_WM831X=y
# CONFIG_MFD_WM831X_I2C is not set
CONFIG_MFD_WM831X_SPI=y
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
CONFIG_RAVE_SP_CORE=m
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
# CONFIG_REGULATOR_88PG86X is not set
# CONFIG_REGULATOR_88PM800 is not set
CONFIG_REGULATOR_88PM8607=m
# CONFIG_REGULATOR_ACT8865 is not set
CONFIG_REGULATOR_ACT8945A=m
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_AAT2870=y
CONFIG_REGULATOR_ARIZONA_LDO1=m
CONFIG_REGULATOR_ARIZONA_MICSUPP=m
# CONFIG_REGULATOR_AS3711 is not set
CONFIG_REGULATOR_AXP20X=m
# CONFIG_REGULATOR_BD9571MWV is not set
CONFIG_REGULATOR_DA9063=m
CONFIG_REGULATOR_DA9210=y
# CONFIG_REGULATOR_DA9211 is not set
# CONFIG_REGULATOR_FAN53555 is not set
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_HI6421=m
CONFIG_REGULATOR_HI6421V530=m
# CONFIG_REGULATOR_ISL9305 is not set
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP873X is not set
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_LP87565=m
# CONFIG_REGULATOR_LP8788 is not set
# CONFIG_REGULATOR_LTC3589 is not set
CONFIG_REGULATOR_LTC3676=m
CONFIG_REGULATOR_MAX14577=m
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX77620=m
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=m
CONFIG_REGULATOR_MAX8925=m
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX77686=m
CONFIG_REGULATOR_MAX77693=m
# CONFIG_REGULATOR_MAX77802 is not set
# CONFIG_REGULATOR_MC13783 is not set
# CONFIG_REGULATOR_MC13892 is not set
CONFIG_REGULATOR_MT6311=m
CONFIG_REGULATOR_PALMAS=m
CONFIG_REGULATOR_PCAP=m
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=m
# CONFIG_REGULATOR_PV88080 is not set
CONFIG_REGULATOR_PV88090=y
# CONFIG_REGULATOR_QCOM_SPMI is not set
CONFIG_REGULATOR_RC5T583=y
# CONFIG_REGULATOR_RN5T618 is not set
CONFIG_REGULATOR_RT5033=m
# CONFIG_REGULATOR_SKY81452 is not set
CONFIG_REGULATOR_TPS51632=y
# CONFIG_REGULATOR_TPS6105X is not set
CONFIG_REGULATOR_TPS62360=m
# CONFIG_REGULATOR_TPS65023 is not set
# CONFIG_REGULATOR_TPS6507X is not set
# CONFIG_REGULATOR_TPS65086 is not set
# CONFIG_REGULATOR_TPS65132 is not set
# CONFIG_REGULATOR_TPS65217 is not set
# CONFIG_REGULATOR_TPS65218 is not set
CONFIG_REGULATOR_TPS6524X=m
CONFIG_REGULATOR_TPS65910=y
CONFIG_REGULATOR_VCTRL=m
CONFIG_REGULATOR_WM831X=m
# CONFIG_RC_CORE is not set
CONFIG_MEDIA_SUPPORT=m

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
# CONFIG_MEDIA_RADIO_SUPPORT is not set
CONFIG_MEDIA_SDR_SUPPORT=y
CONFIG_MEDIA_CEC_SUPPORT=y
CONFIG_MEDIA_CONTROLLER=y
CONFIG_MEDIA_CONTROLLER_DVB=y
CONFIG_VIDEO_DEV=m
# CONFIG_VIDEO_V4L2_SUBDEV_API is not set
CONFIG_VIDEO_V4L2=m
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_V4L2_FWNODE=m
CONFIG_DVB_CORE=m
CONFIG_DVB_MMAP=y
CONFIG_DVB_NET=y
CONFIG_DVB_MAX_ADAPTERS=16
CONFIG_DVB_DYNAMIC_MINORS=y
CONFIG_DVB_DEMUX_SECTION_LOSS_LOG=y
CONFIG_DVB_ULE_DEBUG=y

#
# Media drivers
#
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_DVB_PLATFORM_DRIVERS is not set
CONFIG_CEC_PLATFORM_DRIVERS=y
# CONFIG_SDR_PLATFORM_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=m
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEOBUF2_V4L2=m
CONFIG_VIDEOBUF2_MEMOPS=m
CONFIG_VIDEOBUF2_VMALLOC=m
CONFIG_SMS_SIANO_MDTV=m

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set
CONFIG_MEDIA_ATTACH=y

#
# I2C Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
# CONFIG_VIDEO_TVAUDIO is not set
CONFIG_VIDEO_TDA7432=m
# CONFIG_VIDEO_TDA9840 is not set
CONFIG_VIDEO_TEA6415C=m
CONFIG_VIDEO_TEA6420=m
CONFIG_VIDEO_MSP3400=m
CONFIG_VIDEO_CS3308=m
# CONFIG_VIDEO_CS5345 is not set
CONFIG_VIDEO_CS53L32A=m
CONFIG_VIDEO_TLV320AIC23B=m
# CONFIG_VIDEO_UDA1342 is not set
CONFIG_VIDEO_WM8775=m
# CONFIG_VIDEO_WM8739 is not set
CONFIG_VIDEO_VP27SMPX=m
CONFIG_VIDEO_SONY_BTF_MPX=m

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=m

#
# Video decoders
#
CONFIG_VIDEO_ADV7183=m
# CONFIG_VIDEO_BT819 is not set
CONFIG_VIDEO_BT856=m
CONFIG_VIDEO_BT866=m
# CONFIG_VIDEO_KS0127 is not set
# CONFIG_VIDEO_ML86V7667 is not set
# CONFIG_VIDEO_AD5820 is not set
CONFIG_VIDEO_SAA7110=m
CONFIG_VIDEO_SAA711X=m
# CONFIG_VIDEO_TVP514X is not set
CONFIG_VIDEO_TVP5150=m
CONFIG_VIDEO_TVP7002=m
CONFIG_VIDEO_TW2804=m
CONFIG_VIDEO_TW9903=m
# CONFIG_VIDEO_TW9906 is not set
CONFIG_VIDEO_TW9910=m
# CONFIG_VIDEO_VPX3220 is not set

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=m
CONFIG_VIDEO_CX25840=m

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=m
CONFIG_VIDEO_SAA7185=m
# CONFIG_VIDEO_ADV7170 is not set
CONFIG_VIDEO_ADV7175=m
CONFIG_VIDEO_ADV7343=m
CONFIG_VIDEO_ADV7393=m
CONFIG_VIDEO_AK881X=m
CONFIG_VIDEO_THS8200=m

#
# Camera sensor devices
#
CONFIG_VIDEO_MT9M111=m

#
# Flash devices
#

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=m
# CONFIG_VIDEO_UPD64083 is not set

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=m

#
# SDR tuner chips
#
CONFIG_SDR_MAX2175=m

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_THS7303=m
CONFIG_VIDEO_M52790=m

#
# Sensors used on soc_camera driver
#

#
# SPI helper chips
#

#
# Media SPI Adapters
#
CONFIG_CXD2880_SPI_DRV=m
CONFIG_MEDIA_TUNER=m

#
# Customize TV tuners
#
# CONFIG_MEDIA_TUNER_SIMPLE is not set
CONFIG_MEDIA_TUNER_TDA18250=m
# CONFIG_MEDIA_TUNER_TDA8290 is not set
# CONFIG_MEDIA_TUNER_TDA827X is not set
# CONFIG_MEDIA_TUNER_TDA18271 is not set
CONFIG_MEDIA_TUNER_TDA9887=m
# CONFIG_MEDIA_TUNER_TEA5761 is not set
CONFIG_MEDIA_TUNER_TEA5767=m
CONFIG_MEDIA_TUNER_MSI001=m
# CONFIG_MEDIA_TUNER_MT20XX is not set
CONFIG_MEDIA_TUNER_MT2060=m
CONFIG_MEDIA_TUNER_MT2063=m
# CONFIG_MEDIA_TUNER_MT2266 is not set
# CONFIG_MEDIA_TUNER_MT2131 is not set
CONFIG_MEDIA_TUNER_QT1010=m
CONFIG_MEDIA_TUNER_XC2028=m
CONFIG_MEDIA_TUNER_XC5000=m
# CONFIG_MEDIA_TUNER_XC4000 is not set
CONFIG_MEDIA_TUNER_MXL5005S=m
# CONFIG_MEDIA_TUNER_MXL5007T is not set
# CONFIG_MEDIA_TUNER_MC44S803 is not set
CONFIG_MEDIA_TUNER_MAX2165=m
# CONFIG_MEDIA_TUNER_TDA18218 is not set
# CONFIG_MEDIA_TUNER_FC0011 is not set
CONFIG_MEDIA_TUNER_FC0012=m
CONFIG_MEDIA_TUNER_FC0013=m
# CONFIG_MEDIA_TUNER_TDA18212 is not set
CONFIG_MEDIA_TUNER_E4000=m
CONFIG_MEDIA_TUNER_FC2580=m
CONFIG_MEDIA_TUNER_M88RS6000T=m
# CONFIG_MEDIA_TUNER_TUA9001 is not set
CONFIG_MEDIA_TUNER_SI2157=m
# CONFIG_MEDIA_TUNER_IT913X is not set
# CONFIG_MEDIA_TUNER_R820T is not set
# CONFIG_MEDIA_TUNER_MXL301RF is not set
CONFIG_MEDIA_TUNER_QM1D1C0042=m

#
# Customise DVB Frontends
#

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=m
CONFIG_DVB_STB6100=m
CONFIG_DVB_STV090x=m
CONFIG_DVB_STV0910=m
CONFIG_DVB_STV6110x=m
# CONFIG_DVB_STV6111 is not set
CONFIG_DVB_MXL5XX=m
CONFIG_DVB_M88DS3103=m

#
# Multistandard (cable + terrestrial) frontends
#
# CONFIG_DVB_DRXK is not set
# CONFIG_DVB_TDA18271C2DD is not set
# CONFIG_DVB_SI2165 is not set
CONFIG_DVB_MN88472=m
CONFIG_DVB_MN88473=m

#
# DVB-S (satellite) frontends
#
# CONFIG_DVB_CX24110 is not set
CONFIG_DVB_CX24123=m
# CONFIG_DVB_MT312 is not set
CONFIG_DVB_ZL10036=m
# CONFIG_DVB_ZL10039 is not set
CONFIG_DVB_S5H1420=m
CONFIG_DVB_STV0288=m
CONFIG_DVB_STB6000=m
CONFIG_DVB_STV0299=m
CONFIG_DVB_STV6110=m
CONFIG_DVB_STV0900=m
# CONFIG_DVB_TDA8083 is not set
CONFIG_DVB_TDA10086=m
CONFIG_DVB_TDA8261=m
CONFIG_DVB_VES1X93=m
CONFIG_DVB_TUNER_ITD1000=m
# CONFIG_DVB_TUNER_CX24113 is not set
# CONFIG_DVB_TDA826X is not set
# CONFIG_DVB_TUA6100 is not set
CONFIG_DVB_CX24116=m
CONFIG_DVB_CX24117=m
CONFIG_DVB_CX24120=m
CONFIG_DVB_SI21XX=m
CONFIG_DVB_TS2020=m
CONFIG_DVB_DS3000=m
CONFIG_DVB_MB86A16=m
# CONFIG_DVB_TDA10071 is not set

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=m
CONFIG_DVB_SP887X=m
CONFIG_DVB_CX22700=m
CONFIG_DVB_CX22702=m
# CONFIG_DVB_S5H1432 is not set
# CONFIG_DVB_DRXD is not set
CONFIG_DVB_L64781=m
# CONFIG_DVB_TDA1004X is not set
CONFIG_DVB_NXT6000=m
CONFIG_DVB_MT352=m
CONFIG_DVB_ZL10353=m
# CONFIG_DVB_DIB3000MB is not set
CONFIG_DVB_DIB3000MC=m
CONFIG_DVB_DIB7000M=m
CONFIG_DVB_DIB7000P=m
CONFIG_DVB_DIB9000=m
CONFIG_DVB_TDA10048=m
# CONFIG_DVB_AF9013 is not set
CONFIG_DVB_EC100=m
# CONFIG_DVB_STV0367 is not set
CONFIG_DVB_CXD2820R=m
# CONFIG_DVB_CXD2841ER is not set
# CONFIG_DVB_RTL2830 is not set
# CONFIG_DVB_RTL2832 is not set
CONFIG_DVB_SI2168=m
CONFIG_DVB_ZD1301_DEMOD=m
CONFIG_DVB_CXD2880=m

#
# DVB-C (cable) frontends
#
# CONFIG_DVB_VES1820 is not set
# CONFIG_DVB_TDA10021 is not set
CONFIG_DVB_TDA10023=m
# CONFIG_DVB_STV0297 is not set

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=m
CONFIG_DVB_OR51211=m
CONFIG_DVB_OR51132=m
CONFIG_DVB_BCM3510=m
CONFIG_DVB_LGDT330X=m
# CONFIG_DVB_LGDT3305 is not set
CONFIG_DVB_LGDT3306A=m
CONFIG_DVB_LG2160=m
CONFIG_DVB_S5H1409=m
CONFIG_DVB_AU8522=m
# CONFIG_DVB_AU8522_DTV is not set
CONFIG_DVB_AU8522_V4L=m
# CONFIG_DVB_S5H1411 is not set

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=m
CONFIG_DVB_DIB8000=m
CONFIG_DVB_MB86A20S=m

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
# CONFIG_DVB_TC90522 is not set

#
# Digital terrestrial only tuners/PLL
#
# CONFIG_DVB_PLL is not set
CONFIG_DVB_TUNER_DIB0070=m
CONFIG_DVB_TUNER_DIB0090=m

#
# SEC control devices for DVB-S
#
CONFIG_DVB_DRX39XYJ=m
# CONFIG_DVB_LNBH25 is not set
CONFIG_DVB_LNBP21=m
CONFIG_DVB_LNBP22=m
# CONFIG_DVB_ISL6405 is not set
CONFIG_DVB_ISL6421=m
# CONFIG_DVB_ISL6423 is not set
# CONFIG_DVB_A8293 is not set
# CONFIG_DVB_LGS8GL5 is not set
CONFIG_DVB_LGS8GXX=m
CONFIG_DVB_ATBM8830=m
CONFIG_DVB_TDA665x=m
# CONFIG_DVB_IX2505V is not set
CONFIG_DVB_M88RS2000=m
# CONFIG_DVB_AF9033 is not set
CONFIG_DVB_HORUS3A=m
CONFIG_DVB_ASCOT2E=m
# CONFIG_DVB_HELENE is not set

#
# Common Interface (EN50221) controller drivers
#
CONFIG_DVB_CXD2099=m
# CONFIG_DVB_SP2 is not set

#
# Tools to develop new frontends
#
CONFIG_DVB_DUMMY_FE=m

#
# Graphics support
#
CONFIG_AGP=m
CONFIG_AGP_AMD64=m
CONFIG_AGP_INTEL=m
CONFIG_AGP_SIS=m
CONFIG_AGP_VIA=m
CONFIG_INTEL_GTT=m
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# AMD Library routines
#

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_DDC=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=m
CONFIG_FB_SVGALIB=m
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=y
CONFIG_FB_PM2=y
# CONFIG_FB_PM2_FIFO_DISCONNECT is not set
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
# CONFIG_FB_VESA is not set
CONFIG_FB_N411=m
# CONFIG_FB_HGA is not set
CONFIG_FB_OPENCORES=m
CONFIG_FB_S1D13XXX=y
# CONFIG_FB_NVIDIA is not set
CONFIG_FB_RIVA=m
# CONFIG_FB_RIVA_I2C is not set
CONFIG_FB_RIVA_DEBUG=y
# CONFIG_FB_RIVA_BACKLIGHT is not set
CONFIG_FB_I740=y
CONFIG_FB_LE80578=y
# CONFIG_FB_CARILLO_RANCH is not set
CONFIG_FB_INTEL=m
# CONFIG_FB_INTEL_DEBUG is not set
CONFIG_FB_INTEL_I2C=y
CONFIG_FB_MATROX=y
CONFIG_FB_MATROX_MILLENIUM=y
# CONFIG_FB_MATROX_MYSTIQUE is not set
# CONFIG_FB_MATROX_G is not set
CONFIG_FB_MATROX_I2C=y
# CONFIG_FB_RADEON is not set
CONFIG_FB_ATY128=m
CONFIG_FB_ATY128_BACKLIGHT=y
CONFIG_FB_ATY=y
# CONFIG_FB_ATY_CT is not set
CONFIG_FB_ATY_GX=y
CONFIG_FB_ATY_BACKLIGHT=y
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
CONFIG_FB_VIA=m
# CONFIG_FB_VIA_DIRECT_PROCFS is not set
CONFIG_FB_VIA_X_COMPATIBILITY=y
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
CONFIG_FB_VT8623=m
CONFIG_FB_TRIDENT=m
# CONFIG_FB_ARK is not set
CONFIG_FB_PM3=m
CONFIG_FB_CARMINE=y
# CONFIG_FB_CARMINE_DRAM_EVAL is not set
CONFIG_CARMINE_DRAM_CUSTOM=y
# CONFIG_FB_SM501 is not set
CONFIG_FB_IBM_GXT4500=m
CONFIG_FB_VIRTUAL=m
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
CONFIG_FB_AUO_K190X=m
CONFIG_FB_AUO_K1900=m
# CONFIG_FB_AUO_K1901 is not set
CONFIG_FB_SIMPLE=y
# CONFIG_FB_SSD1307 is not set
CONFIG_FB_SM712=m
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_L4F00242T03 is not set
CONFIG_LCD_LMS283GF05=y
# CONFIG_LCD_LTV350QV is not set
# CONFIG_LCD_ILI922X is not set
# CONFIG_LCD_ILI9320 is not set
CONFIG_LCD_TDO24M=m
# CONFIG_LCD_VGG2432A4 is not set
CONFIG_LCD_PLATFORM=y
CONFIG_LCD_S6E63M0=m
CONFIG_LCD_LD9040=y
CONFIG_LCD_AMS369FG06=y
# CONFIG_LCD_LMS501KF03 is not set
CONFIG_LCD_HX8357=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=m
CONFIG_BACKLIGHT_LM3533=m
CONFIG_BACKLIGHT_CARILLO_RANCH=m
CONFIG_BACKLIGHT_MAX8925=m
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_PM8941_WLED=m
CONFIG_BACKLIGHT_SAHARA=m
CONFIG_BACKLIGHT_WM831X=m
CONFIG_BACKLIGHT_ADP5520=m
CONFIG_BACKLIGHT_ADP8860=m
# CONFIG_BACKLIGHT_ADP8870 is not set
CONFIG_BACKLIGHT_88PM860X=y
# CONFIG_BACKLIGHT_AAT2870 is not set
CONFIG_BACKLIGHT_LM3639=y
# CONFIG_BACKLIGHT_SKY81452 is not set
CONFIG_BACKLIGHT_TPS65217=m
CONFIG_BACKLIGHT_AS3711=y
CONFIG_BACKLIGHT_GPIO=y
CONFIG_BACKLIGHT_LV5207LP=m
CONFIG_BACKLIGHT_BD6107=m
CONFIG_BACKLIGHT_ARCXCNN=m
CONFIG_VGASTATE=y
# CONFIG_LOGO is not set
CONFIG_SOUND=m
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_DMAENGINE_PCM=m
CONFIG_SND_HWDEP=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
# CONFIG_SND_OSSEMUL is not set
# CONFIG_SND_PCM_TIMER is not set
# CONFIG_SND_DYNAMIC_MINORS is not set
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
CONFIG_SND_VERBOSE_PRINTK=y
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
# CONFIG_SND_SEQUENCER is not set
CONFIG_SND_MPU401_UART=m
CONFIG_SND_OPL3_LIB=m
CONFIG_SND_VX_LIB=m
CONFIG_SND_AC97_CODEC=m
CONFIG_SND_DRIVERS=y
CONFIG_SND_DUMMY=m
# CONFIG_SND_ALOOP is not set
CONFIG_SND_MTPAV=m
CONFIG_SND_MTS64=m
# CONFIG_SND_SERIAL_U16550 is not set
# CONFIG_SND_MPU401 is not set
# CONFIG_SND_PORTMAN2X4 is not set
# CONFIG_SND_AC97_POWER_SAVE is not set
CONFIG_SND_PCI=y
# CONFIG_SND_AD1889 is not set
CONFIG_SND_ASIHPI=m
# CONFIG_SND_ATIIXP is not set
CONFIG_SND_ATIIXP_MODEM=m
CONFIG_SND_AU8810=m
# CONFIG_SND_AU8820 is not set
CONFIG_SND_AU8830=m
CONFIG_SND_AW2=m
CONFIG_SND_BT87X=m
CONFIG_SND_BT87X_OVERCLOCK=y
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
CONFIG_SND_OXYGEN_LIB=m
CONFIG_SND_OXYGEN=m
CONFIG_SND_CS4281=m
CONFIG_SND_CS46XX=m
# CONFIG_SND_CS46XX_NEW_DSP is not set
# CONFIG_SND_CTXFI is not set
# CONFIG_SND_DARLA20 is not set
CONFIG_SND_GINA20=m
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
CONFIG_SND_LAYLA24=m
CONFIG_SND_MONA=m
CONFIG_SND_MIA=m
# CONFIG_SND_ECHO3G is not set
CONFIG_SND_INDIGO=m
# CONFIG_SND_INDIGOIO is not set
# CONFIG_SND_INDIGODJ is not set
CONFIG_SND_INDIGOIOX=m
# CONFIG_SND_INDIGODJX is not set
CONFIG_SND_ENS1370=m
# CONFIG_SND_ENS1371 is not set
CONFIG_SND_FM801=m
CONFIG_SND_HDSP=m
CONFIG_SND_HDSPM=m
# CONFIG_SND_ICE1724 is not set
CONFIG_SND_INTEL8X0=m
# CONFIG_SND_INTEL8X0M is not set
CONFIG_SND_KORG1212=m
CONFIG_SND_LOLA=m
CONFIG_SND_LX6464ES=m
CONFIG_SND_MIXART=m
CONFIG_SND_NM256=m
CONFIG_SND_PCXHR=m
# CONFIG_SND_RIPTIDE is not set
CONFIG_SND_RME32=m
CONFIG_SND_RME96=m
CONFIG_SND_RME9652=m
# CONFIG_SND_VIA82XX is not set
CONFIG_SND_VIA82XX_MODEM=m
CONFIG_SND_VIRTUOSO=m
CONFIG_SND_VX222=m
CONFIG_SND_YMFPCI=m

#
# HD-Audio
#
CONFIG_SND_HDA=m
CONFIG_SND_HDA_INTEL=m
# CONFIG_SND_HDA_HWDEP is not set
CONFIG_SND_HDA_RECONFIG=y
# CONFIG_SND_HDA_INPUT_BEEP is not set
# CONFIG_SND_HDA_PATCH_LOADER is not set
# CONFIG_SND_HDA_CODEC_REALTEK is not set
CONFIG_SND_HDA_CODEC_ANALOG=m
CONFIG_SND_HDA_CODEC_SIGMATEL=m
# CONFIG_SND_HDA_CODEC_VIA is not set
# CONFIG_SND_HDA_CODEC_HDMI is not set
CONFIG_SND_HDA_CODEC_CIRRUS=m
CONFIG_SND_HDA_CODEC_CONEXANT=m
CONFIG_SND_HDA_CODEC_CA0110=m
# CONFIG_SND_HDA_CODEC_CA0132 is not set
# CONFIG_SND_HDA_CODEC_CMEDIA is not set
# CONFIG_SND_HDA_CODEC_SI3054 is not set
CONFIG_SND_HDA_GENERIC=m
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_HDA_CORE=m
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_SPI=y
CONFIG_SND_SOC=m
CONFIG_SND_SOC_AC97_BUS=y
CONFIG_SND_SOC_GENERIC_DMAENGINE_PCM=y
CONFIG_SND_SOC_AMD_ACP=m
CONFIG_SND_SOC_AMD_CZ_DA7219MX98357_MACH=m
CONFIG_SND_SOC_AMD_CZ_RT5645_MACH=m
CONFIG_SND_ATMEL_SOC=m
CONFIG_SND_DESIGNWARE_I2S=m
CONFIG_SND_DESIGNWARE_PCM=y

#
# SoC Audio for Freescale CPUs
#

#
# Common SoC Audio options for Freescale CPUs:
#
CONFIG_SND_SOC_FSL_ASRC=m
CONFIG_SND_SOC_FSL_SAI=m
CONFIG_SND_SOC_FSL_SSI=m
CONFIG_SND_SOC_FSL_SPDIF=m
CONFIG_SND_SOC_FSL_ESAI=m
CONFIG_SND_SOC_IMX_AUDMUX=m
CONFIG_SND_I2S_HI6210_I2S=m
CONFIG_SND_SOC_IMG=y
CONFIG_SND_SOC_IMG_I2S_IN=m
# CONFIG_SND_SOC_IMG_I2S_OUT is not set
CONFIG_SND_SOC_IMG_PARALLEL_OUT=m
# CONFIG_SND_SOC_IMG_SPDIF_IN is not set
CONFIG_SND_SOC_IMG_SPDIF_OUT=m
CONFIG_SND_SOC_IMG_PISTACHIO_INTERNAL_DAC=m
# CONFIG_SND_SOC_INTEL_SST_TOPLEVEL is not set

#
# STMicroelectronics STM32 SOC audio support
#
CONFIG_SND_SOC_XTFPGA_I2S=m
CONFIG_ZX_TDM=m
CONFIG_SND_SOC_I2C_AND_SPI=m

#
# CODEC drivers
#
CONFIG_SND_SOC_AC97_CODEC=m
CONFIG_SND_SOC_ADAU_UTILS=m
CONFIG_SND_SOC_ADAU1701=m
CONFIG_SND_SOC_ADAU17X1=m
CONFIG_SND_SOC_ADAU1761=m
CONFIG_SND_SOC_ADAU1761_I2C=m
CONFIG_SND_SOC_ADAU1761_SPI=m
CONFIG_SND_SOC_ADAU7002=m
CONFIG_SND_SOC_AK4104=m
CONFIG_SND_SOC_AK4458=m
CONFIG_SND_SOC_AK4554=m
CONFIG_SND_SOC_AK4613=m
CONFIG_SND_SOC_AK4642=m
CONFIG_SND_SOC_AK5386=m
CONFIG_SND_SOC_AK5558=m
CONFIG_SND_SOC_ALC5623=m
CONFIG_SND_SOC_BD28623=m
CONFIG_SND_SOC_BT_SCO=m
CONFIG_SND_SOC_CS35L32=m
CONFIG_SND_SOC_CS35L33=m
CONFIG_SND_SOC_CS35L34=m
CONFIG_SND_SOC_CS35L35=m
CONFIG_SND_SOC_CS42L42=m
CONFIG_SND_SOC_CS42L51=m
CONFIG_SND_SOC_CS42L51_I2C=m
# CONFIG_SND_SOC_CS42L52 is not set
# CONFIG_SND_SOC_CS42L56 is not set
CONFIG_SND_SOC_CS42L73=m
CONFIG_SND_SOC_CS4265=m
CONFIG_SND_SOC_CS4270=m
CONFIG_SND_SOC_CS4271=m
CONFIG_SND_SOC_CS4271_I2C=m
CONFIG_SND_SOC_CS4271_SPI=m
CONFIG_SND_SOC_CS42XX8=m
CONFIG_SND_SOC_CS42XX8_I2C=m
CONFIG_SND_SOC_CS43130=m
CONFIG_SND_SOC_CS4349=m
CONFIG_SND_SOC_CS53L30=m
CONFIG_SND_SOC_DA7219=m
CONFIG_SND_SOC_DIO2125=m
CONFIG_SND_SOC_ES7134=m
CONFIG_SND_SOC_ES8316=m
CONFIG_SND_SOC_ES8328=m
CONFIG_SND_SOC_ES8328_I2C=m
CONFIG_SND_SOC_ES8328_SPI=m
CONFIG_SND_SOC_GTM601=m
CONFIG_SND_SOC_INNO_RK3036=m
CONFIG_SND_SOC_MAX98357A=m
CONFIG_SND_SOC_MAX98504=m
CONFIG_SND_SOC_MAX9867=m
CONFIG_SND_SOC_MAX98927=m
CONFIG_SND_SOC_MAX98373=m
CONFIG_SND_SOC_MAX9860=m
CONFIG_SND_SOC_MSM8916_WCD_ANALOG=m
CONFIG_SND_SOC_MSM8916_WCD_DIGITAL=m
CONFIG_SND_SOC_PCM1681=m
CONFIG_SND_SOC_PCM1789=m
CONFIG_SND_SOC_PCM1789_I2C=m
CONFIG_SND_SOC_PCM179X=m
CONFIG_SND_SOC_PCM179X_I2C=m
CONFIG_SND_SOC_PCM179X_SPI=m
CONFIG_SND_SOC_PCM186X=m
CONFIG_SND_SOC_PCM186X_I2C=m
CONFIG_SND_SOC_PCM186X_SPI=m
CONFIG_SND_SOC_PCM3168A=m
CONFIG_SND_SOC_PCM3168A_I2C=m
CONFIG_SND_SOC_PCM3168A_SPI=m
CONFIG_SND_SOC_PCM512x=m
CONFIG_SND_SOC_PCM512x_I2C=m
CONFIG_SND_SOC_PCM512x_SPI=m
CONFIG_SND_SOC_RL6231=m
CONFIG_SND_SOC_RT5616=m
CONFIG_SND_SOC_RT5631=m
CONFIG_SND_SOC_RT5645=m
CONFIG_SND_SOC_SGTL5000=m
CONFIG_SND_SOC_SIGMADSP=m
CONFIG_SND_SOC_SIGMADSP_I2C=m
CONFIG_SND_SOC_SIGMADSP_REGMAP=m
CONFIG_SND_SOC_SIRF_AUDIO_CODEC=m
CONFIG_SND_SOC_SPDIF=m
CONFIG_SND_SOC_SSM2602=m
CONFIG_SND_SOC_SSM2602_SPI=m
CONFIG_SND_SOC_SSM2602_I2C=m
CONFIG_SND_SOC_SSM4567=m
CONFIG_SND_SOC_STA32X=m
CONFIG_SND_SOC_STA350=m
CONFIG_SND_SOC_STI_SAS=m
CONFIG_SND_SOC_TAS2552=m
CONFIG_SND_SOC_TAS5086=m
CONFIG_SND_SOC_TAS571X=m
CONFIG_SND_SOC_TAS5720=m
CONFIG_SND_SOC_TAS6424=m
CONFIG_SND_SOC_TDA7419=m
CONFIG_SND_SOC_TFA9879=m
CONFIG_SND_SOC_TLV320AIC23=m
CONFIG_SND_SOC_TLV320AIC23_I2C=m
CONFIG_SND_SOC_TLV320AIC23_SPI=m
CONFIG_SND_SOC_TLV320AIC31XX=m
CONFIG_SND_SOC_TLV320AIC32X4=m
CONFIG_SND_SOC_TLV320AIC32X4_I2C=m
CONFIG_SND_SOC_TLV320AIC32X4_SPI=m
CONFIG_SND_SOC_TLV320AIC3X=m
CONFIG_SND_SOC_TS3A227E=m
CONFIG_SND_SOC_TSCS42XX=m
CONFIG_SND_SOC_WM8510=m
CONFIG_SND_SOC_WM8523=m
CONFIG_SND_SOC_WM8524=m
CONFIG_SND_SOC_WM8580=m
CONFIG_SND_SOC_WM8711=m
CONFIG_SND_SOC_WM8728=m
CONFIG_SND_SOC_WM8731=m
CONFIG_SND_SOC_WM8737=m
CONFIG_SND_SOC_WM8741=m
CONFIG_SND_SOC_WM8750=m
CONFIG_SND_SOC_WM8753=m
CONFIG_SND_SOC_WM8770=m
CONFIG_SND_SOC_WM8776=m
CONFIG_SND_SOC_WM8804=m
CONFIG_SND_SOC_WM8804_I2C=m
CONFIG_SND_SOC_WM8804_SPI=m
CONFIG_SND_SOC_WM8903=m
CONFIG_SND_SOC_WM8960=m
# CONFIG_SND_SOC_WM8962 is not set
CONFIG_SND_SOC_WM8974=m
CONFIG_SND_SOC_WM8978=m
CONFIG_SND_SOC_WM8985=m
# CONFIG_SND_SOC_ZX_AUD96P22 is not set
CONFIG_SND_SOC_MAX9759=m
CONFIG_SND_SOC_NAU8540=m
CONFIG_SND_SOC_NAU8810=m
CONFIG_SND_SOC_NAU8824=m
CONFIG_SND_SOC_TPA6130A2=m
CONFIG_SND_SIMPLE_CARD_UTILS=m
CONFIG_SND_SIMPLE_CARD=m
CONFIG_SND_SIMPLE_SCU_CARD=m
# CONFIG_SND_AUDIO_GRAPH_CARD is not set
# CONFIG_SND_AUDIO_GRAPH_SCU_CARD is not set
# CONFIG_SND_X86 is not set
CONFIG_AC97_BUS=m

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
# CONFIG_HID_ACRUX is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_ASUS is not set
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_PRODIKEYS is not set
# CONFIG_HID_CMEDIA is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_GEMBIRD is not set
# CONFIG_HID_GFRM is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_GYRATION is not set
# CONFIG_HID_ICADE is not set
# CONFIG_HID_ITE is not set
# CONFIG_HID_JABRA is not set
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LED is not set
# CONFIG_HID_LENOVO is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MAYFLASH is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTI is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PLANTRONICS is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_RMI is not set
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_UDRAW_PS3 is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set
# CONFIG_HID_ALPS is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set

#
# Intel ISH HID support
#
# CONFIG_INTEL_ISH_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set
CONFIG_USB_PCI=y

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_GADGET is not set
# CONFIG_TYPEC is not set
# CONFIG_USB_LED_TRIG is not set
# CONFIG_USB_ULPI_BUS is not set
CONFIG_UWB=m
# CONFIG_UWB_WHCI is not set
CONFIG_MMC=m
CONFIG_PWRSEQ_EMMC=m
CONFIG_PWRSEQ_SIMPLE=m
CONFIG_SDIO_UART=m
CONFIG_MMC_TEST=m

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_SDHCI=m
CONFIG_MMC_SDHCI_PCI=m
# CONFIG_MMC_RICOH_MMC is not set
# CONFIG_MMC_SDHCI_ACPI is not set
# CONFIG_MMC_SDHCI_PLTFM is not set
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_SPI is not set
CONFIG_MMC_CB710=m
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MMC_USDHI6ROL0=m
# CONFIG_MMC_REALTEK_PCI is not set
CONFIG_MMC_CQHCI=m
CONFIG_MMC_TOSHIBA_PCI=m
CONFIG_MMC_MTK=m
CONFIG_MEMSTICK=m
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=m
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
# CONFIG_MEMSTICK_REALTEK_PCI is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=m
CONFIG_LEDS_BRIGHTNESS_HW_CHANGED=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=m
# CONFIG_LEDS_AS3645A is not set
CONFIG_LEDS_BCM6328=y
CONFIG_LEDS_BCM6358=m
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=m
# CONFIG_LEDS_LM3692X is not set
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=m
CONFIG_LEDS_LP3952=y
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=y
# CONFIG_LEDS_LP5562 is not set
# CONFIG_LEDS_LP8501 is not set
CONFIG_LEDS_LP8788=m
# CONFIG_LEDS_LP8860 is not set
CONFIG_LEDS_PCA955X=m
# CONFIG_LEDS_PCA955X_GPIO is not set
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_WM831X_STATUS=m
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_REGULATOR=m
CONFIG_LEDS_BD2802=m
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_ADP5520=m
CONFIG_LEDS_MC13783=m
# CONFIG_LEDS_TCA6507 is not set
CONFIG_LEDS_TLC591XX=y
# CONFIG_LEDS_MAX77693 is not set
# CONFIG_LEDS_LM355x is not set
CONFIG_LEDS_MENF21BMC=m
# CONFIG_LEDS_KTD2692 is not set
CONFIG_LEDS_IS31FL319X=y
# CONFIG_LEDS_IS31FL32XX is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
# CONFIG_LEDS_BLINKM is not set
# CONFIG_LEDS_SYSCON is not set
CONFIG_LEDS_MLXREG=m
CONFIG_LEDS_USER=y
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=m
# CONFIG_LEDS_TRIGGER_MTD is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_ACTIVITY is not set
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
CONFIG_LEDS_TRIGGER_CAMERA=m
# CONFIG_LEDS_TRIGGER_PANIC is not set
CONFIG_LEDS_TRIGGER_NETDEV=m
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_SYSTOHC_DEVICE="rtc0"
CONFIG_RTC_DEBUG=y
# CONFIG_RTC_NVMEM is not set

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
CONFIG_RTC_INTF_PROC=y
# CONFIG_RTC_INTF_DEV is not set
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM860X=y
CONFIG_RTC_DRV_88PM80X=y
# CONFIG_RTC_DRV_ABB5ZES3 is not set
CONFIG_RTC_DRV_ABX80X=y
# CONFIG_RTC_DRV_DS1307 is not set
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1374_WDT=y
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_HYM8563=y
CONFIG_RTC_DRV_LP8788=m
CONFIG_RTC_DRV_MAX6900=m
CONFIG_RTC_DRV_MAX8925=y
CONFIG_RTC_DRV_MAX77686=m
# CONFIG_RTC_DRV_RS5C372 is not set
CONFIG_RTC_DRV_ISL1208=y
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_ISL12026=m
CONFIG_RTC_DRV_X1205=m
# CONFIG_RTC_DRV_PCF8523 is not set
CONFIG_RTC_DRV_PCF85063=y
CONFIG_RTC_DRV_PCF85363=y
# CONFIG_RTC_DRV_PCF8563 is not set
CONFIG_RTC_DRV_PCF8583=y
# CONFIG_RTC_DRV_M41T80 is not set
# CONFIG_RTC_DRV_BQ32K is not set
# CONFIG_RTC_DRV_PALMAS is not set
# CONFIG_RTC_DRV_TPS65910 is not set
CONFIG_RTC_DRV_RC5T583=y
CONFIG_RTC_DRV_S35390A=m
CONFIG_RTC_DRV_FM3130=m
CONFIG_RTC_DRV_RX8010=y
CONFIG_RTC_DRV_RX8581=m
CONFIG_RTC_DRV_RX8025=y
# CONFIG_RTC_DRV_EM3027 is not set
CONFIG_RTC_DRV_RV8803=m

#
# SPI RTC drivers
#
CONFIG_RTC_DRV_M41T93=m
# CONFIG_RTC_DRV_M41T94 is not set
CONFIG_RTC_DRV_DS1302=y
# CONFIG_RTC_DRV_DS1305 is not set
CONFIG_RTC_DRV_DS1343=y
# CONFIG_RTC_DRV_DS1347 is not set
# CONFIG_RTC_DRV_DS1390 is not set
CONFIG_RTC_DRV_MAX6916=m
CONFIG_RTC_DRV_R9701=y
# CONFIG_RTC_DRV_RX4581 is not set
CONFIG_RTC_DRV_RX6110=y
CONFIG_RTC_DRV_RS5C348=y
# CONFIG_RTC_DRV_MAX6902 is not set
CONFIG_RTC_DRV_PCF2123=m
CONFIG_RTC_DRV_MCP795=y
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
# CONFIG_RTC_DRV_DS3232 is not set
CONFIG_RTC_DRV_PCF2127=y
CONFIG_RTC_DRV_RV3029C2=m
CONFIG_RTC_DRV_RV3029_HWMON=y

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=m
CONFIG_RTC_DRV_DS1685_FAMILY=y
CONFIG_RTC_DRV_DS1685=y
# CONFIG_RTC_DRV_DS1689 is not set
# CONFIG_RTC_DRV_DS17285 is not set
# CONFIG_RTC_DRV_DS17485 is not set
# CONFIG_RTC_DRV_DS17885 is not set
# CONFIG_RTC_DS1685_PROC_REGS is not set
CONFIG_RTC_DS1685_SYSFS_REGS=y
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_DS2404=y
CONFIG_RTC_DRV_DA9063=m
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=m
CONFIG_RTC_DRV_M48T35=m
# CONFIG_RTC_DRV_M48T59 is not set
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=m
CONFIG_RTC_DRV_V3020=m
CONFIG_RTC_DRV_WM831X=y
# CONFIG_RTC_DRV_ZYNQMP is not set
# CONFIG_RTC_DRV_CROS_EC is not set

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_FTRTC010=y
CONFIG_RTC_DRV_PCAP=m
CONFIG_RTC_DRV_MC13XXX=m
CONFIG_RTC_DRV_SNVS=m
CONFIG_RTC_DRV_R7301=m

#
# HID Sensor RTC drivers
#
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
CONFIG_DMADEVICES_VDEBUG=y

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=m
CONFIG_DMA_ACPI=y
CONFIG_DMA_OF=y
CONFIG_ALTERA_MSGDMA=y
# CONFIG_DW_AXI_DMAC is not set
# CONFIG_FSL_EDMA is not set
CONFIG_INTEL_IDMA64=m
# CONFIG_INTEL_IOATDMA is not set
# CONFIG_INTEL_MIC_X100_DMA is not set
CONFIG_QCOM_HIDMA_MGMT=y
# CONFIG_QCOM_HIDMA is not set
CONFIG_DW_DMAC_CORE=y
# CONFIG_DW_DMAC is not set
CONFIG_DW_DMAC_PCI=y

#
# DMA Clients
#
# CONFIG_ASYNC_TX_DMA is not set
CONFIG_DMATEST=y
CONFIG_DMA_ENGINE_RAID=y

#
# DMABUF options
#
# CONFIG_SYNC_FILE is not set
# CONFIG_AUXDISPLAY is not set
CONFIG_CHARLCD=y
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
# CONFIG_PANEL_CHANGE_MESSAGE is not set
CONFIG_UIO=y
CONFIG_UIO_CIF=m
CONFIG_UIO_PDRV_GENIRQ=m
CONFIG_UIO_DMEM_GENIRQ=y
CONFIG_UIO_AEC=y
CONFIG_UIO_SERCOS3=y
CONFIG_UIO_PCI_GENERIC=m
CONFIG_UIO_NETX=y
# CONFIG_UIO_PRUSS is not set
CONFIG_UIO_MF624=y
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y
# CONFIG_VIRTIO_MENU is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_IPX is not set
# CONFIG_NCP_FS is not set
# CONFIG_COMEDI is not set
# CONFIG_RTLLIB is not set

#
# IIO staging drivers
#

#
# Accelerometers
#
CONFIG_ADIS16201=m
# CONFIG_ADIS16203 is not set
CONFIG_ADIS16209=m
CONFIG_ADIS16240=m

#
# Analog to digital converters
#
CONFIG_AD7606=m
# CONFIG_AD7606_IFACE_PARALLEL is not set
CONFIG_AD7606_IFACE_SPI=m
CONFIG_AD7780=m
CONFIG_AD7816=m
# CONFIG_AD7192 is not set
CONFIG_AD7280=m

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=m
CONFIG_ADT7316_SPI=m
# CONFIG_ADT7316_I2C is not set

#
# Capacitance to digital converters
#
CONFIG_AD7150=m
CONFIG_AD7152=m
CONFIG_AD7746=m

#
# Direct Digital Synthesis
#
CONFIG_AD9832=m
CONFIG_AD9834=m

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16060 is not set

#
# Network Analyzer, Impedance Converters
#
CONFIG_AD5933=m

#
# Light sensors
#
CONFIG_TSL2x7x=m

#
# Active energy metering IC
#
CONFIG_ADE7753=m
CONFIG_ADE7754=m
# CONFIG_ADE7758 is not set
# CONFIG_ADE7759 is not set
CONFIG_ADE7854=m
CONFIG_ADE7854_I2C=m
CONFIG_ADE7854_SPI=m

#
# Resolver to digital converters
#
CONFIG_AD2S90=m
CONFIG_AD2S1200=m
CONFIG_AD2S1210=m
# CONFIG_FB_SM750 is not set
# CONFIG_FB_XGI is not set

#
# Speakup console speech
#
CONFIG_STAGING_MEDIA=y

#
# Android
#
# CONFIG_STAGING_BOARD is not set
# CONFIG_LNET is not set
CONFIG_DGNC=y
CONFIG_GS_FPGABOOT=m
CONFIG_CRYPTO_SKEIN=m
CONFIG_UNISYSSPAR=y
# CONFIG_COMMON_CLK_XLNX_CLKWZRD is not set
CONFIG_FB_TFT=m
CONFIG_FB_TFT_AGM1264K_FL=m
CONFIG_FB_TFT_BD663474=m
CONFIG_FB_TFT_HX8340BN=m
# CONFIG_FB_TFT_HX8347D is not set
# CONFIG_FB_TFT_HX8353D is not set
# CONFIG_FB_TFT_HX8357D is not set
# CONFIG_FB_TFT_ILI9163 is not set
# CONFIG_FB_TFT_ILI9320 is not set
# CONFIG_FB_TFT_ILI9325 is not set
CONFIG_FB_TFT_ILI9340=m
# CONFIG_FB_TFT_ILI9341 is not set
CONFIG_FB_TFT_ILI9481=m
CONFIG_FB_TFT_ILI9486=m
CONFIG_FB_TFT_PCD8544=m
# CONFIG_FB_TFT_RA8875 is not set
CONFIG_FB_TFT_S6D02A1=m
CONFIG_FB_TFT_S6D1121=m
CONFIG_FB_TFT_SH1106=m
CONFIG_FB_TFT_SSD1289=m
CONFIG_FB_TFT_SSD1305=m
CONFIG_FB_TFT_SSD1306=m
CONFIG_FB_TFT_SSD1331=m
CONFIG_FB_TFT_SSD1351=m
# CONFIG_FB_TFT_ST7735R is not set
# CONFIG_FB_TFT_ST7789V is not set
# CONFIG_FB_TFT_TINYLCD is not set
CONFIG_FB_TFT_TLS8204=m
# CONFIG_FB_TFT_UC1611 is not set
CONFIG_FB_TFT_UC1701=m
CONFIG_FB_TFT_UPD161704=m
CONFIG_FB_TFT_WATTEROTT=m
CONFIG_FB_FLEX=m
# CONFIG_FB_TFT_FBTFT_DEVICE is not set
CONFIG_MOST=y
CONFIG_MOST_CDEV=y
CONFIG_MOST_NET=m
# CONFIG_MOST_SOUND is not set
CONFIG_MOST_VIDEO=m
# CONFIG_MOST_DIM2 is not set
# CONFIG_MOST_I2C is not set
# CONFIG_KS7010 is not set
CONFIG_GREYBUS=y
CONFIG_GREYBUS_AUDIO=m
# CONFIG_GREYBUS_BOOTROM is not set
# CONFIG_GREYBUS_FIRMWARE is not set
# CONFIG_GREYBUS_HID is not set
CONFIG_GREYBUS_LIGHT=m
CONFIG_GREYBUS_LOG=m
CONFIG_GREYBUS_LOOPBACK=y
# CONFIG_GREYBUS_POWER is not set
# CONFIG_GREYBUS_RAW is not set
# CONFIG_GREYBUS_VIBRATOR is not set
# CONFIG_GREYBUS_BRIDGED_PHY is not set

#
# USB Power Delivery and Type-C drivers
#
CONFIG_PI433=m
CONFIG_MTK_MMC=m
CONFIG_MTK_AEE_KDUMP=y
# CONFIG_MTK_MMC_CD_POLL is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_PMC_ATOM=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_PSTORE=y
CONFIG_CROS_EC_CTL=y
# CONFIG_CROS_EC_LPC is not set
CONFIG_CROS_EC_PROTO=y
# CONFIG_CROS_KBD_LED_BACKLIGHT is not set
CONFIG_MELLANOX_PLATFORM=y
# CONFIG_MLXREG_HOTPLUG is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
CONFIG_COMMON_CLK_WM831X=m
CONFIG_CLK_HSDK=y
# CONFIG_COMMON_CLK_MAX77686 is not set
CONFIG_COMMON_CLK_SI5351=y
# CONFIG_COMMON_CLK_SI514 is not set
CONFIG_COMMON_CLK_SI544=m
CONFIG_COMMON_CLK_SI570=m
CONFIG_COMMON_CLK_CDCE706=m
CONFIG_COMMON_CLK_CDCE925=y
# CONFIG_COMMON_CLK_CS2000_CP is not set
CONFIG_COMMON_CLK_PALMAS=m
# CONFIG_COMMON_CLK_VC5 is not set
# CONFIG_HWSPINLOCK is not set

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_MAILBOX=y
CONFIG_PLATFORM_MHU=m
# CONFIG_PCC is not set
CONFIG_ALTERA_MBOX=m
# CONFIG_MAILBOX_TEST is not set
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
CONFIG_IOMMU_IOVA=m
# CONFIG_AMD_IOMMU is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y

#
# Rpmsg drivers
#
CONFIG_RPMSG=m
CONFIG_RPMSG_CHAR=m
CONFIG_RPMSG_QCOM_GLINK_NATIVE=m
CONFIG_RPMSG_QCOM_GLINK_RPM=m
CONFIG_RPMSG_VIRTIO=m
CONFIG_SOUNDWIRE=y

#
# SoundWire Devices
#
# CONFIG_SOUNDWIRE_INTEL is not set

#
# SOC (System On Chip) specific Drivers
#

#
# Amlogic SoC drivers
#

#
# Broadcom SoC drivers
#

#
# i.MX SoC drivers
#

#
# Qualcomm SoC drivers
#
# CONFIG_SOC_TI is not set

#
# Xilinx SoC drivers
#
CONFIG_XILINX_VCU=m
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=m
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=m
# CONFIG_DEVFREQ_GOV_PASSIVE is not set

#
# DEVFREQ Drivers
#
# CONFIG_PM_DEVFREQ_EVENT is not set
CONFIG_EXTCON=m

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=m
# CONFIG_EXTCON_ARIZONA is not set
# CONFIG_EXTCON_AXP288 is not set
# CONFIG_EXTCON_GPIO is not set
# CONFIG_EXTCON_INTEL_INT3496 is not set
# CONFIG_EXTCON_MAX14577 is not set
# CONFIG_EXTCON_MAX3355 is not set
# CONFIG_EXTCON_MAX77693 is not set
CONFIG_EXTCON_PALMAS=m
CONFIG_EXTCON_RT8973A=m
CONFIG_EXTCON_SM5502=m
CONFIG_EXTCON_USB_GPIO=m
CONFIG_EXTCON_USBC_CROS_EC=m
CONFIG_MEMORY=y
CONFIG_IIO=m
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=m
CONFIG_IIO_BUFFER_HW_CONSUMER=m
CONFIG_IIO_KFIFO_BUF=m
CONFIG_IIO_TRIGGERED_BUFFER=m
CONFIG_IIO_CONFIGFS=m
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
# CONFIG_IIO_SW_DEVICE is not set
CONFIG_IIO_SW_TRIGGER=m

#
# Accelerometers
#
CONFIG_ADXL345=m
CONFIG_ADXL345_I2C=m
CONFIG_ADXL345_SPI=m
CONFIG_BMA180=m
CONFIG_BMA220=m
CONFIG_BMC150_ACCEL=m
CONFIG_BMC150_ACCEL_I2C=m
CONFIG_BMC150_ACCEL_SPI=m
CONFIG_DA280=m
CONFIG_DA311=m
CONFIG_DMARD06=m
CONFIG_DMARD09=m
# CONFIG_DMARD10 is not set
# CONFIG_IIO_CROS_EC_ACCEL_LEGACY is not set
CONFIG_IIO_ST_ACCEL_3AXIS=m
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=m
CONFIG_IIO_ST_ACCEL_SPI_3AXIS=m
CONFIG_KXSD9=m
CONFIG_KXSD9_SPI=m
CONFIG_KXSD9_I2C=m
# CONFIG_KXCJK1013 is not set
# CONFIG_MC3230 is not set
CONFIG_MMA7455=m
CONFIG_MMA7455_I2C=m
# CONFIG_MMA7455_SPI is not set
# CONFIG_MMA7660 is not set
CONFIG_MMA8452=m
CONFIG_MMA9551_CORE=m
CONFIG_MMA9551=m
CONFIG_MMA9553=m
# CONFIG_MXC4005 is not set
# CONFIG_MXC6255 is not set
# CONFIG_SCA3000 is not set
# CONFIG_STK8312 is not set
# CONFIG_STK8BA50 is not set

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=m
# CONFIG_AD7266 is not set
# CONFIG_AD7291 is not set
# CONFIG_AD7298 is not set
# CONFIG_AD7476 is not set
# CONFIG_AD7766 is not set
# CONFIG_AD7791 is not set
CONFIG_AD7793=m
CONFIG_AD7887=m
CONFIG_AD7923=m
# CONFIG_AD799X is not set
CONFIG_AXP20X_ADC=m
CONFIG_AXP288_ADC=m
CONFIG_CC10001_ADC=m
CONFIG_DA9150_GPADC=m
# CONFIG_ENVELOPE_DETECTOR is not set
# CONFIG_HI8435 is not set
CONFIG_HX711=m
CONFIG_INA2XX_ADC=m
# CONFIG_LP8788_ADC is not set
CONFIG_LTC2471=m
# CONFIG_LTC2485 is not set
CONFIG_LTC2497=m
# CONFIG_MAX1027 is not set
CONFIG_MAX11100=m
CONFIG_MAX1118=m
CONFIG_MAX1363=m
# CONFIG_MAX9611 is not set
CONFIG_MCP320X=m
CONFIG_MCP3422=m
# CONFIG_MEN_Z188_ADC is not set
# CONFIG_NAU7802 is not set
CONFIG_PALMAS_GPADC=m
CONFIG_QCOM_SPMI_IADC=m
# CONFIG_QCOM_SPMI_VADC is not set
CONFIG_SD_ADC_MODULATOR=m
# CONFIG_STX104 is not set
CONFIG_TI_ADC081C=m
CONFIG_TI_ADC0832=m
# CONFIG_TI_ADC084S021 is not set
# CONFIG_TI_ADC12138 is not set
CONFIG_TI_ADC108S102=m
CONFIG_TI_ADC128S052=m
# CONFIG_TI_ADC161S626 is not set
# CONFIG_TI_ADS7950 is not set
# CONFIG_TI_ADS8688 is not set
CONFIG_TI_TLC4541=m
CONFIG_VF610_ADC=m

#
# Amplifiers
#
CONFIG_AD8366=m

#
# Chemical Sensors
#
# CONFIG_ATLAS_PH_SENSOR is not set
CONFIG_CCS811=m
CONFIG_IAQCORE=m
CONFIG_VZ89X=m
CONFIG_IIO_CROS_EC_SENSORS_CORE=m
CONFIG_IIO_CROS_EC_SENSORS=m

#
# Hid Sensor IIO Common
#
CONFIG_IIO_MS_SENSORS_I2C=m

#
# SSP Sensor Common
#
# CONFIG_IIO_SSP_SENSORS_COMMONS is not set
CONFIG_IIO_SSP_SENSORHUB=m
CONFIG_IIO_ST_SENSORS_I2C=m
CONFIG_IIO_ST_SENSORS_SPI=m
CONFIG_IIO_ST_SENSORS_CORE=m

#
# Counters
#
# CONFIG_104_QUAD_8 is not set

#
# Digital to analog converters
#
# CONFIG_AD5064 is not set
# CONFIG_AD5360 is not set
CONFIG_AD5380=m
CONFIG_AD5421=m
CONFIG_AD5446=m
CONFIG_AD5449=m
CONFIG_AD5592R_BASE=m
CONFIG_AD5592R=m
# CONFIG_AD5593R is not set
# CONFIG_AD5504 is not set
# CONFIG_AD5624R_SPI is not set
CONFIG_LTC2632=m
# CONFIG_AD5686 is not set
CONFIG_AD5755=m
# CONFIG_AD5761 is not set
# CONFIG_AD5764 is not set
CONFIG_AD5791=m
CONFIG_AD7303=m
CONFIG_CIO_DAC=m
CONFIG_AD8801=m
CONFIG_DPOT_DAC=m
CONFIG_DS4424=m
CONFIG_M62332=m
CONFIG_MAX517=m
CONFIG_MAX5821=m
CONFIG_MCP4725=m
# CONFIG_MCP4922 is not set
CONFIG_TI_DAC082S085=m
CONFIG_VF610_DAC=m

#
# IIO dummy driver
#

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
# CONFIG_AD9523 is not set

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
CONFIG_ADF4350=m

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16080 is not set
CONFIG_ADIS16130=m
CONFIG_ADIS16136=m
CONFIG_ADIS16260=m
# CONFIG_ADXRS450 is not set
CONFIG_BMG160=m
CONFIG_BMG160_I2C=m
CONFIG_BMG160_SPI=m
CONFIG_MPU3050=m
CONFIG_MPU3050_I2C=m
CONFIG_IIO_ST_GYRO_3AXIS=m
CONFIG_IIO_ST_GYRO_I2C_3AXIS=m
CONFIG_IIO_ST_GYRO_SPI_3AXIS=m
CONFIG_ITG3200=m

#
# Health Sensors
#

#
# Heart Rate Monitors
#
CONFIG_AFE4403=m
# CONFIG_AFE4404 is not set
# CONFIG_MAX30100 is not set
CONFIG_MAX30102=m

#
# Humidity sensors
#
CONFIG_AM2315=m
CONFIG_DHT11=m
CONFIG_HDC100X=m
CONFIG_HTS221=m
CONFIG_HTS221_I2C=m
CONFIG_HTS221_SPI=m
CONFIG_HTU21=m
CONFIG_SI7005=m
CONFIG_SI7020=m

#
# Inertial measurement units
#
CONFIG_ADIS16400=m
# CONFIG_ADIS16480 is not set
# CONFIG_BMI160_I2C is not set
# CONFIG_BMI160_SPI is not set
CONFIG_KMX61=m
CONFIG_INV_MPU6050_IIO=m
# CONFIG_INV_MPU6050_I2C is not set
CONFIG_INV_MPU6050_SPI=m
CONFIG_IIO_ST_LSM6DSX=m
CONFIG_IIO_ST_LSM6DSX_I2C=m
CONFIG_IIO_ST_LSM6DSX_SPI=m
CONFIG_IIO_ADIS_LIB=m
CONFIG_IIO_ADIS_LIB_BUFFER=y

#
# Light sensors
#
# CONFIG_ACPI_ALS is not set
CONFIG_ADJD_S311=m
CONFIG_AL3320A=m
# CONFIG_APDS9300 is not set
# CONFIG_APDS9960 is not set
CONFIG_BH1750=m
CONFIG_BH1780=m
CONFIG_CM32181=m
CONFIG_CM3232=m
# CONFIG_CM3323 is not set
# CONFIG_CM3605 is not set
CONFIG_CM36651=m
CONFIG_IIO_CROS_EC_LIGHT_PROX=m
CONFIG_GP2AP020A00F=m
CONFIG_SENSORS_ISL29018=m
CONFIG_SENSORS_ISL29028=m
CONFIG_ISL29125=m
# CONFIG_JSA1212 is not set
CONFIG_RPR0521=m
CONFIG_SENSORS_LM3533=m
# CONFIG_LTR501 is not set
CONFIG_LV0104CS=m
CONFIG_MAX44000=m
CONFIG_OPT3001=m
CONFIG_PA12203001=m
CONFIG_SI1145=m
CONFIG_STK3310=m
# CONFIG_ST_UVIS25 is not set
CONFIG_TCS3414=m
CONFIG_TCS3472=m
# CONFIG_SENSORS_TSL2563 is not set
# CONFIG_TSL2583 is not set
# CONFIG_TSL4531 is not set
# CONFIG_US5182D is not set
CONFIG_VCNL4000=m
# CONFIG_VEML6070 is not set
# CONFIG_VL6180 is not set
CONFIG_ZOPT2201=m

#
# Magnetometer sensors
#
CONFIG_AK8974=m
CONFIG_AK8975=m
CONFIG_AK09911=m
# CONFIG_BMC150_MAGN_I2C is not set
# CONFIG_BMC150_MAGN_SPI is not set
# CONFIG_MAG3110 is not set
# CONFIG_MMC35240 is not set
CONFIG_IIO_ST_MAGN_3AXIS=m
CONFIG_IIO_ST_MAGN_I2C_3AXIS=m
CONFIG_IIO_ST_MAGN_SPI_3AXIS=m
CONFIG_SENSORS_HMC5843=m
CONFIG_SENSORS_HMC5843_I2C=m
CONFIG_SENSORS_HMC5843_SPI=m

#
# Multiplexers
#
# CONFIG_IIO_MUX is not set

#
# Inclinometer sensors
#

#
# Triggers - standalone
#
CONFIG_IIO_HRTIMER_TRIGGER=m
CONFIG_IIO_INTERRUPT_TRIGGER=m
CONFIG_IIO_TIGHTLOOP_TRIGGER=m
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Digital potentiometers
#
CONFIG_AD5272=m
# CONFIG_DS1803 is not set
# CONFIG_MAX5481 is not set
CONFIG_MAX5487=m
CONFIG_MCP4018=m
CONFIG_MCP4131=m
CONFIG_MCP4531=m
CONFIG_TPL0102=m

#
# Digital potentiostats
#
# CONFIG_LMP91000 is not set

#
# Pressure sensors
#
CONFIG_ABP060MG=m
CONFIG_BMP280=m
CONFIG_BMP280_I2C=m
CONFIG_BMP280_SPI=m
CONFIG_IIO_CROS_EC_BARO=m
CONFIG_HP03=m
CONFIG_MPL115=m
# CONFIG_MPL115_I2C is not set
CONFIG_MPL115_SPI=m
# CONFIG_MPL3115 is not set
# CONFIG_MS5611 is not set
CONFIG_MS5637=m
CONFIG_IIO_ST_PRESS=m
CONFIG_IIO_ST_PRESS_I2C=m
CONFIG_IIO_ST_PRESS_SPI=m
CONFIG_T5403=m
CONFIG_HP206C=m
# CONFIG_ZPA2326 is not set

#
# Lightning sensors
#
CONFIG_AS3935=m

#
# Proximity and distance sensors
#
CONFIG_LIDAR_LITE_V2=m
# CONFIG_RFD77402 is not set
# CONFIG_SRF04 is not set
# CONFIG_SX9500 is not set
# CONFIG_SRF08 is not set

#
# Temperature sensors
#
CONFIG_MAXIM_THERMOCOUPLE=m
CONFIG_MLX90614=m
CONFIG_MLX90632=m
CONFIG_TMP006=m
# CONFIG_TMP007 is not set
CONFIG_TSYS01=m
CONFIG_TSYS02D=m
CONFIG_NTB=y
CONFIG_NTB_AMD=m
CONFIG_NTB_IDT=y
# CONFIG_NTB_INTEL is not set
CONFIG_NTB_SWITCHTEC=m
# CONFIG_NTB_PINGPONG is not set
CONFIG_NTB_TOOL=y
CONFIG_NTB_PERF=m
CONFIG_NTB_TRANSPORT=m
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
# CONFIG_VME_CA91CX42 is not set
CONFIG_VME_TSI148=y
CONFIG_VME_FAKE=y

#
# VME Board Drivers
#
CONFIG_VMIVME_7805=m

#
# VME Device Drivers
#
# CONFIG_VME_USER is not set
# CONFIG_PWM is not set

#
# IRQ chip support
#
CONFIG_IRQCHIP=y
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=m
CONFIG_BOARD_TPCI200=m
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_RESET_TI_SYSCON is not set
CONFIG_FMC=y
CONFIG_FMC_FAKEDEV=m
CONFIG_FMC_TRIVIAL=m
CONFIG_FMC_WRITE_EEPROM=y
CONFIG_FMC_CHARDEV=m

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=y
CONFIG_PHY_PXA_28NM_USB2=y
# CONFIG_PHY_CPCAP_USB is not set
# CONFIG_PHY_MAPPHONE_MDM6600 is not set
# CONFIG_POWERCAP is not set
CONFIG_MCB=y
CONFIG_MCB_PCI=y
CONFIG_MCB_LPC=y

#
# Performance monitor support
#
# CONFIG_RAS is not set
CONFIG_THUNDERBOLT=m

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_DAX=y
CONFIG_DEV_DAX=y
CONFIG_NVMEM=y

#
# HW tracing support
#
CONFIG_STM=y
CONFIG_STM_DUMMY=m
# CONFIG_STM_SOURCE_CONSOLE is not set
CONFIG_STM_SOURCE_HEARTBEAT=y
CONFIG_INTEL_TH=y
# CONFIG_INTEL_TH_PCI is not set
# CONFIG_INTEL_TH_ACPI is not set
# CONFIG_INTEL_TH_GTH is not set
# CONFIG_INTEL_TH_STH is not set
CONFIG_INTEL_TH_MSU=y
# CONFIG_INTEL_TH_PTI is not set
CONFIG_INTEL_TH_DEBUG=y
CONFIG_FPGA=m
CONFIG_ALTERA_PR_IP_CORE=m
# CONFIG_ALTERA_PR_IP_CORE_PLAT is not set
CONFIG_FPGA_MGR_ALTERA_PS_SPI=m
CONFIG_FPGA_MGR_ALTERA_CVP=m
# CONFIG_FPGA_MGR_XILINX_SPI is not set
CONFIG_FPGA_MGR_ICE40_SPI=m
# CONFIG_FPGA_BRIDGE is not set
CONFIG_FSI=m
CONFIG_FSI_MASTER_GPIO=m
CONFIG_FSI_MASTER_HUB=m
# CONFIG_FSI_SCOM is not set
CONFIG_MULTIPLEXER=y

#
# Multiplexer drivers
#
CONFIG_MUX_ADG792A=y
CONFIG_MUX_GPIO=y
CONFIG_MUX_MMIO=m
CONFIG_PM_OPP=y
# CONFIG_UNISYS_VISORBUS is not set
CONFIG_SIOX=m
CONFIG_SIOX_BUS_GPIO=m
# CONFIG_SLIMBUS is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
# CONFIG_FIRMWARE_MEMMAP is not set
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_FW_CFG_SYSFS=y
CONFIG_FW_CFG_SYSFS_CMDLINE=y
CONFIG_GOOGLE_FIRMWARE=y
CONFIG_GOOGLE_COREBOOT_TABLE=m
# CONFIG_GOOGLE_COREBOOT_TABLE_ACPI is not set
CONFIG_GOOGLE_COREBOOT_TABLE_OF=m
CONFIG_GOOGLE_MEMCONSOLE=m
CONFIG_GOOGLE_MEMCONSOLE_COREBOOT=m
CONFIG_GOOGLE_VPD=m

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_EXPORTFS_BLOCK_OPS=y
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=m
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=m
CONFIG_QUOTACTL=y
CONFIG_AUTOFS4_FS=y
# CONFIG_FUSE_FS is not set
# CONFIG_OVERLAY_FS is not set

#
# Caches
#
CONFIG_FSCACHE=m
# CONFIG_FSCACHE_STATS is not set
# CONFIG_FSCACHE_HISTOGRAM is not set
CONFIG_FSCACHE_DEBUG=y
# CONFIG_FSCACHE_OBJECT_LIST is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
# CONFIG_HUGETLBFS is not set
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ORANGEFS_FS=m
CONFIG_ECRYPT_FS=y
CONFIG_ECRYPT_FS_MESSAGING=y
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
# CONFIG_JFFS2_FS_WRITEBUFFER is not set
CONFIG_JFFS2_SUMMARY=y
CONFIG_JFFS2_FS_XATTR=y
CONFIG_JFFS2_FS_POSIX_ACL=y
# CONFIG_JFFS2_FS_SECURITY is not set
# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
CONFIG_JFFS2_ZLIB=y
CONFIG_JFFS2_RTIME=y
CONFIG_UBIFS_FS=m
CONFIG_UBIFS_FS_ADVANCED_COMPR=y
CONFIG_UBIFS_FS_LZO=y
CONFIG_UBIFS_FS_ZLIB=y
CONFIG_UBIFS_ATIME_SUPPORT=y
CONFIG_UBIFS_FS_SECURITY=y
CONFIG_CRAMFS=m
CONFIG_CRAMFS_MTD=y
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
CONFIG_PSTORE_DEFLATE_COMPRESS=m
CONFIG_PSTORE_LZO_COMPRESS=y
CONFIG_PSTORE_LZ4_COMPRESS=m
CONFIG_PSTORE_LZ4HC_COMPRESS=y
CONFIG_PSTORE_842_COMPRESS=y
CONFIG_PSTORE_COMPRESS=y
# CONFIG_PSTORE_DEFLATE_COMPRESS_DEFAULT is not set
# CONFIG_PSTORE_LZO_COMPRESS_DEFAULT is not set
# CONFIG_PSTORE_LZ4_COMPRESS_DEFAULT is not set
# CONFIG_PSTORE_LZ4HC_COMPRESS_DEFAULT is not set
CONFIG_PSTORE_842_COMPRESS_DEFAULT=y
CONFIG_PSTORE_COMPRESS_DEFAULT="842"
# CONFIG_PSTORE_CONSOLE is not set
CONFIG_PSTORE_PMSG=y
CONFIG_PSTORE_RAM=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=m
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
# CONFIG_ROOT_NFS is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
# CONFIG_NFSD is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=m
CONFIG_RPCSEC_GSS_KRB5=m
# CONFIG_SUNRPC_DEBUG is not set
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=m
# CONFIG_CIFS_STATS is not set
# CONFIG_CIFS_WEAK_PW_HASH is not set
# CONFIG_CIFS_UPCALL is not set
# CONFIG_CIFS_XATTR is not set
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DEBUG_DUMP_KEYS is not set
# CONFIG_CIFS_DFS_UPCALL is not set
# CONFIG_CIFS_SMB311 is not set
# CONFIG_CIFS_FSCACHE is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
# CONFIG_9P_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
# CONFIG_NLS_UTF8 is not set
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_FRAME_POINTER=y
CONFIG_STACK_VALIDATION=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_PAGE_EXTENSION is not set
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_PAGE_POISONING=y
# CONFIG_PAGE_POISONING_NO_SANITY is not set
# CONFIG_PAGE_POISONING_ZERO is not set
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_VMACACHE=y
# CONFIG_DEBUG_VM_RB is not set
# CONFIG_DEBUG_VM_PGFLAGS is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_ARCH_HAS_KCOV=y
# CONFIG_KCOV is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_SOFTLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=1
CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
# CONFIG_HARDLOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
CONFIG_DEBUG_TIMEKEEPING=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_LOCKDEP=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_LOCK_TORTURE_TEST is not set
# CONFIG_WW_MUTEX_SELFTEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
CONFIG_WARN_ALL_UNSEEDED_RANDOM=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
CONFIG_DEBUG_SG=y
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
CONFIG_TORTURE_TEST=y
CONFIG_RCU_PERF_TEST=y
CONFIG_RCU_TORTURE_TEST=m
# CONFIG_RCU_TRACE is not set
CONFIG_RCU_EQS_DEBUG=y
CONFIG_DEBUG_WQ_FORCE_RR_CPU=y
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
CONFIG_FAIL_PAGE_ALLOC=y
# CONFIG_FAIL_FUTEX is not set
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
# CONFIG_LATENCYTOP is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
CONFIG_RUNTIME_TESTING_MENU=y
CONFIG_TEST_LIST_SORT=m
CONFIG_TEST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=m
CONFIG_INTERVAL_TREE_TEST=y
CONFIG_PERCPU_TEST=m
# CONFIG_ATOMIC64_SELFTEST is not set
CONFIG_TEST_HEXDUMP=y
CONFIG_TEST_STRING_HELPERS=m
CONFIG_TEST_KSTRTOX=m
CONFIG_TEST_PRINTF=m
CONFIG_TEST_BITMAP=m
# CONFIG_TEST_UUID is not set
CONFIG_TEST_RHASHTABLE=m
# CONFIG_TEST_HASH is not set
# CONFIG_TEST_LKM is not set
CONFIG_TEST_USER_COPY=m
# CONFIG_TEST_BPF is not set
CONFIG_FIND_BIT_BENCHMARK=y
CONFIG_TEST_FIRMWARE=y
# CONFIG_TEST_SYSCTL is not set
# CONFIG_TEST_UDELAY is not set
# CONFIG_TEST_STATIC_KEYS is not set
CONFIG_MEMTEST=y
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_X86_VERBOSE_BOOTUP=y
# CONFIG_EARLY_PRINTK is not set
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=m
# CONFIG_DEBUG_WX is not set
# CONFIG_DOUBLEFAULT is not set
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_ENTRY is not set
CONFIG_DEBUG_NMI_SELFTEST=y
CONFIG_X86_DEBUG_FPU=y
# CONFIG_PUNIT_ATOM_DEBUG is not set
# CONFIG_UNWINDER_ORC is not set
CONFIG_UNWINDER_FRAME_POINTER=y
# CONFIG_UNWINDER_GUESS is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
# CONFIG_BIG_KEYS is not set
CONFIG_TRUSTED_KEYS=m
# CONFIG_ENCRYPTED_KEYS is not set
# CONFIG_KEY_DH_OPERATIONS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_PAGE_TABLE_ISOLATION=y
# CONFIG_SECURITY_NETWORK_XFRM is not set
CONFIG_SECURITY_PATH=y
# CONFIG_FORTIFY_SOURCE is not set
CONFIG_STATIC_USERMODEHELPER=y
CONFIG_STATIC_USERMODEHELPER_PATH="/sbin/usermode-helper"
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_YAMA is not set
# CONFIG_INTEGRITY is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=y
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_DH=y
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=m
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=m
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=m
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=m
CONFIG_CRYPTO_CHACHA20POLY1305=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
# CONFIG_CRYPTO_CFB is not set
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
# CONFIG_CRYPTO_LRW is not set
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=m

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=m
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=m

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
# CONFIG_CRYPTO_CRC32 is not set
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=m
# CONFIG_CRYPTO_CRCT10DIF_PCLMUL is not set
CONFIG_CRYPTO_GHASH=m
CONFIG_CRYPTO_POLY1305=y
# CONFIG_CRYPTO_POLY1305_X86_64 is not set
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=m
CONFIG_CRYPTO_SHA1_SSSE3=m
CONFIG_CRYPTO_SHA256_SSSE3=y
# CONFIG_CRYPTO_SHA512_SSSE3 is not set
CONFIG_CRYPTO_SHA1_MB=m
CONFIG_CRYPTO_SHA256_MB=m
# CONFIG_CRYPTO_SHA512_MB is not set
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=m
CONFIG_CRYPTO_SHA3=y
CONFIG_CRYPTO_SM3=y
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_TI is not set
CONFIG_CRYPTO_AES_X86_64=m
# CONFIG_CRYPTO_AES_NI_INTEL is not set
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=m
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_DES3_EDE_X86_64=y
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_X86_64=m
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
CONFIG_CRYPTO_SM4=y
CONFIG_CRYPTO_SPECK=m
# CONFIG_CRYPTO_TEA is not set
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=m

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=m
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_842=y
CONFIG_CRYPTO_LZ4=m
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
# CONFIG_CRYPTO_USER_API_HASH is not set
CONFIG_CRYPTO_USER_API_SKCIPHER=m
CONFIG_CRYPTO_USER_API_RNG=y
CONFIG_CRYPTO_USER_API_AEAD=m
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_X509_CERTIFICATE_PARSER=y
# CONFIG_PKCS7_MESSAGE_PARSER is not set

#
# Certificates for signature checking
#
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
# CONFIG_SYSTEM_BLACKLIST_KEYRING is not set
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=m
CONFIG_CRC_T10DIF=m
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
CONFIG_CRC32_SLICEBY4=y
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC4=m
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=m
CONFIG_CRC8=y
CONFIG_RANDOM32_SELFTEST=y
CONFIG_842_COMPRESS=y
CONFIG_842_DECOMPRESS=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=m
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
# CONFIG_XZ_DEC_IA64 is not set
# CONFIG_XZ_DEC_ARM is not set
# CONFIG_XZ_DEC_ARMTHUMB is not set
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=m
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_BCH=m
CONFIG_BCH_CONST_PARAMS=y
CONFIG_INTERVAL_TREE=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_SGL_ALLOC=y
CONFIG_DMA_DIRECT_OPS=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=m
CONFIG_DDR=y
# CONFIG_IRQ_POLL is not set
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
# CONFIG_STRING_SELFTEST is not set

--g4n64py7ydqsqxql--
