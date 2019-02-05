Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F049C282C4
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 01:37:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A3222083B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 01:37:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="W2vI/ele"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A3222083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D06D18E006D; Mon,  4 Feb 2019 20:37:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB5718E001C; Mon,  4 Feb 2019 20:37:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7D188E006D; Mon,  4 Feb 2019 20:37:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A1428E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 20:37:23 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id t29so1855946qkt.16
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 17:37:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WbUNf2iZpXNBC2bD/SfWq7+inLOG4GTS1xrSxTM5r7Y=;
        b=hMKXIAZ/8aFZ4G+ly3weHO29bmF/nIizM+fWndGN9cYD5G5VXoy78tRS+/ME0nLIxw
         2wq/+fA3yOhF/xmyWZ7QOSwipWk5lMOhw0E16nLPgBbfzfupEXMVwHnt231sX5wvi96F
         CGthFzJzE66GmlUz/Lt/EFd6q/t5VOsBCXP/GnZe7gTCnS4XsnOKF3bWmHRekyMrqmB0
         Y/hWRKT+SUebkndO3SPBKv7OrWl68PndBg3V5fl6k2LJA6bfHX885CIpRqrD1+Z0GQIV
         QegZO2dzr5TZm1lDBSFKhMOxxDHfMFPE3uouK3Wca7JtHpaEAZJ6FknEheGiocm8Ys67
         bMAw==
X-Gm-Message-State: AHQUAua+egonZSAVCqJB2U4NEgYesYDa9irOyIfzhd4vftBmTF718Smi
	3ymLfR1gbrILNqpKkMuyJN1+mqyJ4dayssxD8EaXcWQcCZt86vdViItMztr62bHs35eak4nzGsJ
	QVcoxNmEK3c/zB8YHTpvokS+5DuiqXqJaixI6rLT/s3sn2XMlIM//ymxlpbM3rd3B8pyEtxmHAk
	H2gwhCRoinYRIENMSP6th6wMnHdpVOGfX7mFCz9kOVL6wg9A3qlOzqrQtuy8w8U16pDdbFDL2VN
	ye9UKLUsaykO94prvI9pJ9J3ywpDMf3eVEzrmzkpgWzNQs9zYOpI6cs256xX6ijk8YITwy1787x
	Hwi4/Hp+RdFOzVGi5pl7HLjAuLpcL2UL3jNivz/NZW/98qhlALfKboWxZ0BqG3gElWUJHqC5Cu6
	4
X-Received: by 2002:a37:7481:: with SMTP id p123mr1683766qkc.178.1549330643265;
        Mon, 04 Feb 2019 17:37:23 -0800 (PST)
