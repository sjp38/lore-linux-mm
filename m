Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3036B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 15:04:45 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id wm4so8520768obc.27
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 12:04:45 -0800 (PST)
Received: from mail-ob0-x230.google.com (mail-ob0-x230.google.com [2607:f8b0:4003:c01::230])
        by mx.google.com with ESMTPS id p3si10351859oew.41.2014.02.03.12.04.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 12:04:44 -0800 (PST)
Received: by mail-ob0-f176.google.com with SMTP id gq1so8349411obb.21
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 12:04:44 -0800 (PST)
Message-ID: <52EFF658.2080001@lwfinger.net>
Date: Mon, 03 Feb 2014 14:04:40 -0600
From: Larry Finger <Larry.Finger@lwfinger.net>
MIME-Version: 1.0
Subject: Kernel WARNING splat in 3.14-rc1
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On my freshly built 3.14-rc1 kernel, I get the following new warning splat from 
slub:

[   69.008845] ------------[ cut here ]------------
[   69.008861] WARNING: CPU: 0 PID: 1578 at mm/slub.c:1007 
deactivate_slab+0x4bb/0x520()
[   69.008863] Modules linked in: rfcomm nfs fscache af_packet lockd sunrpc bnep 
rtl8723be arc4 rtl8723_common b43 rtl_pci rtlwifi mac80211 cfg80211 btusb bl
uetooth powernow_k8 kvm_amd kvm snd_hda_intel snd_hda_codec bcma snd_hwdep r852 
sdhci_pci sdhci snd_pcm sr_mod snd_seq ssb cdrom forcedeth sm_common pcspkr s
nd_timer serio_raw snd_seq_device snd nand mtd mmc_core rfkill ata_generic 
pata_amd nand_ids nand_bch bch nand_ecc 6lowpan_iphc soundcore btcoexist r592 ac v
ideo memstick button battery sg dm_mod autofs4 thermal processor thermal_sys hwmon
[   69.008934] CPU: 0 PID: 1578 Comm: akonadi_newmail Not tainted 3.14.0-rc1-wl+ #60
[   69.008936] Hardware name: Hewlett-Packard HP Pavilion dv2700 Notebook 
PC/30D6, BIOS F.27 11/27/2008
[   69.008939]  0000000000000009 ffff880085ab1cd0 ffffffff815ee4a0 0000000000000000
[   69.008945]  ffff880085ab1d08 ffffffff8104e768 ffffea0001ee69c0 ffff8800bb401800
[   69.008950]  0000000000000000 ffff8800bb400c80 0000000000000002 ffff880085ab1d18
[   69.008956] Call Trace:
[   69.008965]  [<ffffffff815ee4a0>] dump_stack+0x4d/0x6f
[   69.008971]  [<ffffffff8104e768>] warn_slowpath_common+0x78/0xa0
[   69.008976]  [<ffffffff8104e845>] warn_slowpath_null+0x15/0x20
[   69.008980]  [<ffffffff8118581b>] deactivate_slab+0x4bb/0x520
[   69.008985]  [<ffffffff81183429>] ? new_slab+0x1f9/0x300
[   69.008989]  [<ffffffff815ebe57>] __slab_alloc+0x34d/0x4f5
[   69.008994]  [<ffffffff81185a6b>] ? kmem_cache_alloc+0x18b/0x1c0
[   69.008999]  [<ffffffff810770d1>] ? prepare_creds+0x21/0x1a0
[   69.009003]  [<ffffffff810770d1>] ? prepare_creds+0x21/0x1a0
[   69.009007]  [<ffffffff81185a6b>] kmem_cache_alloc+0x18b/0x1c0
[   69.009011]  [<ffffffff810770d1>] prepare_creds+0x21/0x1a0
[   69.009016]  [<ffffffff8119f955>] SyS_access+0x35/0x1f0
[   69.009019]  [<ffffffff815fe8a2>] system_call_fastpath+0x16/0x1b
[   69.009019] ---[ end trace c63f75644bfb030a ]---

There is a similar warning for my other CPU as well. The warning comes from 
"lockdep_assert_held(&n->list_lock);".

If needed, I can bisect this issue.

Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
