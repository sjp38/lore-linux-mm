Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8380EC28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:37:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 092AD2089E
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:37:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 092AD2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1ADB46B000C; Fri,  7 Jun 2019 02:06:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1105E6B0266; Fri,  7 Jun 2019 02:06:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F24166B0269; Fri,  7 Jun 2019 02:06:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A28CE6B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 02:06:48 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l53so1527305edc.7
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 23:06:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=I9QRIUQesoA7PvBni8ercjLBmUfHrHcKYXBNK3H7UGQ=;
        b=WBYu5wkIm+SebXMccHPlbDw2VDg+Qf2+875ug+8rAdc2P5EGX4IxCM4/R40JUoeThe
         6Gk4c/w6YEWfttq5KAwfXBKcY+T21dRyy3gol64VzM+6+UXvlihnd2mGo0Dga+0hWnB6
         qaFnOH5jKp3CeeQi6ApJ4GexRAlFpHW5TRKPVy3/MCvRdwyVrNYfUNIkM+ILKQz4t0fQ
         L6umF4ZQi+rh1M1uB90vzghP442tdEDM8EmYnqNjdCd4RwqThcVoeuN/Df+tcG57hSPO
         I8KNFq5rmwKo1zZpAnMeoTnSLYgAKgfWmgIfIHlpaKCeWpTwF9hX7mEBJdLZ6jfcLL4F
         SCPw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.140.110.172 is neither permitted nor denied by best guess record for domain of anshuman.khandual@arm.com) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAX7lWKoFCDLl4d/W2yQrpAcX7BsQ4i5oUAh18uD4xMz8tSmuOLU
	Zgml25PC2NdDHLMrKYlI7eDlALAE5GnhYvUL79/v3GccAT3xNPPJdERqjaUeO1WfX15VEXvMroF
	2u1NGCYzJNczcfVFVkvlw7utbCMc2MCBjdDo9E5Rqh/qX0FYgOAO95swYeHv9rs0=
X-Received: by 2002:a17:906:d182:: with SMTP id c2mr30851733ejz.311.1559887608136;
        Thu, 06 Jun 2019 23:06:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKFbKmjIUfAYvoceOrq5KVVfjq2BqZfX2Iu/GvVBcUcuXU53GLNDsHsPt36DV5hJD7LiyO
X-Received: by 2002:a17:906:d182:: with SMTP id c2mr30851668ejz.311.1559887606922;
        Thu, 06 Jun 2019 23:06:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559887606; cv=none;
        d=google.com; s=arc-20160816;
        b=LPnAP+Olsi5TmtVzGrfbYT8YeZ/wsNbosqqkEzIpFIrnIb2GXJdzgmLe8lgkd9nCMh
         LE6Wm7FnlTpFWzKcVQysaqRFQQG8bdRxnNbY8PdQ3lHwkan3Znd86LIrfbYf7oLyYq9l
         XO6tiqoA5SDGMQBgf7mw4njqPovz1m589ZZ4yVysPGbFe6OL7o25Z2OMYh5lXmctELQ9
         pVg/iEVRyOsAWb0h1zANhQ3vuhG2PBZRuUoG1OdVlJB/xutgoX/Guozoy53UTYF71unf
         ni0aRrhR7K3Jth1o1JsuXYFLhVfrL/s6BASPZM7P7gqsMhkYYwMB2DNYfi+0nCbyEIJU
         7e/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=I9QRIUQesoA7PvBni8ercjLBmUfHrHcKYXBNK3H7UGQ=;
        b=VbPsRMi/7Sqho9d4CtgJox9XOIk8PTGLhTFgcMLGQCEj3xcuJJxhS72NPSryBlJlTE
         JDYTwWfrlviEKTXhQxc4edfcs9ijX1BNpKPklUzCIXBJ95u3+QajaaVCAYnDBPbW5gZQ
         Z/zUgtQZHABPB/qyyTgnfKnIndVuBFDleIrvaNlukn79E1S410RWRYP9KWx+ITvZCHaT
         gdZiHClIM9FCntrvaQnC1TORs+b+kE5/Rhvy8YL1VWNr/V3zxMNDFcYXMpp8rRpaTWb0
         7qBRF/tm8AHWuB8639ALuawXa7BgeLH0byiz0O3B9h0V4Oa+gayBpenZFdVwiAKED2Cz
         cTdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.140.110.172 is neither permitted nor denied by best guess record for domain of anshuman.khandual@arm.com) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com ([217.140.110.172])
        by mx.google.com with ESMTP id h20si630026edb.315.2019.06.06.23.06.45
        for <linux-mm@kvack.org>;
        Thu, 06 Jun 2019 23:06:46 -0700 (PDT)
