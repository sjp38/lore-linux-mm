Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E5C9C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 07:41:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D071320855
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 07:41:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D071320855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53BEE8E0004; Fri,  8 Mar 2019 02:41:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F09C8E0002; Fri,  8 Mar 2019 02:41:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 400EA8E0004; Fri,  8 Mar 2019 02:41:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D8F428E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 02:41:45 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d31so9367283eda.1
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 23:41:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6zEaKstTYVFDpaoqUI36IWXry17f74zDAgKu93MSFj0=;
        b=SXBSe3FNmC4fQnI2hiFKxbT0xwzRwBgJbLFw8hSM9X958aZkrvWFZNUfmQ8wWdaYtw
         5xhY+icpQgru9IvB4h1zrQocjI/KdvZVOloiiCNXbKS3jOhnuoWD+tv6v6I8Y+/z7JMk
         Xmu0Mz0+hEQvot6miZbm+4RiDEylZ1VZjFOIInjxMlc1WFqfAXDyRZ5DINgiN7L3Hiyw
         dtRaqZAWMoRQt1Nm18kS/OhATO0amX68NAxyX62kKA5BSVWkaO5U6HmL/Ls24GQKTrTL
         gns5Nf7J/GpV+DOfubRmLGhqFkdrvBSqD0LldHN+9EtkhS3bCz00Xkdf7m0KbyKdPGY9
         Cv9Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWlAkywm9qeFkJDf1/Hx+0omYdOX7X2G5F1G+1TfZ8DvdpBuuP5
	iwRKuSeFFVh6AW6O6Kqc3OQCH22QyLuXxou85empl+DcOL7mqup5jHyWsH2Nt2viscGU/toCQ81
	ZrpXnCpssDi80V5LimiIo/m8UaMPhZjY5gRZHpHXIUs0eJbDwzYP6xeQElu5ESJU=
X-Received: by 2002:a17:906:a296:: with SMTP id i22mr10891666ejz.62.1552030905396;
        Thu, 07 Mar 2019 23:41:45 -0800 (PST)
X-Google-Smtp-Source: APXvYqyzNVT3xAgb6fsfh2sdTnqAKXiJ4KpBbjWytOInWIiPIDVn3WJgQoIBRgOfLjmQxhdAliwb
X-Received: by 2002:a17:906:a296:: with SMTP id i22mr10891583ejz.62.1552030903652;
        Thu, 07 Mar 2019 23:41:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552030903; cv=none;
        d=google.com; s=arc-20160816;
        b=fwU6IoHfBvZ/wpiBqPcNsIKHjlFqAJLtX9ApeExWzIqfWDBpUklRGUAf1EG+zDOMtN
         Hhpbkg8PlmGe0naLwiTAW6eVGWmMdgln5jfag4QpDt8+Yczbuo0Z3GNkmcVg5M4Amc7F
         BnKlCnJ9JklhR2C4WHEOfxypMtgQRIiVLD97zbWsEr8XI79j+P8fr7EoZlkhacw+jUCW
         nlakiW8R9gt/Cv/NIZEATmlne3vNiZc3G6Rx/vIUUwpOMQeYlRqybZnkaIFcVx15LlMX
         GMxpaOvHQLf57F0MuM+kj8FsMZdWYmWlTfOjVpgcojEAKQ7snSM+ePdqVD7UHVxEJVfG
         GhFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6zEaKstTYVFDpaoqUI36IWXry17f74zDAgKu93MSFj0=;
        b=Jg4+HEgQdLgjgqLi/cs8fWlkoHwFPZYnS8j8mtL093FFRp4fDqz5VxBnz458fJfXJd
         y/BarJkmlc4Jj0U6GkwQNDsyD22j2PBi8VnEJePSGAYYfsPuUwe7iJYAw6s4TqOZChLH
         e/PacIxm4/CBPZrkEOSJadkECBe6pegQi1W6AS9JVAvJ4w0Hgc7vXpwxkXtRHDFWpMaA
         9M1XUmuMudAGNpq+Z4MrYH59w31fWeQpD/bnXGIVymquQ9jQYfNmXjcgVH8kHUABPLcJ
         8ttKwNsfgCyuy5Gc9hpWtVHMi1WpBQXQGJnQ8mOu8SVI3Vd2AQY0ywTXlt3kWRqm6prJ
         A82w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a57si3006496edd.310.2019.03.07.23.41.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 23:41:43 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D2754AFBF;
	Fri,  8 Mar 2019 07:41:42 +0000 (UTC)