X-Received: by 2002:a37:7481:: with SMTP id p123mr1683732qkc.178.1549330642358;
        Mon, 04 Feb 2019 17:37:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549330642; cv=none;
        d=google.com; s=arc-20160816;
        b=IWdo9XF5sPvVDXSPlTu2PUWns0DOngQRSm3ZqYRBIf23oPlNFSLzLb7ZZXjwlYyDK9
         CXa3ToyM2QQ0Br+H1xlg+0TPgYVkHzuvqLHZkz5uQEYje8+uhAHGu+D4KtB/kHKnRekL
         o9C6hRiJ+AJzRzA4rPwnYwcwb9MLGBFaBdmTO8+FaRtJuAtyV4/Xv+Ge7nROuARyKxp6
         7+EbwLOs9FxC+db95EPPm09cStkFR3TPiNAR+NPV7Hwa4avF0ipmcX+cxephwF4vWQVH
         spOH8jaOl52SfAYeeb7hdayq3IBDhTJFQ2YNa6yc9ZLFyseRfRopEpm+Ov+X8MT5QbpG
         14OA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=WbUNf2iZpXNBC2bD/SfWq7+inLOG4GTS1xrSxTM5r7Y=;
        b=B3biFLmKlr9o+Q2qCkDzk/OeRNA7bW4PxK2hfV12JPAZKp6qBvMK7jI64Ez887Legk
         +4PTNpbOvAhDr9hgNR7uT8NTkS4JswdEh3RztWAx/gJ9NFe+hXbtofS2vl8uZhQRfT5z
         BhbYOuC2eUJ1YHl12bKETGBNBdMXOjAMZnbuvz+9c7QzmNQNInfg0veZTydxNsKqiIa/
         AL0uT4ckm5Gy5in28a40hqSkjV+yCFBgGRMngFMKcImTzY9QV2hMuXl9rS927EeAf4kM
         HACqhtIBHR6d8xiK5tdibOub4iXDaRuxEgz0BNsauyqETDqAj2GuBShbGUU6Q9NMBnPt
         Olxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="W2vI/ele";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y44sor25754095qtk.29.2019.02.04.17.37.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 17:37:22 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="W2vI/ele";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=WbUNf2iZpXNBC2bD/SfWq7+inLOG4GTS1xrSxTM5r7Y=;
        b=W2vI/elebESdXjQe/Y6JXrNhGmOc+HsNAp/2QdzzSRvptdqMUvutNAQcgof1jbCXeb
         8n0XJlg6BwOLj1hwhu/G2YtKsaoKYIpMRu0V9zx7HEN+M2c8eUxLfu1ztgSCpfuquE73
         DOa1t+nyD74ITMWrepdCIMWEsoE0BHpUzZZLGDOGw9rqx9u/ixBeJCL6zYbmP+mwR61T
         r1QZuR8AqtReLuLsoElqA+joMim4PD46se/acg3EDnuEHAhzzdA0l6DK66nK8aWKJMoe
         cDvmYGnwn+KlOww7Od/lvFSEJRTGmPgR46/IGoIWpMlgvSAmnC3pbyBDcAO84biTt5Aq
         FuJQ==
X-Google-Smtp-Source: AHgI3IarbONAZOUWB1Eg6zxz45AmckGayNSRBYZoKBkYsqsa0i0PvkPOpFwWFZy2r+7n9Q4wUacRWg==
X-Received: by 2002:aed:3622:: with SMTP id e31mr1742043qtb.5.1549330641672;
        Mon, 04 Feb 2019 17:37:21 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id e49sm16101601qta.0.2019.02.04.17.37.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 17:37:21 -0800 (PST)
Subject: Re: mm: race in put_and_wait_on_page_locked()
To: Hugh Dickins <hughd@google.com>, Artem Savkov <asavkov@redhat.com>
Cc: Baoquan He <bhe@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>,
 Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <20190204091300.GB13536@shodan.usersys.redhat.com>
 <alpine.LSU.2.11.1902041201280.4441@eggly.anvils>
