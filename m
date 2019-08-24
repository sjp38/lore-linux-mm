Return-Path: <SRS0=KlKP=WU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2ABFC3A5A2
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 02:57:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66C1921726
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 02:57:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66C1921726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECEB16B04D0; Fri, 23 Aug 2019 22:57:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E56BC6B04D1; Fri, 23 Aug 2019 22:57:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1E586B04D2; Fri, 23 Aug 2019 22:57:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0126.hostedemail.com [216.40.44.126])
	by kanga.kvack.org (Postfix) with ESMTP id A92166B04D0
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 22:57:44 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 344826418
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 02:57:44 +0000 (UTC)
X-FDA: 75855811248.22.trip99_4358ff75d2832
X-HE-Tag: trip99_4358ff75d2832
X-Filterd-Recvd-Size: 7305
Received: from r3-21.sinamail.sina.com.cn (r3-21.sinamail.sina.com.cn [202.108.3.21])
	by imf38.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 02:57:42 +0000 (UTC)
Received: from unknown (HELO localhost.localdomain)([124.64.0.77])
	by sina.com with ESMTP
	id 5D60A7A200023491; Sat, 24 Aug 2019 10:57:40 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 142829752972
From: Hillf Danton <hdanton@sina.com>
To: Adric Blake <promarbler14@gmail.com>
Cc: akpm@linux-foundation.org,
	ktkhai@virtuozzo.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	daniel.m.jordan@oracle.com,
	laoar.shao@gmail.com,
	yang.shi@linux.alibaba.com,
	mgorman@techsingularity.net,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: WARNINGs in set_task_reclaim_state with memory cgroup and full memory usage
Date: Sat, 24 Aug 2019 10:57:26 +0800
Message-Id: <20190824025726.14032-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 23 Aug 2019 18:00:15 -0400 Adric Blake wrote:
> Synopsis:
> A WARN_ON_ONCE is hit twice in set_task_reclaim_state under the
> following conditions:
> - a memory cgroup has been created and a task assigned it it
> - memory.limit_in_bytes has been set
> - memory has filled up, likely from cache
>=20
Thanks for report.