Date: Fri, 8 Mar 2019 08:41:41 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Richard Biener <rguenther@suse.de>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: Kernel bug with MPX?
Message-ID: <20190308073949.GA5232@dhcp22.suse.cz>
References: <alpine.LSU.2.20.1903060944550.7898@zhemvz.fhfr.qr>
 <ba1d2d3c-e616-611d-3cff-acf6b8aaeb66@intel.com>
 <20190308071249.GJ30234@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190308071249.GJ30234@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 08-03-19 08:12:49, Michal Hocko wrote:
> On Thu 07-03-19 12:38:15, Dave Hansen wrote:
> > On 3/6/19 12:53 AM, Richard Biener wrote:
> > > When running the gcc.target/i386/mpx/memmove-1.c testcase
> > > from the GCC 8 branch on MPX capable hardware the testcase
> > > faults and the kernel log reports the following:
> > 
> > While I don't doubt that we have some MPX bugs around, I wasn't able to
> > reproduce this one with that binary.  Is there anything else that would
> > help us track this down?
> 
> I have simply executed the binary without any special preparation and I
> could see the leak information in dmesg
> 
> [112423.206497] BUG: Bad rss-counter state mm:000000007aa9c8a7 idx:1 val:25593

And this seems real leak because I just hit some bugons later