From: Qian Cai <cai@lca.pw>
Message-ID: <fc11de02-9644-1087-9ab6-1537594b924b@lca.pw>
Date: Mon, 4 Feb 2019 20:37:19 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1902041201280.4441@eggly.anvils>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/4/19 3:42 PM, Hugh Dickins wrote:
> On Mon, 4 Feb 2019, Artem Savkov wrote:
> 
>> Hi Hugh,
>>
>> Your recent patch 9a1ea439b16b "mm: put_and_wait_on_page_locked() while
>> page is migrated" seems to have introduced a race into page migration
>> process. I have a host that eagerly reproduces the following BUG under
>> stress:
>>
>> [  302.847402] page:f000000000021700 count:0 mapcount:0 mapping:c0000000b2710bb0 index:0x19
>> [  302.848096] xfs_address_space_operations [xfs] 
>> [  302.848100] name:"libc-2.28.so" 
>> [  302.848244] flags: 0x3ffff800000006(referenced|uptodate)
>> [  302.848521] raw: 003ffff800000006 5deadbeef0000100 5deadbeef0000200 0000000000000000
>> [  302.848724] raw: 0000000000000019 0000000000000000 00000001ffffffff c0000000bc0b1000
>> [  302.848919] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
>> [  302.849076] page->mem_cgroup:c0000000bc0b1000
>> [  302.849269] ------------[ cut here ]------------
>> [  302.849397] kernel BUG at include/linux/mm.h:546!
>> [  302.849586] Oops: Exception in kernel mode, sig: 5 [#1]
>> [  302.849711] LE SMP NR_CPUS=2048 NUMA pSeries
>> [  302.849839] Modules linked in: pseries_rng sunrpc xts vmx_crypto virtio_balloon xfs libcrc32c virtio_net net_failover virtio_console failover virtio_blk
>> [  302.850400] CPU: 3 PID: 8759 Comm: cc1 Not tainted 5.0.0-rc4+ #36
>> [  302.850571] NIP:  c00000000039c8b8 LR: c00000000039c8b4 CTR: c00000000080a0e0
>> [  302.850758] REGS: c0000000b0d7f7e0 TRAP: 0700   Not tainted  (5.0.0-rc4+)
>> [  302.850952] MSR:  8000000000029033 <SF,EE,ME,IR,DR,RI,LE>  CR: 48024422  XER: 00000000
>> [  302.851150] CFAR: c0000000003ff584 IRQMASK: 0 
>> [  302.851150] GPR00: c00000000039c8b4 c0000000b0d7fa70 c000000001bcca00 0000000000000021 
>> [  302.851150] GPR04: c0000000b044c628 0000000000000007 55555555555555a0 c000000001fc3760 
>> [  302.851150] GPR08: 0000000000000007 0000000000000000 c0000000b0d7c000 c0000000b0d7f5ff 
>> [  302.851150] GPR12: 0000000000004400 c00000003fffae80 0000000000000000 0000000000000000 
>> [  302.851150] GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 
>> [  302.851150] GPR20: c0000000689f5aa8 c00000002a13ee48 0000000000000000 c000000001da29b0 
>> [  302.851150] GPR24: c000000001bf7d80 c0000000689f5a00 0000000000000000 0000000000000000 
>> [  302.851150] GPR28: c000000001bf9e80 c0000000b0d7fab8 0000000000000001 f000000000021700 
>> [  302.852914] NIP [c00000000039c8b8] put_and_wait_on_page_locked+0x398/0x3d0
>> [  302.853080] LR [c00000000039c8b4] put_and_wait_on_page_locked+0x394/0x3d0
>> [  302.853235] Call Trace:
>> [  302.853305] [c0000000b0d7fa70] [c00000000039c8b4] put_and_wait_on_page_locked+0x394/0x3d0 (unreliable)
>> [  302.853540] [c0000000b0d7fb10] [c00000000047b838] __migration_entry_wait+0x178/0x250
>> [  302.853738] [c0000000b0d7fb50] [c00000000040c928] do_swap_page+0xd78/0xf60
>> [  302.853997] [c0000000b0d7fbd0] [c000000000411078] __handle_mm_fault+0xbf8/0xe80
>> [  302.854187] [c0000000b0d7fcb0] [c000000000411548] handle_mm_fault+0x248/0x450
>> [  302.854379] [c0000000b0d7fd00] [c000000000078ca4] __do_page_fault+0x2d4/0xdf0
>> [  302.854877] [c0000000b0d7fde0] [c0000000000797f8] do_page_fault+0x38/0xf0
>> [  302.855057] [c0000000b0d7fe20] [c00000000000a7c4] handle_page_fault+0x18/0x38
>> [  302.855300] Instruction dump:
>> [  302.855432] 4bfffcf0 60000000 3948ffff 4bfffd20 60000000 60000000 3c82ff36 7fe3fb78 
>> [  302.855689] fb210068 38843b78 48062f09 60000000 <0fe00000> 60000000 3b400001 3b600001 
>> [  302.855950] ---[ end trace a52140e0f9751ae0 ]---
>>
>> What seems to be happening is migrate_page_move_mapping() calling
>> page_ref_freeze() on another cpu somewhere between __migration_entry_wait()
>> taking a reference and wait_on_page_bit_common() calling page_put().
> 
> Thank you for reporting, Artem.
> 
> And see the mm thread https://marc.info/?l=linux-mm&m=154821775401218&w=2
> 
> That was on arm64, you are on power I think: both point towards xfs
> (Cai could not reproduce it on ext4), but that should not be taken too
> seriously - it could just be easier to reproduce on one than the other.

Agree, although I have never been able to trigger it for ext4 running LTP
migrate_pages03 exclusively overnight (500+ iterations) and spontaneously for a
few weeks now. It might just be lucky.

