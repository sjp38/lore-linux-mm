Return-Path: <SRS0=7uET=XD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55CABC433EF
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 08:31:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F102A20863
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 08:31:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F102A20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 270216B0005; Sun,  8 Sep 2019 04:31:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 220316B0006; Sun,  8 Sep 2019 04:31:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1371C6B0007; Sun,  8 Sep 2019 04:31:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0028.hostedemail.com [216.40.44.28])
	by kanga.kvack.org (Postfix) with ESMTP id E73DA6B0005
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 04:31:51 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 82847824CA3A
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 08:31:51 +0000 (UTC)
X-FDA: 75911085222.25.join40_4a41f78aba84b
X-HE-Tag: join40_4a41f78aba84b
X-Filterd-Recvd-Size: 2624
Received: from huawei.com (szxga05-in.huawei.com [45.249.212.191])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 08:31:50 +0000 (UTC)
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 73A7687D29BFBA0A6B45;
	Sun,  8 Sep 2019 16:31:42 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS402-HUB.china.huawei.com
 (10.3.19.202) with Microsoft SMTP Server id 14.3.439.0; Sun, 8 Sep 2019
 16:31:34 +0800
Message-ID: <5D74BC65.4070309@huawei.com>
Date: Sun, 8 Sep 2019 16:31:33 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: <ldufour@linux.ibm.com>
CC: Vinayak Menon <vinmenon@codeaurora.org>, Linux-MM <linux-mm@kvack.org>,
	"Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>, <charante@codeaurora.org>,
	zhongjiang <zhongjiang@huawei.com>
Subject: Speculative page faults
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Laurent,  Vinayak

I have got the following crash on 4.14 kernel with speculative page faults enabled.
Unfortunately,  The issue disappears when trying disabling SPF.

The call trace is as follows.

Unable to handle kernel NULL pointer dereference at virtual address 00000000
user pgtable: 4k pages, 39-bit VAs, pgd = ffffffc177337000
[0000000000000000] *pgd=0000000177346003, *pud=0000000177346003, *pmd=0000000000000000
Internal error: Oops: 96000046 [#1] PREEMPT SMP

CPU: 0 PID: 3184 Comm: Signal Catcher VIP: 00 Tainted: G           O    4.14.116 #1
PC is at __rb_erase_color+0x54/0x260
LR is at anon_vma_interval_tree_remove+0x2ac/0x2c0

Call trace:
[<ffffff8009aa45c4>] __rb_erase_color+0x54/0x260
[<ffffff80083a73f8>] anon_vma_interval_tree_remove+0x2ac/0x2c0
[<ffffff80083b96ac>] unlink_anon_vmas+0x84/0x170
[<ffffff80083aa8f4>] free_pgtables+0x9c/0x100
[<ffffff80083b6814>] exit_mmap+0xb0/0x1d8
[<ffffff8008227e8c>] mmput+0x3c/0xe0
[ffffff800822ed00>] do_exit+0x2f0/0x954
[<ffffff800822f41c>] do_group_exit+0x88/0x9c
[<ffffff800823b768>] get_signal+0x360/0x56c
[<ffffff8008208eb8>] do_notify_resume+0x150/0x5e4
Exception stack(0xffffffc1eac07ec0 to 0xffffffc1eac08000)

It seems to rb_node is empty accidentally under anon_vma rwsem when the process is exiting.
I have no idea whether any race existence or not to result in the issue.

Let me know if you have hit the issue or any  suggestions.

Thanks,
zhong jiang


