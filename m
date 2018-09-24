Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 288A18E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 12:40:37 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id c24-v6so3360472otm.4
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 09:40:37 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o203-v6si14868352oif.198.2018.09.24.09.40.35
        for <linux-mm@kvack.org>;
        Mon, 24 Sep 2018 09:40:35 -0700 (PDT)
Subject: Re: [PATCH] mm/migrate: Split only transparent huge pages when
 allocation fails
References: <1537798495-4996-1-git-send-email-anshuman.khandual@arm.com>
 <20180924143027.GE18685@dhcp22.suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <421f9b78-cb0f-01ce-dca0-93ff6eae0816@arm.com>
Date: Mon, 24 Sep 2018 22:10:30 +0530
MIME-Version: 1.0
In-Reply-To: <20180924143027.GE18685@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org



On 09/24/2018 08:00 PM, Michal Hocko wrote:
> On Mon 24-09-18 19:44:55, Anshuman Khandual wrote:
>> When unmap_and_move[_huge_page] function fails due to lack of memory, the
>> splitting should happen only for transparent huge pages not for HugeTLB
>> pages. PageTransHuge() returns true for both THP and HugeTLB pages. Hence
>> the conditonal check should test PagesHuge() flag to make sure that given
>> pages is not a HugeTLB one.
> 
> Well spotted! Have you actually seen this happening or this is review
> driven? I am wondering what would be the real effect of this mismatch?
> I have tried to follow to code path but I suspect
> split_huge_page_to_list would fail for hugetlbfs pages. If there is a
> more serious effect then we should mark the patch for stable as well.

split_huge_page_to_list() fails on HugeTLB pages. I was experimenting around
moving 32MB contig HugeTLB pages on arm64 (with a debug patch applied) hit
the following stack trace when the kernel crashed.

[ 3732.462797] Call trace:
[ 3732.462835]  split_huge_page_to_list+0x3b0/0x858
[ 3732.462913]  migrate_pages+0x728/0xc20
[ 3732.462999]  soft_offline_page+0x448/0x8b0
[ 3732.463097]  __arm64_sys_madvise+0x724/0x850
[ 3732.463197]  el0_svc_handler+0x74/0x110
[ 3732.463297]  el0_svc+0x8/0xc
[ 3732.463347] Code: d1000400 f90b0e60 f2fbd5a2 a94982a1 (f9000420)
