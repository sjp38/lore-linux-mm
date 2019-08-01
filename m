Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D249EC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:08:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21A26206A3
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:08:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21A26206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B56908E0005; Thu,  1 Aug 2019 02:08:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B09FC8E0001; Thu,  1 Aug 2019 02:08:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E92F8E0005; Thu,  1 Aug 2019 02:08:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 193878E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 02:08:46 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i2so44976583pfe.1
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 23:08:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=0ojNDyz0TC1YoUuMXEegPwPTMg05pDzP6PYGDc7psgE=;
        b=djpvLXeHbe/NNkatrSW8d1KIhdfnDzqJujPgzMdT+e1YbD+uJwZnFbn2wxiDwdAOKA
         /965J0xSS6qZr0k+BkQsrBYCON0N6//cHXN25yjr3xHmPgtS9T0BUbaxnToYJTISAQ8f
         Z+iFJySLfBz8DfozG9Wy7jtMyEyLzMmm0ulZXMDiKt13o899qUpPnGiC5P9+Kjz9c8Fx
         tE+X1I+fkTMDKEMhWU0yQf7QnH2vEtRlc7qObW+YhWSAEpyWRk2vNJp7gIkvO3Nv8H0w
         VV7KSYAwn/AaqAM9TsNVTRdZd8th2yjsAMzpnwYnzDvO+t8+D86mATiAk/nCzLIcSXEY
         C3Tg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW5kLvmg6KUTYZ01unRAETXj0RLYwZ3JAr3AglgUfQg1J07H8lY
	VJ7o7lmZWO66QG2WEl/fZbWUI8Si0iMIexCUOFAwmIQJyAe6bhHi9BCJs58aiNVzFDh4+2doCxo
	jRDHMQj9pcJRnebnmZquEOlQbRyuDfK3D/S36SPvoQUOZqPKUlIGJ2PGkCwAtmLmpPQ==
X-Received: by 2002:a63:3407:: with SMTP id b7mr5448480pga.143.1564639725257;
        Wed, 31 Jul 2019 23:08:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw88SiUYRjDugLGj4GQwtPho/POCC448SB7inSVlzMBVmsk5sVLy+9Q5H99yE/2yDIRpCt1
X-Received: by 2002:a63:3407:: with SMTP id b7mr5448049pga.143.1564639718024;
        Wed, 31 Jul 2019 23:08:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564639718; cv=none;
        d=google.com; s=arc-20160816;
        b=I8ANkZBvUgJz+DsKjTE53FnoTDZ64NXB/uccVkmWdtBMtUKzG6zxN0UdsRawspZiVD
         km97cqvt1HIsdzzmc5taWqN9fbRobkvZu78V5eLRg/mv/i9WdVsHMCyEnp3OqiI0uVkJ
         CWsC10n4jUghAmV7eVbea6uQFWOSqP+etl3riPby8rMSgqhMlNaO9H13nbV5NN0dhP+w
         LPo2kv+URImbqXqH1eBW92kinTUx88eIaii+DMo9FHk1CQiroL6JNicCB7fcud0JTxg6
         Ce9UvWmE3AbrTUdA1vP0Ehqju7CYtthgU39xeiX7wbskhDYDkFrHiGgqRuGT/0lhF5v6
         aFTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-transfer-encoding:content-disposition
         :mime-version:message-id:subject:cc:to:from:date;
        bh=0ojNDyz0TC1YoUuMXEegPwPTMg05pDzP6PYGDc7psgE=;
        b=UixBV7Mwqhf8DqN2u6002zzQEOfPGua+CCr5wg8pLwVfvJpnt7ISPAJWtWSLJSYMMI
         LDTVyFzb9ilPShRQB7aQlXrJ9h5ch72+ELo9hsQXIvTjhHexz1kO1hp9zb5XTX2DeUAf
         FITMnwDrLAc6Nge6iDONNmm04fI2LNljhtK8mWRADet/kYrZ5f4BkZZMA3ryyizXkHW4
         5URe5n6eRCQh0Hp0O7pmokdJurZpvsiz5bhi8jTKXIrSPTohfoJbkJfbEolkkAiZ2dxd
         10tbLwPSi2jf9ZRQWbTMbDrkJ3Oz9j1cw+g+Mwp/gRU5OhpayCw1U44Rdz2XvLIv0gfx
         3dvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c25si35232315pgm.73.2019.07.31.23.08.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 23:08:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 31 Jul 2019 23:08:36 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,333,1559545200"; 
   d="gz'50?scan'50,208,50";a="163502134"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga007.jf.intel.com with ESMTP; 31 Jul 2019 23:08:33 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1ht4GO-0006rV-F1; Thu, 01 Aug 2019 14:08:32 +0800
Date: Thu, 1 Aug 2019 14:08:11 +0800
From: kbuild test robot <lkp@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Roman Gushchin <guro@fb.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Lu Shuaibing <shuaibinglu@126.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: [rgushchin:fix_stock_sync 128/139] htmldocs:
 drivers/gpu/drm/drm_dp_mst_topology.c:1594: warning: Function parameter or
 member 'connector' not described in 'drm_dp_mst_connector_late_register'
Message-ID: <201908011404.myZ0iQJG%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="di2bpyf2eo2esioq"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
X-Patchwork-Hint: ignore
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--di2bpyf2eo2esioq
Content-Type: text/plain; charset=unknown-8bit
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hi Andrew,

First bad commit (maybe != root cause):

tree:   https://github.com/rgushchin/linux.git fix_stock_sync
head:   77c1d66e244190589ac167eacbd3df0d4a15d53f
commit: 32c23264144055cd71160d785f9f04a7236451e8 [128/139] linux-next-git-rejects
reproduce: make htmldocs

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>

All warnings (new ones prefixed by >>):

   include/linux/skbuff.h:881: warning: Function parameter or member 'remcsum_offload' not described in 'sk_buff'
   include/linux/skbuff.h:881: warning: Function parameter or member 'sender_cpu' not described in 'sk_buff'
   include/linux/skbuff.h:881: warning: Function parameter or member 'reserved_tailroom' not described in 'sk_buff'
   include/linux/skbuff.h:881: warning: Function parameter or member 'inner_ipproto' not described in 'sk_buff'
   include/net/sock.h:233: warning: Function parameter or member 'skc_addrpair' not described in 'sock_common'
   include/net/sock.h:233: warning: Function parameter or member 'skc_portpair' not described in 'sock_common'
   include/net/sock.h:233: warning: Function parameter or member 'skc_ipv6only' not described in 'sock_common'
   include/net/sock.h:233: warning: Function parameter or member 'skc_net_refcnt' not described in 'sock_common'
   include/net/sock.h:233: warning: Function parameter or member 'skc_v6_daddr' not described in 'sock_common'
   include/net/sock.h:233: warning: Function parameter or member 'skc_v6_rcv_saddr' not described in 'sock_common'
   include/net/sock.h:233: warning: Function parameter or member 'skc_cookie' not described in 'sock_common'
   include/net/sock.h:233: warning: Function parameter or member 'skc_listener' not described in 'sock_common'
   include/net/sock.h:233: warning: Function parameter or member 'skc_tw_dr' not described in 'sock_common'
   include/net/sock.h:233: warning: Function parameter or member 'skc_rcv_wnd' not described in 'sock_common'
   include/net/sock.h:233: warning: Function parameter or member 'skc_tw_rcv_nxt' not described in 'sock_common'
   include/net/sock.h:515: warning: Function parameter or member 'sk_rx_skb_cache' not described in 'sock'
   include/net/sock.h:515: warning: Function parameter or member 'sk_wq_raw' not described in 'sock'
   include/net/sock.h:515: warning: Function parameter or member 'tcp_rtx_queue' not described in 'sock'
   include/net/sock.h:515: warning: Function parameter or member 'sk_tx_skb_cache' not described in 'sock'
   include/net/sock.h:515: warning: Function parameter or member 'sk_route_forced_caps' not described in 'sock'
   include/net/sock.h:515: warning: Function parameter or member 'sk_txtime_report_errors' not described in 'sock'
   include/net/sock.h:515: warning: Function parameter or member 'sk_validate_xmit_skb' not described in 'sock'
   include/net/sock.h:515: warning: Function parameter or member 'sk_bpf_storage' not described in 'sock'
   include/net/sock.h:2439: warning: Function parameter or member 'tcp_rx_skb_cache_key' not described in 'DECLARE_STATIC_KEY_FALSE'
   include/net/sock.h:2439: warning: Excess function parameter 'sk' description in 'DECLARE_STATIC_KEY_FALSE'
   include/net/sock.h:2439: warning: Excess function parameter 'skb' description in 'DECLARE_STATIC_KEY_FALSE'
   include/linux/netdevice.h:2040: warning: Function parameter or member 'gso_partial_features' not described in 'net_device'
   include/linux/netdevice.h:2040: warning: Function parameter or member 'l3mdev_ops' not described in 'net_device'
   include/linux/netdevice.h:2040: warning: Function parameter or member 'xfrmdev_ops' not described in 'net_device'
   include/linux/netdevice.h:2040: warning: Function parameter or member 'tlsdev_ops' not described in 'net_device'
   include/linux/netdevice.h:2040: warning: Function parameter or member 'name_assign_type' not described in 'net_device'
   include/linux/netdevice.h:2040: warning: Function parameter or member 'ieee802154_ptr' not described in 'net_device'
   include/linux/netdevice.h:2040: warning: Function parameter or member 'mpls_ptr' not described in 'net_device'
   include/linux/netdevice.h:2040: warning: Function parameter or member 'xdp_prog' not described in 'net_device'
   include/linux/netdevice.h:2040: warning: Function parameter or member 'gro_flush_timeout' not described in 'net_device'
   include/linux/netdevice.h:2040: warning: Function parameter or member 'nf_hooks_ingress' not described in 'net_device'
   include/linux/netdevice.h:2040: warning: Function parameter or member '____cacheline_aligned_in_smp' not described in 'net_device'
   include/linux/netdevice.h:2040: warning: Function parameter or member 'qdisc_hash' not described in 'net_device'
   include/linux/netdevice.h:2040: warning: Function parameter or member 'xps_cpus_map' not described in 'net_device'
   include/linux/netdevice.h:2040: warning: Function parameter or member 'xps_rxqs_map' not described in 'net_device'
   include/linux/phylink.h:56: warning: Function parameter or member '__ETHTOOL_DECLARE_LINK_MODE_MASK(advertising' not described in 'phylink_link_state'
   include/linux/phylink.h:56: warning: Function parameter or member '__ETHTOOL_DECLARE_LINK_MODE_MASK(lp_advertising' not described in 'phylink_link_state'
   drivers/net/phy/phylink.c:593: warning: Function parameter or member 'config' not described in 'phylink_create'
   drivers/net/phy/phylink.c:593: warning: Excess function parameter 'ndev' description in 'phylink_create'
   include/linux/lsm_hooks.h:1811: warning: Function parameter or member 'quotactl' not described in 'security_list_options'
   include/linux/lsm_hooks.h:1811: warning: Function parameter or member 'quota_on' not described in 'security_list_options'
   include/linux/lsm_hooks.h:1811: warning: Function parameter or member 'sb_free_mnt_opts' not described in 'security_list_options'
   include/linux/lsm_hooks.h:1811: warning: Function parameter or member 'sb_eat_lsm_opts' not described in 'security_list_options'
   include/linux/lsm_hooks.h:1811: warning: Function parameter or member 'sb_kern_mount' not described in 'security_list_options'
   include/linux/lsm_hooks.h:1811: warning: Function parameter or member 'sb_show_options' not described in 'security_list_options'
   include/linux/lsm_hooks.h:1811: warning: Function parameter or member 'sb_add_mnt_opt' not described in 'security_list_options'
   include/linux/lsm_hooks.h:1811: warning: Function parameter or member 'd_instantiate' not described in 'security_list_options'
   include/linux/lsm_hooks.h:1811: warning: Function parameter or member 'getprocattr' not described in 'security_list_options'
   include/linux/lsm_hooks.h:1811: warning: Function parameter or member 'setprocattr' not described in 'security_list_options'
   drivers/gpu/drm/amd/amdgpu/amdgpu_dma_buf.c:350: warning: Excess function parameter 'dev' description in 'amdgpu_gem_prime_export'
   drivers/gpu/drm/amd/amdgpu/amdgpu_dma_buf.c:351: warning: Excess function parameter 'dev' description in 'amdgpu_gem_prime_export'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:142: warning: Function parameter or member 'blockable' not described in 'amdgpu_mn_read_lock'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:347: warning: cannot understand function prototype: 'struct amdgpu_vm_pt_cursor '
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:348: warning: cannot understand function prototype: 'struct amdgpu_vm_pt_cursor '
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:494: warning: Function parameter or member 'start' not described in 'amdgpu_vm_pt_first_dfs'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:546: warning: Function parameter or member 'adev' not described in 'for_each_amdgpu_vm_pt_dfs_safe'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:546: warning: Function parameter or member 'vm' not described in 'for_each_amdgpu_vm_pt_dfs_safe'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:546: warning: Function parameter or member 'start' not described in 'for_each_amdgpu_vm_pt_dfs_safe'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:546: warning: Function parameter or member 'cursor' not described in 'for_each_amdgpu_vm_pt_dfs_safe'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:546: warning: Function parameter or member 'entry' not described in 'for_each_amdgpu_vm_pt_dfs_safe'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:823: warning: Function parameter or member 'level' not described in 'amdgpu_vm_bo_param'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1285: warning: Function parameter or member 'params' not described in 'amdgpu_vm_update_flags'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1285: warning: Function parameter or member 'bo' not described in 'amdgpu_vm_update_flags'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1285: warning: Function parameter or member 'level' not described in 'amdgpu_vm_update_flags'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1285: warning: Function parameter or member 'pe' not described in 'amdgpu_vm_update_flags'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1285: warning: Function parameter or member 'addr' not described in 'amdgpu_vm_update_flags'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1285: warning: Function parameter or member 'count' not described in 'amdgpu_vm_update_flags'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1285: warning: Function parameter or member 'incr' not described in 'amdgpu_vm_update_flags'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1285: warning: Function parameter or member 'flags' not described in 'amdgpu_vm_update_flags'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:2822: warning: Function parameter or member 'pasid' not described in 'amdgpu_vm_make_compute'
   drivers/gpu/drm/amd/amdgpu/amdgpu_irq.c:378: warning: Excess function parameter 'entry' description in 'amdgpu_irq_dispatch'
   drivers/gpu/drm/amd/amdgpu/amdgpu_irq.c:379: warning: Function parameter or member 'ih' not described in 'amdgpu_irq_dispatch'
   drivers/gpu/drm/amd/amdgpu/amdgpu_irq.c:379: warning: Excess function parameter 'entry' description in 'amdgpu_irq_dispatch'
   drivers/gpu/drm/amd/amdgpu/amdgpu_xgmi.c:1: warning: no structured comments found
   drivers/gpu/drm/amd/amdgpu/amdgpu_ras.c:1: warning: no structured comments found
   drivers/gpu/drm/amd/amdgpu/amdgpu_pm.c:1: warning: 'pp_dpm_sclk pp_dpm_mclk pp_dpm_pcie' not found
   drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.h:132: warning: Incorrect use of kernel-doc format: Documentation Makefile include scripts source @atomic_obj
   drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.h:238: warning: Incorrect use of kernel-doc format: Documentation Makefile include scripts source gpu_info FW provided soc bounding box struct or 0 if not
   drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.h:243: warning: Function parameter or member 'atomic_obj' not described in 'amdgpu_display_manager'
   drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.h:243: warning: Function parameter or member 'backlight_link' not described in 'amdgpu_display_manager'
   drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.h:243: warning: Function parameter or member 'backlight_caps' not described in 'amdgpu_display_manager'
   drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.h:243: warning: Function parameter or member 'freesync_module' not described in 'amdgpu_display_manager'
   drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.h:243: warning: Function parameter or member 'fw_dmcu' not described in 'amdgpu_display_manager'
   drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.h:243: warning: Function parameter or member 'dmcu_fw_version' not described in 'amdgpu_display_manager'
   drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.h:243: warning: Function parameter or member 'soc_bounding_box' not described in 'amdgpu_display_manager'
   drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.c:1: warning: 'dm_crtc_high_irq' not found
   drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.c:1: warning: 'dm_pflip_high_irq' not found
   drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.c:1: warning: 'register_hpd_handlers' not found
   include/drm/drm_modeset_helper_vtables.h:1053: warning: Function parameter or member 'prepare_writeback_job' not described in 'drm_connector_helper_funcs'
   include/drm/drm_modeset_helper_vtables.h:1053: warning: Function parameter or member 'cleanup_writeback_job' not described in 'drm_connector_helper_funcs'
   include/drm/drm_atomic_state_helper.h:1: warning: no structured comments found
   drivers/gpu/drm/drm_dp_mst_topology.c:1593: warning: Excess function parameter 'drm_connector' description in 'drm_dp_mst_connector_late_register'
   drivers/gpu/drm/drm_dp_mst_topology.c:1613: warning: Excess function parameter 'drm_connector' description in 'drm_dp_mst_connector_early_unregister'
   drivers/gpu/drm/drm_dp_mst_topology.c:1593: warning: Excess function parameter 'drm_connector' description in 'drm_dp_mst_connector_late_register'
   drivers/gpu/drm/drm_dp_mst_topology.c:1613: warning: Excess function parameter 'drm_connector' description in 'drm_dp_mst_connector_early_unregister'
>> drivers/gpu/drm/drm_dp_mst_topology.c:1594: warning: Function parameter or member 'connector' not described in 'drm_dp_mst_connector_late_register'
   drivers/gpu/drm/drm_dp_mst_topology.c:1594: warning: Excess function parameter 'drm_connector' description in 'drm_dp_mst_connector_late_register'
>> drivers/gpu/drm/drm_dp_mst_topology.c:1614: warning: Function parameter or member 'connector' not described in 'drm_dp_mst_connector_early_unregister'
   drivers/gpu/drm/drm_dp_mst_topology.c:1614: warning: Excess function parameter 'drm_connector' description in 'drm_dp_mst_connector_early_unregister'
   drivers/gpu/drm/drm_dp_mst_topology.c:1593: warning: Excess function parameter 'drm_connector' description in 'drm_dp_mst_connector_late_register'
   drivers/gpu/drm/drm_dp_mst_topology.c:1613: warning: Excess function parameter 'drm_connector' description in 'drm_dp_mst_connector_early_unregister'
   drivers/gpu/drm/i915/display/intel_dpll_mgr.h:158: warning: Enum value 'DPLL_ID_TGL_MGPLL5' not described in enum 'intel_dpll_id'
   drivers/gpu/drm/i915/display/intel_dpll_mgr.h:158: warning: Enum value 'DPLL_ID_TGL_MGPLL6' not described in enum 'intel_dpll_id'
   drivers/gpu/drm/i915/display/intel_dpll_mgr.h:158: warning: Excess enum value 'DPLL_ID_TGL_TCPLL6' description in 'intel_dpll_id'
   drivers/gpu/drm/i915/display/intel_dpll_mgr.h:158: warning: Excess enum value 'DPLL_ID_TGL_TCPLL5' description in 'intel_dpll_id'
   drivers/gpu/drm/i915/display/intel_dpll_mgr.h:342: warning: Function parameter or member 'wakeref' not described in 'intel_shared_dpll'
   include/net/cfg80211.h:1092: warning: Function parameter or member 'txpwr' not described in 'station_parameters'
   include/net/mac80211.h:4043: warning: Function parameter or member 'sta_set_txpwr' not described in 'ieee80211_ops'
   include/net/mac80211.h:2006: warning: Function parameter or member 'txpwr' not described in 'ieee80211_sta'
   Documentation/admin-guide/xfs.rst:257: WARNING: Block quote ends without a blank line; unexpected unindent.
   Documentation/admin-guide/sysctl/kernel.rst:397: WARNING: Title underline too short.

