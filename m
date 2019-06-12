Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D08F4C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 04:02:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79831206BA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 04:02:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79831206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFC336B0007; Wed, 12 Jun 2019 00:02:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAC116B0008; Wed, 12 Jun 2019 00:02:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B74CB6B000A; Wed, 12 Jun 2019 00:02:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6B98C6B0007
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 00:02:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f19so18828057edv.16
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 21:02:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=qYiM1nB+OyD/mEZwMx7JkHBPaXFtWcbqs5mGrZ0tS0I=;
        b=UccwSuK7mSd6SHsjYvGy36iBb1255zYIGPfhYXvpOoHzbgt5K0pezUbVLJjToj7N0c
         S1gmC+rvcsi1h289CSx/SUJ4AtmHFwxT5fM9hSsUPUdckAG9wMj1rESN0SSsfS7z8ZG3
         arpbDD1SL4iDBqpXqTAKdpX2kZwIipxfmhCmaqXWD0tzUxNsFZAaSk8/w0eQ6RYFUJw7
         iXzWXrnVrhXm3F8XOCV0bA7RxqIaXi8MwpGHBL5aQa8GUKxcv95RD4NUccttavIhavCR
         6r3XQAtPVfiPpyPe2rVerHPFpXxKMRTZ7GyTkRVJ0oRsuwBpQVac//DCCo3AU/dnv9Y5
         RN8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVZfqlTbd0Du1rQNYYNDHeLd3VqEBMeX21LEaSCqF3WalofGwzv
	f9lqpShjTd0qn2C0B28dk54oD0CVb8MHoQy8TaShilnEeGe0OWUiZIDbeVDmqYnypfMcjyvk2q7
	Joy3lq15bzowy3TIngwSKrhIdN3P+4ggGwVfqjBh4xzDFvF+DYbWDnaE02EmH6hBevA==
X-Received: by 2002:a17:906:948c:: with SMTP id t12mr54234306ejx.222.1560312162846;
        Tue, 11 Jun 2019 21:02:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVZ4IbNwMx/a0HPtBX5khdM1w0CS025RLaX4R2D0CkETP7IWzy5drdasQ0p5mvlfbP8hjI
X-Received: by 2002:a17:906:948c:: with SMTP id t12mr54234242ejx.222.1560312161654;
        Tue, 11 Jun 2019 21:02:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560312161; cv=none;
        d=google.com; s=arc-20160816;
        b=VjP/kOJNYoBQ1RNEJ8QMEljiyVsBXb48VM8uuSghKQecTI2JmIO4r8DnNpRSWHDFcq
         S6JyY9v0WQ01hXU9IKpXplELjGZ21PwZscDitOMve1F2ywQYxJiAmgiC3j7ei6QLZuof
         JbRcHeW2KC0M+wrqDaeVmkEFk/AnypEzKdIXLZppthvNJH2zqsAAuQbyFVO09i5clvKb
         tVWEP07kakajLv5xlhsk220XFfypxePopm9EZS1reKs2Ni+NGeG5LBkbkZu70Bx4fnZV
         ekGv9UbT+HxlsTcFAM5pMZ5+ZVtchEzFUh/aIkhkgqSOBHxpBTWLNa2O8DYD1JQ8i1b5
         Fozw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=qYiM1nB+OyD/mEZwMx7JkHBPaXFtWcbqs5mGrZ0tS0I=;
        b=b+OS1us7vEvBdXk4AsPsj0wuIyQL8mAv88onxFhXFlBjlMTTrItH9v8gp7mzvDekx2
         PpOspI7HYnYB4EyVQMZBWWNYadNUklajavMDUguSjcAWHZBTYM4kGbEs60zcTJn6B0fK
         8H98PQd2zMaAPPfH+r/jea47wszmiP79iX8cG2Wwon4UOPaCW1qC6Q3HptJBd9kXbPrV
         0/QXGluLoJ9ISJfMZ2e2tD8fRV8DD9zSDnJaMUR+R6ypZ6o7ZEvNi16H1b1/3o2Ij1Ii
         NiSuZxfz9vUl8JCYrsw2ejm/D9ER1M+MInpWVKwXPq+BosFJqb+YKyZ/zP6zk2yRhEOs
         SJug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id y2si4051259edd.322.2019.06.11.21.02.41
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 21:02:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 723F228;
	Tue, 11 Jun 2019 21:02:40 -0700 (PDT)
Received: from [10.162.42.142] (p8cg001049571a15.blr.arm.com [10.162.42.142])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EA9C03F557;
	Tue, 11 Jun 2019 21:02:36 -0700 (PDT)
Subject: Re: [PATCH V5 - Rebased] mm/hotplug: Reorder memblock_[free|remove]()
 calls in try_remove_memory()
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com,
 will.deacon@arm.com, ard.biesheuvel@arm.com, osalvador@suse.de,
 david@redhat.com, mhocko@suse.com, mark.rutland@arm.com
References: <36e0126f-e2d1-239c-71f3-91125a49e019@redhat.com>
 <1560252373-3230-1-git-send-email-anshuman.khandual@arm.com>
 <20190611151908.cdd6b73fd17fda09b1b3b65b@linux-foundation.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <5b4f1f19-2f8d-9b8f-4240-7b728952b6fe@arm.com>
