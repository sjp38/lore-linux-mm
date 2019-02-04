Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE83EC282D8
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 09:13:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BE02218FD
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 09:13:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BE02218FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB2098E003C; Mon,  4 Feb 2019 04:13:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5F988E001C; Mon,  4 Feb 2019 04:13:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4E058E003C; Mon,  4 Feb 2019 04:13:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id A98158E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 04:13:03 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id u32so18223678qte.1
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 01:13:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=NavmRPyeP+FefkEenA+lOGO+2yA5hB0tz/bQnDe5W0w=;
        b=H9EPT2g6UgyXdhYNFjtQE6nOaCtrPU1VZKnj8DJquAUW/9N51uAcF+IXZAWXYhWis5
         Ula1W9iEQhVdw9U5neJnzQNRodKcnIJy+tcDk4uv+wdmj+EPP26z4vYlas8J1G4+TL2a
         IO8owxO/dnC2UBP8MCzuYB/l78OLEcmL2hWwHI/OBG0817m57UhkCNJmQWkXYobuc/Sf
         F+PYWHvMWitowqmmAwMNwha1uV0hmVDZ1cbJeUopYGcXEkbnh99glUBV2XYDtPXadkfe
         /fZGdjyChmzVruk8ToBT7ipu1cRgJidOvklW/XQjUJxdrsjtOdm1BoGAiEr7bEUXYmEW
         uz1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of asavkov@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=asavkov@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfz8abq9uWFT9rO40pDPHZEF0U7zDHrZvDWX9xXWUe8gkGd0FMu
	KJ9HxIy3yNFlZatZyWpBjsPirxZPXQlmW7k1OIQ2GnBM9L9NCDbWfpZjrSO1Zl7bprWgChfubpz
	0afCofwMnLV4C/EAaR5QJdVkx++Tt23zmdcsv7fSTJDs7uzcExYTDZVmiOiFosPhLfA==
X-Received: by 2002:a0c:f584:: with SMTP id k4mr47118269qvm.22.1549271583427;
        Mon, 04 Feb 2019 01:13:03 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7BEJe4GHJc8deyxQaPQig+0gfzKPLGW6sex+vw/ekc8N/oOHdYJaoerp52Yq5h3N9vNJaC
X-Received: by 2002:a0c:f584:: with SMTP id k4mr47118245qvm.22.1549271582759;
        Mon, 04 Feb 2019 01:13:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549271582; cv=none;
        d=google.com; s=arc-20160816;
        b=Gq/MT6AZxNo5uDb/YhYPFUUE9NFskunbyxBZG2m1F+w4oU7UGZ6819uKXqPs3jTWIc
         HQJe6MdkM1F9EVMgxH45mLVtsSv3waFoLINpmhnmorwCZ7azXQvnKxB2iIg4dCLWUxSh
         SHBJYlcBmkurvs3/ku7fdA+7o/0FCnFCyp9DA2J4sb2+yrIn1A52rboJPX86SpDQZB5Y
         S7jyWhxLHRFjVw2+8k4+n55QnRy3NwXEPfvoNuhvK1/S7JKMSnXL7CmeAx4YNb0ML8e8
         Ke4mcTrnT8l+TF1DK6HzVIBaYXz/V0+xN7TnHUmVOvjBnxtcYUrhKY2ZXBkUs4Y9vc51
         gc2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=NavmRPyeP+FefkEenA+lOGO+2yA5hB0tz/bQnDe5W0w=;
        b=pMwJ2frFHIL+M0NFL3ozMfjrhLxDzLyPHcKlLNDDUyhJWJMYrXiDltYCqR57jIkNuU
         qBap97RCZZGRmY+jfBNe6osb2F0AgMJGF6B7A4GrkzWc2olEXNUGI79mghnqFvlA+Yk1
         qRmaNu58rFi2KEcHOC1Yzo8PSCArs7VV3VWnFhulEgDfGUt48kCeyJx9HqLCCv9ynTWf
         AQXfRve6UCPmP8K1q1pMFO4fJZMJED3al+IaLDdMOEGVLtnt3DiOHIbyAMnHal3PnEgw
         tbnA90JEijQ/Ma8sgLp9Hvqq7KnrQzc89y9yRr3zwiDgVfkRYFYGlAwPaS3MLDEKaY5J
         QDXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of asavkov@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=asavkov@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k22si292209qtm.144.2019.02.04.01.13.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 01:13:02 -0800 (PST)
