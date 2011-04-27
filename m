Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0259A6B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 12:33:51 -0400 (EDT)
Content-Type: text/plain; charset=UTF-8
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
In-reply-to: <1303920553.2583.7.camel@mulgrave.site>
References: <1303920553.2583.7.camel@mulgrave.site>
Date: Wed, 27 Apr 2011 12:33:37 -0400
Message-Id: <1303921583-sup-4021@think>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <james.bottomley@hansenpartnership.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Excerpts from James Bottomley's message of 2011-04-27 12:09:13 -0400:
> The bug manifests as a soft lockup in kswapd:
> 
> [  155.759084] netconsole: network logging started
> [  598.920430] BUG: soft lockup - CPU#1 stuck for 67s! [kswapd0:46]
> [  598.920472] Modules linked in: netconsole configfs fuse sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_intel snd_hda_codec snd_hwdep arc4 snd_seq snd_seq_device snd_pcm iwlagn mac80211 snd_timer uvcvideo btusb bluetooth snd cfg80211 videodev soundcore v4l2_compat_ioctl32 iTCO_wdt xhci_hcd e1000e snd_page_alloc rfkill i2c_i801 wmi iTCO_vendor_support microcode pcspkr joydev uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: netconsole]
> [  598.920834] CPU 1 
> [  598.920843] Modules linked in: netconsole configfs fuse sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_intel snd_hda_codec snd_hwdep arc4 snd_seq snd_seq_device snd_pcm iwlagn mac80211 snd_timer uvcvideo btusb bluetooth snd cfg80211 videodev soundcore v4l2_compat_ioctl32 iTCO_wdt xhci_hcd e1000e snd_page_alloc rfkill i2c_i801 wmi iTCO_vendor_support microcode pcspkr joydev uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: netconsole]
> [  598.926818] 

Probably easier to debug with a sysrq-l and sysrq-w.  If you get stuck
on the filesystem, it is probably waiting on ram, which it probably
can't get because kswapd is spinning.  Eventually everyone backs up
waiting for the transaction that never ends.  If we're really lucky it
is just GFP_KERNEL where it should NOFS.

Since you're often stuck in different spots inside shrink_slab, we're
probably not stuck on a lock.  But, trying with lock debugging, lockdep
enabled and preempt on is a good idea to rule out locking mistakes.

Does the fedora debug kernel enable preempt?

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