[112423.206497] BUG: Bad rss-counter state mm:000000007aa9c8a7 idx:1 val:25593
[113601.595093] page:ffffea00041a07c0 count:2 mapcount:1 mapping:ffff88818d70e9a1 index:0x7f821adf6
[113601.595102] anon 
[113601.595105] flags: 0x200000000080025(locked|uptodate|active|swapbacked)
[113601.595110] raw: 0200000000080025 ffffea00041a0788 ffffc9000155be20 ffff88818d70e9a1
[113601.595113] raw: 00000007f821adf6 0000000000000000 0000000200000000 ffff8882458b2000
[113601.595115] page dumped because: VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !anon_vma)
[113601.595116] page->mem_cgroup:ffff8882458b2000
[113601.595135] ------------[ cut here ]------------
[113601.595137] kernel BUG at mm/migrate.c:1108!
[113601.595145] invalid opcode: 0000 [#1] PREEMPT SMP PTI
[113601.595150] CPU: 2 PID: 298 Comm: kcompactd0 Not tainted 5.0.0-00510-gcd2a3bf02625 #48
[113601.595151] Hardware name: Dell Inc. Latitude E7470/0T6HHJ, BIOS 1.5.3 04/18/2016
[113601.595157] RIP: 0010:migrate_pages+0x579/0x9f4
[113601.595160] Code: f6 c2 01 74 04 48 8d 42 ff 48 8b 40 18 83 e0 03 48 83 f8 03 74 16 4d 85 f6 75 11 48 c7 c6 95 40 e2 81 48 89 df e8 af 88 fc ff <0f> 0b be 19 00 00 00 48 89 df e8 f5 d1 fd ff b9 01 00 00 00 48 89
[113601.595162] RSP: 0000:ffffc9000155bd20 EFLAGS: 00010296
[113601.595164] RAX: 0000000000000021 RBX: ffffea00041a07c0 RCX: 0000000000000007
[113601.595166] RDX: 0000000000000006 RSI: ffffffff8109ee60 RDI: ffffffff8109ee60
[113601.595167] RBP: 0000000000100000 R08: 0000000000000001 R09: ffffffff824cc670
[113601.595169] R10: 000000000000000f R11: ffffc9000155bbd8 R12: ffffea0006d48ac0
[113601.595171] R13: ffffffff81153531 R14: 0000000000000000 R15: 0000000000000001
[113601.595173] FS:  0000000000000000(0000) GS:ffff888245f00000(0000) knlGS:0000000000000000
[113601.595174] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[113601.595176] CR2: 00007f8503550000 CR3: 00000002137d0004 CR4: 00000000003606e0
[113601.595177] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[113601.595179] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[113601.595180] Call Trace:
[113601.595194]  ? isolate_migratepages_block+0x737/0x737
[113601.595197]  compact_zone+0x513/0x762
[113601.595200]  kcompactd_do_work+0x17f/0x232
[113601.595205]  ? kcompactd_do_work+0x232/0x232
[113601.595207]  kcompactd+0x153/0x16b
[113601.595212]  ? wait_woken+0x6d/0x6d
[113601.595216]  kthread+0x114/0x11c
[113601.595218]  ? kthread_park+0x76/0x76
[113601.595223]  ret_from_fork+0x3a/0x50
[113601.595228] Modules linked in: tun ctr ccm binfmt_misc snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic arc4 uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 videobuf2_common i915 snd_hda_intel snd_hda_codec videodev snd_hda_core iwlmvm snd_pcm_oss media snd_mixer_oss i2c_algo_bit iosf_mbi mac80211 drm_kms_helper coretemp hwmon cfbfillrect syscopyarea x86_pkg_temp_thermal cfbimgblt sysfillrect sysimgblt fb_sys_fops kvm_intel iwlwifi cfbcopyarea snd_pcm fb font snd_timer kvm fbdev drm irqbypass drm_panel_orientation_quirks snd cfg80211 i2c_i801 i2c_core video backlight
[113601.595259] ---[ end trace 5785d1645237432f ]---
[113601.595263] RIP: 0010:migrate_pages+0x579/0x9f4
[113601.595264] Code: f6 c2 01 74 04 48 8d 42 ff 48 8b 40 18 83 e0 03 48 83 f8 03 74 16 4d 85 f6 75 11 48 c7 c6 95 40 e2 81 48 89 df e8 af 88 fc ff <0f> 0b be 19 00 00 00 48 89 df e8 f5 d1 fd ff b9 01 00 00 00 48 89
[113601.595266] RSP: 0000:ffffc9000155bd20 EFLAGS: 00010296
[113601.595268] RAX: 0000000000000021 RBX: ffffea00041a07c0 RCX: 0000000000000007
[113601.595270] RDX: 0000000000000006 RSI: ffffffff8109ee60 RDI: ffffffff8109ee60
[113601.595271] RBP: 0000000000100000 R08: 0000000000000001 R09: ffffffff824cc670
[113601.595273] R10: 000000000000000f R11: ffffc9000155bbd8 R12: ffffea0006d48ac0
[113601.595274] R13: ffffffff81153531 R14: 0000000000000000 R15: 0000000000000001
[113601.595276] FS:  0000000000000000(0000) GS:ffff888245f00000(0000) knlGS:0000000000000000
[113601.595278] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[113601.595279] CR2: 00007f8503550000 CR3: 00000002137d0004 CR4: 00000000003606e0
[113601.595281] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[113601.595282] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[113608.427311] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[113608.427315] #PF error: [normal kernel read fault]
[113608.427317] PGD 80000002137ec067 P4D 80000002137ec067 PUD 0 
[113608.427321] Oops: 0000 [#2] PREEMPT SMP PTI
[113608.427325] CPU: 1 PID: 724 Comm: kswapd0 Tainted: G      D           5.0.0-00510-gcd2a3bf02625 #48
[113608.427327] Hardware name: Dell Inc. Latitude E7470/0T6HHJ, BIOS 1.5.3 04/18/2016
[113608.427332] RIP: 0010:down_read_trylock+0x5/0x3b
[113608.427334] Code: c5 48 8b 43 08 48 39 c2 75 05 ff 43 04 eb 09 48 8b 7b 08 e8 8a ed 59 00 48 89 ee 48 89 df 5b 5d e9 d3 0f 5a 00 0f 1f 44 00 00 <48> 8b 07 48 89 c2 48 83 c2 01 7e 07 f0 48 0f b1 17 75 f0 48 89 c2
[113608.427336] RSP: 0018:ffffc90000e37c48 EFLAGS: 00010202
[113608.427338] RAX: 0000000000000001 RBX: ffff88821dda2b00 RCX: 0000000000000000
[113608.427339] RDX: 0000000000000001 RSI: ffffc90000e37ce0 RDI: 0000000000000008
[113608.427341] RBP: 0000000000000008 R08: ffffea0008547f88 R09: 00000000000b7b57
[113608.427342] R10: 00000000000e2b24 R11: 0000000000000000 R12: ffff88821dda2b01
[113608.427344] R13: ffffea0008643dc0 R14: 0000000000000000 R15: ffffea0008643dc0
[113608.427346] FS:  0000000000000000(0000) GS:ffff888245e80000(0000) knlGS:0000000000000000
[113608.427347] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[113608.427349] CR2: 0000000000000008 CR3: 00000002137d0003 CR4: 00000000003606e0
[113608.427350] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[113608.427351] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[113608.427352] Call Trace:
[113608.427360]  page_lock_anon_vma_read+0x4c/0xda
[113608.427365]  rmap_walk_anon+0x50/0x2a0
[113608.427368]  page_referenced+0x102/0x128
[113608.427371]  ? invalid_page_referenced_vma+0x84/0x84
[113608.427373]  ? page_get_anon_vma+0x79/0x79
[113608.427375]  shrink_active_list+0x25a/0x450
[113608.427378]  balance_pgdat+0x1d8/0x3f5
[113608.427381]  kswapd+0x332/0x37d
[113608.427384]  ? wait_woken+0x6d/0x6d
[113608.427386]  ? balance_pgdat+0x3f5/0x3f5
[113608.427389]  kthread+0x114/0x11c
[113608.427391]  ? kthread_park+0x76/0x76
[113608.427394]  ret_from_fork+0x3a/0x50
[113608.427397] Modules linked in: tun ctr ccm binfmt_misc snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic arc4 uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 videobuf2_common i915 snd_hda_intel snd_hda_codec videodev snd_hda_core iwlmvm snd_pcm_oss media snd_mixer_oss i2c_algo_bit iosf_mbi mac80211 drm_kms_helper coretemp hwmon cfbfillrect syscopyarea x86_pkg_temp_thermal cfbimgblt sysfillrect sysimgblt fb_sys_fops kvm_intel iwlwifi cfbcopyarea snd_pcm fb font snd_timer kvm fbdev drm irqbypass drm_panel_orientation_quirks snd cfg80211 i2c_i801 i2c_core video backlight
[113608.427421] CR2: 0000000000000008
[113608.427423] ---[ end trace 5785d16452374330 ]---
[113608.427427] RIP: 0010:migrate_pages+0x579/0x9f4
[113608.427428] Code: f6 c2 01 74 04 48 8d 42 ff 48 8b 40 18 83 e0 03 48 83 f8 03 74 16 4d 85 f6 75 11 48 c7 c6 95 40 e2 81 48 89 df e8 af 88 fc ff <0f> 0b be 19 00 00 00 48 89 df e8 f5 d1 fd ff b9 01 00 00 00 48 89
[113608.427430] RSP: 0000:ffffc9000155bd20 EFLAGS: 00010296
[113608.427431] RAX: 0000000000000021 RBX: ffffea00041a07c0 RCX: 0000000000000007
[113608.427433] RDX: 0000000000000006 RSI: ffffffff8109ee60 RDI: ffffffff8109ee60
[113608.427434] RBP: 0000000000100000 R08: 0000000000000001 R09: ffffffff824cc670
[113608.427435] R10: 000000000000000f R11: ffffc9000155bbd8 R12: ffffea0006d48ac0
[113608.427436] R13: ffffffff81153531 R14: 0000000000000000 R15: 0000000000000001
[113608.427438] FS:  0000000000000000(0000) GS:ffff888245e80000(0000) knlGS:0000000000000000
[113608.427439] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[113608.427441] CR2: 0000000000000008 CR3: 00000002137d0003 CR4: 00000000003606e0
[113608.427442] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[113608.427443] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[113608.427489] WARNING: CPU: 1 PID: 724 at kernel/rcu/tree_plugin.h:337 rcu_note_context_switch+0xa5/0x3b0
[113608.427491] Modules linked in: tun ctr ccm binfmt_misc snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic arc4 uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 videobuf2_common i915 snd_hda_intel snd_hda_codec videodev snd_hda_core iwlmvm snd_pcm_oss media snd_mixer_oss i2c_algo_bit iosf_mbi mac80211 drm_kms_helper coretemp hwmon cfbfillrect syscopyarea x86_pkg_temp_thermal cfbimgblt sysfillrect sysimgblt fb_sys_fops kvm_intel iwlwifi cfbcopyarea snd_pcm fb font snd_timer kvm fbdev drm irqbypass drm_panel_orientation_quirks snd cfg80211 i2c_i801 i2c_core video backlight
[113608.427510] CPU: 1 PID: 724 Comm: kswapd0 Tainted: G      D           5.0.0-00510-gcd2a3bf02625 #48
[113608.427512] Hardware name: Dell Inc. Latitude E7470/0T6HHJ, BIOS 1.5.3 04/18/2016
[113608.427514] RIP: 0010:rcu_note_context_switch+0xa5/0x3b0
[113608.427516] Code: 7b 08 48 8b 03 48 83 c3 18 4c 89 f6 e8 be 3a 95 00 48 83 3b 00 eb d5 8b 85 88 03 00 00 45 84 e4 75 0c 85 c0 0f 8e 6e 02 00 00 <0f> 0b eb 08 85 c0 0f 8e 62 02 00 00 80 bd 8c 03 00 00 00 0f 85 6a
[113608.427517] RSP: 0018:ffffc90000e37e30 EFLAGS: 00010002
[113608.427519] RAX: 0000000000000001 RBX: ffff888245ea0d80 RCX: 0000000080270024
[113608.427520] RDX: 0000000000020d80 RSI: ffffffff81e256b9 RDI: ffffffff81e3cd32
[113608.427522] RBP: ffff888242920000 R08: 0000000000000002 R09: ffffffff81057000
[113608.427523] R10: ffffea0009107140 R11: ffff88824553fd98 R12: 0000000000000000
[113608.427524] R13: ffff888245ea1a00 R14: 0000000000000000 R15: ffff888245ea0d80
[113608.427525] FS:  0000000000000000(0000) GS:ffff888245e80000(0000) knlGS:0000000000000000
[113608.427526] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[113608.427527] CR2: 0000000000000008 CR3: 00000002137d0003 CR4: 00000000003606e0
[113608.427528] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[113608.427529] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[113608.427530] Call Trace:
[113608.427534]  __schedule+0xf7/0x785
[113608.427536]  do_task_dead+0x40/0x42
[113608.427539]  do_exit+0x9eb/0x9eb
[113608.427541]  ? balance_pgdat+0x3f5/0x3f5
[113608.427543]  rewind_stack_do_exit+0x17/0x20
[113608.427545] ---[ end trace 5785d16452374331 ]---
[113668.428771] rcu: INFO: rcu_preempt detected stalls on CPUs/tasks:
[113668.428778] rcu: 	Tasks blocked on level-0 rcu_node (CPUs 0-3): P724
[113668.428780] rcu: 	(detected by 0, t=15002 jiffies, g=10453189, q=9162)
[113845.817139] page:ffffea00014429c0 count:2 mapcount:1 mapping:ffff88818d70e9a1 index:0x7f821adfc
[113845.817143] anon 
[113845.817145] flags: 0x100000000080025(locked|uptodate|active|swapbacked)
[113845.817148] raw: 0100000000080025 ffffea0001442988 ffffc900015abbb0 ffff88818d70e9a1
[113845.817149] raw: 00000007f821adfc 0000000000000000 0000000200000000 ffff8882458b2000
[113845.817151] page dumped because: VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !anon_vma)
[113845.817151] page->mem_cgroup:ffff8882458b2000
[113845.817159] ------------[ cut here ]------------
[113845.817160] kernel BUG at mm/migrate.c:1108!
[113845.817165] invalid opcode: 0000 [#3] PREEMPT SMP PTI
[113845.817167] CPU: 0 PID: 300 Comm: khugepaged Tainted: G      D W         5.0.0-00510-gcd2a3bf02625 #48
[113845.817169] Hardware name: Dell Inc. Latitude E7470/0T6HHJ, BIOS 1.5.3 04/18/2016
[113845.817172] RIP: 0010:migrate_pages+0x579/0x9f4
[113845.817174] Code: f6 c2 01 74 04 48 8d 42 ff 48 8b 40 18 83 e0 03 48 83 f8 03 74 16 4d 85 f6 75 11 48 c7 c6 95 40 e2 81 48 89 df e8 af 88 fc ff <0f> 0b be 19 00 00 00 48 89 df e8 f5 d1 fd ff b9 01 00 00 00 48 89
[113845.817175] RSP: 0018:ffffc900015abac0 EFLAGS: 00010296
[113845.817177] RAX: 0000000000000021 RBX: ffffea00014429c0 RCX: 0000000000000007
[113845.817178] RDX: 0000000000000006 RSI: ffffffff8109ee60 RDI: ffffffff8109ee60
[113845.817179] RBP: 0000000000000000 R08: 0000000000000001 R09: ffffffff824cc670
[113845.817180] R10: 000000000000000f R11: ffffc900015ab978 R12: ffffea0001a04ac0
[113845.817181] R13: ffffffff81153531 R14: 0000000000000000 R15: 0000000000000000
[113845.817182] FS:  0000000000000000(0000) GS:ffff888245e00000(0000) knlGS:0000000000000000
[113845.817183] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[113845.817184] CR2: 0000123ece2d7000 CR3: 000000000200e001 CR4: 00000000003606f0
[113845.817185] Call Trace:
[113845.817191]  ? isolate_migratepages_block+0x737/0x737
[113845.817193]  compact_zone+0x513/0x762
[113845.817195]  compact_zone_order+0x88/0xa8
[113845.817198]  try_to_compact_pages+0x100/0x193
[113845.817200]  __alloc_pages_direct_compact+0x6b/0x10d
[113845.817202]  __alloc_pages_nodemask+0x2a1/0xb67
[113845.817205]  ? preempt_count_sub+0xc6/0xd2
[113845.817207]  ? _raw_spin_unlock_irqrestore+0x2c/0x3e
[113845.817210]  khugepaged_alloc_page+0x4b/0x79
[113845.817212]  khugepaged+0xb20/0x1be0
[113845.817216]  ? wait_woken+0x6d/0x6d
[113845.817217]  ? _raw_spin_unlock_irqrestore+0x2c/0x3e
[113845.817219]  ? collapse_shmem+0xcd7/0xcd7
[113845.817221]  kthread+0x114/0x11c
[113845.817223]  ? kthread_park+0x76/0x76
[113845.817224]  ret_from_fork+0x3a/0x50
[113845.817227] Modules linked in: tun ctr ccm binfmt_misc snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic arc4 uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 videobuf2_common i915 snd_hda_intel snd_hda_codec videodev snd_hda_core iwlmvm snd_pcm_oss media snd_mixer_oss i2c_algo_bit iosf_mbi mac80211 drm_kms_helper coretemp hwmon cfbfillrect syscopyarea x86_pkg_temp_thermal cfbimgblt sysfillrect sysimgblt fb_sys_fops kvm_intel iwlwifi cfbcopyarea snd_pcm fb font snd_timer kvm fbdev drm irqbypass drm_panel_orientation_quirks snd cfg80211 i2c_i801 i2c_core video backlight
Mar  8 08:34:36 tiehlicka kernel: [113845.817244] ---[ end trace 5785d16452374332 ]---
-- 
Michal Hocko
SUSE Labs