Date: Wed, 12 Jun 2019 09:32:55 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190611151908.cdd6b73fd17fda09b1b3b65b@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/12/2019 03:49 AM, Andrew Morton wrote:
> On Tue, 11 Jun 2019 16:56:13 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
> 
>> Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs
>> entries between memory block and node. It first checks pfn validity with
>> pfn_valid_within() before fetching nid. With CONFIG_HOLES_IN_ZONE config
>> (arm64 has this enabled) pfn_valid_within() calls pfn_valid().
>>
>> pfn_valid() is an arch implementation on arm64 (CONFIG_HAVE_ARCH_PFN_VALID)
>> which scans all mapped memblock regions with memblock_is_map_memory(). This
>> creates a problem in memory hot remove path which has already removed given
>> memory range from memory block with memblock_[remove|free] before arriving
>> at unregister_mem_sect_under_nodes(). Hence get_nid_for_pfn() returns -1
>> skipping subsequent sysfs_remove_link() calls leaving node <-> memory block
>> sysfs entries as is. Subsequent memory add operation hits BUG_ON() because
>> of existing sysfs entries.
>>
>> [   62.007176] NUMA: Unknown node for memory at 0x680000000, assuming node 0
>> [   62.052517] ------------[ cut here ]------------
>> [   62.053211] kernel BUG at mm/memory_hotplug.c:1143!
>> [   62.053868] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
>> [   62.054589] Modules linked in:
>> [   62.054999] CPU: 19 PID: 3275 Comm: bash Not tainted 5.1.0-rc2-00004-g28cea40b2683 #41
>> [   62.056274] Hardware name: linux,dummy-virt (DT)
>> [   62.057166] pstate: 40400005 (nZcv daif +PAN -UAO)
>> [   62.058083] pc : add_memory_resource+0x1cc/0x1d8
>> [   62.058961] lr : add_memory_resource+0x10c/0x1d8
>> [   62.059842] sp : ffff0000168b3ce0
>> [   62.060477] x29: ffff0000168b3ce0 x28: ffff8005db546c00
>> [   62.061501] x27: 0000000000000000 x26: 0000000000000000
>> [   62.062509] x25: ffff0000111ef000 x24: ffff0000111ef5d0
>> [   62.063520] x23: 0000000000000000 x22: 00000006bfffffff
>> [   62.064540] x21: 00000000ffffffef x20: 00000000006c0000
>> [   62.065558] x19: 0000000000680000 x18: 0000000000000024
>> [   62.066566] x17: 0000000000000000 x16: 0000000000000000
>> [   62.067579] x15: ffffffffffffffff x14: ffff8005e412e890
>> [   62.068588] x13: ffff8005d6b105d8 x12: 0000000000000000
>> [   62.069610] x11: ffff8005d6b10490 x10: 0000000000000040
>> [   62.070615] x9 : ffff8005e412e898 x8 : ffff8005e412e890
>> [   62.071631] x7 : ffff8005d6b105d8 x6 : ffff8005db546c00
>> [   62.072640] x5 : 0000000000000001 x4 : 0000000000000002
>> [   62.073654] x3 : ffff8005d7049480 x2 : 0000000000000002
>> [   62.074666] x1 : 0000000000000003 x0 : 00000000ffffffef
>> [   62.075685] Process bash (pid: 3275, stack limit = 0x00000000d754280f)
>> [   62.076930] Call trace:
>> [   62.077411]  add_memory_resource+0x1cc/0x1d8
>> [   62.078227]  __add_memory+0x70/0xa8
>> [   62.078901]  probe_store+0xa4/0xc8
>> [   62.079561]  dev_attr_store+0x18/0x28
>> [   62.080270]  sysfs_kf_write+0x40/0x58
>> [   62.080992]  kernfs_fop_write+0xcc/0x1d8
>> [   62.081744]  __vfs_write+0x18/0x40
>> [   62.082400]  vfs_write+0xa4/0x1b0
>> [   62.083037]  ksys_write+0x5c/0xc0
>> [   62.083681]  __arm64_sys_write+0x18/0x20
>> [   62.084432]  el0_svc_handler+0x88/0x100
>> [   62.085177]  el0_svc+0x8/0xc
> 
> This seems like a serious problem.  Once which should be fixed in 5.2
> and perhaps the various -stable kernels as well.

But the problem does not exist in the current kernel as yet till the reworked
versions of the other two patches in this series get merged. This patch was
after arm64 hot-remove enablement in V1 (https://lkml.org/lkml/2019/4/3/28)
but after some discussions it was decided to be moved before hot-remove from
V2 (https://lkml.org/lkml/2019/4/14/5) onwards as a prerequisite patch instead.

> 
>> Re-ordering memblock_[free|remove]() with arch_remove_memory() solves the
>> problem on arm64 as pfn_valid() behaves correctly and returns positive
>> as memblock for the address range still exists. arch_remove_memory()
>> removes applicable memory sections from zone with __remove_pages() and
>> tears down kernel linear mapping. Removing memblock regions afterwards
>> is safe because there is no other memblock (bootmem) allocator user that
>> late. So nobody is going to allocate from the removed range just to blow
>> up later. Also nobody should be using the bootmem allocated range else
>> we wouldn't allow to remove it. So reordering is indeed safe.
>>
>> ...
>>
>>
>> - Rebased on linux-next (next-20190611)
> 
> Yet the patch you've prepared is designed for 5.3.  Was that
> deliberate, or should we be targeting earlier kernels?

It was deliberate for 5.3 as a preparation for upcoming reworked arm64 hot-remove.