> In my usage, I create a cgroup under the current session scope and
> assign a task to it. I then set memory.limit_in_bytes and
> memory.soft_limit_in_bytes for the cgroup to reasonable values, say
> 1G/512M. The program accesses large files frequently and gradually
> fills memory with the page cache. The warnings appears when the
> entirety of the system memory is filled, presumably from other
> programs.
>=20
> If I wait until the program has filled the entirety of system memory
> with cache and then assign a memory limit, the warnings appear
> immediately.
>=20
> I am building the linux git. I first noticed this issue with the
> drm-tip 5.3rc3 and 5.3rc4 kernels, and tested linux master after
> 5.3rc5 to confirm the bug more resoundingly.
>=20
> Here are the warnings.
>=20
> [38491.963105] WARNING: CPU: 7 PID: 175 at mm/vmscan.c:245 set_task_rec=
laim_state+0x1e/0x40
> [38491.963106] Modules linked in: iwlmvm mac80211 libarc4 iwlwifi
> cfg80211 xt_comment nls_iso8859_1 nls_cp437 vfat fat xfs jfs btrfs xor
> raid6_pq libcrc32c ccm tun rfcomm fuse xt_tcpudp ip6t_REJECT
> nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_multiport xt_owner
> snd_hda_codec_hdmi ip6table_filter ip6_tables iptable_filter bnep ext4
> crc32c_generic mbcache jbd2 snd_hda_codec_realtek
> snd_hda_codec_generic snd_soc_skl snd_soc_hdac_hda snd_hda_ext_core
> snd_soc_skl_ipc x86_pkg_temp_thermal intel_powerclamp snd_soc_sst_ipc
> coretemp snd_soc_sst_dsp snd_soc_acpi_intel_match kvm_intel
> snd_soc_acpi i915 snd_soc_core kvm snd_compress ac97_bus
> snd_pcm_dmaengine snd_hda_intel i2c_algo_bit btusb irqbypass
> drm_kms_helper btrtl snd_hda_codec dell_laptop btbcm crct10dif_pclmul
> snd_hda_core crc32c_intel btintel iTCO_wdt ghash_clmulni_intel drm
> ledtrig_audio aesni_intel iTCO_vendor_support snd_hwdep dell_wmi
> rtsx_usb_ms r8169 dell_smbios aes_x86_64 mei_hdcp crypto_simd
> intel_gtt bluetooth snd_pcm cryptd dcdbas
> [38491.963155]  wmi_bmof dell_wmi_descriptor intel_rapl_msr
> glue_helper snd_timer joydev intel_cstate snd realtek memstick
> dell_smm_hwmon mousedev psmouse input_leds libphy intel_uncore
> ecdh_generic ecc crc16 rfkill intel_rapl_perf soundcore i2c_i801
> agpgart mei_me tpm_crb syscopyarea sysfillrect sysimgblt mei
> intel_xhci_usb_role_switch fb_sys_fops idma64 tpm_tis roles
> processor_thermal_device intel_rapl_common i2c_hid tpm_tis_core
> int3403_thermal intel_soc_dts_iosf battery wmi intel_lpss_pci
> intel_lpss intel_pch_thermal tpm int3400_thermal int3402_thermal
> acpi_thermal_rel int340x_thermal_zone rng_core intel_hid ac
> sparse_keymap evdev mac_hid crypto_user ip_tables x_tables
> hid_multitouch rtsx_usb_sdmmc mmc_core rtsx_usb hid_logitech_hidpp
> sr_mod cdrom sd_mod uas usb_storage hid_logitech_dj hid_generic usbhid
> hid ahci serio_raw libahci atkbd libps2 libata xhci_pci scsi_mod
> xhci_hcd crc32_pclmul i8042 serio f2fs [last unloaded: cfg80211]
> [38491.963221] CPU: 7 PID: 175 Comm: kswapd0 Not tainted 5.3.0-rc5+149+=
gbb7ba8069de9 #1
> [38491.963222] Hardware name: Dell Inc. Inspiron 5570/09YTN7, BIOS 1.2.=
3 05/15/2019
> [38491.963226] RIP: 0010:set_task_reclaim_state+0x1e/0x40
> [38491.963228] Code: 78 a9 e7 ff 0f 1f 84 00 00 00 00 00 0f 1f 44 00
> 00 55 48 89 f5 53 48 89 fb 48 85 ed 48 8b 83 08 08 00 00 74 11 48 85
> c0 74 02 <0f> 0b 48 89 ab 08 08 00 00 5b 5d c3 48 85 c0 75 f1 0f 0b 48
> 89 ab
> [38491.963229] RSP: 0018:ffff8c898031fc60 EFLAGS: 00010286
> [38491.963230] RAX: ffff8c898031fe28 RBX: ffff892aa04ddc40 RCX: 0000000=
000000000
> [38491.963231] RDX: ffff8c898031fc60 RSI: ffff8c898031fcd0 RDI: ffff892=
aa04ddc40
> [38491.963233] RBP: ffff8c898031fcd0 R08: ffff8c898031fd48 R09: ffff892=
79674b800
> [38491.963234] R10: 00000000ffffffff R11: 0000000000000000 R12: ffff8c8=
98031fd48
> [38491.963235] R13: ffff892a842ef000 R14: ffff892aaf7fc000 R15: 0000000=
000000000
> [38491.963236] FS:  0000000000000000(0000) GS:ffff892aa33c0000(0000) kn=
lGS:0000000000000000
> [38491.963238] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [38491.963239] CR2: 00007f90628fa000 CR3: 000000027ee0a002 CR4: 0000000=
0003606e0
> [38491.963239] Call Trace:
> [38491.963246]  mem_cgroup_shrink_node+0x9b/0x1d0
> [38491.963250]  mem_cgroup_soft_limit_reclaim+0x10c/0x3a0
> [38491.963254]  balance_pgdat+0x276/0x540
> [38491.963258]  kswapd+0x200/0x3f0
> [38491.963261]  ? wait_woken+0x80/0x80
> [38491.963265]  kthread+0xfd/0x130
> [38491.963267]  ? balance_pgdat+0x540/0x540
> [38491.963269]  ? kthread_park+0x80/0x80
> [38491.963273]  ret_from_fork+0x35/0x40
> [38491.963276] ---[ end trace 727343df67b2398a ]---

Save and restore reclaim state for global reclaimer as it
can be clobbered by memcg.

--- a/mm/vmscan.c
+++ b/bb/vmscan.c
@@ -253,6 +253,22 @@ static void set_task_reclaim_state(struc
 	task->reclaim_state =3D rs;
 }
=20
+static struct reclaim_state *
+save_task_reclaim_state(struct task_struct *task)
+{
+	struct reclaim_state *rs =3D task->reclaim_state;
+	if (rs)
+		set_task_reclaim_state(task, NULL);
+	return rs;
+}
+
+static void restore_task_reclaim_state(struct task_struct *task,
+					struct reclaim_state *rs)
+{
+	if (rs)
+		set_task_reclaim_state(task, rs);
+}
+
 #ifdef CONFIG_MEMCG
 static bool global_reclaim(struct scan_control *sc)
 {
@@ -3241,7 +3257,9 @@ unsigned long mem_cgroup_shrink_node(str
 		.may_shrinkslab =3D 1,
 	};
 	unsigned long lru_pages;
+	struct reclaim_state *rs;
=20
+	rs =3D save_task_reclaim_state(current);
 	set_task_reclaim_state(current, &sc.reclaim_state);
 	sc.gfp_mask =3D (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -3261,6 +3279,7 @@ unsigned long mem_cgroup_shrink_node(str
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
=20
 	set_task_reclaim_state(current, NULL);
+	restore_task_reclaim_state(current, rs);
 	*nr_scanned =3D sc.nr_scanned;
=20
 	return sc.nr_reclaimed;
--