Received-SPF: pass (google.com: domain of asavkov@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of asavkov@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=asavkov@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DB89D81F13;
	Mon,  4 Feb 2019 09:13:01 +0000 (UTC)
Received: from shodan.usersys.redhat.com (unknown [10.43.17.28])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 851EB7C0B3;
	Mon,  4 Feb 2019 09:13:01 +0000 (UTC)
Received: by shodan.usersys.redhat.com (Postfix, from userid 1000)
	id CDA082C0AD2; Mon,  4 Feb 2019 10:13:00 +0100 (CET)
Date: Mon, 4 Feb 2019 10:13:00 +0100
From: Artem Savkov <asavkov@redhat.com>
To: Hugh Dickins <hughd@google.com>
Cc: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: mm: race in put_and_wait_on_page_locked()
Message-ID: <20190204091300.GB13536@shodan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 04 Feb 2019 09:13:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh,

Your recent patch 9a1ea439b16b "mm: put_and_wait_on_page_locked() while
page is migrated" seems to have introduced a race into page migration
process. I have a host that eagerly reproduces the following BUG under
stress:

[  302.847402] page:f000000000021700 count:0 mapcount:0 mapping:c0000000b2710bb0 index:0x19
[  302.848096] xfs_address_space_operations [xfs] 
[  302.848100] name:"libc-2.28.so" 
[  302.848244] flags: 0x3ffff800000006(referenced|uptodate)
[  302.848521] raw: 003ffff800000006 5deadbeef0000100 5deadbeef0000200 0000000000000000
[  302.848724] raw: 0000000000000019 0000000000000000 00000001ffffffff c0000000bc0b1000
[  302.848919] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
[  302.849076] page->mem_cgroup:c0000000bc0b1000
[  302.849269] ------------[ cut here ]------------
[  302.849397] kernel BUG at include/linux/mm.h:546!
[  302.849586] Oops: Exception in kernel mode, sig: 5 [#1]
[  302.849711] LE SMP NR_CPUS=2048 NUMA pSeries
[  302.849839] Modules linked in: pseries_rng sunrpc xts vmx_crypto virtio_balloon xfs libcrc32c virtio_net net_failover virtio_console failover virtio_blk
[  302.850400] CPU: 3 PID: 8759 Comm: cc1 Not tainted 5.0.0-rc4+ #36
[  302.850571] NIP:  c00000000039c8b8 LR: c00000000039c8b4 CTR: c00000000080a0e0
[  302.850758] REGS: c0000000b0d7f7e0 TRAP: 0700   Not tainted  (5.0.0-rc4+)
[  302.850952] MSR:  8000000000029033 <SF,EE,ME,IR,DR,RI,LE>  CR: 48024422  XER: 00000000
[  302.851150] CFAR: c0000000003ff584 IRQMASK: 0 
[  302.851150] GPR00: c00000000039c8b4 c0000000b0d7fa70 c000000001bcca00 0000000000000021 
[  302.851150] GPR04: c0000000b044c628 0000000000000007 55555555555555a0 c000000001fc3760 
[  302.851150] GPR08: 0000000000000007 0000000000000000 c0000000b0d7c000 c0000000b0d7f5ff 
[  302.851150] GPR12: 0000000000004400 c00000003fffae80 0000000000000000 0000000000000000 
[  302.851150] GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 
[  302.851150] GPR20: c0000000689f5aa8 c00000002a13ee48 0000000000000000 c000000001da29b0 
[  302.851150] GPR24: c000000001bf7d80 c0000000689f5a00 0000000000000000 0000000000000000 
[  302.851150] GPR28: c000000001bf9e80 c0000000b0d7fab8 0000000000000001 f000000000021700 
[  302.852914] NIP [c00000000039c8b8] put_and_wait_on_page_locked+0x398/0x3d0
[  302.853080] LR [c00000000039c8b4] put_and_wait_on_page_locked+0x394/0x3d0
[  302.853235] Call Trace:
[  302.853305] [c0000000b0d7fa70] [c00000000039c8b4] put_and_wait_on_page_locked+0x394/0x3d0 (unreliable)
[  302.853540] [c0000000b0d7fb10] [c00000000047b838] __migration_entry_wait+0x178/0x250
[  302.853738] [c0000000b0d7fb50] [c00000000040c928] do_swap_page+0xd78/0xf60
[  302.853997] [c0000000b0d7fbd0] [c000000000411078] __handle_mm_fault+0xbf8/0xe80
[  302.854187] [c0000000b0d7fcb0] [c000000000411548] handle_mm_fault+0x248/0x450
[  302.854379] [c0000000b0d7fd00] [c000000000078ca4] __do_page_fault+0x2d4/0xdf0
[  302.854877] [c0000000b0d7fde0] [c0000000000797f8] do_page_fault+0x38/0xf0
[  302.855057] [c0000000b0d7fe20] [c00000000000a7c4] handle_page_fault+0x18/0x38
[  302.855300] Instruction dump:
[  302.855432] 4bfffcf0 60000000 3948ffff 4bfffd20 60000000 60000000 3c82ff36 7fe3fb78 
[  302.855689] fb210068 38843b78 48062f09 60000000 <0fe00000> 60000000 3b400001 3b600001 
[  302.855950] ---[ end trace a52140e0f9751ae0 ]---

What seems to be happening is migrate_page_move_mapping() calling
page_ref_freeze() on another cpu somewhere between __migration_entry_wait()
taking a reference and wait_on_page_bit_common() calling page_put().

-- 
 Artem