vim +1594 drivers/gpu/drm/drm_dp_mst_topology.c

ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1579  
3dfd9a885fbb869 Andrew Morton        2019-07-27  1580  /**
3dfd9a885fbb869 Andrew Morton        2019-07-27  1581   * drm_dp_mst_connector_late_register() - Late MST connector registration
3dfd9a885fbb869 Andrew Morton        2019-07-27  1582   * @drm_connector: The MST connector
3dfd9a885fbb869 Andrew Morton        2019-07-27  1583   * @port: The MST port for this connector
3dfd9a885fbb869 Andrew Morton        2019-07-27  1584   *
3dfd9a885fbb869 Andrew Morton        2019-07-27  1585   * Helper to register the remote aux device for this MST port. Drivers should
3dfd9a885fbb869 Andrew Morton        2019-07-27  1586   * call this from their mst connector's late_register hook to enable MST aux
3dfd9a885fbb869 Andrew Morton        2019-07-27  1587   * devices.
3dfd9a885fbb869 Andrew Morton        2019-07-27  1588   *
3dfd9a885fbb869 Andrew Morton        2019-07-27  1589   * Return: 0 on success, negative error code on failure.
3dfd9a885fbb869 Andrew Morton        2019-07-27  1590   */
3dfd9a885fbb869 Andrew Morton        2019-07-27  1591  int drm_dp_mst_connector_late_register(struct drm_connector *connector,
3dfd9a885fbb869 Andrew Morton        2019-07-27  1592  				       struct drm_dp_mst_port *port)
3dfd9a885fbb869 Andrew Morton        2019-07-27 @1593  {
3dfd9a885fbb869 Andrew Morton        2019-07-27 @1594  	DRM_DEBUG_KMS("registering %s remote bus for %s\n",
3dfd9a885fbb869 Andrew Morton        2019-07-27  1595  		      port->aux.name, connector->kdev->kobj.name);
3dfd9a885fbb869 Andrew Morton        2019-07-27  1596  
3dfd9a885fbb869 Andrew Morton        2019-07-27  1597  	port->aux.dev = connector->kdev;
3dfd9a885fbb869 Andrew Morton        2019-07-27  1598  	return drm_dp_aux_register_devnode(&port->aux);
3dfd9a885fbb869 Andrew Morton        2019-07-27  1599  }
3dfd9a885fbb869 Andrew Morton        2019-07-27  1600  EXPORT_SYMBOL(drm_dp_mst_connector_late_register);
3dfd9a885fbb869 Andrew Morton        2019-07-27  1601  
3dfd9a885fbb869 Andrew Morton        2019-07-27  1602  /**
3dfd9a885fbb869 Andrew Morton        2019-07-27  1603   * drm_dp_mst_connector_early_unregister() - Early MST connector unregistration
3dfd9a885fbb869 Andrew Morton        2019-07-27  1604   * @drm_connector: The MST connector
3dfd9a885fbb869 Andrew Morton        2019-07-27  1605   * @port: The MST port for this connector
3dfd9a885fbb869 Andrew Morton        2019-07-27  1606   *
3dfd9a885fbb869 Andrew Morton        2019-07-27  1607   * Helper to unregister the remote aux device for this MST port, registered by
3dfd9a885fbb869 Andrew Morton        2019-07-27  1608   * drm_dp_mst_connector_late_register(). Drivers should call this from their mst
3dfd9a885fbb869 Andrew Morton        2019-07-27  1609   * connector's early_unregister hook.
3dfd9a885fbb869 Andrew Morton        2019-07-27  1610   */
3dfd9a885fbb869 Andrew Morton        2019-07-27  1611  void drm_dp_mst_connector_early_unregister(struct drm_connector *connector,
3dfd9a885fbb869 Andrew Morton        2019-07-27  1612  					   struct drm_dp_mst_port *port)
3dfd9a885fbb869 Andrew Morton        2019-07-27  1613  {
3dfd9a885fbb869 Andrew Morton        2019-07-27 @1614  	DRM_DEBUG_KMS("unregistering %s remote bus for %s\n",
3dfd9a885fbb869 Andrew Morton        2019-07-27  1615  		      port->aux.name, connector->kdev->kobj.name);
3dfd9a885fbb869 Andrew Morton        2019-07-27  1616  	drm_dp_aux_unregister_devnode(&port->aux);
3dfd9a885fbb869 Andrew Morton        2019-07-27  1617  }
3dfd9a885fbb869 Andrew Morton        2019-07-27  1618  EXPORT_SYMBOL(drm_dp_mst_connector_early_unregister);
3dfd9a885fbb869 Andrew Morton        2019-07-27  1619  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1620  static void drm_dp_add_port(struct drm_dp_mst_branch *mstb,
7b0a89a6db9a591 Dhinakaran Pandiyan  2017-01-24  1621  			    struct drm_device *dev,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1622  			    struct drm_dp_link_addr_reply_port *port_msg)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1623  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1624  	struct drm_dp_mst_port *port;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1625  	bool ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1626  	bool created = false;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1627  	int old_pdt = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1628  	int old_ddps = 0;
ebcc0e6b509108b Lyude Paul           2019-01-10  1629  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1630  	port = drm_dp_get_port(mstb, port_msg->port_number);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1631  	if (!port) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1632  		port = kzalloc(sizeof(*port), GFP_KERNEL);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1633  		if (!port)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1634  			return;
ebcc0e6b509108b Lyude Paul           2019-01-10  1635  		kref_init(&port->topology_kref);
ebcc0e6b509108b Lyude Paul           2019-01-10  1636  		kref_init(&port->malloc_kref);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1637  		port->parent = mstb;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1638  		port->port_num = port_msg->port_number;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1639  		port->mgr = mstb->mgr;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1640  		port->aux.name = "DPMST";
7b0a89a6db9a591 Dhinakaran Pandiyan  2017-01-24  1641  		port->aux.dev = dev->dev;
3dfd9a885fbb869 Andrew Morton        2019-07-27  1642  		port->aux.is_remote = true;
ebcc0e6b509108b Lyude Paul           2019-01-10  1643  
ebcc0e6b509108b Lyude Paul           2019-01-10  1644  		/*
ebcc0e6b509108b Lyude Paul           2019-01-10  1645  		 * Make sure the memory allocation for our parent branch stays
ebcc0e6b509108b Lyude Paul           2019-01-10  1646  		 * around until our own memory allocation is released
ebcc0e6b509108b Lyude Paul           2019-01-10  1647  		 */
ebcc0e6b509108b Lyude Paul           2019-01-10  1648  		drm_dp_mst_get_mstb_malloc(mstb);
ebcc0e6b509108b Lyude Paul           2019-01-10  1649  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1650  		created = true;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1651  	} else {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1652  		old_pdt = port->pdt;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1653  		old_ddps = port->ddps;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1654  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1655  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1656  	port->pdt = port_msg->peer_device_type;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1657  	port->input = port_msg->input_port;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1658  	port->mcs = port_msg->mcs;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1659  	port->ddps = port_msg->ddps;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1660  	port->ldps = port_msg->legacy_device_plug_status;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1661  	port->dpcd_rev = port_msg->dpcd_revision;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1662  	port->num_sdp_streams = port_msg->num_sdp_streams;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1663  	port->num_sdp_stream_sinks = port_msg->num_sdp_stream_sinks;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1664  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1665  	/* manage mstb port lists with mgr lock - take a reference
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1666  	   for this list */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1667  	if (created) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1668  		mutex_lock(&mstb->mgr->lock);
ebcc0e6b509108b Lyude Paul           2019-01-10  1669  		drm_dp_mst_topology_get_port(port);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1670  		list_add(&port->next, &mstb->ports);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1671  		mutex_unlock(&mstb->mgr->lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1672  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1673  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1674  	if (old_ddps != port->ddps) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1675  		if (port->ddps) {
3d76df632d7f4eb Lyude Paul           2019-01-10  1676  			if (!port->input) {
3d76df632d7f4eb Lyude Paul           2019-01-10  1677  				drm_dp_send_enum_path_resources(mstb->mgr,
3d76df632d7f4eb Lyude Paul           2019-01-10  1678  								mstb, port);
3d76df632d7f4eb Lyude Paul           2019-01-10  1679  			}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1680  		} else {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1681  			port->available_pbn = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1682  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1683  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1684  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1685  	if (old_pdt != port->pdt && !port->input) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1686  		drm_dp_port_teardown_pdt(port, old_pdt);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1687  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1688  		ret = drm_dp_port_setup_pdt(port);
68d8c9fc91a0f63 Dave Airlie          2015-09-06  1689  		if (ret == true)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1690  			drm_dp_send_link_address(mstb->mgr, port->mstb);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1691  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1692  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1693  	if (created && !port->input) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1694  		char proppath[255];
1c960876be7cffd Dave Airlie          2015-09-16  1695  
3d76df632d7f4eb Lyude Paul           2019-01-10  1696  		build_mst_prop_path(mstb, port->port_num, proppath,
3d76df632d7f4eb Lyude Paul           2019-01-10  1697  				    sizeof(proppath));
3d76df632d7f4eb Lyude Paul           2019-01-10  1698  		port->connector = (*mstb->mgr->cbs->add_connector)(mstb->mgr,
3d76df632d7f4eb Lyude Paul           2019-01-10  1699  								   port,
3d76df632d7f4eb Lyude Paul           2019-01-10  1700  								   proppath);
df4839fdc9b3c92 Dave Airlie          2015-09-16  1701  		if (!port->connector) {
df4839fdc9b3c92 Dave Airlie          2015-09-16  1702  			/* remove it from the port list */
df4839fdc9b3c92 Dave Airlie          2015-09-16  1703  			mutex_lock(&mstb->mgr->lock);
df4839fdc9b3c92 Dave Airlie          2015-09-16  1704  			list_del(&port->next);
df4839fdc9b3c92 Dave Airlie          2015-09-16  1705  			mutex_unlock(&mstb->mgr->lock);
df4839fdc9b3c92 Dave Airlie          2015-09-16  1706  			/* drop port list reference */
d0757afd00d71dc Lyude Paul           2019-01-10  1707  			drm_dp_mst_topology_put_port(port);
df4839fdc9b3c92 Dave Airlie          2015-09-16  1708  			goto out;
df4839fdc9b3c92 Dave Airlie          2015-09-16  1709  		}
4da5caa6a6f82cd Ville Syrjälä        2016-10-26  1710  		if ((port->pdt == DP_PEER_DEVICE_DP_LEGACY_CONV ||
4da5caa6a6f82cd Ville Syrjälä        2016-10-26  1711  		     port->pdt == DP_PEER_DEVICE_SST_SINK) &&
4da5caa6a6f82cd Ville Syrjälä        2016-10-26  1712  		    port->port_num >= DP_MST_LOGICAL_PORT_0) {
3d76df632d7f4eb Lyude Paul           2019-01-10  1713  			port->cached_edid = drm_get_edid(port->connector,
3d76df632d7f4eb Lyude Paul           2019-01-10  1714  							 &port->aux.ddc);
97e14fbeb53fe06 Daniel Vetter        2018-07-09  1715  			drm_connector_set_tile_property(port->connector);
8ae22cb419ad0ba Dave Airlie          2016-02-17  1716  		}
d9515c5ec1a20c7 Dave Airlie          2015-09-16  1717  		(*mstb->mgr->cbs->register_connector)(port->connector);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1718  	}
8ae22cb419ad0ba Dave Airlie          2016-02-17  1719  
df4839fdc9b3c92 Dave Airlie          2015-09-16  1720  out:
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1721  	/* put reference to this port */
d0757afd00d71dc Lyude Paul           2019-01-10  1722  	drm_dp_mst_topology_put_port(port);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1723  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1724  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1725  static void drm_dp_update_port(struct drm_dp_mst_branch *mstb,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1726  			       struct drm_dp_connection_status_notify *conn_stat)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1727  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1728  	struct drm_dp_mst_port *port;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1729  	int old_pdt;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1730  	int old_ddps;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1731  	bool dowork = false;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1732  	port = drm_dp_get_port(mstb, conn_stat->port_number);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1733  	if (!port)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1734  		return;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1735  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1736  	old_ddps = port->ddps;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1737  	old_pdt = port->pdt;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1738  	port->pdt = conn_stat->peer_device_type;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1739  	port->mcs = conn_stat->message_capability_status;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1740  	port->ldps = conn_stat->legacy_device_plug_status;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1741  	port->ddps = conn_stat->displayport_device_plug_status;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1742  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1743  	if (old_ddps != port->ddps) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1744  		if (port->ddps) {
8ae22cb419ad0ba Dave Airlie          2016-02-17  1745  			dowork = true;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1746  		} else {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1747  			port->available_pbn = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1748  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1749  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1750  	if (old_pdt != port->pdt && !port->input) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1751  		drm_dp_port_teardown_pdt(port, old_pdt);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1752  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1753  		if (drm_dp_port_setup_pdt(port))
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1754  			dowork = true;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1755  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1756  
d0757afd00d71dc Lyude Paul           2019-01-10  1757  	drm_dp_mst_topology_put_port(port);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1758  	if (dowork)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1759  		queue_work(system_long_wq, &mstb->mgr->work);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1760  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1761  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1762  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1763  static struct drm_dp_mst_branch *drm_dp_get_mst_branch_device(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1764  							       u8 lct, u8 *rad)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1765  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1766  	struct drm_dp_mst_branch *mstb;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1767  	struct drm_dp_mst_port *port;
ebcc0e6b509108b Lyude Paul           2019-01-10  1768  	int i, ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1769  	/* find the port by iterating down */
9eb1e57f564d4e6 Dave Airlie          2015-06-22  1770  
9eb1e57f564d4e6 Dave Airlie          2015-06-22  1771  	mutex_lock(&mgr->lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1772  	mstb = mgr->mst_primary;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1773  
23d8003907d094f Stanislav Lisovskiy  2018-11-09  1774  	if (!mstb)
23d8003907d094f Stanislav Lisovskiy  2018-11-09  1775  		goto out;
23d8003907d094f Stanislav Lisovskiy  2018-11-09  1776  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1777  	for (i = 0; i < lct - 1; i++) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1778  		int shift = (i % 2) ? 0 : 4;
7a11a334aa6af4c Mykola Lysenko       2015-12-25  1779  		int port_num = (rad[i / 2] >> shift) & 0xf;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1780  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1781  		list_for_each_entry(port, &mstb->ports, next) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1782  			if (port->port_num == port_num) {
30730c7f5943b3b Adam Richter         2015-10-16  1783  				mstb = port->mstb;
30730c7f5943b3b Adam Richter         2015-10-16  1784  				if (!mstb) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1785  					DRM_ERROR("failed to lookup MSTB with lct %d, rad %02x\n", lct, rad[0]);
30730c7f5943b3b Adam Richter         2015-10-16  1786  					goto out;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1787  				}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1788  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1789  				break;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1790  			}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1791  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1792  	}
ebcc0e6b509108b Lyude Paul           2019-01-10  1793  	ret = drm_dp_mst_topology_try_get_mstb(mstb);
ebcc0e6b509108b Lyude Paul           2019-01-10  1794  	if (!ret)
ebcc0e6b509108b Lyude Paul           2019-01-10  1795  		mstb = NULL;
30730c7f5943b3b Adam Richter         2015-10-16  1796  out:
9eb1e57f564d4e6 Dave Airlie          2015-06-22  1797  	mutex_unlock(&mgr->lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1798  	return mstb;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1799  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1800  
bd9343208704fcc Mykola Lysenko       2015-12-18  1801  static struct drm_dp_mst_branch *get_mst_branch_device_by_guid_helper(
bd9343208704fcc Mykola Lysenko       2015-12-18  1802  	struct drm_dp_mst_branch *mstb,
bd9343208704fcc Mykola Lysenko       2015-12-18  1803  	uint8_t *guid)
bd9343208704fcc Mykola Lysenko       2015-12-18  1804  {
bd9343208704fcc Mykola Lysenko       2015-12-18  1805  	struct drm_dp_mst_branch *found_mstb;
bd9343208704fcc Mykola Lysenko       2015-12-18  1806  	struct drm_dp_mst_port *port;
bd9343208704fcc Mykola Lysenko       2015-12-18  1807  
5e93b8208d3c419 Hersen Wu            2016-01-22  1808  	if (memcmp(mstb->guid, guid, 16) == 0)
5e93b8208d3c419 Hersen Wu            2016-01-22  1809  		return mstb;
5e93b8208d3c419 Hersen Wu            2016-01-22  1810  
5e93b8208d3c419 Hersen Wu            2016-01-22  1811  
bd9343208704fcc Mykola Lysenko       2015-12-18  1812  	list_for_each_entry(port, &mstb->ports, next) {
bd9343208704fcc Mykola Lysenko       2015-12-18  1813  		if (!port->mstb)
bd9343208704fcc Mykola Lysenko       2015-12-18  1814  			continue;
bd9343208704fcc Mykola Lysenko       2015-12-18  1815  
bd9343208704fcc Mykola Lysenko       2015-12-18  1816  		found_mstb = get_mst_branch_device_by_guid_helper(port->mstb, guid);
bd9343208704fcc Mykola Lysenko       2015-12-18  1817  
bd9343208704fcc Mykola Lysenko       2015-12-18  1818  		if (found_mstb)
bd9343208704fcc Mykola Lysenko       2015-12-18  1819  			return found_mstb;
bd9343208704fcc Mykola Lysenko       2015-12-18  1820  	}
bd9343208704fcc Mykola Lysenko       2015-12-18  1821  
bd9343208704fcc Mykola Lysenko       2015-12-18  1822  	return NULL;
bd9343208704fcc Mykola Lysenko       2015-12-18  1823  }
bd9343208704fcc Mykola Lysenko       2015-12-18  1824  
de6d68182f22c67 Lyude Paul           2019-01-10  1825  static struct drm_dp_mst_branch *
de6d68182f22c67 Lyude Paul           2019-01-10  1826  drm_dp_get_mst_branch_device_by_guid(struct drm_dp_mst_topology_mgr *mgr,
bd9343208704fcc Mykola Lysenko       2015-12-18  1827  				     uint8_t *guid)
bd9343208704fcc Mykola Lysenko       2015-12-18  1828  {
bd9343208704fcc Mykola Lysenko       2015-12-18  1829  	struct drm_dp_mst_branch *mstb;
ebcc0e6b509108b Lyude Paul           2019-01-10  1830  	int ret;
bd9343208704fcc Mykola Lysenko       2015-12-18  1831  
bd9343208704fcc Mykola Lysenko       2015-12-18  1832  	/* find the port by iterating down */
bd9343208704fcc Mykola Lysenko       2015-12-18  1833  	mutex_lock(&mgr->lock);
bd9343208704fcc Mykola Lysenko       2015-12-18  1834  
bd9343208704fcc Mykola Lysenko       2015-12-18  1835  	mstb = get_mst_branch_device_by_guid_helper(mgr->mst_primary, guid);
ebcc0e6b509108b Lyude Paul           2019-01-10  1836  	if (mstb) {
ebcc0e6b509108b Lyude Paul           2019-01-10  1837  		ret = drm_dp_mst_topology_try_get_mstb(mstb);
ebcc0e6b509108b Lyude Paul           2019-01-10  1838  		if (!ret)
ebcc0e6b509108b Lyude Paul           2019-01-10  1839  			mstb = NULL;
ebcc0e6b509108b Lyude Paul           2019-01-10  1840  	}
bd9343208704fcc Mykola Lysenko       2015-12-18  1841  
bd9343208704fcc Mykola Lysenko       2015-12-18  1842  	mutex_unlock(&mgr->lock);
bd9343208704fcc Mykola Lysenko       2015-12-18  1843  	return mstb;
bd9343208704fcc Mykola Lysenko       2015-12-18  1844  }
bd9343208704fcc Mykola Lysenko       2015-12-18  1845  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1846  static void drm_dp_check_and_send_link_address(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1847  					       struct drm_dp_mst_branch *mstb)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1848  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1849  	struct drm_dp_mst_port *port;
9254ec496a1dbdd Daniel Vetter        2015-06-22  1850  	struct drm_dp_mst_branch *mstb_child;
68d8c9fc91a0f63 Dave Airlie          2015-09-06  1851  	if (!mstb->link_address_sent)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1852  		drm_dp_send_link_address(mgr, mstb);
68d8c9fc91a0f63 Dave Airlie          2015-09-06  1853  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1854  	list_for_each_entry(port, &mstb->ports, next) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1855  		if (port->input)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1856  			continue;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1857  
8ae22cb419ad0ba Dave Airlie          2016-02-17  1858  		if (!port->ddps)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1859  			continue;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1860  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1861  		if (!port->available_pbn)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1862  			drm_dp_send_enum_path_resources(mgr, mstb, port);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1863  
9254ec496a1dbdd Daniel Vetter        2015-06-22  1864  		if (port->mstb) {
d0757afd00d71dc Lyude Paul           2019-01-10  1865  			mstb_child = drm_dp_mst_topology_get_mstb_validated(
d0757afd00d71dc Lyude Paul           2019-01-10  1866  			    mgr, port->mstb);
9254ec496a1dbdd Daniel Vetter        2015-06-22  1867  			if (mstb_child) {
9254ec496a1dbdd Daniel Vetter        2015-06-22  1868  				drm_dp_check_and_send_link_address(mgr, mstb_child);
d0757afd00d71dc Lyude Paul           2019-01-10  1869  				drm_dp_mst_topology_put_mstb(mstb_child);
9254ec496a1dbdd Daniel Vetter        2015-06-22  1870  			}
9254ec496a1dbdd Daniel Vetter        2015-06-22  1871  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1872  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1873  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1874  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1875  static void drm_dp_mst_link_probe_work(struct work_struct *work)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1876  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1877  	struct drm_dp_mst_topology_mgr *mgr = container_of(work, struct drm_dp_mst_topology_mgr, work);
9254ec496a1dbdd Daniel Vetter        2015-06-22  1878  	struct drm_dp_mst_branch *mstb;
ebcc0e6b509108b Lyude Paul           2019-01-10  1879  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1880  
9254ec496a1dbdd Daniel Vetter        2015-06-22  1881  	mutex_lock(&mgr->lock);
9254ec496a1dbdd Daniel Vetter        2015-06-22  1882  	mstb = mgr->mst_primary;
9254ec496a1dbdd Daniel Vetter        2015-06-22  1883  	if (mstb) {
ebcc0e6b509108b Lyude Paul           2019-01-10  1884  		ret = drm_dp_mst_topology_try_get_mstb(mstb);
ebcc0e6b509108b Lyude Paul           2019-01-10  1885  		if (!ret)
ebcc0e6b509108b Lyude Paul           2019-01-10  1886  			mstb = NULL;
9254ec496a1dbdd Daniel Vetter        2015-06-22  1887  	}
9254ec496a1dbdd Daniel Vetter        2015-06-22  1888  	mutex_unlock(&mgr->lock);
9254ec496a1dbdd Daniel Vetter        2015-06-22  1889  	if (mstb) {
9254ec496a1dbdd Daniel Vetter        2015-06-22  1890  		drm_dp_check_and_send_link_address(mgr, mstb);
d0757afd00d71dc Lyude Paul           2019-01-10  1891  		drm_dp_mst_topology_put_mstb(mstb);
9254ec496a1dbdd Daniel Vetter        2015-06-22  1892  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1893  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1894  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1895  static bool drm_dp_validate_guid(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1896  				 u8 *guid)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1897  {
e38e12895022d71 Ville Syrjälä        2017-07-12  1898  	u64 salt;
e38e12895022d71 Ville Syrjälä        2017-07-12  1899  
e38e12895022d71 Ville Syrjälä        2017-07-12  1900  	if (memchr_inv(guid, 0, 16))
e38e12895022d71 Ville Syrjälä        2017-07-12  1901  		return true;
e38e12895022d71 Ville Syrjälä        2017-07-12  1902  
e38e12895022d71 Ville Syrjälä        2017-07-12  1903  	salt = get_jiffies_64();
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1904  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1905  	memcpy(&guid[0], &salt, sizeof(u64));
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1906  	memcpy(&guid[8], &salt, sizeof(u64));
e38e12895022d71 Ville Syrjälä        2017-07-12  1907  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1908  	return false;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1909  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1910  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1911  static int build_dpcd_read(struct drm_dp_sideband_msg_tx *msg, u8 port_num, u32 offset, u8 num_bytes)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1912  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1913  	struct drm_dp_sideband_msg_req_body req;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1914  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1915  	req.req_type = DP_REMOTE_DPCD_READ;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1916  	req.u.dpcd_read.port_number = port_num;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1917  	req.u.dpcd_read.dpcd_address = offset;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1918  	req.u.dpcd_read.num_bytes = num_bytes;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1919  	drm_dp_encode_sideband_req(&req, msg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1920  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1921  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1922  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1923  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1924  static int drm_dp_send_sideband_msg(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1925  				    bool up, u8 *msg, int len)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1926  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1927  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1928  	int regbase = up ? DP_SIDEBAND_MSG_UP_REP_BASE : DP_SIDEBAND_MSG_DOWN_REQ_BASE;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1929  	int tosend, total, offset;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1930  	int retries = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1931  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1932  retry:
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1933  	total = len;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1934  	offset = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1935  	do {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1936  		tosend = min3(mgr->max_dpcd_transaction_bytes, 16, total);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1937  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1938  		ret = drm_dp_dpcd_write(mgr->aux, regbase + offset,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1939  					&msg[offset],
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1940  					tosend);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1941  		if (ret != tosend) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1942  			if (ret == -EIO && retries < 5) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1943  				retries++;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1944  				goto retry;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1945  			}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1946  			DRM_DEBUG_KMS("failed to dpcd write %d %d\n", tosend, ret);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1947  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1948  			return -EIO;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1949  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1950  		offset += tosend;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1951  		total -= tosend;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1952  	} while (total > 0);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1953  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1954  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1955  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1956  static int set_hdr_from_dst_qlock(struct drm_dp_sideband_msg_hdr *hdr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1957  				  struct drm_dp_sideband_msg_tx *txmsg)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1958  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1959  	struct drm_dp_mst_branch *mstb = txmsg->dst;
bd9343208704fcc Mykola Lysenko       2015-12-18  1960  	u8 req_type;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1961  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1962  	/* both msg slots are full */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1963  	if (txmsg->seqno == -1) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1964  		if (mstb->tx_slots[0] && mstb->tx_slots[1]) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1965  			DRM_DEBUG_KMS("%s: failed to find slot\n", __func__);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1966  			return -EAGAIN;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1967  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1968  		if (mstb->tx_slots[0] == NULL && mstb->tx_slots[1] == NULL) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1969  			txmsg->seqno = mstb->last_seqno;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1970  			mstb->last_seqno ^= 1;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1971  		} else if (mstb->tx_slots[0] == NULL)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1972  			txmsg->seqno = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1973  		else
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1974  			txmsg->seqno = 1;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1975  		mstb->tx_slots[txmsg->seqno] = txmsg;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1976  	}
bd9343208704fcc Mykola Lysenko       2015-12-18  1977  
bd9343208704fcc Mykola Lysenko       2015-12-18  1978  	req_type = txmsg->msg[0] & 0x7f;
bd9343208704fcc Mykola Lysenko       2015-12-18  1979  	if (req_type == DP_CONNECTION_STATUS_NOTIFY ||
bd9343208704fcc Mykola Lysenko       2015-12-18  1980  		req_type == DP_RESOURCE_STATUS_NOTIFY)
bd9343208704fcc Mykola Lysenko       2015-12-18  1981  		hdr->broadcast = 1;
bd9343208704fcc Mykola Lysenko       2015-12-18  1982  	else
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1983  		hdr->broadcast = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1984  	hdr->path_msg = txmsg->path_msg;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1985  	hdr->lct = mstb->lct;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1986  	hdr->lcr = mstb->lct - 1;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1987  	if (mstb->lct > 1)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1988  		memcpy(hdr->rad, mstb->rad, mstb->lct / 2);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1989  	hdr->seqno = txmsg->seqno;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1990  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1991  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1992  /*
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1993   * process a single block of the next message in the sideband queue
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1994   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1995  static int process_single_tx_qlock(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1996  				   struct drm_dp_sideband_msg_tx *txmsg,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1997  				   bool up)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1998  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  1999  	u8 chunk[48];
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2000  	struct drm_dp_sideband_msg_hdr hdr;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2001  	int len, space, idx, tosend;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2002  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2003  
bf3719c04ee3322 Damien Lespiau       2014-07-14  2004  	memset(&hdr, 0, sizeof(struct drm_dp_sideband_msg_hdr));
bf3719c04ee3322 Damien Lespiau       2014-07-14  2005  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2006  	if (txmsg->state == DRM_DP_SIDEBAND_TX_QUEUED) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2007  		txmsg->seqno = -1;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2008  		txmsg->state = DRM_DP_SIDEBAND_TX_START_SEND;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2009  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2010  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2011  	/* make hdr from dst mst - for replies use seqno
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2012  	   otherwise assign one */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2013  	ret = set_hdr_from_dst_qlock(&hdr, txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2014  	if (ret < 0)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2015  		return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2016  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2017  	/* amount left to send in this message */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2018  	len = txmsg->cur_len - txmsg->cur_offset;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2019  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2020  	/* 48 - sideband msg size - 1 byte for data CRC, x header bytes */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2021  	space = 48 - 1 - drm_dp_calc_sb_hdr_size(&hdr);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2022  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2023  	tosend = min(len, space);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2024  	if (len == txmsg->cur_len)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2025  		hdr.somt = 1;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2026  	if (space >= len)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2027  		hdr.eomt = 1;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2028  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2029  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2030  	hdr.msg_len = tosend + 1;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2031  	drm_dp_encode_sideband_msg_hdr(&hdr, chunk, &idx);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2032  	memcpy(&chunk[idx], &txmsg->msg[txmsg->cur_offset], tosend);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2033  	/* add crc at end */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2034  	drm_dp_crc_sideband_chunk_req(&chunk[idx], tosend);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2035  	idx += tosend + 1;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2036  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2037  	ret = drm_dp_send_sideband_msg(mgr, up, chunk, idx);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2038  	if (ret) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2039  		DRM_DEBUG_KMS("sideband msg failed to send\n");
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2040  		return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2041  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2042  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2043  	txmsg->cur_offset += tosend;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2044  	if (txmsg->cur_offset == txmsg->cur_len) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2045  		txmsg->state = DRM_DP_SIDEBAND_TX_SENT;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2046  		return 1;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2047  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2048  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2049  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2050  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2051  static void process_single_down_tx_qlock(struct drm_dp_mst_topology_mgr *mgr)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2052  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2053  	struct drm_dp_sideband_msg_tx *txmsg;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2054  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2055  
cd961bb9eebb630 Daniel Vetter        2015-01-28  2056  	WARN_ON(!mutex_is_locked(&mgr->qlock));
cd961bb9eebb630 Daniel Vetter        2015-01-28  2057  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2058  	/* construct a chunk from the first msg in the tx_msg queue */
cb021a3eb6e9870 Daniel Vetter        2016-07-15  2059  	if (list_empty(&mgr->tx_msg_downq))
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2060  		return;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2061  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2062  	txmsg = list_first_entry(&mgr->tx_msg_downq, struct drm_dp_sideband_msg_tx, next);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2063  	ret = process_single_tx_qlock(mgr, txmsg, false);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2064  	if (ret == 1) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2065  		/* txmsg is sent it should be in the slots now */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2066  		list_del(&txmsg->next);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2067  	} else if (ret) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2068  		DRM_DEBUG_KMS("failed to send msg in q %d\n", ret);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2069  		list_del(&txmsg->next);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2070  		if (txmsg->seqno != -1)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2071  			txmsg->dst->tx_slots[txmsg->seqno] = NULL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2072  		txmsg->state = DRM_DP_SIDEBAND_TX_TIMEOUT;
68e989dc044346a Chris Wilson         2017-05-13  2073  		wake_up_all(&mgr->tx_waitq);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2074  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2075  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2076  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2077  /* called holding qlock */
1f16ee7fa13649f Mykola Lysenko       2015-12-18  2078  static void process_single_up_tx_qlock(struct drm_dp_mst_topology_mgr *mgr,
1f16ee7fa13649f Mykola Lysenko       2015-12-18  2079  				       struct drm_dp_sideband_msg_tx *txmsg)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2080  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2081  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2082  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2083  	/* construct a chunk from the first msg in the tx_msg queue */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2084  	ret = process_single_tx_qlock(mgr, txmsg, true);
1f16ee7fa13649f Mykola Lysenko       2015-12-18  2085  
1f16ee7fa13649f Mykola Lysenko       2015-12-18  2086  	if (ret != 1)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2087  		DRM_DEBUG_KMS("failed to send msg in q %d\n", ret);
1f16ee7fa13649f Mykola Lysenko       2015-12-18  2088  
d8fd3722207f154 Imre Deak            2019-05-24  2089  	if (txmsg->seqno != -1) {
d8fd3722207f154 Imre Deak            2019-05-24  2090  		WARN_ON((unsigned int)txmsg->seqno >
d8fd3722207f154 Imre Deak            2019-05-24  2091  			ARRAY_SIZE(txmsg->dst->tx_slots));
1f16ee7fa13649f Mykola Lysenko       2015-12-18  2092  		txmsg->dst->tx_slots[txmsg->seqno] = NULL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2093  	}
d8fd3722207f154 Imre Deak            2019-05-24  2094  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2095  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2096  static void drm_dp_queue_down_tx(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2097  				 struct drm_dp_sideband_msg_tx *txmsg)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2098  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2099  	mutex_lock(&mgr->qlock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2100  	list_add_tail(&txmsg->next, &mgr->tx_msg_downq);
cb021a3eb6e9870 Daniel Vetter        2016-07-15  2101  	if (list_is_singular(&mgr->tx_msg_downq))
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2102  		process_single_down_tx_qlock(mgr);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2103  	mutex_unlock(&mgr->qlock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2104  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2105  
68d8c9fc91a0f63 Dave Airlie          2015-09-06  2106  static void drm_dp_send_link_address(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2107  				     struct drm_dp_mst_branch *mstb)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2108  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2109  	int len;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2110  	struct drm_dp_sideband_msg_tx *txmsg;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2111  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2112  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2113  	txmsg = kzalloc(sizeof(*txmsg), GFP_KERNEL);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2114  	if (!txmsg)
68d8c9fc91a0f63 Dave Airlie          2015-09-06  2115  		return;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2116  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2117  	txmsg->dst = mstb;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2118  	len = build_link_address(txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2119  
68d8c9fc91a0f63 Dave Airlie          2015-09-06  2120  	mstb->link_address_sent = true;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2121  	drm_dp_queue_down_tx(mgr, txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2122  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2123  	ret = drm_dp_mst_wait_tx_reply(mstb, txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2124  	if (ret > 0) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2125  		int i;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2126  
45bbda1e35f4943 Ville Syrjälä        2019-01-22  2127  		if (txmsg->reply.reply_type == DP_SIDEBAND_REPLY_NAK) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2128  			DRM_DEBUG_KMS("link address nak received\n");
45bbda1e35f4943 Ville Syrjälä        2019-01-22  2129  		} else {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2130  			DRM_DEBUG_KMS("link address reply: %d\n", txmsg->reply.u.link_addr.nports);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2131  			for (i = 0; i < txmsg->reply.u.link_addr.nports; i++) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2132  				DRM_DEBUG_KMS("port %d: input %d, pdt: %d, pn: %d, dpcd_rev: %02x, mcs: %d, ddps: %d, ldps %d, sdp %d/%d\n", i,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2133  				       txmsg->reply.u.link_addr.ports[i].input_port,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2134  				       txmsg->reply.u.link_addr.ports[i].peer_device_type,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2135  				       txmsg->reply.u.link_addr.ports[i].port_number,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2136  				       txmsg->reply.u.link_addr.ports[i].dpcd_revision,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2137  				       txmsg->reply.u.link_addr.ports[i].mcs,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2138  				       txmsg->reply.u.link_addr.ports[i].ddps,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2139  				       txmsg->reply.u.link_addr.ports[i].legacy_device_plug_status,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2140  				       txmsg->reply.u.link_addr.ports[i].num_sdp_streams,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2141  				       txmsg->reply.u.link_addr.ports[i].num_sdp_stream_sinks);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2142  			}
5e93b8208d3c419 Hersen Wu            2016-01-22  2143  
5e93b8208d3c419 Hersen Wu            2016-01-22  2144  			drm_dp_check_mstb_guid(mstb, txmsg->reply.u.link_addr.guid);
5e93b8208d3c419 Hersen Wu            2016-01-22  2145  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2146  			for (i = 0; i < txmsg->reply.u.link_addr.nports; i++) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2147  				drm_dp_add_port(mstb, mgr->dev, &txmsg->reply.u.link_addr.ports[i]);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2148  			}
16bff572cc660f1 Daniel Vetter        2018-11-28  2149  			drm_kms_helper_hotplug_event(mgr->dev);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2150  		}
68d8c9fc91a0f63 Dave Airlie          2015-09-06  2151  	} else {
68d8c9fc91a0f63 Dave Airlie          2015-09-06  2152  		mstb->link_address_sent = false;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2153  		DRM_DEBUG_KMS("link address failed %d\n", ret);
68d8c9fc91a0f63 Dave Airlie          2015-09-06  2154  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2155  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2156  	kfree(txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2157  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2158  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2159  static int drm_dp_send_enum_path_resources(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2160  					   struct drm_dp_mst_branch *mstb,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2161  					   struct drm_dp_mst_port *port)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2162  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2163  	int len;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2164  	struct drm_dp_sideband_msg_tx *txmsg;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2165  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2166  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2167  	txmsg = kzalloc(sizeof(*txmsg), GFP_KERNEL);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2168  	if (!txmsg)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2169  		return -ENOMEM;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2170  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2171  	txmsg->dst = mstb;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2172  	len = build_enum_path_resources(txmsg, port->port_num);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2173  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2174  	drm_dp_queue_down_tx(mgr, txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2175  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2176  	ret = drm_dp_mst_wait_tx_reply(mstb, txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2177  	if (ret > 0) {
45bbda1e35f4943 Ville Syrjälä        2019-01-22  2178  		if (txmsg->reply.reply_type == DP_SIDEBAND_REPLY_NAK) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2179  			DRM_DEBUG_KMS("enum path resources nak received\n");
45bbda1e35f4943 Ville Syrjälä        2019-01-22  2180  		} else {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2181  			if (port->port_num != txmsg->reply.u.path_resources.port_number)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2182  				DRM_ERROR("got incorrect port in response\n");
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2183  			DRM_DEBUG_KMS("enum path resources %d: %d %d\n", txmsg->reply.u.path_resources.port_number, txmsg->reply.u.path_resources.full_payload_bw_number,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2184  			       txmsg->reply.u.path_resources.avail_payload_bw_number);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2185  			port->available_pbn = txmsg->reply.u.path_resources.avail_payload_bw_number;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2186  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2187  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2188  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2189  	kfree(txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2190  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2191  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2192  
91a25e463130c8e Mykola Lysenko       2016-01-27  2193  static struct drm_dp_mst_port *drm_dp_get_last_connected_port_to_mstb(struct drm_dp_mst_branch *mstb)
91a25e463130c8e Mykola Lysenko       2016-01-27  2194  {
91a25e463130c8e Mykola Lysenko       2016-01-27  2195  	if (!mstb->port_parent)
91a25e463130c8e Mykola Lysenko       2016-01-27  2196  		return NULL;
91a25e463130c8e Mykola Lysenko       2016-01-27  2197  
91a25e463130c8e Mykola Lysenko       2016-01-27  2198  	if (mstb->port_parent->mstb != mstb)
91a25e463130c8e Mykola Lysenko       2016-01-27  2199  		return mstb->port_parent;
91a25e463130c8e Mykola Lysenko       2016-01-27  2200  
91a25e463130c8e Mykola Lysenko       2016-01-27  2201  	return drm_dp_get_last_connected_port_to_mstb(mstb->port_parent->parent);
91a25e463130c8e Mykola Lysenko       2016-01-27  2202  }
91a25e463130c8e Mykola Lysenko       2016-01-27  2203  
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2204  /*
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2205   * Searches upwards in the topology starting from mstb to try to find the
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2206   * closest available parent of mstb that's still connected to the rest of the
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2207   * topology. This can be used in order to perform operations like releasing
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2208   * payloads, where the branch device which owned the payload may no longer be
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2209   * around and thus would require that the payload on the last living relative
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2210   * be freed instead.
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2211   */
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2212  static struct drm_dp_mst_branch *
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2213  drm_dp_get_last_connected_port_and_mstb(struct drm_dp_mst_topology_mgr *mgr,
91a25e463130c8e Mykola Lysenko       2016-01-27  2214  					struct drm_dp_mst_branch *mstb,
91a25e463130c8e Mykola Lysenko       2016-01-27  2215  					int *port_num)
91a25e463130c8e Mykola Lysenko       2016-01-27  2216  {
91a25e463130c8e Mykola Lysenko       2016-01-27  2217  	struct drm_dp_mst_branch *rmstb = NULL;
91a25e463130c8e Mykola Lysenko       2016-01-27  2218  	struct drm_dp_mst_port *found_port;
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2219  
91a25e463130c8e Mykola Lysenko       2016-01-27  2220  	mutex_lock(&mgr->lock);
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2221  	if (!mgr->mst_primary)
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2222  		goto out;
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2223  
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2224  	do {
91a25e463130c8e Mykola Lysenko       2016-01-27  2225  		found_port = drm_dp_get_last_connected_port_to_mstb(mstb);
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2226  		if (!found_port)
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2227  			break;
91a25e463130c8e Mykola Lysenko       2016-01-27  2228  
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2229  		if (drm_dp_mst_topology_try_get_mstb(found_port->parent)) {
91a25e463130c8e Mykola Lysenko       2016-01-27  2230  			rmstb = found_port->parent;
91a25e463130c8e Mykola Lysenko       2016-01-27  2231  			*port_num = found_port->port_num;
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2232  		} else {
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2233  			/* Search again, starting from this parent */
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2234  			mstb = found_port->parent;
91a25e463130c8e Mykola Lysenko       2016-01-27  2235  		}
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2236  	} while (!rmstb);
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2237  out:
91a25e463130c8e Mykola Lysenko       2016-01-27  2238  	mutex_unlock(&mgr->lock);
91a25e463130c8e Mykola Lysenko       2016-01-27  2239  	return rmstb;
91a25e463130c8e Mykola Lysenko       2016-01-27  2240  }
91a25e463130c8e Mykola Lysenko       2016-01-27  2241  
8fa6a4255e80537 Thierry Reding       2014-07-21  2242  static int drm_dp_payload_send_msg(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2243  				   struct drm_dp_mst_port *port,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2244  				   int id,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2245  				   int pbn)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2246  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2247  	struct drm_dp_sideband_msg_tx *txmsg;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2248  	struct drm_dp_mst_branch *mstb;
91a25e463130c8e Mykola Lysenko       2016-01-27  2249  	int len, ret, port_num;
ef8f9bea1368b89 Libin Yang           2015-12-02  2250  	u8 sinks[DRM_DP_MAX_SDP_STREAMS];
ef8f9bea1368b89 Libin Yang           2015-12-02  2251  	int i;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2252  
91a25e463130c8e Mykola Lysenko       2016-01-27  2253  	port_num = port->port_num;
d0757afd00d71dc Lyude Paul           2019-01-10  2254  	mstb = drm_dp_mst_topology_get_mstb_validated(mgr, port->parent);
91a25e463130c8e Mykola Lysenko       2016-01-27  2255  	if (!mstb) {
de6d68182f22c67 Lyude Paul           2019-01-10  2256  		mstb = drm_dp_get_last_connected_port_and_mstb(mgr,
de6d68182f22c67 Lyude Paul           2019-01-10  2257  							       port->parent,
de6d68182f22c67 Lyude Paul           2019-01-10  2258  							       &port_num);
91a25e463130c8e Mykola Lysenko       2016-01-27  2259  
cfe9f90358d97a8 Lyude Paul           2019-01-10  2260  		if (!mstb)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2261  			return -EINVAL;
91a25e463130c8e Mykola Lysenko       2016-01-27  2262  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2263  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2264  	txmsg = kzalloc(sizeof(*txmsg), GFP_KERNEL);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2265  	if (!txmsg) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2266  		ret = -ENOMEM;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2267  		goto fail_put;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2268  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2269  
ef8f9bea1368b89 Libin Yang           2015-12-02  2270  	for (i = 0; i < port->num_sdp_streams; i++)
ef8f9bea1368b89 Libin Yang           2015-12-02  2271  		sinks[i] = i;
ef8f9bea1368b89 Libin Yang           2015-12-02  2272  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2273  	txmsg->dst = mstb;
91a25e463130c8e Mykola Lysenko       2016-01-27  2274  	len = build_allocate_payload(txmsg, port_num,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2275  				     id,
ef8f9bea1368b89 Libin Yang           2015-12-02  2276  				     pbn, port->num_sdp_streams, sinks);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2277  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2278  	drm_dp_queue_down_tx(mgr, txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2279  
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2280  	/*
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2281  	 * FIXME: there is a small chance that between getting the last
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2282  	 * connected mstb and sending the payload message, the last connected
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2283  	 * mstb could also be removed from the topology. In the future, this
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2284  	 * needs to be fixed by restarting the
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2285  	 * drm_dp_get_last_connected_port_and_mstb() search in the event of a
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2286  	 * timeout if the topology is still connected to the system.
56d1c14ecfe81d5 Lyude Paul           2019-01-10  2287  	 */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2288  	ret = drm_dp_mst_wait_tx_reply(mstb, txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2289  	if (ret > 0) {
45bbda1e35f4943 Ville Syrjälä        2019-01-22  2290  		if (txmsg->reply.reply_type == DP_SIDEBAND_REPLY_NAK)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2291  			ret = -EINVAL;
de6d68182f22c67 Lyude Paul           2019-01-10  2292  		else
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2293  			ret = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2294  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2295  	kfree(txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2296  fail_put:
d0757afd00d71dc Lyude Paul           2019-01-10  2297  	drm_dp_mst_topology_put_mstb(mstb);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2298  	return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2299  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2300  
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2301  int drm_dp_send_power_updown_phy(struct drm_dp_mst_topology_mgr *mgr,
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2302  				 struct drm_dp_mst_port *port, bool power_up)
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2303  {
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2304  	struct drm_dp_sideband_msg_tx *txmsg;
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2305  	int len, ret;
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2306  
d0757afd00d71dc Lyude Paul           2019-01-10  2307  	port = drm_dp_mst_topology_get_port_validated(mgr, port);
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2308  	if (!port)
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2309  		return -EINVAL;
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2310  
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2311  	txmsg = kzalloc(sizeof(*txmsg), GFP_KERNEL);
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2312  	if (!txmsg) {
d0757afd00d71dc Lyude Paul           2019-01-10  2313  		drm_dp_mst_topology_put_port(port);
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2314  		return -ENOMEM;
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2315  	}
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2316  
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2317  	txmsg->dst = port->parent;
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2318  	len = build_power_updown_phy(txmsg, port->port_num, power_up);
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2319  	drm_dp_queue_down_tx(mgr, txmsg);
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2320  
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2321  	ret = drm_dp_mst_wait_tx_reply(port->parent, txmsg);
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2322  	if (ret > 0) {
45bbda1e35f4943 Ville Syrjälä        2019-01-22  2323  		if (txmsg->reply.reply_type == DP_SIDEBAND_REPLY_NAK)
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2324  			ret = -EINVAL;
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2325  		else
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2326  			ret = 0;
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2327  	}
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2328  	kfree(txmsg);
d0757afd00d71dc Lyude Paul           2019-01-10  2329  	drm_dp_mst_topology_put_port(port);
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2330  
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2331  	return ret;
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2332  }
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2333  EXPORT_SYMBOL(drm_dp_send_power_updown_phy);
0bb9c2b27f5e503 Dhinakaran Pandiyan  2017-09-06  2334  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2335  static int drm_dp_create_payload_step1(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2336  				       int id,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2337  				       struct drm_dp_payload *payload)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2338  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2339  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2340  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2341  	ret = drm_dp_dpcd_write_payload(mgr, id, payload);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2342  	if (ret < 0) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2343  		payload->payload_state = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2344  		return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2345  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2346  	payload->payload_state = DP_PAYLOAD_LOCAL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2347  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2348  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2349  
8fa6a4255e80537 Thierry Reding       2014-07-21  2350  static int drm_dp_create_payload_step2(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2351  				       struct drm_dp_mst_port *port,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2352  				       int id,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2353  				       struct drm_dp_payload *payload)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2354  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2355  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2356  	ret = drm_dp_payload_send_msg(mgr, port, id, port->vcpi.pbn);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2357  	if (ret < 0)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2358  		return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2359  	payload->payload_state = DP_PAYLOAD_REMOTE;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2360  	return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2361  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2362  
8fa6a4255e80537 Thierry Reding       2014-07-21  2363  static int drm_dp_destroy_payload_step1(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2364  					struct drm_dp_mst_port *port,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2365  					int id,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2366  					struct drm_dp_payload *payload)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2367  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2368  	DRM_DEBUG_KMS("\n");
1e55a53a28d3e52 Matt Roper           2019-02-01  2369  	/* it's okay for these to fail */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2370  	if (port) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2371  		drm_dp_payload_send_msg(mgr, port, id, 0);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2372  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2373  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2374  	drm_dp_dpcd_write_payload(mgr, id, payload);
dfda0df3426483c Dave Airlie          2014-08-06  2375  	payload->payload_state = DP_PAYLOAD_DELETE_LOCAL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2376  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2377  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2378  
8fa6a4255e80537 Thierry Reding       2014-07-21  2379  static int drm_dp_destroy_payload_step2(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2380  					int id,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2381  					struct drm_dp_payload *payload)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2382  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2383  	payload->payload_state = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2384  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2385  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2386  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2387  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2388   * drm_dp_update_payload_part1() - Execute payload update part 1
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2389   * @mgr: manager to use.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2390   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2391   * This iterates over all proposed virtual channels, and tries to
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2392   * allocate space in the link for them. For 0->slots transitions,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2393   * this step just writes the VCPI to the MST device. For slots->0
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2394   * transitions, this writes the updated VCPIs and removes the
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2395   * remote VC payloads.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2396   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2397   * after calling this the driver should generate ACT and payload
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2398   * packets.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2399   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2400  int drm_dp_update_payload_part1(struct drm_dp_mst_topology_mgr *mgr)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2401  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2402  	struct drm_dp_payload req_payload;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2403  	struct drm_dp_mst_port *port;
cfe9f90358d97a8 Lyude Paul           2019-01-10  2404  	int i, j;
cfe9f90358d97a8 Lyude Paul           2019-01-10  2405  	int cur_slots = 1;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2406  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2407  	mutex_lock(&mgr->payload_lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2408  	for (i = 0; i < mgr->max_payloads; i++) {
706246c761ddd39 Lyude Paul           2018-12-13  2409  		struct drm_dp_vcpi *vcpi = mgr->proposed_vcpis[i];
706246c761ddd39 Lyude Paul           2018-12-13  2410  		struct drm_dp_payload *payload = &mgr->payloads[i];
cfe9f90358d97a8 Lyude Paul           2019-01-10  2411  		bool put_port = false;
706246c761ddd39 Lyude Paul           2018-12-13  2412  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2413  		/* solve the current payloads - compare to the hw ones
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2414  		   - update the hw view */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2415  		req_payload.start_slot = cur_slots;
706246c761ddd39 Lyude Paul           2018-12-13  2416  		if (vcpi) {
706246c761ddd39 Lyude Paul           2018-12-13  2417  			port = container_of(vcpi, struct drm_dp_mst_port,
706246c761ddd39 Lyude Paul           2018-12-13  2418  					    vcpi);
cfe9f90358d97a8 Lyude Paul           2019-01-10  2419  
cfe9f90358d97a8 Lyude Paul           2019-01-10  2420  			/* Validated ports don't matter if we're releasing
cfe9f90358d97a8 Lyude Paul           2019-01-10  2421  			 * VCPI
cfe9f90358d97a8 Lyude Paul           2019-01-10  2422  			 */
cfe9f90358d97a8 Lyude Paul           2019-01-10  2423  			if (vcpi->num_slots) {
cfe9f90358d97a8 Lyude Paul           2019-01-10  2424  				port = drm_dp_mst_topology_get_port_validated(
cfe9f90358d97a8 Lyude Paul           2019-01-10  2425  				    mgr, port);
263efde31f97c49 cpaul@redhat.com     2016-04-22  2426  				if (!port) {
263efde31f97c49 cpaul@redhat.com     2016-04-22  2427  					mutex_unlock(&mgr->payload_lock);
263efde31f97c49 cpaul@redhat.com     2016-04-22  2428  					return -EINVAL;
263efde31f97c49 cpaul@redhat.com     2016-04-22  2429  				}
cfe9f90358d97a8 Lyude Paul           2019-01-10  2430  				put_port = true;
cfe9f90358d97a8 Lyude Paul           2019-01-10  2431  			}
cfe9f90358d97a8 Lyude Paul           2019-01-10  2432  
706246c761ddd39 Lyude Paul           2018-12-13  2433  			req_payload.num_slots = vcpi->num_slots;
706246c761ddd39 Lyude Paul           2018-12-13  2434  			req_payload.vcpi = vcpi->vcpi;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2435  		} else {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2436  			port = NULL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2437  			req_payload.num_slots = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2438  		}
dfda0df3426483c Dave Airlie          2014-08-06  2439  
706246c761ddd39 Lyude Paul           2018-12-13  2440  		payload->start_slot = req_payload.start_slot;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2441  		/* work out what is required to happen with this payload */
706246c761ddd39 Lyude Paul           2018-12-13  2442  		if (payload->num_slots != req_payload.num_slots) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2443  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2444  			/* need to push an update for this payload */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2445  			if (req_payload.num_slots) {
706246c761ddd39 Lyude Paul           2018-12-13  2446  				drm_dp_create_payload_step1(mgr, vcpi->vcpi,
706246c761ddd39 Lyude Paul           2018-12-13  2447  							    &req_payload);
706246c761ddd39 Lyude Paul           2018-12-13  2448  				payload->num_slots = req_payload.num_slots;
706246c761ddd39 Lyude Paul           2018-12-13  2449  				payload->vcpi = req_payload.vcpi;
706246c761ddd39 Lyude Paul           2018-12-13  2450  
706246c761ddd39 Lyude Paul           2018-12-13  2451  			} else if (payload->num_slots) {
706246c761ddd39 Lyude Paul           2018-12-13  2452  				payload->num_slots = 0;
706246c761ddd39 Lyude Paul           2018-12-13  2453  				drm_dp_destroy_payload_step1(mgr, port,
706246c761ddd39 Lyude Paul           2018-12-13  2454  							     payload->vcpi,
706246c761ddd39 Lyude Paul           2018-12-13  2455  							     payload);
706246c761ddd39 Lyude Paul           2018-12-13  2456  				req_payload.payload_state =
706246c761ddd39 Lyude Paul           2018-12-13  2457  					payload->payload_state;
706246c761ddd39 Lyude Paul           2018-12-13  2458  				payload->start_slot = 0;
706246c761ddd39 Lyude Paul           2018-12-13  2459  			}
706246c761ddd39 Lyude Paul           2018-12-13  2460  			payload->payload_state = req_payload.payload_state;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2461  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2462  		cur_slots += req_payload.num_slots;
263efde31f97c49 cpaul@redhat.com     2016-04-22  2463  
cfe9f90358d97a8 Lyude Paul           2019-01-10  2464  		if (put_port)
d0757afd00d71dc Lyude Paul           2019-01-10  2465  			drm_dp_mst_topology_put_port(port);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2466  	}
dfda0df3426483c Dave Airlie          2014-08-06  2467  
dfda0df3426483c Dave Airlie          2014-08-06  2468  	for (i = 0; i < mgr->max_payloads; i++) {
706246c761ddd39 Lyude Paul           2018-12-13  2469  		if (mgr->payloads[i].payload_state != DP_PAYLOAD_DELETE_LOCAL)
706246c761ddd39 Lyude Paul           2018-12-13  2470  			continue;
706246c761ddd39 Lyude Paul           2018-12-13  2471  
dfda0df3426483c Dave Airlie          2014-08-06  2472  		DRM_DEBUG_KMS("removing payload %d\n", i);
dfda0df3426483c Dave Airlie          2014-08-06  2473  		for (j = i; j < mgr->max_payloads - 1; j++) {
706246c761ddd39 Lyude Paul           2018-12-13  2474  			mgr->payloads[j] = mgr->payloads[j + 1];
dfda0df3426483c Dave Airlie          2014-08-06  2475  			mgr->proposed_vcpis[j] = mgr->proposed_vcpis[j + 1];
706246c761ddd39 Lyude Paul           2018-12-13  2476  
706246c761ddd39 Lyude Paul           2018-12-13  2477  			if (mgr->proposed_vcpis[j] &&
706246c761ddd39 Lyude Paul           2018-12-13  2478  			    mgr->proposed_vcpis[j]->num_slots) {
dfda0df3426483c Dave Airlie          2014-08-06  2479  				set_bit(j + 1, &mgr->payload_mask);
dfda0df3426483c Dave Airlie          2014-08-06  2480  			} else {
dfda0df3426483c Dave Airlie          2014-08-06  2481  				clear_bit(j + 1, &mgr->payload_mask);
dfda0df3426483c Dave Airlie          2014-08-06  2482  			}
dfda0df3426483c Dave Airlie          2014-08-06  2483  		}
706246c761ddd39 Lyude Paul           2018-12-13  2484  
706246c761ddd39 Lyude Paul           2018-12-13  2485  		memset(&mgr->payloads[mgr->max_payloads - 1], 0,
706246c761ddd39 Lyude Paul           2018-12-13  2486  		       sizeof(struct drm_dp_payload));
dfda0df3426483c Dave Airlie          2014-08-06  2487  		mgr->proposed_vcpis[mgr->max_payloads - 1] = NULL;
dfda0df3426483c Dave Airlie          2014-08-06  2488  		clear_bit(mgr->max_payloads, &mgr->payload_mask);
dfda0df3426483c Dave Airlie          2014-08-06  2489  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2490  	mutex_unlock(&mgr->payload_lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2491  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2492  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2493  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2494  EXPORT_SYMBOL(drm_dp_update_payload_part1);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2495  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2496  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2497   * drm_dp_update_payload_part2() - Execute payload update part 2
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2498   * @mgr: manager to use.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2499   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2500   * This iterates over all proposed virtual channels, and tries to
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2501   * allocate space in the link for them. For 0->slots transitions,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2502   * this step writes the remote VC payload commands. For slots->0
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2503   * this just resets some internal state.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2504   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2505  int drm_dp_update_payload_part2(struct drm_dp_mst_topology_mgr *mgr)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2506  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2507  	struct drm_dp_mst_port *port;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2508  	int i;
7389ad4b6515c2d Damien Lespiau       2014-07-14  2509  	int ret = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2510  	mutex_lock(&mgr->payload_lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2511  	for (i = 0; i < mgr->max_payloads; i++) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2512  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2513  		if (!mgr->proposed_vcpis[i])
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2514  			continue;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2515  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2516  		port = container_of(mgr->proposed_vcpis[i], struct drm_dp_mst_port, vcpi);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2517  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2518  		DRM_DEBUG_KMS("payload %d %d\n", i, mgr->payloads[i].payload_state);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2519  		if (mgr->payloads[i].payload_state == DP_PAYLOAD_LOCAL) {
dfda0df3426483c Dave Airlie          2014-08-06  2520  			ret = drm_dp_create_payload_step2(mgr, port, mgr->proposed_vcpis[i]->vcpi, &mgr->payloads[i]);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2521  		} else if (mgr->payloads[i].payload_state == DP_PAYLOAD_DELETE_LOCAL) {
dfda0df3426483c Dave Airlie          2014-08-06  2522  			ret = drm_dp_destroy_payload_step2(mgr, mgr->proposed_vcpis[i]->vcpi, &mgr->payloads[i]);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2523  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2524  		if (ret) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2525  			mutex_unlock(&mgr->payload_lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2526  			return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2527  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2528  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2529  	mutex_unlock(&mgr->payload_lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2530  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2531  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2532  EXPORT_SYMBOL(drm_dp_update_payload_part2);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2533  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2534  static int drm_dp_send_dpcd_read(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2535  				 struct drm_dp_mst_port *port,
3dfd9a885fbb869 Andrew Morton        2019-07-27  2536  				 int offset, int size, u8 *bytes)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2537  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2538  	int len;
3dfd9a885fbb869 Andrew Morton        2019-07-27  2539  	int ret = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2540  	struct drm_dp_sideband_msg_tx *txmsg;
3dfd9a885fbb869 Andrew Morton        2019-07-27  2541  	struct drm_dp_mst_branch *mstb;
3dfd9a885fbb869 Andrew Morton        2019-07-27  2542  
3dfd9a885fbb869 Andrew Morton        2019-07-27  2543  	mstb = drm_dp_mst_topology_get_mstb_validated(mgr, port->parent);
3dfd9a885fbb869 Andrew Morton        2019-07-27  2544  	if (!mstb)
3dfd9a885fbb869 Andrew Morton        2019-07-27  2545  		return -EINVAL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2546  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2547  	txmsg = kzalloc(sizeof(*txmsg), GFP_KERNEL);
3dfd9a885fbb869 Andrew Morton        2019-07-27  2548  	if (!txmsg) {
3dfd9a885fbb869 Andrew Morton        2019-07-27  2549  		ret = -ENOMEM;
3dfd9a885fbb869 Andrew Morton        2019-07-27  2550  		goto fail_put;
3dfd9a885fbb869 Andrew Morton        2019-07-27  2551  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2552  
3dfd9a885fbb869 Andrew Morton        2019-07-27  2553  	len = build_dpcd_read(txmsg, port->port_num, offset, size);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2554  	txmsg->dst = port->parent;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2555  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2556  	drm_dp_queue_down_tx(mgr, txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2557  
3dfd9a885fbb869 Andrew Morton        2019-07-27  2558  	ret = drm_dp_mst_wait_tx_reply(mstb, txmsg);
3dfd9a885fbb869 Andrew Morton        2019-07-27  2559  	if (ret < 0)
3dfd9a885fbb869 Andrew Morton        2019-07-27  2560  		goto fail_free;
3dfd9a885fbb869 Andrew Morton        2019-07-27  2561  
3dfd9a885fbb869 Andrew Morton        2019-07-27  2562  	/* DPCD read should never be NACKed */
3dfd9a885fbb869 Andrew Morton        2019-07-27  2563  	if (txmsg->reply.reply_type == 1) {
3dfd9a885fbb869 Andrew Morton        2019-07-27  2564  		DRM_ERROR("mstb %p port %d: DPCD read on addr 0x%x for %d bytes NAKed\n",
3dfd9a885fbb869 Andrew Morton        2019-07-27  2565  			  mstb, port->port_num, offset, size);
3dfd9a885fbb869 Andrew Morton        2019-07-27  2566  		ret = -EIO;
3dfd9a885fbb869 Andrew Morton        2019-07-27  2567  		goto fail_free;
3dfd9a885fbb869 Andrew Morton        2019-07-27  2568  	}
3dfd9a885fbb869 Andrew Morton        2019-07-27  2569  
3dfd9a885fbb869 Andrew Morton        2019-07-27  2570  	if (txmsg->reply.u.remote_dpcd_read_ack.num_bytes != size) {
3dfd9a885fbb869 Andrew Morton        2019-07-27  2571  		ret = -EPROTO;
3dfd9a885fbb869 Andrew Morton        2019-07-27  2572  		goto fail_free;
3dfd9a885fbb869 Andrew Morton        2019-07-27  2573  	}
3dfd9a885fbb869 Andrew Morton        2019-07-27  2574  
3dfd9a885fbb869 Andrew Morton        2019-07-27  2575  	ret = min_t(size_t, txmsg->reply.u.remote_dpcd_read_ack.num_bytes,
3dfd9a885fbb869 Andrew Morton        2019-07-27  2576  		    size);
3dfd9a885fbb869 Andrew Morton        2019-07-27  2577  	memcpy(bytes, txmsg->reply.u.remote_dpcd_read_ack.bytes, ret);
3dfd9a885fbb869 Andrew Morton        2019-07-27  2578  
3dfd9a885fbb869 Andrew Morton        2019-07-27  2579  fail_free:
3dfd9a885fbb869 Andrew Morton        2019-07-27  2580  	kfree(txmsg);
3dfd9a885fbb869 Andrew Morton        2019-07-27  2581  fail_put:
3dfd9a885fbb869 Andrew Morton        2019-07-27  2582  	drm_dp_mst_topology_put_mstb(mstb);
3dfd9a885fbb869 Andrew Morton        2019-07-27  2583  
3dfd9a885fbb869 Andrew Morton        2019-07-27  2584  	return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2585  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2586  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2587  static int drm_dp_send_dpcd_write(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2588  				  struct drm_dp_mst_port *port,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2589  				  int offset, int size, u8 *bytes)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2590  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2591  	int len;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2592  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2593  	struct drm_dp_sideband_msg_tx *txmsg;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2594  	struct drm_dp_mst_branch *mstb;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2595  
d0757afd00d71dc Lyude Paul           2019-01-10  2596  	mstb = drm_dp_mst_topology_get_mstb_validated(mgr, port->parent);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2597  	if (!mstb)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2598  		return -EINVAL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2599  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2600  	txmsg = kzalloc(sizeof(*txmsg), GFP_KERNEL);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2601  	if (!txmsg) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2602  		ret = -ENOMEM;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2603  		goto fail_put;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2604  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2605  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2606  	len = build_dpcd_write(txmsg, port->port_num, offset, size, bytes);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2607  	txmsg->dst = mstb;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2608  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2609  	drm_dp_queue_down_tx(mgr, txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2610  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2611  	ret = drm_dp_mst_wait_tx_reply(mstb, txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2612  	if (ret > 0) {
45bbda1e35f4943 Ville Syrjälä        2019-01-22  2613  		if (txmsg->reply.reply_type == DP_SIDEBAND_REPLY_NAK)
3dfd9a885fbb869 Andrew Morton        2019-07-27  2614  			ret = -EIO;
45bbda1e35f4943 Ville Syrjälä        2019-01-22  2615  		else
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2616  			ret = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2617  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2618  	kfree(txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2619  fail_put:
d0757afd00d71dc Lyude Paul           2019-01-10  2620  	drm_dp_mst_topology_put_mstb(mstb);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2621  	return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2622  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2623  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2624  static int drm_dp_encode_up_ack_reply(struct drm_dp_sideband_msg_tx *msg, u8 req_type)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2625  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2626  	struct drm_dp_sideband_msg_reply_body reply;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2627  
45bbda1e35f4943 Ville Syrjälä        2019-01-22  2628  	reply.reply_type = DP_SIDEBAND_REPLY_ACK;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2629  	reply.req_type = req_type;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2630  	drm_dp_encode_sideband_reply(&reply, msg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2631  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2632  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2633  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2634  static int drm_dp_send_up_ack_reply(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2635  				    struct drm_dp_mst_branch *mstb,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2636  				    int req_type, int seqno, bool broadcast)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2637  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2638  	struct drm_dp_sideband_msg_tx *txmsg;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2639  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2640  	txmsg = kzalloc(sizeof(*txmsg), GFP_KERNEL);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2641  	if (!txmsg)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2642  		return -ENOMEM;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2643  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2644  	txmsg->dst = mstb;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2645  	txmsg->seqno = seqno;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2646  	drm_dp_encode_up_ack_reply(txmsg, req_type);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2647  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2648  	mutex_lock(&mgr->qlock);
1f16ee7fa13649f Mykola Lysenko       2015-12-18  2649  
1f16ee7fa13649f Mykola Lysenko       2015-12-18  2650  	process_single_up_tx_qlock(mgr, txmsg);
1f16ee7fa13649f Mykola Lysenko       2015-12-18  2651  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2652  	mutex_unlock(&mgr->qlock);
1f16ee7fa13649f Mykola Lysenko       2015-12-18  2653  
1f16ee7fa13649f Mykola Lysenko       2015-12-18  2654  	kfree(txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2655  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2656  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2657  
b853fdb3c0e7122 Chris Wilson         2014-11-12  2658  static bool drm_dp_get_vc_payload_bw(int dp_link_bw,
b853fdb3c0e7122 Chris Wilson         2014-11-12  2659  				     int dp_link_count,
b853fdb3c0e7122 Chris Wilson         2014-11-12  2660  				     int *out)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2661  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2662  	switch (dp_link_bw) {
b853fdb3c0e7122 Chris Wilson         2014-11-12  2663  	default:
b853fdb3c0e7122 Chris Wilson         2014-11-12  2664  		DRM_DEBUG_KMS("invalid link bandwidth in DPCD: %x (link count: %d)\n",
b853fdb3c0e7122 Chris Wilson         2014-11-12  2665  			      dp_link_bw, dp_link_count);
b853fdb3c0e7122 Chris Wilson         2014-11-12  2666  		return false;
b853fdb3c0e7122 Chris Wilson         2014-11-12  2667  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2668  	case DP_LINK_BW_1_62:
b853fdb3c0e7122 Chris Wilson         2014-11-12  2669  		*out = 3 * dp_link_count;
b853fdb3c0e7122 Chris Wilson         2014-11-12  2670  		break;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2671  	case DP_LINK_BW_2_7:
b853fdb3c0e7122 Chris Wilson         2014-11-12  2672  		*out = 5 * dp_link_count;
b853fdb3c0e7122 Chris Wilson         2014-11-12  2673  		break;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2674  	case DP_LINK_BW_5_4:
b853fdb3c0e7122 Chris Wilson         2014-11-12  2675  		*out = 10 * dp_link_count;
b853fdb3c0e7122 Chris Wilson         2014-11-12  2676  		break;
e0bd878a959008f Manasi Navare        2018-01-22  2677  	case DP_LINK_BW_8_1:
e0bd878a959008f Manasi Navare        2018-01-22  2678  		*out = 15 * dp_link_count;
e0bd878a959008f Manasi Navare        2018-01-22  2679  		break;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2680  	}
b853fdb3c0e7122 Chris Wilson         2014-11-12  2681  	return true;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2682  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2683  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2684  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2685   * drm_dp_mst_topology_mgr_set_mst() - Set the MST state for a topology manager
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2686   * @mgr: manager to set state for
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2687   * @mst_state: true to enable MST on this connector - false to disable.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2688   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2689   * This is called by the driver when it detects an MST capable device plugged
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2690   * into a DP MST capable port, or when a DP MST capable device is unplugged.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2691   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2692  int drm_dp_mst_topology_mgr_set_mst(struct drm_dp_mst_topology_mgr *mgr, bool mst_state)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2693  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2694  	int ret = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2695  	struct drm_dp_mst_branch *mstb = NULL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2696  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2697  	mutex_lock(&mgr->lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2698  	if (mst_state == mgr->mst_state)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2699  		goto out_unlock;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2700  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2701  	mgr->mst_state = mst_state;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2702  	/* set the device into MST mode */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2703  	if (mst_state) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2704  		WARN_ON(mgr->mst_primary);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2705  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2706  		/* get dpcd info */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2707  		ret = drm_dp_dpcd_read(mgr->aux, DP_DPCD_REV, mgr->dpcd, DP_RECEIVER_CAP_SIZE);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2708  		if (ret != DP_RECEIVER_CAP_SIZE) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2709  			DRM_DEBUG_KMS("failed to read DPCD\n");
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2710  			goto out_unlock;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2711  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2712  
b853fdb3c0e7122 Chris Wilson         2014-11-12  2713  		if (!drm_dp_get_vc_payload_bw(mgr->dpcd[1],
b853fdb3c0e7122 Chris Wilson         2014-11-12  2714  					      mgr->dpcd[2] & DP_MAX_LANE_COUNT_MASK,
b853fdb3c0e7122 Chris Wilson         2014-11-12  2715  					      &mgr->pbn_div)) {
b853fdb3c0e7122 Chris Wilson         2014-11-12  2716  			ret = -EINVAL;
b853fdb3c0e7122 Chris Wilson         2014-11-12  2717  			goto out_unlock;
b853fdb3c0e7122 Chris Wilson         2014-11-12  2718  		}
b853fdb3c0e7122 Chris Wilson         2014-11-12  2719  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2720  		/* add initial branch device at LCT 1 */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2721  		mstb = drm_dp_add_mst_branch_device(1, NULL);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2722  		if (mstb == NULL) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2723  			ret = -ENOMEM;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2724  			goto out_unlock;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2725  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2726  		mstb->mgr = mgr;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2727  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2728  		/* give this the main reference */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2729  		mgr->mst_primary = mstb;
ebcc0e6b509108b Lyude Paul           2019-01-10  2730  		drm_dp_mst_topology_get_mstb(mgr->mst_primary);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2731  
c175cd16df27211 Andrey Grodzovsky    2016-01-22  2732  		ret = drm_dp_dpcd_writeb(mgr->aux, DP_MSTM_CTRL,
c175cd16df27211 Andrey Grodzovsky    2016-01-22  2733  							 DP_MST_EN | DP_UP_REQ_EN | DP_UPSTREAM_IS_SRC);
c175cd16df27211 Andrey Grodzovsky    2016-01-22  2734  		if (ret < 0) {
c175cd16df27211 Andrey Grodzovsky    2016-01-22  2735  			goto out_unlock;
c175cd16df27211 Andrey Grodzovsky    2016-01-22  2736  		}
c175cd16df27211 Andrey Grodzovsky    2016-01-22  2737  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2738  		{
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2739  			struct drm_dp_payload reset_pay;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2740  			reset_pay.start_slot = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2741  			reset_pay.num_slots = 0x3f;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2742  			drm_dp_dpcd_write_payload(mgr, 0, &reset_pay);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2743  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2744  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2745  		queue_work(system_long_wq, &mgr->work);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2746  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2747  		ret = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2748  	} else {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2749  		/* disable MST on the device */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2750  		mstb = mgr->mst_primary;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2751  		mgr->mst_primary = NULL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2752  		/* this can fail if the device is gone */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2753  		drm_dp_dpcd_writeb(mgr->aux, DP_MSTM_CTRL, 0);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2754  		ret = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2755  		memset(mgr->payloads, 0, mgr->max_payloads * sizeof(struct drm_dp_payload));
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2756  		mgr->payload_mask = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2757  		set_bit(0, &mgr->payload_mask);
dfda0df3426483c Dave Airlie          2014-08-06  2758  		mgr->vcpi_mask = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2759  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2760  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2761  out_unlock:
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2762  	mutex_unlock(&mgr->lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2763  	if (mstb)
d0757afd00d71dc Lyude Paul           2019-01-10  2764  		drm_dp_mst_topology_put_mstb(mstb);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2765  	return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2766  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2767  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2768  EXPORT_SYMBOL(drm_dp_mst_topology_mgr_set_mst);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2769  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2770  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2771   * drm_dp_mst_topology_mgr_suspend() - suspend the MST manager
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2772   * @mgr: manager to suspend
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2773   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2774   * This function tells the MST device that we can't handle UP messages
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2775   * anymore. This should stop it from sending any since we are suspended.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2776   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2777  void drm_dp_mst_topology_mgr_suspend(struct drm_dp_mst_topology_mgr *mgr)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2778  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2779  	mutex_lock(&mgr->lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2780  	drm_dp_dpcd_writeb(mgr->aux, DP_MSTM_CTRL,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2781  			   DP_MST_EN | DP_UPSTREAM_IS_SRC);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2782  	mutex_unlock(&mgr->lock);
274d83524895fe4 Dave Airlie          2015-09-30  2783  	flush_work(&mgr->work);
274d83524895fe4 Dave Airlie          2015-09-30  2784  	flush_work(&mgr->destroy_connector_work);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2785  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2786  EXPORT_SYMBOL(drm_dp_mst_topology_mgr_suspend);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2787  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2788  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2789   * drm_dp_mst_topology_mgr_resume() - resume the MST manager
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2790   * @mgr: manager to resume
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2791   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2792   * This will fetch DPCD and see if the device is still there,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2793   * if it is, it will rewrite the MSTM control bits, and return.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2794   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2795   * if the device fails this returns -1, and the driver should do
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2796   * a full MST reprobe, in case we were undocked.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2797   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2798  int drm_dp_mst_topology_mgr_resume(struct drm_dp_mst_topology_mgr *mgr)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2799  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2800  	int ret = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2801  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2802  	mutex_lock(&mgr->lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2803  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2804  	if (mgr->mst_primary) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2805  		int sret;
1652fce65f70f10 Lyude                2016-04-13  2806  		u8 guid[16];
1652fce65f70f10 Lyude                2016-04-13  2807  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2808  		sret = drm_dp_dpcd_read(mgr->aux, DP_DPCD_REV, mgr->dpcd, DP_RECEIVER_CAP_SIZE);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2809  		if (sret != DP_RECEIVER_CAP_SIZE) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2810  			DRM_DEBUG_KMS("dpcd read failed - undocked during suspend?\n");
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2811  			ret = -1;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2812  			goto out_unlock;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2813  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2814  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2815  		ret = drm_dp_dpcd_writeb(mgr->aux, DP_MSTM_CTRL,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2816  					 DP_MST_EN | DP_UP_REQ_EN | DP_UPSTREAM_IS_SRC);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2817  		if (ret < 0) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2818  			DRM_DEBUG_KMS("mst write failed - undocked during suspend?\n");
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2819  			ret = -1;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2820  			goto out_unlock;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2821  		}
1652fce65f70f10 Lyude                2016-04-13  2822  
1652fce65f70f10 Lyude                2016-04-13  2823  		/* Some hubs forget their guids after they resume */
1652fce65f70f10 Lyude                2016-04-13  2824  		sret = drm_dp_dpcd_read(mgr->aux, DP_GUID, guid, 16);
1652fce65f70f10 Lyude                2016-04-13  2825  		if (sret != 16) {
1652fce65f70f10 Lyude                2016-04-13  2826  			DRM_DEBUG_KMS("dpcd read failed - undocked during suspend?\n");
1652fce65f70f10 Lyude                2016-04-13  2827  			ret = -1;
1652fce65f70f10 Lyude                2016-04-13  2828  			goto out_unlock;
1652fce65f70f10 Lyude                2016-04-13  2829  		}
1652fce65f70f10 Lyude                2016-04-13  2830  		drm_dp_check_mstb_guid(mgr->mst_primary, guid);
1652fce65f70f10 Lyude                2016-04-13  2831  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2832  		ret = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2833  	} else
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2834  		ret = -1;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2835  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2836  out_unlock:
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2837  	mutex_unlock(&mgr->lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2838  	return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2839  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2840  EXPORT_SYMBOL(drm_dp_mst_topology_mgr_resume);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2841  
636c4c3e762b62a Imre Deak            2017-07-19  2842  static bool drm_dp_get_one_sb_msg(struct drm_dp_mst_topology_mgr *mgr, bool up)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2843  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2844  	int len;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2845  	u8 replyblock[32];
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2846  	int replylen, origlen, curreply;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2847  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2848  	struct drm_dp_sideband_msg_rx *msg;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2849  	int basereg = up ? DP_SIDEBAND_MSG_UP_REQ_BASE : DP_SIDEBAND_MSG_DOWN_REP_BASE;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2850  	msg = up ? &mgr->up_req_recv : &mgr->down_rep_recv;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2851  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2852  	len = min(mgr->max_dpcd_transaction_bytes, 16);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2853  	ret = drm_dp_dpcd_read(mgr->aux, basereg,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2854  			       replyblock, len);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2855  	if (ret != len) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2856  		DRM_DEBUG_KMS("failed to read DPCD down rep %d %d\n", len, ret);
636c4c3e762b62a Imre Deak            2017-07-19  2857  		return false;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2858  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2859  	ret = drm_dp_sideband_msg_build(msg, replyblock, len, true);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2860  	if (!ret) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2861  		DRM_DEBUG_KMS("sideband msg build failed %d\n", replyblock[0]);
636c4c3e762b62a Imre Deak            2017-07-19  2862  		return false;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2863  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2864  	replylen = msg->curchunk_len + msg->curchunk_hdrlen;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2865  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2866  	origlen = replylen;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2867  	replylen -= len;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2868  	curreply = len;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2869  	while (replylen > 0) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2870  		len = min3(replylen, mgr->max_dpcd_transaction_bytes, 16);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2871  		ret = drm_dp_dpcd_read(mgr->aux, basereg + curreply,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2872  				    replyblock, len);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2873  		if (ret != len) {
448421b5e93b917 Imre Deak            2017-07-19  2874  			DRM_DEBUG_KMS("failed to read a chunk (len %d, ret %d)\n",
448421b5e93b917 Imre Deak            2017-07-19  2875  				      len, ret);
636c4c3e762b62a Imre Deak            2017-07-19  2876  			return false;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2877  		}
448421b5e93b917 Imre Deak            2017-07-19  2878  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2879  		ret = drm_dp_sideband_msg_build(msg, replyblock, len, false);
448421b5e93b917 Imre Deak            2017-07-19  2880  		if (!ret) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2881  			DRM_DEBUG_KMS("failed to build sideband msg\n");
636c4c3e762b62a Imre Deak            2017-07-19  2882  			return false;
448421b5e93b917 Imre Deak            2017-07-19  2883  		}
448421b5e93b917 Imre Deak            2017-07-19  2884  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2885  		curreply += len;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2886  		replylen -= len;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2887  	}
636c4c3e762b62a Imre Deak            2017-07-19  2888  	return true;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2889  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2890  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2891  static int drm_dp_mst_handle_down_rep(struct drm_dp_mst_topology_mgr *mgr)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2892  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2893  	int ret = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2894  
636c4c3e762b62a Imre Deak            2017-07-19  2895  	if (!drm_dp_get_one_sb_msg(mgr, false)) {
636c4c3e762b62a Imre Deak            2017-07-19  2896  		memset(&mgr->down_rep_recv, 0,
636c4c3e762b62a Imre Deak            2017-07-19  2897  		       sizeof(struct drm_dp_sideband_msg_rx));
636c4c3e762b62a Imre Deak            2017-07-19  2898  		return 0;
636c4c3e762b62a Imre Deak            2017-07-19  2899  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2900  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2901  	if (mgr->down_rep_recv.have_eomt) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2902  		struct drm_dp_sideband_msg_tx *txmsg;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2903  		struct drm_dp_mst_branch *mstb;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2904  		int slot = -1;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2905  		mstb = drm_dp_get_mst_branch_device(mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2906  						    mgr->down_rep_recv.initial_hdr.lct,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2907  						    mgr->down_rep_recv.initial_hdr.rad);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2908  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2909  		if (!mstb) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2910  			DRM_DEBUG_KMS("Got MST reply from unknown device %d\n", mgr->down_rep_recv.initial_hdr.lct);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2911  			memset(&mgr->down_rep_recv, 0, sizeof(struct drm_dp_sideband_msg_rx));
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2912  			return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2913  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2914  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2915  		/* find the message */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2916  		slot = mgr->down_rep_recv.initial_hdr.seqno;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2917  		mutex_lock(&mgr->qlock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2918  		txmsg = mstb->tx_slots[slot];
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2919  		/* remove from slots */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2920  		mutex_unlock(&mgr->qlock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2921  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2922  		if (!txmsg) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2923  			DRM_DEBUG_KMS("Got MST reply with no msg %p %d %d %02x %02x\n",
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2924  			       mstb,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2925  			       mgr->down_rep_recv.initial_hdr.seqno,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2926  			       mgr->down_rep_recv.initial_hdr.lct,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2927  				      mgr->down_rep_recv.initial_hdr.rad[0],
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2928  				      mgr->down_rep_recv.msg[0]);
d0757afd00d71dc Lyude Paul           2019-01-10  2929  			drm_dp_mst_topology_put_mstb(mstb);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2930  			memset(&mgr->down_rep_recv, 0, sizeof(struct drm_dp_sideband_msg_rx));
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2931  			return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2932  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2933  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2934  		drm_dp_sideband_parse_reply(&mgr->down_rep_recv, &txmsg->reply);
45bbda1e35f4943 Ville Syrjälä        2019-01-22  2935  
45bbda1e35f4943 Ville Syrjälä        2019-01-22  2936  		if (txmsg->reply.reply_type == DP_SIDEBAND_REPLY_NAK)
3dadbd2957eb8da Ville Syrjälä        2019-01-22  2937  			DRM_DEBUG_KMS("Got NAK reply: req 0x%02x (%s), reason 0x%02x (%s), nak data 0x%02x\n",
3dadbd2957eb8da Ville Syrjälä        2019-01-22  2938  				      txmsg->reply.req_type,
3dadbd2957eb8da Ville Syrjälä        2019-01-22  2939  				      drm_dp_mst_req_type_str(txmsg->reply.req_type),
3dadbd2957eb8da Ville Syrjälä        2019-01-22  2940  				      txmsg->reply.u.nak.reason,
3dadbd2957eb8da Ville Syrjälä        2019-01-22  2941  				      drm_dp_mst_nak_reason_str(txmsg->reply.u.nak.reason),
3dadbd2957eb8da Ville Syrjälä        2019-01-22  2942  				      txmsg->reply.u.nak.nak_data);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2943  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2944  		memset(&mgr->down_rep_recv, 0, sizeof(struct drm_dp_sideband_msg_rx));
d0757afd00d71dc Lyude Paul           2019-01-10  2945  		drm_dp_mst_topology_put_mstb(mstb);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2946  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2947  		mutex_lock(&mgr->qlock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2948  		txmsg->state = DRM_DP_SIDEBAND_TX_RX;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2949  		mstb->tx_slots[slot] = NULL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2950  		mutex_unlock(&mgr->qlock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2951  
68e989dc044346a Chris Wilson         2017-05-13  2952  		wake_up_all(&mgr->tx_waitq);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2953  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2954  	return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2955  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2956  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2957  static int drm_dp_mst_handle_up_req(struct drm_dp_mst_topology_mgr *mgr)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2958  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2959  	int ret = 0;
636c4c3e762b62a Imre Deak            2017-07-19  2960  
636c4c3e762b62a Imre Deak            2017-07-19  2961  	if (!drm_dp_get_one_sb_msg(mgr, true)) {
636c4c3e762b62a Imre Deak            2017-07-19  2962  		memset(&mgr->up_req_recv, 0,
636c4c3e762b62a Imre Deak            2017-07-19  2963  		       sizeof(struct drm_dp_sideband_msg_rx));
636c4c3e762b62a Imre Deak            2017-07-19  2964  		return 0;
636c4c3e762b62a Imre Deak            2017-07-19  2965  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2966  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2967  	if (mgr->up_req_recv.have_eomt) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2968  		struct drm_dp_sideband_msg_req_body msg;
bd9343208704fcc Mykola Lysenko       2015-12-18  2969  		struct drm_dp_mst_branch *mstb = NULL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2970  		bool seqno;
bd9343208704fcc Mykola Lysenko       2015-12-18  2971  
bd9343208704fcc Mykola Lysenko       2015-12-18  2972  		if (!mgr->up_req_recv.initial_hdr.broadcast) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2973  			mstb = drm_dp_get_mst_branch_device(mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2974  							    mgr->up_req_recv.initial_hdr.lct,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2975  							    mgr->up_req_recv.initial_hdr.rad);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2976  			if (!mstb) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2977  				DRM_DEBUG_KMS("Got MST reply from unknown device %d\n", mgr->up_req_recv.initial_hdr.lct);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2978  				memset(&mgr->up_req_recv, 0, sizeof(struct drm_dp_sideband_msg_rx));
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2979  				return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2980  			}
bd9343208704fcc Mykola Lysenko       2015-12-18  2981  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2982  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2983  		seqno = mgr->up_req_recv.initial_hdr.seqno;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2984  		drm_dp_sideband_parse_req(&mgr->up_req_recv, &msg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2985  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2986  		if (msg.req_type == DP_CONNECTION_STATUS_NOTIFY) {
bd9343208704fcc Mykola Lysenko       2015-12-18  2987  			drm_dp_send_up_ack_reply(mgr, mgr->mst_primary, msg.req_type, seqno, false);
bd9343208704fcc Mykola Lysenko       2015-12-18  2988  
bd9343208704fcc Mykola Lysenko       2015-12-18  2989  			if (!mstb)
bd9343208704fcc Mykola Lysenko       2015-12-18  2990  				mstb = drm_dp_get_mst_branch_device_by_guid(mgr, msg.u.conn_stat.guid);
bd9343208704fcc Mykola Lysenko       2015-12-18  2991  
bd9343208704fcc Mykola Lysenko       2015-12-18  2992  			if (!mstb) {
bd9343208704fcc Mykola Lysenko       2015-12-18  2993  				DRM_DEBUG_KMS("Got MST reply from unknown device %d\n", mgr->up_req_recv.initial_hdr.lct);
bd9343208704fcc Mykola Lysenko       2015-12-18  2994  				memset(&mgr->up_req_recv, 0, sizeof(struct drm_dp_sideband_msg_rx));
bd9343208704fcc Mykola Lysenko       2015-12-18  2995  				return 0;
bd9343208704fcc Mykola Lysenko       2015-12-18  2996  			}
bd9343208704fcc Mykola Lysenko       2015-12-18  2997  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  2998  			drm_dp_update_port(mstb, &msg.u.conn_stat);
5e93b8208d3c419 Hersen Wu            2016-01-22  2999  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3000  			DRM_DEBUG_KMS("Got CSN: pn: %d ldps:%d ddps: %d mcs: %d ip: %d pdt: %d\n", msg.u.conn_stat.port_number, msg.u.conn_stat.legacy_device_plug_status, msg.u.conn_stat.displayport_device_plug_status, msg.u.conn_stat.message_capability_status, msg.u.conn_stat.input_port, msg.u.conn_stat.peer_device_type);
16bff572cc660f1 Daniel Vetter        2018-11-28  3001  			drm_kms_helper_hotplug_event(mgr->dev);
8ae22cb419ad0ba Dave Airlie          2016-02-17  3002  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3003  		} else if (msg.req_type == DP_RESOURCE_STATUS_NOTIFY) {
bd9343208704fcc Mykola Lysenko       2015-12-18  3004  			drm_dp_send_up_ack_reply(mgr, mgr->mst_primary, msg.req_type, seqno, false);
bd9343208704fcc Mykola Lysenko       2015-12-18  3005  			if (!mstb)
bd9343208704fcc Mykola Lysenko       2015-12-18  3006  				mstb = drm_dp_get_mst_branch_device_by_guid(mgr, msg.u.resource_stat.guid);
bd9343208704fcc Mykola Lysenko       2015-12-18  3007  
bd9343208704fcc Mykola Lysenko       2015-12-18  3008  			if (!mstb) {
bd9343208704fcc Mykola Lysenko       2015-12-18  3009  				DRM_DEBUG_KMS("Got MST reply from unknown device %d\n", mgr->up_req_recv.initial_hdr.lct);
bd9343208704fcc Mykola Lysenko       2015-12-18  3010  				memset(&mgr->up_req_recv, 0, sizeof(struct drm_dp_sideband_msg_rx));
bd9343208704fcc Mykola Lysenko       2015-12-18  3011  				return 0;
bd9343208704fcc Mykola Lysenko       2015-12-18  3012  			}
bd9343208704fcc Mykola Lysenko       2015-12-18  3013  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3014  			DRM_DEBUG_KMS("Got RSN: pn: %d avail_pbn %d\n", msg.u.resource_stat.port_number, msg.u.resource_stat.available_pbn);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3015  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3016  
7f8b3987da54cb4 Imre Deak            2017-07-19  3017  		if (mstb)
d0757afd00d71dc Lyude Paul           2019-01-10  3018  			drm_dp_mst_topology_put_mstb(mstb);
7f8b3987da54cb4 Imre Deak            2017-07-19  3019  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3020  		memset(&mgr->up_req_recv, 0, sizeof(struct drm_dp_sideband_msg_rx));
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3021  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3022  	return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3023  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3024  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3025  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3026   * drm_dp_mst_hpd_irq() - MST hotplug IRQ notify
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3027   * @mgr: manager to notify irq for.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3028   * @esi: 4 bytes from SINK_COUNT_ESI
295ee85316aedfe Daniel Vetter        2014-07-30  3029   * @handled: whether the hpd interrupt was consumed or not
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3030   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3031   * This should be called from the driver when it detects a short IRQ,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3032   * along with the value of the DEVICE_SERVICE_IRQ_VECTOR_ESI0. The
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3033   * topology manager will process the sideband messages received as a result
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3034   * of this.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3035   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3036  int drm_dp_mst_hpd_irq(struct drm_dp_mst_topology_mgr *mgr, u8 *esi, bool *handled)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3037  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3038  	int ret = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3039  	int sc;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3040  	*handled = false;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3041  	sc = esi[0] & 0x3f;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3042  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3043  	if (sc != mgr->sink_count) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3044  		mgr->sink_count = sc;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3045  		*handled = true;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3046  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3047  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3048  	if (esi[1] & DP_DOWN_REP_MSG_RDY) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3049  		ret = drm_dp_mst_handle_down_rep(mgr);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3050  		*handled = true;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3051  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3052  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3053  	if (esi[1] & DP_UP_REQ_MSG_RDY) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3054  		ret |= drm_dp_mst_handle_up_req(mgr);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3055  		*handled = true;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3056  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3057  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3058  	drm_dp_mst_kick_tx(mgr);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3059  	return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3060  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3061  EXPORT_SYMBOL(drm_dp_mst_hpd_irq);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3062  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3063  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3064   * drm_dp_mst_detect_port() - get connection status for an MST port
132d49d728f3af6 Daniel Vetter        2016-07-15  3065   * @connector: DRM connector for this port
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3066   * @mgr: manager for this port
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3067   * @port: unverified pointer to a port
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3068   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3069   * This returns the current connection state for a port. It validates the
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3070   * port pointer still exists so the caller doesn't require a reference
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3071   */
c6a0aed4d493936 Dave Airlie          2014-10-20  3072  enum drm_connector_status drm_dp_mst_detect_port(struct drm_connector *connector,
c6a0aed4d493936 Dave Airlie          2014-10-20  3073  						 struct drm_dp_mst_topology_mgr *mgr, struct drm_dp_mst_port *port)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3074  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3075  	enum drm_connector_status status = connector_status_disconnected;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3076  
1e55a53a28d3e52 Matt Roper           2019-02-01  3077  	/* we need to search for the port in the mgr in case it's gone */
d0757afd00d71dc Lyude Paul           2019-01-10  3078  	port = drm_dp_mst_topology_get_port_validated(mgr, port);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3079  	if (!port)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3080  		return connector_status_disconnected;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3081  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3082  	if (!port->ddps)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3083  		goto out;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3084  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3085  	switch (port->pdt) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3086  	case DP_PEER_DEVICE_NONE:
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3087  	case DP_PEER_DEVICE_MST_BRANCHING:
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3088  		break;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3089  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3090  	case DP_PEER_DEVICE_SST_SINK:
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3091  		status = connector_status_connected;
8ae22cb419ad0ba Dave Airlie          2016-02-17  3092  		/* for logical ports - cache the EDID */
8ae22cb419ad0ba Dave Airlie          2016-02-17  3093  		if (port->port_num >= 8 && !port->cached_edid) {
8ae22cb419ad0ba Dave Airlie          2016-02-17  3094  			port->cached_edid = drm_get_edid(connector, &port->aux.ddc);
8ae22cb419ad0ba Dave Airlie          2016-02-17  3095  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3096  		break;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3097  	case DP_PEER_DEVICE_DP_LEGACY_CONV:
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3098  		if (port->ldps)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3099  			status = connector_status_connected;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3100  		break;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3101  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3102  out:
d0757afd00d71dc Lyude Paul           2019-01-10  3103  	drm_dp_mst_topology_put_port(port);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3104  	return status;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3105  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3106  EXPORT_SYMBOL(drm_dp_mst_detect_port);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3107  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3108  /**
ef8f9bea1368b89 Libin Yang           2015-12-02  3109   * drm_dp_mst_port_has_audio() - Check whether port has audio capability or not
ef8f9bea1368b89 Libin Yang           2015-12-02  3110   * @mgr: manager for this port
ef8f9bea1368b89 Libin Yang           2015-12-02  3111   * @port: unverified pointer to a port.
ef8f9bea1368b89 Libin Yang           2015-12-02  3112   *
ef8f9bea1368b89 Libin Yang           2015-12-02  3113   * This returns whether the port supports audio or not.
ef8f9bea1368b89 Libin Yang           2015-12-02  3114   */
ef8f9bea1368b89 Libin Yang           2015-12-02  3115  bool drm_dp_mst_port_has_audio(struct drm_dp_mst_topology_mgr *mgr,
ef8f9bea1368b89 Libin Yang           2015-12-02  3116  					struct drm_dp_mst_port *port)
ef8f9bea1368b89 Libin Yang           2015-12-02  3117  {
ef8f9bea1368b89 Libin Yang           2015-12-02  3118  	bool ret = false;
ef8f9bea1368b89 Libin Yang           2015-12-02  3119  
d0757afd00d71dc Lyude Paul           2019-01-10  3120  	port = drm_dp_mst_topology_get_port_validated(mgr, port);
ef8f9bea1368b89 Libin Yang           2015-12-02  3121  	if (!port)
ef8f9bea1368b89 Libin Yang           2015-12-02  3122  		return ret;
ef8f9bea1368b89 Libin Yang           2015-12-02  3123  	ret = port->has_audio;
d0757afd00d71dc Lyude Paul           2019-01-10  3124  	drm_dp_mst_topology_put_port(port);
ef8f9bea1368b89 Libin Yang           2015-12-02  3125  	return ret;
ef8f9bea1368b89 Libin Yang           2015-12-02  3126  }
ef8f9bea1368b89 Libin Yang           2015-12-02  3127  EXPORT_SYMBOL(drm_dp_mst_port_has_audio);
ef8f9bea1368b89 Libin Yang           2015-12-02  3128  
ef8f9bea1368b89 Libin Yang           2015-12-02  3129  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3130   * drm_dp_mst_get_edid() - get EDID for an MST port
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3131   * @connector: toplevel connector to get EDID for
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3132   * @mgr: manager for this port
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3133   * @port: unverified pointer to a port.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3134   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3135   * This returns an EDID for the port connected to a connector,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3136   * It validates the pointer still exists so the caller doesn't require a
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3137   * reference.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3138   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3139  struct edid *drm_dp_mst_get_edid(struct drm_connector *connector, struct drm_dp_mst_topology_mgr *mgr, struct drm_dp_mst_port *port)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3140  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3141  	struct edid *edid = NULL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3142  
1e55a53a28d3e52 Matt Roper           2019-02-01  3143  	/* we need to search for the port in the mgr in case it's gone */
d0757afd00d71dc Lyude Paul           2019-01-10  3144  	port = drm_dp_mst_topology_get_port_validated(mgr, port);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3145  	if (!port)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3146  		return NULL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3147  
c6a0aed4d493936 Dave Airlie          2014-10-20  3148  	if (port->cached_edid)
c6a0aed4d493936 Dave Airlie          2014-10-20  3149  		edid = drm_edid_duplicate(port->cached_edid);
8ae22cb419ad0ba Dave Airlie          2016-02-17  3150  	else {
8ae22cb419ad0ba Dave Airlie          2016-02-17  3151  		edid = drm_get_edid(connector, &port->aux.ddc);
8ae22cb419ad0ba Dave Airlie          2016-02-17  3152  	}
ef8f9bea1368b89 Libin Yang           2015-12-02  3153  	port->has_audio = drm_detect_monitor_audio(edid);
d0757afd00d71dc Lyude Paul           2019-01-10  3154  	drm_dp_mst_topology_put_port(port);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3155  	return edid;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3156  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3157  EXPORT_SYMBOL(drm_dp_mst_get_edid);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3158  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3159  /**
e4b0c868106d7ef Lyude Paul           2018-10-23  3160   * drm_dp_find_vcpi_slots() - Find VCPI slots for this PBN value
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3161   * @mgr: manager to use
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3162   * @pbn: payload bandwidth to convert into slots.
e4b0c868106d7ef Lyude Paul           2018-10-23  3163   *
e4b0c868106d7ef Lyude Paul           2018-10-23  3164   * Calculate the number of VCPI slots that will be required for the given PBN
e4b0c868106d7ef Lyude Paul           2018-10-23  3165   * value. This function is deprecated, and should not be used in atomic
e4b0c868106d7ef Lyude Paul           2018-10-23  3166   * drivers.
e4b0c868106d7ef Lyude Paul           2018-10-23  3167   *
e4b0c868106d7ef Lyude Paul           2018-10-23  3168   * RETURNS:
e4b0c868106d7ef Lyude Paul           2018-10-23  3169   * The total slots required for this port, or error.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3170   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3171  int drm_dp_find_vcpi_slots(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3172  			   int pbn)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3173  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3174  	int num_slots;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3175  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3176  	num_slots = DIV_ROUND_UP(pbn, mgr->pbn_div);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3177  
feb2c3bc331576e Pandiyan, Dhinakaran 2017-03-16  3178  	/* max. time slots - one slot for MTP header */
feb2c3bc331576e Pandiyan, Dhinakaran 2017-03-16  3179  	if (num_slots > 63)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3180  		return -ENOSPC;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3181  	return num_slots;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3182  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3183  EXPORT_SYMBOL(drm_dp_find_vcpi_slots);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3184  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3185  static int drm_dp_init_vcpi(struct drm_dp_mst_topology_mgr *mgr,
1e797f556c616a4 Pandiyan, Dhinakaran 2017-03-16  3186  			    struct drm_dp_vcpi *vcpi, int pbn, int slots)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3187  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3188  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3189  
feb2c3bc331576e Pandiyan, Dhinakaran 2017-03-16  3190  	/* max. time slots - one slot for MTP header */
1e797f556c616a4 Pandiyan, Dhinakaran 2017-03-16  3191  	if (slots > 63)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3192  		return -ENOSPC;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3193  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3194  	vcpi->pbn = pbn;
1e797f556c616a4 Pandiyan, Dhinakaran 2017-03-16  3195  	vcpi->aligned_pbn = slots * mgr->pbn_div;
1e797f556c616a4 Pandiyan, Dhinakaran 2017-03-16  3196  	vcpi->num_slots = slots;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3197  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3198  	ret = drm_dp_mst_assign_payload_id(mgr, vcpi);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3199  	if (ret < 0)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3200  		return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3201  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3202  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3203  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3204  /**
eceae147246749c Lyude Paul           2019-01-10  3205   * drm_dp_atomic_find_vcpi_slots() - Find and add VCPI slots to the state
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3206   * @state: global atomic state
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3207   * @mgr: MST topology manager for the port
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3208   * @port: port to find vcpi slots for
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3209   * @pbn: bandwidth required for the mode in PBN
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3210   *
eceae147246749c Lyude Paul           2019-01-10  3211   * Allocates VCPI slots to @port, replacing any previous VCPI allocations it
eceae147246749c Lyude Paul           2019-01-10  3212   * may have had. Any atomic drivers which support MST must call this function
eceae147246749c Lyude Paul           2019-01-10  3213   * in their &drm_encoder_helper_funcs.atomic_check() callback to change the
eceae147246749c Lyude Paul           2019-01-10  3214   * current VCPI allocation for the new state, but only when
eceae147246749c Lyude Paul           2019-01-10  3215   * &drm_crtc_state.mode_changed or &drm_crtc_state.connectors_changed is set
eceae147246749c Lyude Paul           2019-01-10  3216   * to ensure compatibility with userspace applications that still use the
eceae147246749c Lyude Paul           2019-01-10  3217   * legacy modesetting UAPI.
eceae147246749c Lyude Paul           2019-01-10  3218   *
eceae147246749c Lyude Paul           2019-01-10  3219   * Allocations set by this function are not checked against the bandwidth
eceae147246749c Lyude Paul           2019-01-10  3220   * restraints of @mgr until the driver calls drm_dp_mst_atomic_check().
eceae147246749c Lyude Paul           2019-01-10  3221   *
eceae147246749c Lyude Paul           2019-01-10  3222   * Additionally, it is OK to call this function multiple times on the same
eceae147246749c Lyude Paul           2019-01-10  3223   * @port as needed. It is not OK however, to call this function and
eceae147246749c Lyude Paul           2019-01-10  3224   * drm_dp_atomic_release_vcpi_slots() in the same atomic check phase.
eceae147246749c Lyude Paul           2019-01-10  3225   *
eceae147246749c Lyude Paul           2019-01-10  3226   * See also:
eceae147246749c Lyude Paul           2019-01-10  3227   * drm_dp_atomic_release_vcpi_slots()
eceae147246749c Lyude Paul           2019-01-10  3228   * drm_dp_mst_atomic_check()
eceae147246749c Lyude Paul           2019-01-10  3229   *
eceae147246749c Lyude Paul           2019-01-10  3230   * Returns:
eceae147246749c Lyude Paul           2019-01-10  3231   * Total slots in the atomic state assigned for this port, or a negative error
eceae147246749c Lyude Paul           2019-01-10  3232   * code if the port no longer exists
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3233   */
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3234  int drm_dp_atomic_find_vcpi_slots(struct drm_atomic_state *state,
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3235  				  struct drm_dp_mst_topology_mgr *mgr,
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3236  				  struct drm_dp_mst_port *port, int pbn)
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3237  {
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3238  	struct drm_dp_mst_topology_state *topology_state;
eceae147246749c Lyude Paul           2019-01-10  3239  	struct drm_dp_vcpi_allocation *pos, *vcpi = NULL;
eceae147246749c Lyude Paul           2019-01-10  3240  	int prev_slots, req_slots, ret;
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3241  
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3242  	topology_state = drm_atomic_get_mst_topology_state(state, mgr);
56a91c4932bd038 Ville Syrjälä        2017-07-12  3243  	if (IS_ERR(topology_state))
56a91c4932bd038 Ville Syrjälä        2017-07-12  3244  		return PTR_ERR(topology_state);
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3245  
eceae147246749c Lyude Paul           2019-01-10  3246  	/* Find the current allocation for this port, if any */
eceae147246749c Lyude Paul           2019-01-10  3247  	list_for_each_entry(pos, &topology_state->vcpis, next) {
eceae147246749c Lyude Paul           2019-01-10  3248  		if (pos->port == port) {
eceae147246749c Lyude Paul           2019-01-10  3249  			vcpi = pos;
eceae147246749c Lyude Paul           2019-01-10  3250  			prev_slots = vcpi->vcpi;
eceae147246749c Lyude Paul           2019-01-10  3251  
eceae147246749c Lyude Paul           2019-01-10  3252  			/*
eceae147246749c Lyude Paul           2019-01-10  3253  			 * This should never happen, unless the driver tries
eceae147246749c Lyude Paul           2019-01-10  3254  			 * releasing and allocating the same VCPI allocation,
eceae147246749c Lyude Paul           2019-01-10  3255  			 * which is an error
eceae147246749c Lyude Paul           2019-01-10  3256  			 */
eceae147246749c Lyude Paul           2019-01-10  3257  			if (WARN_ON(!prev_slots)) {
eceae147246749c Lyude Paul           2019-01-10  3258  				DRM_ERROR("cannot allocate and release VCPI on [MST PORT:%p] in the same state\n",
eceae147246749c Lyude Paul           2019-01-10  3259  					  port);
eceae147246749c Lyude Paul           2019-01-10  3260  				return -EINVAL;
eceae147246749c Lyude Paul           2019-01-10  3261  			}
eceae147246749c Lyude Paul           2019-01-10  3262  
eceae147246749c Lyude Paul           2019-01-10  3263  			break;
eceae147246749c Lyude Paul           2019-01-10  3264  		}
eceae147246749c Lyude Paul           2019-01-10  3265  	}
eceae147246749c Lyude Paul           2019-01-10  3266  	if (!vcpi)
eceae147246749c Lyude Paul           2019-01-10  3267  		prev_slots = 0;
eceae147246749c Lyude Paul           2019-01-10  3268  
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3269  	req_slots = DIV_ROUND_UP(pbn, mgr->pbn_div);
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3270  
eceae147246749c Lyude Paul           2019-01-10  3271  	DRM_DEBUG_ATOMIC("[CONNECTOR:%d:%s] [MST PORT:%p] VCPI %d -> %d\n",
eceae147246749c Lyude Paul           2019-01-10  3272  			 port->connector->base.id, port->connector->name,
eceae147246749c Lyude Paul           2019-01-10  3273  			 port, prev_slots, req_slots);
eceae147246749c Lyude Paul           2019-01-10  3274  
eceae147246749c Lyude Paul           2019-01-10  3275  	/* Add the new allocation to the state */
eceae147246749c Lyude Paul           2019-01-10  3276  	if (!vcpi) {
eceae147246749c Lyude Paul           2019-01-10  3277  		vcpi = kzalloc(sizeof(*vcpi), GFP_KERNEL);
a3d15c4b0ecd169 Lyude Paul           2019-02-01  3278  		if (!vcpi)
a3d15c4b0ecd169 Lyude Paul           2019-02-01  3279  			return -ENOMEM;
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3280  
eceae147246749c Lyude Paul           2019-01-10  3281  		drm_dp_mst_get_port_malloc(port);
eceae147246749c Lyude Paul           2019-01-10  3282  		vcpi->port = port;
eceae147246749c Lyude Paul           2019-01-10  3283  		list_add(&vcpi->next, &topology_state->vcpis);
eceae147246749c Lyude Paul           2019-01-10  3284  	}
eceae147246749c Lyude Paul           2019-01-10  3285  	vcpi->vcpi = req_slots;
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3286  
eceae147246749c Lyude Paul           2019-01-10  3287  	ret = req_slots;
eceae147246749c Lyude Paul           2019-01-10  3288  	return ret;
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3289  }
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3290  EXPORT_SYMBOL(drm_dp_atomic_find_vcpi_slots);
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3291  
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3292  /**
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3293   * drm_dp_atomic_release_vcpi_slots() - Release allocated vcpi slots
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3294   * @state: global atomic state
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3295   * @mgr: MST topology manager for the port
eceae147246749c Lyude Paul           2019-01-10  3296   * @port: The port to release the VCPI slots from
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3297   *
eceae147246749c Lyude Paul           2019-01-10  3298   * Releases any VCPI slots that have been allocated to a port in the atomic
eceae147246749c Lyude Paul           2019-01-10  3299   * state. Any atomic drivers which support MST must call this function in
eceae147246749c Lyude Paul           2019-01-10  3300   * their &drm_connector_helper_funcs.atomic_check() callback when the
1e55a53a28d3e52 Matt Roper           2019-02-01  3301   * connector will no longer have VCPI allocated (e.g. because its CRTC was
eceae147246749c Lyude Paul           2019-01-10  3302   * removed) when it had VCPI allocated in the previous atomic state.
eceae147246749c Lyude Paul           2019-01-10  3303   *
eceae147246749c Lyude Paul           2019-01-10  3304   * It is OK to call this even if @port has been removed from the system.
eceae147246749c Lyude Paul           2019-01-10  3305   * Additionally, it is OK to call this function multiple times on the same
eceae147246749c Lyude Paul           2019-01-10  3306   * @port as needed. It is not OK however, to call this function and
eceae147246749c Lyude Paul           2019-01-10  3307   * drm_dp_atomic_find_vcpi_slots() on the same @port in a single atomic check
eceae147246749c Lyude Paul           2019-01-10  3308   * phase.
eceae147246749c Lyude Paul           2019-01-10  3309   *
eceae147246749c Lyude Paul           2019-01-10  3310   * See also:
eceae147246749c Lyude Paul           2019-01-10  3311   * drm_dp_atomic_find_vcpi_slots()
eceae147246749c Lyude Paul           2019-01-10  3312   * drm_dp_mst_atomic_check()
eceae147246749c Lyude Paul           2019-01-10  3313   *
eceae147246749c Lyude Paul           2019-01-10  3314   * Returns:
eceae147246749c Lyude Paul           2019-01-10  3315   * 0 if all slots for this port were added back to
eceae147246749c Lyude Paul           2019-01-10  3316   * &drm_dp_mst_topology_state.avail_slots or negative error code
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3317   */
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3318  int drm_dp_atomic_release_vcpi_slots(struct drm_atomic_state *state,
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3319  				     struct drm_dp_mst_topology_mgr *mgr,
eceae147246749c Lyude Paul           2019-01-10  3320  				     struct drm_dp_mst_port *port)
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3321  {
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3322  	struct drm_dp_mst_topology_state *topology_state;
eceae147246749c Lyude Paul           2019-01-10  3323  	struct drm_dp_vcpi_allocation *pos;
eceae147246749c Lyude Paul           2019-01-10  3324  	bool found = false;
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3325  
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3326  	topology_state = drm_atomic_get_mst_topology_state(state, mgr);
56a91c4932bd038 Ville Syrjälä        2017-07-12  3327  	if (IS_ERR(topology_state))
56a91c4932bd038 Ville Syrjälä        2017-07-12  3328  		return PTR_ERR(topology_state);
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3329  
eceae147246749c Lyude Paul           2019-01-10  3330  	list_for_each_entry(pos, &topology_state->vcpis, next) {
eceae147246749c Lyude Paul           2019-01-10  3331  		if (pos->port == port) {
eceae147246749c Lyude Paul           2019-01-10  3332  			found = true;
eceae147246749c Lyude Paul           2019-01-10  3333  			break;
eceae147246749c Lyude Paul           2019-01-10  3334  		}
eceae147246749c Lyude Paul           2019-01-10  3335  	}
eceae147246749c Lyude Paul           2019-01-10  3336  	if (WARN_ON(!found)) {
eceae147246749c Lyude Paul           2019-01-10  3337  		DRM_ERROR("no VCPI for [MST PORT:%p] found in mst state %p\n",
eceae147246749c Lyude Paul           2019-01-10  3338  			  port, &topology_state->base);
eceae147246749c Lyude Paul           2019-01-10  3339  		return -EINVAL;
eceae147246749c Lyude Paul           2019-01-10  3340  	}
eceae147246749c Lyude Paul           2019-01-10  3341  
eceae147246749c Lyude Paul           2019-01-10  3342  	DRM_DEBUG_ATOMIC("[MST PORT:%p] VCPI %d -> 0\n", port, pos->vcpi);
eceae147246749c Lyude Paul           2019-01-10  3343  	if (pos->vcpi) {
eceae147246749c Lyude Paul           2019-01-10  3344  		drm_dp_mst_put_port_malloc(port);
eceae147246749c Lyude Paul           2019-01-10  3345  		pos->vcpi = 0;
eceae147246749c Lyude Paul           2019-01-10  3346  	}
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3347  
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3348  	return 0;
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3349  }
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3350  EXPORT_SYMBOL(drm_dp_atomic_release_vcpi_slots);
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3351  
edb1ed1ab7d314e Pandiyan, Dhinakaran 2017-04-20  3352  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3353   * drm_dp_mst_allocate_vcpi() - Allocate a virtual channel
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3354   * @mgr: manager for this port
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3355   * @port: port to allocate a virtual channel for.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3356   * @pbn: payload bandwidth number to request
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3357   * @slots: returned number of slots for this PBN.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3358   */
1e797f556c616a4 Pandiyan, Dhinakaran 2017-03-16  3359  bool drm_dp_mst_allocate_vcpi(struct drm_dp_mst_topology_mgr *mgr,
1e797f556c616a4 Pandiyan, Dhinakaran 2017-03-16  3360  			      struct drm_dp_mst_port *port, int pbn, int slots)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3361  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3362  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3363  
d0757afd00d71dc Lyude Paul           2019-01-10  3364  	port = drm_dp_mst_topology_get_port_validated(mgr, port);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3365  	if (!port)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3366  		return false;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3367  
1e797f556c616a4 Pandiyan, Dhinakaran 2017-03-16  3368  	if (slots < 0)
1e797f556c616a4 Pandiyan, Dhinakaran 2017-03-16  3369  		return false;
1e797f556c616a4 Pandiyan, Dhinakaran 2017-03-16  3370  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3371  	if (port->vcpi.vcpi > 0) {
e0ac7113fb23519 Lyude Paul           2019-01-10  3372  		DRM_DEBUG_KMS("payload: vcpi %d already allocated for pbn %d - requested pbn %d\n",
e0ac7113fb23519 Lyude Paul           2019-01-10  3373  			      port->vcpi.vcpi, port->vcpi.pbn, pbn);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3374  		if (pbn == port->vcpi.pbn) {
d0757afd00d71dc Lyude Paul           2019-01-10  3375  			drm_dp_mst_topology_put_port(port);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3376  			return true;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3377  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3378  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3379  
1e797f556c616a4 Pandiyan, Dhinakaran 2017-03-16  3380  	ret = drm_dp_init_vcpi(mgr, &port->vcpi, pbn, slots);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3381  	if (ret) {
feb2c3bc331576e Pandiyan, Dhinakaran 2017-03-16  3382  		DRM_DEBUG_KMS("failed to init vcpi slots=%d max=63 ret=%d\n",
feb2c3bc331576e Pandiyan, Dhinakaran 2017-03-16  3383  			      DIV_ROUND_UP(pbn, mgr->pbn_div), ret);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3384  		goto out;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3385  	}
feb2c3bc331576e Pandiyan, Dhinakaran 2017-03-16  3386  	DRM_DEBUG_KMS("initing vcpi for pbn=%d slots=%d\n",
feb2c3bc331576e Pandiyan, Dhinakaran 2017-03-16  3387  		      pbn, port->vcpi.num_slots);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3388  
1e55a53a28d3e52 Matt Roper           2019-02-01  3389  	/* Keep port allocated until its payload has been removed */
cfe9f90358d97a8 Lyude Paul           2019-01-10  3390  	drm_dp_mst_get_port_malloc(port);
d0757afd00d71dc Lyude Paul           2019-01-10  3391  	drm_dp_mst_topology_put_port(port);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3392  	return true;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3393  out:
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3394  	return false;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3395  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3396  EXPORT_SYMBOL(drm_dp_mst_allocate_vcpi);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3397  
87f5942d1f7bc32 Dave Airlie          2015-02-24  3398  int drm_dp_mst_get_vcpi_slots(struct drm_dp_mst_topology_mgr *mgr, struct drm_dp_mst_port *port)
87f5942d1f7bc32 Dave Airlie          2015-02-24  3399  {
87f5942d1f7bc32 Dave Airlie          2015-02-24  3400  	int slots = 0;
d0757afd00d71dc Lyude Paul           2019-01-10  3401  	port = drm_dp_mst_topology_get_port_validated(mgr, port);
87f5942d1f7bc32 Dave Airlie          2015-02-24  3402  	if (!port)
87f5942d1f7bc32 Dave Airlie          2015-02-24  3403  		return slots;
87f5942d1f7bc32 Dave Airlie          2015-02-24  3404  
87f5942d1f7bc32 Dave Airlie          2015-02-24  3405  	slots = port->vcpi.num_slots;
d0757afd00d71dc Lyude Paul           2019-01-10  3406  	drm_dp_mst_topology_put_port(port);
87f5942d1f7bc32 Dave Airlie          2015-02-24  3407  	return slots;
87f5942d1f7bc32 Dave Airlie          2015-02-24  3408  }
87f5942d1f7bc32 Dave Airlie          2015-02-24  3409  EXPORT_SYMBOL(drm_dp_mst_get_vcpi_slots);
87f5942d1f7bc32 Dave Airlie          2015-02-24  3410  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3411  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3412   * drm_dp_mst_reset_vcpi_slots() - Reset number of slots to 0 for VCPI
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3413   * @mgr: manager for this port
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3414   * @port: unverified pointer to a port.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3415   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3416   * This just resets the number of slots for the ports VCPI for later programming.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3417   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3418  void drm_dp_mst_reset_vcpi_slots(struct drm_dp_mst_topology_mgr *mgr, struct drm_dp_mst_port *port)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3419  {
cfe9f90358d97a8 Lyude Paul           2019-01-10  3420  	/*
1e55a53a28d3e52 Matt Roper           2019-02-01  3421  	 * A port with VCPI will remain allocated until its VCPI is
cfe9f90358d97a8 Lyude Paul           2019-01-10  3422  	 * released, no verified ref needed
cfe9f90358d97a8 Lyude Paul           2019-01-10  3423  	 */
cfe9f90358d97a8 Lyude Paul           2019-01-10  3424  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3425  	port->vcpi.num_slots = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3426  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3427  EXPORT_SYMBOL(drm_dp_mst_reset_vcpi_slots);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3428  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3429  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3430   * drm_dp_mst_deallocate_vcpi() - deallocate a VCPI
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3431   * @mgr: manager for this port
3a8844c298522fa Lyude Paul           2019-02-01  3432   * @port: port to deallocate vcpi for
3a8844c298522fa Lyude Paul           2019-02-01  3433   *
3a8844c298522fa Lyude Paul           2019-02-01  3434   * This can be called unconditionally, regardless of whether
3a8844c298522fa Lyude Paul           2019-02-01  3435   * drm_dp_mst_allocate_vcpi() succeeded or not.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3436   */
4afb8a26b53a6d9 Lyude Paul           2019-01-10  3437  void drm_dp_mst_deallocate_vcpi(struct drm_dp_mst_topology_mgr *mgr,
4afb8a26b53a6d9 Lyude Paul           2019-01-10  3438  				struct drm_dp_mst_port *port)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3439  {
3a8844c298522fa Lyude Paul           2019-02-01  3440  	if (!port->vcpi.vcpi)
3a8844c298522fa Lyude Paul           2019-02-01  3441  		return;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3442  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3443  	drm_dp_mst_put_payload_id(mgr, port->vcpi.vcpi);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3444  	port->vcpi.num_slots = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3445  	port->vcpi.pbn = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3446  	port->vcpi.aligned_pbn = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3447  	port->vcpi.vcpi = 0;
cfe9f90358d97a8 Lyude Paul           2019-01-10  3448  	drm_dp_mst_put_port_malloc(port);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3449  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3450  EXPORT_SYMBOL(drm_dp_mst_deallocate_vcpi);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3451  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3452  static int drm_dp_dpcd_write_payload(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3453  				     int id, struct drm_dp_payload *payload)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3454  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3455  	u8 payload_alloc[3], status;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3456  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3457  	int retries = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3458  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3459  	drm_dp_dpcd_writeb(mgr->aux, DP_PAYLOAD_TABLE_UPDATE_STATUS,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3460  			   DP_PAYLOAD_TABLE_UPDATED);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3461  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3462  	payload_alloc[0] = id;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3463  	payload_alloc[1] = payload->start_slot;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3464  	payload_alloc[2] = payload->num_slots;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3465  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3466  	ret = drm_dp_dpcd_write(mgr->aux, DP_PAYLOAD_ALLOCATE_SET, payload_alloc, 3);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3467  	if (ret != 3) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3468  		DRM_DEBUG_KMS("failed to write payload allocation %d\n", ret);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3469  		goto fail;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3470  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3471  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3472  retry:
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3473  	ret = drm_dp_dpcd_readb(mgr->aux, DP_PAYLOAD_TABLE_UPDATE_STATUS, &status);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3474  	if (ret < 0) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3475  		DRM_DEBUG_KMS("failed to read payload table status %d\n", ret);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3476  		goto fail;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3477  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3478  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3479  	if (!(status & DP_PAYLOAD_TABLE_UPDATED)) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3480  		retries++;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3481  		if (retries < 20) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3482  			usleep_range(10000, 20000);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3483  			goto retry;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3484  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3485  		DRM_DEBUG_KMS("status not set after read payload table status %d\n", status);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3486  		ret = -EINVAL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3487  		goto fail;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3488  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3489  	ret = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3490  fail:
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3491  	return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3492  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3493  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3494  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3495  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3496   * drm_dp_check_act_status() - Check ACT handled status.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3497   * @mgr: manager to use
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3498   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3499   * Check the payload status bits in the DPCD for ACT handled completion.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3500   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3501  int drm_dp_check_act_status(struct drm_dp_mst_topology_mgr *mgr)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3502  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3503  	u8 status;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3504  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3505  	int count = 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3506  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3507  	do {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3508  		ret = drm_dp_dpcd_readb(mgr->aux, DP_PAYLOAD_TABLE_UPDATE_STATUS, &status);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3509  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3510  		if (ret < 0) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3511  			DRM_DEBUG_KMS("failed to read payload table status %d\n", ret);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3512  			goto fail;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3513  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3514  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3515  		if (status & DP_PAYLOAD_ACT_HANDLED)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3516  			break;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3517  		count++;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3518  		udelay(100);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3519  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3520  	} while (count < 30);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3521  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3522  	if (!(status & DP_PAYLOAD_ACT_HANDLED)) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3523  		DRM_DEBUG_KMS("failed to get ACT bit %d after %d retries\n", status, count);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3524  		ret = -EINVAL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3525  		goto fail;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3526  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3527  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3528  fail:
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3529  	return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3530  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3531  EXPORT_SYMBOL(drm_dp_check_act_status);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3532  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3533  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3534   * drm_dp_calc_pbn_mode() - Calculate the PBN for a mode.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3535   * @clock: dot clock for the mode
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3536   * @bpp: bpp for the mode.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3537   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3538   * This uses the formula in the spec to calculate the PBN value for a mode.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3539   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3540  int drm_dp_calc_pbn_mode(int clock, int bpp)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3541  {
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3542  	u64 kbps;
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3543  	s64 peak_kbps;
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3544  	u32 numerator;
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3545  	u32 denominator;
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3546  
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3547  	kbps = clock * bpp;
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3548  
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3549  	/*
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3550  	 * margin 5300ppm + 300ppm ~ 0.6% as per spec, factor is 1.006
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3551  	 * The unit of 54/64Mbytes/sec is an arbitrary unit chosen based on
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3552  	 * common multiplier to render an integer PBN for all link rate/lane
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3553  	 * counts combinations
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3554  	 * calculate
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3555  	 * peak_kbps *= (1006/1000)
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3556  	 * peak_kbps *= (64/54)
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3557  	 * peak_kbps *= 8    convert to bytes
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3558  	 */
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3559  
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3560  	numerator = 64 * 1006;
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3561  	denominator = 54 * 8 * 1000 * 1000;
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3562  
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3563  	kbps *= numerator;
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3564  	peak_kbps = drm_fixp_from_fraction(kbps, denominator);
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3565  
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3566  	return drm_fixp2int_ceil(peak_kbps);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3567  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3568  EXPORT_SYMBOL(drm_dp_calc_pbn_mode);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3569  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3570  static int test_calc_pbn_mode(void)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3571  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3572  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3573  	ret = drm_dp_calc_pbn_mode(154000, 30);
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3574  	if (ret != 689) {
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3575  		DRM_ERROR("PBN calculation test failed - clock %d, bpp %d, expected PBN %d, actual PBN %d.\n",
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3576  				154000, 30, 689, ret);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3577  		return -EINVAL;
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3578  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3579  	ret = drm_dp_calc_pbn_mode(234000, 30);
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3580  	if (ret != 1047) {
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3581  		DRM_ERROR("PBN calculation test failed - clock %d, bpp %d, expected PBN %d, actual PBN %d.\n",
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3582  				234000, 30, 1047, ret);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3583  		return -EINVAL;
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3584  	}
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3585  	ret = drm_dp_calc_pbn_mode(297000, 24);
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3586  	if (ret != 1063) {
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3587  		DRM_ERROR("PBN calculation test failed - clock %d, bpp %d, expected PBN %d, actual PBN %d.\n",
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3588  				297000, 24, 1063, ret);
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3589  		return -EINVAL;
a9ebb3e46c7ef61 Harry Wentland       2016-01-22  3590  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3591  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3592  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3593  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3594  /* we want to kick the TX after we've ack the up/down IRQs. */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3595  static void drm_dp_mst_kick_tx(struct drm_dp_mst_topology_mgr *mgr)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3596  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3597  	queue_work(system_long_wq, &mgr->tx_work);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3598  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3599  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3600  static void drm_dp_mst_dump_mstb(struct seq_file *m,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3601  				 struct drm_dp_mst_branch *mstb)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3602  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3603  	struct drm_dp_mst_port *port;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3604  	int tabs = mstb->lct;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3605  	char prefix[10];
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3606  	int i;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3607  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3608  	for (i = 0; i < tabs; i++)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3609  		prefix[i] = '\t';
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3610  	prefix[i] = '\0';
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3611  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3612  	seq_printf(m, "%smst: %p, %d\n", prefix, mstb, mstb->num_ports);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3613  	list_for_each_entry(port, &mstb->ports, next) {
51108f252b02d3b Jim Bride            2016-04-14  3614  		seq_printf(m, "%sport: %d: input: %d: pdt: %d, ddps: %d ldps: %d, sdp: %d/%d, %p, conn: %p\n", prefix, port->port_num, port->input, port->pdt, port->ddps, port->ldps, port->num_sdp_streams, port->num_sdp_stream_sinks, port, port->connector);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3615  		if (port->mstb)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3616  			drm_dp_mst_dump_mstb(m, port->mstb);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3617  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3618  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3619  
7056a2bccc3b5af Andy Shevchenko      2018-03-19  3620  #define DP_PAYLOAD_TABLE_SIZE		64
7056a2bccc3b5af Andy Shevchenko      2018-03-19  3621  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3622  static bool dump_dp_payload_table(struct drm_dp_mst_topology_mgr *mgr,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3623  				  char *buf)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3624  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3625  	int i;
46466b0dac3f6be Joe Perches          2017-05-30  3626  
7056a2bccc3b5af Andy Shevchenko      2018-03-19  3627  	for (i = 0; i < DP_PAYLOAD_TABLE_SIZE; i += 16) {
46466b0dac3f6be Joe Perches          2017-05-30  3628  		if (drm_dp_dpcd_read(mgr->aux,
46466b0dac3f6be Joe Perches          2017-05-30  3629  				     DP_PAYLOAD_TABLE_UPDATE_STATUS + i,
46466b0dac3f6be Joe Perches          2017-05-30  3630  				     &buf[i], 16) != 16)
46466b0dac3f6be Joe Perches          2017-05-30  3631  			return false;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3632  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3633  	return true;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3634  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3635  
51108f252b02d3b Jim Bride            2016-04-14  3636  static void fetch_monitor_name(struct drm_dp_mst_topology_mgr *mgr,
51108f252b02d3b Jim Bride            2016-04-14  3637  			       struct drm_dp_mst_port *port, char *name,
51108f252b02d3b Jim Bride            2016-04-14  3638  			       int namelen)
51108f252b02d3b Jim Bride            2016-04-14  3639  {
51108f252b02d3b Jim Bride            2016-04-14  3640  	struct edid *mst_edid;
51108f252b02d3b Jim Bride            2016-04-14  3641  
51108f252b02d3b Jim Bride            2016-04-14  3642  	mst_edid = drm_dp_mst_get_edid(port->connector, mgr, port);
51108f252b02d3b Jim Bride            2016-04-14  3643  	drm_edid_get_monitor_name(mst_edid, name, namelen);
51108f252b02d3b Jim Bride            2016-04-14  3644  }
51108f252b02d3b Jim Bride            2016-04-14  3645  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3646  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3647   * drm_dp_mst_dump_topology(): dump topology to seq file.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3648   * @m: seq_file to dump output to
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3649   * @mgr: manager to dump current topology for.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3650   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3651   * helper to dump MST topology to a seq file for debugfs.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3652   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3653  void drm_dp_mst_dump_topology(struct seq_file *m,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3654  			      struct drm_dp_mst_topology_mgr *mgr)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3655  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3656  	int i;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3657  	struct drm_dp_mst_port *port;
51108f252b02d3b Jim Bride            2016-04-14  3658  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3659  	mutex_lock(&mgr->lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3660  	if (mgr->mst_primary)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3661  		drm_dp_mst_dump_mstb(m, mgr->mst_primary);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3662  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3663  	/* dump VCPIs */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3664  	mutex_unlock(&mgr->lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3665  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3666  	mutex_lock(&mgr->payload_lock);
51108f252b02d3b Jim Bride            2016-04-14  3667  	seq_printf(m, "vcpi: %lx %lx %d\n", mgr->payload_mask, mgr->vcpi_mask,
51108f252b02d3b Jim Bride            2016-04-14  3668  		mgr->max_payloads);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3669  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3670  	for (i = 0; i < mgr->max_payloads; i++) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3671  		if (mgr->proposed_vcpis[i]) {
51108f252b02d3b Jim Bride            2016-04-14  3672  			char name[14];
51108f252b02d3b Jim Bride            2016-04-14  3673  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3674  			port = container_of(mgr->proposed_vcpis[i], struct drm_dp_mst_port, vcpi);
51108f252b02d3b Jim Bride            2016-04-14  3675  			fetch_monitor_name(mgr, port, name, sizeof(name));
51108f252b02d3b Jim Bride            2016-04-14  3676  			seq_printf(m, "vcpi %d: %d %d %d sink name: %s\n", i,
51108f252b02d3b Jim Bride            2016-04-14  3677  				   port->port_num, port->vcpi.vcpi,
51108f252b02d3b Jim Bride            2016-04-14  3678  				   port->vcpi.num_slots,
51108f252b02d3b Jim Bride            2016-04-14  3679  				   (*name != 0) ? name :  "Unknown");
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3680  		} else
51108f252b02d3b Jim Bride            2016-04-14  3681  			seq_printf(m, "vcpi %d:unused\n", i);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3682  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3683  	for (i = 0; i < mgr->max_payloads; i++) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3684  		seq_printf(m, "payload %d: %d, %d, %d\n",
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3685  			   i,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3686  			   mgr->payloads[i].payload_state,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3687  			   mgr->payloads[i].start_slot,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3688  			   mgr->payloads[i].num_slots);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3689  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3690  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3691  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3692  	mutex_unlock(&mgr->payload_lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3693  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3694  	mutex_lock(&mgr->lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3695  	if (mgr->mst_primary) {
7056a2bccc3b5af Andy Shevchenko      2018-03-19  3696  		u8 buf[DP_PAYLOAD_TABLE_SIZE];
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3697  		int ret;
46466b0dac3f6be Joe Perches          2017-05-30  3698  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3699  		ret = drm_dp_dpcd_read(mgr->aux, DP_DPCD_REV, buf, DP_RECEIVER_CAP_SIZE);
46466b0dac3f6be Joe Perches          2017-05-30  3700  		seq_printf(m, "dpcd: %*ph\n", DP_RECEIVER_CAP_SIZE, buf);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3701  		ret = drm_dp_dpcd_read(mgr->aux, DP_FAUX_CAP, buf, 2);
46466b0dac3f6be Joe Perches          2017-05-30  3702  		seq_printf(m, "faux/mst: %*ph\n", 2, buf);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3703  		ret = drm_dp_dpcd_read(mgr->aux, DP_MSTM_CTRL, buf, 1);
46466b0dac3f6be Joe Perches          2017-05-30  3704  		seq_printf(m, "mst ctrl: %*ph\n", 1, buf);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3705  
44790462d041d30 Dave Airlie          2015-07-14  3706  		/* dump the standard OUI branch header */
44790462d041d30 Dave Airlie          2015-07-14  3707  		ret = drm_dp_dpcd_read(mgr->aux, DP_BRANCH_OUI, buf, DP_BRANCH_OUI_HEADER_SIZE);
46466b0dac3f6be Joe Perches          2017-05-30  3708  		seq_printf(m, "branch oui: %*phN devid: ", 3, buf);
51108f252b02d3b Jim Bride            2016-04-14  3709  		for (i = 0x3; i < 0x8 && buf[i]; i++)
44790462d041d30 Dave Airlie          2015-07-14  3710  			seq_printf(m, "%c", buf[i]);
46466b0dac3f6be Joe Perches          2017-05-30  3711  		seq_printf(m, " revision: hw: %x.%x sw: %x.%x\n",
46466b0dac3f6be Joe Perches          2017-05-30  3712  			   buf[0x9] >> 4, buf[0x9] & 0xf, buf[0xa], buf[0xb]);
46466b0dac3f6be Joe Perches          2017-05-30  3713  		if (dump_dp_payload_table(mgr, buf))
7056a2bccc3b5af Andy Shevchenko      2018-03-19  3714  			seq_printf(m, "payload table: %*ph\n", DP_PAYLOAD_TABLE_SIZE, buf);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3715  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3716  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3717  	mutex_unlock(&mgr->lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3718  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3719  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3720  EXPORT_SYMBOL(drm_dp_mst_dump_topology);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3721  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3722  static void drm_dp_tx_work(struct work_struct *work)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3723  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3724  	struct drm_dp_mst_topology_mgr *mgr = container_of(work, struct drm_dp_mst_topology_mgr, tx_work);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3725  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3726  	mutex_lock(&mgr->qlock);
cb021a3eb6e9870 Daniel Vetter        2016-07-15  3727  	if (!list_empty(&mgr->tx_msg_downq))
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3728  		process_single_down_tx_qlock(mgr);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3729  	mutex_unlock(&mgr->qlock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3730  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3731  
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3732  static void drm_dp_destroy_connector_work(struct work_struct *work)
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3733  {
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3734  	struct drm_dp_mst_topology_mgr *mgr = container_of(work, struct drm_dp_mst_topology_mgr, destroy_connector_work);
4772ff03df8094f Maarten Lankhorst    2015-08-11  3735  	struct drm_dp_mst_port *port;
df4839fdc9b3c92 Dave Airlie          2015-09-16  3736  	bool send_hotplug = false;
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3737  	/*
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3738  	 * Not a regular list traverse as we have to drop the destroy
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3739  	 * connector lock before destroying the connector, to avoid AB->BA
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3740  	 * ordering between this lock and the config mutex.
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3741  	 */
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3742  	for (;;) {
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3743  		mutex_lock(&mgr->destroy_connector_lock);
4772ff03df8094f Maarten Lankhorst    2015-08-11  3744  		port = list_first_entry_or_null(&mgr->destroy_connector_list, struct drm_dp_mst_port, next);
4772ff03df8094f Maarten Lankhorst    2015-08-11  3745  		if (!port) {
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3746  			mutex_unlock(&mgr->destroy_connector_lock);
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3747  			break;
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3748  		}
4772ff03df8094f Maarten Lankhorst    2015-08-11  3749  		list_del(&port->next);
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3750  		mutex_unlock(&mgr->destroy_connector_lock);
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3751  
91a25e463130c8e Mykola Lysenko       2016-01-27  3752  		INIT_LIST_HEAD(&port->next);
91a25e463130c8e Mykola Lysenko       2016-01-27  3753  
4772ff03df8094f Maarten Lankhorst    2015-08-11  3754  		mgr->cbs->destroy_connector(mgr, port->connector);
4772ff03df8094f Maarten Lankhorst    2015-08-11  3755  
4772ff03df8094f Maarten Lankhorst    2015-08-11  3756  		drm_dp_port_teardown_pdt(port, port->pdt);
36e3fa6a38e135e Ville Syrjälä        2016-10-26  3757  		port->pdt = DP_PEER_DEVICE_NONE;
4772ff03df8094f Maarten Lankhorst    2015-08-11  3758  
ebcc0e6b509108b Lyude Paul           2019-01-10  3759  		drm_dp_mst_put_port_malloc(port);
df4839fdc9b3c92 Dave Airlie          2015-09-16  3760  		send_hotplug = true;
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3761  	}
df4839fdc9b3c92 Dave Airlie          2015-09-16  3762  	if (send_hotplug)
16bff572cc660f1 Daniel Vetter        2018-11-28  3763  		drm_kms_helper_hotplug_event(mgr->dev);
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3764  }
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3765  
a4370c777406c28 Ville Syrjälä        2017-07-12  3766  static struct drm_private_state *
a4370c777406c28 Ville Syrjälä        2017-07-12  3767  drm_dp_mst_duplicate_state(struct drm_private_obj *obj)
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3768  {
eceae147246749c Lyude Paul           2019-01-10  3769  	struct drm_dp_mst_topology_state *state, *old_state =
eceae147246749c Lyude Paul           2019-01-10  3770  		to_dp_mst_topology_state(obj->state);
eceae147246749c Lyude Paul           2019-01-10  3771  	struct drm_dp_vcpi_allocation *pos, *vcpi;
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3772  
eceae147246749c Lyude Paul           2019-01-10  3773  	state = kmemdup(old_state, sizeof(*state), GFP_KERNEL);
a4370c777406c28 Ville Syrjälä        2017-07-12  3774  	if (!state)
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3775  		return NULL;
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3776  
a4370c777406c28 Ville Syrjälä        2017-07-12  3777  	__drm_atomic_helper_private_obj_duplicate_state(obj, &state->base);
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3778  
eceae147246749c Lyude Paul           2019-01-10  3779  	INIT_LIST_HEAD(&state->vcpis);
eceae147246749c Lyude Paul           2019-01-10  3780  
eceae147246749c Lyude Paul           2019-01-10  3781  	list_for_each_entry(pos, &old_state->vcpis, next) {
eceae147246749c Lyude Paul           2019-01-10  3782  		/* Prune leftover freed VCPI allocations */
eceae147246749c Lyude Paul           2019-01-10  3783  		if (!pos->vcpi)
eceae147246749c Lyude Paul           2019-01-10  3784  			continue;
eceae147246749c Lyude Paul           2019-01-10  3785  
eceae147246749c Lyude Paul           2019-01-10  3786  		vcpi = kmemdup(pos, sizeof(*vcpi), GFP_KERNEL);
eceae147246749c Lyude Paul           2019-01-10  3787  		if (!vcpi)
eceae147246749c Lyude Paul           2019-01-10  3788  			goto fail;
eceae147246749c Lyude Paul           2019-01-10  3789  
eceae147246749c Lyude Paul           2019-01-10  3790  		drm_dp_mst_get_port_malloc(vcpi->port);
eceae147246749c Lyude Paul           2019-01-10  3791  		list_add(&vcpi->next, &state->vcpis);
eceae147246749c Lyude Paul           2019-01-10  3792  	}
eceae147246749c Lyude Paul           2019-01-10  3793  
a4370c777406c28 Ville Syrjälä        2017-07-12  3794  	return &state->base;
eceae147246749c Lyude Paul           2019-01-10  3795  
eceae147246749c Lyude Paul           2019-01-10  3796  fail:
eceae147246749c Lyude Paul           2019-01-10  3797  	list_for_each_entry_safe(pos, vcpi, &state->vcpis, next) {
eceae147246749c Lyude Paul           2019-01-10  3798  		drm_dp_mst_put_port_malloc(pos->port);
eceae147246749c Lyude Paul           2019-01-10  3799  		kfree(pos);
eceae147246749c Lyude Paul           2019-01-10  3800  	}
eceae147246749c Lyude Paul           2019-01-10  3801  	kfree(state);
eceae147246749c Lyude Paul           2019-01-10  3802  
eceae147246749c Lyude Paul           2019-01-10  3803  	return NULL;
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3804  }
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3805  
a4370c777406c28 Ville Syrjälä        2017-07-12  3806  static void drm_dp_mst_destroy_state(struct drm_private_obj *obj,
a4370c777406c28 Ville Syrjälä        2017-07-12  3807  				     struct drm_private_state *state)
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3808  {
a4370c777406c28 Ville Syrjälä        2017-07-12  3809  	struct drm_dp_mst_topology_state *mst_state =
a4370c777406c28 Ville Syrjälä        2017-07-12  3810  		to_dp_mst_topology_state(state);
eceae147246749c Lyude Paul           2019-01-10  3811  	struct drm_dp_vcpi_allocation *pos, *tmp;
eceae147246749c Lyude Paul           2019-01-10  3812  
eceae147246749c Lyude Paul           2019-01-10  3813  	list_for_each_entry_safe(pos, tmp, &mst_state->vcpis, next) {
eceae147246749c Lyude Paul           2019-01-10  3814  		/* We only keep references to ports with non-zero VCPIs */
eceae147246749c Lyude Paul           2019-01-10  3815  		if (pos->vcpi)
eceae147246749c Lyude Paul           2019-01-10  3816  			drm_dp_mst_put_port_malloc(pos->port);
eceae147246749c Lyude Paul           2019-01-10  3817  		kfree(pos);
eceae147246749c Lyude Paul           2019-01-10  3818  	}
a4370c777406c28 Ville Syrjälä        2017-07-12  3819  
a4370c777406c28 Ville Syrjälä        2017-07-12  3820  	kfree(mst_state);
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3821  }
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3822  
eceae147246749c Lyude Paul           2019-01-10  3823  static inline int
eceae147246749c Lyude Paul           2019-01-10  3824  drm_dp_mst_atomic_check_topology_state(struct drm_dp_mst_topology_mgr *mgr,
eceae147246749c Lyude Paul           2019-01-10  3825  				       struct drm_dp_mst_topology_state *mst_state)
eceae147246749c Lyude Paul           2019-01-10  3826  {
eceae147246749c Lyude Paul           2019-01-10  3827  	struct drm_dp_vcpi_allocation *vcpi;
5e187a01426d220 Lyude Paul           2019-01-10  3828  	int avail_slots = 63, payload_count = 0;
eceae147246749c Lyude Paul           2019-01-10  3829  
eceae147246749c Lyude Paul           2019-01-10  3830  	list_for_each_entry(vcpi, &mst_state->vcpis, next) {
eceae147246749c Lyude Paul           2019-01-10  3831  		/* Releasing VCPI is always OK-even if the port is gone */
eceae147246749c Lyude Paul           2019-01-10  3832  		if (!vcpi->vcpi) {
eceae147246749c Lyude Paul           2019-01-10  3833  			DRM_DEBUG_ATOMIC("[MST PORT:%p] releases all VCPI slots\n",
eceae147246749c Lyude Paul           2019-01-10  3834  					 vcpi->port);
eceae147246749c Lyude Paul           2019-01-10  3835  			continue;
eceae147246749c Lyude Paul           2019-01-10  3836  		}
eceae147246749c Lyude Paul           2019-01-10  3837  
eceae147246749c Lyude Paul           2019-01-10  3838  		DRM_DEBUG_ATOMIC("[MST PORT:%p] requires %d vcpi slots\n",
eceae147246749c Lyude Paul           2019-01-10  3839  				 vcpi->port, vcpi->vcpi);
eceae147246749c Lyude Paul           2019-01-10  3840  
eceae147246749c Lyude Paul           2019-01-10  3841  		avail_slots -= vcpi->vcpi;
eceae147246749c Lyude Paul           2019-01-10  3842  		if (avail_slots < 0) {
eceae147246749c Lyude Paul           2019-01-10  3843  			DRM_DEBUG_ATOMIC("[MST PORT:%p] not enough VCPI slots in mst state %p (avail=%d)\n",
eceae147246749c Lyude Paul           2019-01-10  3844  					 vcpi->port, mst_state,
eceae147246749c Lyude Paul           2019-01-10  3845  					 avail_slots + vcpi->vcpi);
eceae147246749c Lyude Paul           2019-01-10  3846  			return -ENOSPC;
eceae147246749c Lyude Paul           2019-01-10  3847  		}
5e187a01426d220 Lyude Paul           2019-01-10  3848  
5e187a01426d220 Lyude Paul           2019-01-10  3849  		if (++payload_count > mgr->max_payloads) {
5e187a01426d220 Lyude Paul           2019-01-10  3850  			DRM_DEBUG_ATOMIC("[MST MGR:%p] state %p has too many payloads (max=%d)\n",
5e187a01426d220 Lyude Paul           2019-01-10  3851  					 mgr, mst_state, mgr->max_payloads);
5e187a01426d220 Lyude Paul           2019-01-10  3852  			return -EINVAL;
5e187a01426d220 Lyude Paul           2019-01-10  3853  		}
eceae147246749c Lyude Paul           2019-01-10  3854  	}
eceae147246749c Lyude Paul           2019-01-10  3855  	DRM_DEBUG_ATOMIC("[MST MGR:%p] mst state %p VCPI avail=%d used=%d\n",
eceae147246749c Lyude Paul           2019-01-10  3856  			 mgr, mst_state, avail_slots,
eceae147246749c Lyude Paul           2019-01-10  3857  			 63 - avail_slots);
eceae147246749c Lyude Paul           2019-01-10  3858  
eceae147246749c Lyude Paul           2019-01-10  3859  	return 0;
eceae147246749c Lyude Paul           2019-01-10  3860  }
eceae147246749c Lyude Paul           2019-01-10  3861  
eceae147246749c Lyude Paul           2019-01-10  3862  /**
eceae147246749c Lyude Paul           2019-01-10  3863   * drm_dp_mst_atomic_check - Check that the new state of an MST topology in an
eceae147246749c Lyude Paul           2019-01-10  3864   * atomic update is valid
eceae147246749c Lyude Paul           2019-01-10  3865   * @state: Pointer to the new &struct drm_dp_mst_topology_state
eceae147246749c Lyude Paul           2019-01-10  3866   *
eceae147246749c Lyude Paul           2019-01-10  3867   * Checks the given topology state for an atomic update to ensure that it's
eceae147246749c Lyude Paul           2019-01-10  3868   * valid. This includes checking whether there's enough bandwidth to support
eceae147246749c Lyude Paul           2019-01-10  3869   * the new VCPI allocations in the atomic update.
eceae147246749c Lyude Paul           2019-01-10  3870   *
eceae147246749c Lyude Paul           2019-01-10  3871   * Any atomic drivers supporting DP MST must make sure to call this after
eceae147246749c Lyude Paul           2019-01-10  3872   * checking the rest of their state in their
eceae147246749c Lyude Paul           2019-01-10  3873   * &drm_mode_config_funcs.atomic_check() callback.
eceae147246749c Lyude Paul           2019-01-10  3874   *
eceae147246749c Lyude Paul           2019-01-10  3875   * See also:
eceae147246749c Lyude Paul           2019-01-10  3876   * drm_dp_atomic_find_vcpi_slots()
eceae147246749c Lyude Paul           2019-01-10  3877   * drm_dp_atomic_release_vcpi_slots()
eceae147246749c Lyude Paul           2019-01-10  3878   *
eceae147246749c Lyude Paul           2019-01-10  3879   * Returns:
eceae147246749c Lyude Paul           2019-01-10  3880   *
eceae147246749c Lyude Paul           2019-01-10  3881   * 0 if the new state is valid, negative error code otherwise.
eceae147246749c Lyude Paul           2019-01-10  3882   */
eceae147246749c Lyude Paul           2019-01-10  3883  int drm_dp_mst_atomic_check(struct drm_atomic_state *state)
eceae147246749c Lyude Paul           2019-01-10  3884  {
eceae147246749c Lyude Paul           2019-01-10  3885  	struct drm_dp_mst_topology_mgr *mgr;
eceae147246749c Lyude Paul           2019-01-10  3886  	struct drm_dp_mst_topology_state *mst_state;
eceae147246749c Lyude Paul           2019-01-10  3887  	int i, ret = 0;
eceae147246749c Lyude Paul           2019-01-10  3888  
eceae147246749c Lyude Paul           2019-01-10  3889  	for_each_new_mst_mgr_in_state(state, mgr, mst_state, i) {
eceae147246749c Lyude Paul           2019-01-10  3890  		ret = drm_dp_mst_atomic_check_topology_state(mgr, mst_state);
eceae147246749c Lyude Paul           2019-01-10  3891  		if (ret)
eceae147246749c Lyude Paul           2019-01-10  3892  			break;
eceae147246749c Lyude Paul           2019-01-10  3893  	}
eceae147246749c Lyude Paul           2019-01-10  3894  
eceae147246749c Lyude Paul           2019-01-10  3895  	return ret;
eceae147246749c Lyude Paul           2019-01-10  3896  }
eceae147246749c Lyude Paul           2019-01-10  3897  EXPORT_SYMBOL(drm_dp_mst_atomic_check);
eceae147246749c Lyude Paul           2019-01-10  3898  
bea5c38f1eb6698 Lyude Paul           2019-01-10  3899  const struct drm_private_state_funcs drm_dp_mst_topology_state_funcs = {
a4370c777406c28 Ville Syrjälä        2017-07-12  3900  	.atomic_duplicate_state = drm_dp_mst_duplicate_state,
a4370c777406c28 Ville Syrjälä        2017-07-12  3901  	.atomic_destroy_state = drm_dp_mst_destroy_state,
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3902  };
bea5c38f1eb6698 Lyude Paul           2019-01-10  3903  EXPORT_SYMBOL(drm_dp_mst_topology_state_funcs);
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3904  
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3905  /**
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3906   * drm_atomic_get_mst_topology_state: get MST topology state
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3907   *
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3908   * @state: global atomic state
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3909   * @mgr: MST topology manager, also the private object in this case
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3910   *
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3911   * This function wraps drm_atomic_get_priv_obj_state() passing in the MST atomic
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3912   * state vtable so that the private object state returned is that of a MST
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3913   * topology object. Also, drm_atomic_get_private_obj_state() expects the caller
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3914   * to care of the locking, so warn if don't hold the connection_mutex.
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3915   *
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3916   * RETURNS:
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3917   *
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3918   * The MST topology state or error pointer.
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3919   */
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3920  struct drm_dp_mst_topology_state *drm_atomic_get_mst_topology_state(struct drm_atomic_state *state,
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3921  								    struct drm_dp_mst_topology_mgr *mgr)
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3922  {
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3923  	struct drm_device *dev = mgr->dev;
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3924  
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3925  	WARN_ON(!drm_modeset_is_locked(&dev->mode_config.connection_mutex));
a4370c777406c28 Ville Syrjälä        2017-07-12  3926  	return to_dp_mst_topology_state(drm_atomic_get_private_obj_state(state, &mgr->base));
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3927  }
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3928  EXPORT_SYMBOL(drm_atomic_get_mst_topology_state);
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3929  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3930  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3931   * drm_dp_mst_topology_mgr_init - initialise a topology manager
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3932   * @mgr: manager struct to initialise
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3933   * @dev: device providing this structure - for i2c addition.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3934   * @aux: DP helper aux channel to talk to this device
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3935   * @max_dpcd_transaction_bytes: hw specific DPCD transaction limit
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3936   * @max_payloads: maximum number of payloads this GPU can source
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3937   * @conn_base_id: the connector object ID the MST device is connected to.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3938   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3939   * Return 0 for success, or negative error code on failure
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3940   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3941  int drm_dp_mst_topology_mgr_init(struct drm_dp_mst_topology_mgr *mgr,
7b0a89a6db9a591 Dhinakaran Pandiyan  2017-01-24  3942  				 struct drm_device *dev, struct drm_dp_aux *aux,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3943  				 int max_dpcd_transaction_bytes,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3944  				 int max_payloads, int conn_base_id)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3945  {
a4370c777406c28 Ville Syrjälä        2017-07-12  3946  	struct drm_dp_mst_topology_state *mst_state;
a4370c777406c28 Ville Syrjälä        2017-07-12  3947  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3948  	mutex_init(&mgr->lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3949  	mutex_init(&mgr->qlock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3950  	mutex_init(&mgr->payload_lock);
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3951  	mutex_init(&mgr->destroy_connector_lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3952  	INIT_LIST_HEAD(&mgr->tx_msg_downq);
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3953  	INIT_LIST_HEAD(&mgr->destroy_connector_list);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3954  	INIT_WORK(&mgr->work, drm_dp_mst_link_probe_work);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3955  	INIT_WORK(&mgr->tx_work, drm_dp_tx_work);
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3956  	INIT_WORK(&mgr->destroy_connector_work, drm_dp_destroy_connector_work);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3957  	init_waitqueue_head(&mgr->tx_waitq);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3958  	mgr->dev = dev;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3959  	mgr->aux = aux;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3960  	mgr->max_dpcd_transaction_bytes = max_dpcd_transaction_bytes;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3961  	mgr->max_payloads = max_payloads;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3962  	mgr->conn_base_id = conn_base_id;
4d6a10da79fddcf Imre Deak            2016-01-29  3963  	if (max_payloads + 1 > sizeof(mgr->payload_mask) * 8 ||
4d6a10da79fddcf Imre Deak            2016-01-29  3964  	    max_payloads + 1 > sizeof(mgr->vcpi_mask) * 8)
4d6a10da79fddcf Imre Deak            2016-01-29  3965  		return -EINVAL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3966  	mgr->payloads = kcalloc(max_payloads, sizeof(struct drm_dp_payload), GFP_KERNEL);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3967  	if (!mgr->payloads)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3968  		return -ENOMEM;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3969  	mgr->proposed_vcpis = kcalloc(max_payloads, sizeof(struct drm_dp_vcpi *), GFP_KERNEL);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3970  	if (!mgr->proposed_vcpis)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3971  		return -ENOMEM;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3972  	set_bit(0, &mgr->payload_mask);
441388a8a73f905 Imre Deak            2016-01-29  3973  	if (test_calc_pbn_mode() < 0)
441388a8a73f905 Imre Deak            2016-01-29  3974  		DRM_ERROR("MST PBN self-test failed\n");
441388a8a73f905 Imre Deak            2016-01-29  3975  
a4370c777406c28 Ville Syrjälä        2017-07-12  3976  	mst_state = kzalloc(sizeof(*mst_state), GFP_KERNEL);
a4370c777406c28 Ville Syrjälä        2017-07-12  3977  	if (mst_state == NULL)
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3978  		return -ENOMEM;
a4370c777406c28 Ville Syrjälä        2017-07-12  3979  
a4370c777406c28 Ville Syrjälä        2017-07-12  3980  	mst_state->mgr = mgr;
eceae147246749c Lyude Paul           2019-01-10  3981  	INIT_LIST_HEAD(&mst_state->vcpis);
a4370c777406c28 Ville Syrjälä        2017-07-12  3982  
b962a12050a387e Rob Clark            2018-10-22  3983  	drm_atomic_private_obj_init(dev, &mgr->base,
a4370c777406c28 Ville Syrjälä        2017-07-12  3984  				    &mst_state->base,
bea5c38f1eb6698 Lyude Paul           2019-01-10  3985  				    &drm_dp_mst_topology_state_funcs);
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  3986  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3987  	return 0;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3988  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3989  EXPORT_SYMBOL(drm_dp_mst_topology_mgr_init);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3990  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3991  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3992   * drm_dp_mst_topology_mgr_destroy() - destroy topology manager.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3993   * @mgr: manager to destroy
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3994   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3995  void drm_dp_mst_topology_mgr_destroy(struct drm_dp_mst_topology_mgr *mgr)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  3996  {
f536e00c46d22cc Lyude Paul           2018-12-11  3997  	drm_dp_mst_topology_mgr_set_mst(mgr, false);
274d83524895fe4 Dave Airlie          2015-09-30  3998  	flush_work(&mgr->work);
6b8eeca65b18ae7 Dave Airlie          2015-06-15  3999  	flush_work(&mgr->destroy_connector_work);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4000  	mutex_lock(&mgr->payload_lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4001  	kfree(mgr->payloads);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4002  	mgr->payloads = NULL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4003  	kfree(mgr->proposed_vcpis);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4004  	mgr->proposed_vcpis = NULL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4005  	mutex_unlock(&mgr->payload_lock);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4006  	mgr->dev = NULL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4007  	mgr->aux = NULL;
a4370c777406c28 Ville Syrjälä        2017-07-12  4008  	drm_atomic_private_obj_fini(&mgr->base);
3f3353b7e1218d2 Pandiyan, Dhinakaran 2017-04-20  4009  	mgr->funcs = NULL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4010  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4011  EXPORT_SYMBOL(drm_dp_mst_topology_mgr_destroy);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4012  
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4013  static bool remote_i2c_read_ok(const struct i2c_msg msgs[], int num)
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4014  {
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4015  	int i;
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4016  
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4017  	if (num - 1 > DP_REMOTE_I2C_READ_MAX_TRANSACTIONS)
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4018  		return false;
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4019  
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4020  	for (i = 0; i < num - 1; i++) {
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4021  		if (msgs[i].flags & I2C_M_RD ||
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4022  		    msgs[i].len > 0xff)
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4023  			return false;
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4024  	}
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4025  
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4026  	return msgs[num - 1].flags & I2C_M_RD &&
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4027  		msgs[num - 1].len <= 0xff;
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4028  }
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4029  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4030  /* I2C device */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4031  static int drm_dp_mst_i2c_xfer(struct i2c_adapter *adapter, struct i2c_msg *msgs,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4032  			       int num)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4033  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4034  	struct drm_dp_aux *aux = adapter->algo_data;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4035  	struct drm_dp_mst_port *port = container_of(aux, struct drm_dp_mst_port, aux);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4036  	struct drm_dp_mst_branch *mstb;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4037  	struct drm_dp_mst_topology_mgr *mgr = port->mgr;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4038  	unsigned int i;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4039  	struct drm_dp_sideband_msg_req_body msg;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4040  	struct drm_dp_sideband_msg_tx *txmsg = NULL;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4041  	int ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4042  
d0757afd00d71dc Lyude Paul           2019-01-10  4043  	mstb = drm_dp_mst_topology_get_mstb_validated(mgr, port->parent);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4044  	if (!mstb)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4045  		return -EREMOTEIO;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4046  
cb8ce7111117e16 Ville Syrjälä        2018-09-28  4047  	if (!remote_i2c_read_ok(msgs, num)) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4048  		DRM_DEBUG_KMS("Unsupported I2C transaction for MST device\n");
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4049  		ret = -EIO;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4050  		goto out;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4051  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4052  
ae491542cbbbcca Dave Airlie          2015-10-14  4053  	memset(&msg, 0, sizeof(msg));
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4054  	msg.req_type = DP_REMOTE_I2C_READ;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4055  	msg.u.i2c_read.num_transactions = num - 1;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4056  	msg.u.i2c_read.port_number = port->port_num;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4057  	for (i = 0; i < num - 1; i++) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4058  		msg.u.i2c_read.transactions[i].i2c_dev_id = msgs[i].addr;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4059  		msg.u.i2c_read.transactions[i].num_bytes = msgs[i].len;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4060  		msg.u.i2c_read.transactions[i].bytes = msgs[i].buf;
c978ae9bde582e8 Ville Syrjälä        2018-09-28  4061  		msg.u.i2c_read.transactions[i].no_stop_bit = !(msgs[i].flags & I2C_M_STOP);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4062  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4063  	msg.u.i2c_read.read_i2c_device_id = msgs[num - 1].addr;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4064  	msg.u.i2c_read.num_bytes_read = msgs[num - 1].len;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4065  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4066  	txmsg = kzalloc(sizeof(*txmsg), GFP_KERNEL);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4067  	if (!txmsg) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4068  		ret = -ENOMEM;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4069  		goto out;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4070  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4071  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4072  	txmsg->dst = mstb;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4073  	drm_dp_encode_sideband_req(&msg, txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4074  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4075  	drm_dp_queue_down_tx(mgr, txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4076  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4077  	ret = drm_dp_mst_wait_tx_reply(mstb, txmsg);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4078  	if (ret > 0) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4079  
45bbda1e35f4943 Ville Syrjälä        2019-01-22  4080  		if (txmsg->reply.reply_type == DP_SIDEBAND_REPLY_NAK) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4081  			ret = -EREMOTEIO;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4082  			goto out;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4083  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4084  		if (txmsg->reply.u.remote_i2c_read_ack.num_bytes != msgs[num - 1].len) {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4085  			ret = -EIO;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4086  			goto out;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4087  		}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4088  		memcpy(msgs[num - 1].buf, txmsg->reply.u.remote_i2c_read_ack.bytes, msgs[num - 1].len);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4089  		ret = num;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4090  	}
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4091  out:
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4092  	kfree(txmsg);
d0757afd00d71dc Lyude Paul           2019-01-10  4093  	drm_dp_mst_topology_put_mstb(mstb);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4094  	return ret;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4095  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4096  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4097  static u32 drm_dp_mst_i2c_functionality(struct i2c_adapter *adapter)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4098  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4099  	return I2C_FUNC_I2C | I2C_FUNC_SMBUS_EMUL |
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4100  	       I2C_FUNC_SMBUS_READ_BLOCK_DATA |
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4101  	       I2C_FUNC_SMBUS_BLOCK_PROC_CALL |
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4102  	       I2C_FUNC_10BIT_ADDR;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4103  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4104  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4105  static const struct i2c_algorithm drm_dp_mst_i2c_algo = {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4106  	.functionality = drm_dp_mst_i2c_functionality,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4107  	.master_xfer = drm_dp_mst_i2c_xfer,
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4108  };
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4109  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4110  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4111   * drm_dp_mst_register_i2c_bus() - register an I2C adapter for I2C-over-AUX
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4112   * @aux: DisplayPort AUX channel
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4113   *
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4114   * Returns 0 on success or a negative error code on failure.
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4115   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4116  static int drm_dp_mst_register_i2c_bus(struct drm_dp_aux *aux)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4117  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4118  	aux->ddc.algo = &drm_dp_mst_i2c_algo;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4119  	aux->ddc.algo_data = aux;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4120  	aux->ddc.retries = 3;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4121  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4122  	aux->ddc.class = I2C_CLASS_DDC;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4123  	aux->ddc.owner = THIS_MODULE;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4124  	aux->ddc.dev.parent = aux->dev;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4125  	aux->ddc.dev.of_node = aux->dev->of_node;
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4126  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4127  	strlcpy(aux->ddc.name, aux->name ? aux->name : dev_name(aux->dev),
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4128  		sizeof(aux->ddc.name));
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4129  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4130  	return i2c_add_adapter(&aux->ddc);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4131  }
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4132  
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4133  /**
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4134   * drm_dp_mst_unregister_i2c_bus() - unregister an I2C-over-AUX adapter
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4135   * @aux: DisplayPort AUX channel
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4136   */
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4137  static void drm_dp_mst_unregister_i2c_bus(struct drm_dp_aux *aux)
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4138  {
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4139  	i2c_del_adapter(&aux->ddc);
ad7f8a1f9ced7f0 Dave Airlie          2014-06-05  4140  }

:::::: The code at line 1594 was first introduced by commit
:::::: 3dfd9a885fbb869e90f34346b9e2c23f07596d8d linux-next

:::::: TO: Andrew Morton <akpm@linux-foundation.org>
:::::: CC: Johannes Weiner <hannes@cmpxchg.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--di2bpyf2eo2esioq
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
8Qs+CqysgmkAAA==

--di2bpyf2eo2esioq--