Received-SPF: neutral (google.com: 217.140.110.172 is neither permitted nor denied by best guess record for domain of anshuman.khandual@arm.com) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.140.110.172 is neither permitted nor denied by best guess record for domain of anshuman.khandual@arm.com) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E8DA941B5;
	Thu,  6 Jun 2019 23:06:44 -0700 (PDT)
Received: from [10.162.42.131] (p8cg001049571a15.blr.arm.com [10.162.42.131])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 520C14029C;
	Thu,  6 Jun 2019 19:28:26 -0700 (PDT)
Subject: Re: [PATCH V5 1/3] mm/hotplug: Reorder arch_remove_memory() call in
 __remove_memory()
To: Mark Rutland <mark.rutland@arm.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 catalin.marinas@arm.com, will.deacon@arm.com, mhocko@suse.com,
 ira.weiny@intel.com, david@redhat.com, cai@lca.pw, logang@deltatee.com,
 james.morse@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, mgorman@techsingularity.net, osalvador@suse.de,
 ard.biesheuvel@arm.com
References: <1559121387-674-1-git-send-email-anshuman.khandual@arm.com>
 <1559121387-674-2-git-send-email-anshuman.khandual@arm.com>
 <20190530103709.GB56046@lakrids.cambridge.arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <7d0538bb-aeef-f5f5-3371-db7b58dcb083@arm.com>
Date: Fri, 7 Jun 2019 07:58:42 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190530103709.GB56046@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/30/2019 04:07 PM, Mark Rutland wrote:
> On Wed, May 29, 2019 at 02:46:25PM +0530, Anshuman Khandual wrote:
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
>>
>> Re-ordering arch_remove_memory() with memblock_[free|remove] solves the
>> problem on arm64 as pfn_valid() behaves correctly and returns positive
>> as memblock for the address range still exists. arch_remove_memory()
>> removes applicable memory sections from zone with __remove_pages() and
>> tears down kernel linear mapping. Removing memblock regions afterwards
>> is safe because there is no other memblock (bootmem) allocator user that
>> late. So nobody is going to allocate from the removed range just to blow
>> up later. Also nobody should be using the bootmem allocated range else
>> we wouldn't allow to remove it. So reordering is indeed safe.
>>
>> Acked-by: Michal Hocko <mhocko@suse.com>
>> Reviewed-by: David Hildenbrand <david@redhat.com>
>> Reviewed-by: Oscar Salvador <osalvador@suse.de>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> 
> Acked-by: Mark Rutland <mark.rutland@arm.com>

Hello Andrew,

Will it be possible for this particular patch of the series to be merged alone.
I am still reworking arm64 hot-remove parts as per the suggestions from Mark.
Just wondering if this patch which has been reviewed and acked for a while now
can be out of our way.

Also because this has some conflict with David's series which can be sorted out
earlier before arm64 hot-remove V6 series comes in.

From my previous response on this series last week, the following can resolve
the conflict with David's [v3, 09/11] patch.

C) Rebase (https://patchwork.kernel.org/patch/10962589/) [v3, 09/11]

	- hot-remove series moves arch_remove_memory() before memblock_[free|remove]()
	- So remove_memory_block_devices() should be moved before arch_remove_memory()
	  in it's new position   

It will be great if this patch can be merged alone.

- Anshuman

