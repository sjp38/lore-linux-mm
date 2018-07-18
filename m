Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2AD6B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 22:37:00 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id d189-v6so1138097vka.8
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 19:37:00 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y74-v6si785074vkd.146.2018.07.17.19.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 19:36:58 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm: fix race on soft-offlining free huge pages
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1531805552-19547-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180717142743.GJ7193@dhcp22.suse.cz>
 <773a2f4e-c420-e973-cadd-4144730d28e8@oracle.com>
 <20180718012817.GB12184@hori1.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <161a4a4c-4311-9d68-fe05-b22d7e33dd61@oracle.com>
Date: Tue, 17 Jul 2018 19:36:47 -0700
MIME-Version: 1.0
In-Reply-To: <20180718012817.GB12184@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "zy.zhengyi@alibaba-inc.com" <zy.zhengyi@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 07/17/2018 06:28 PM, Naoya Horiguchi wrote:
> On Tue, Jul 17, 2018 at 01:10:39PM -0700, Mike Kravetz wrote:
>> It seems that soft_offline_free_page can be called for in use pages.
>> Certainly, that is the case in the first workflow above.  With the
>> suggested changes, I think this is OK for huge pages.  However, it seems
>> that setting HWPoison on a in use non-huge page could cause issues?
> 
> Just after dissolve_free_huge_page() returns, the target page is just a
> free buddy page without PageHWPoison set. If this page is allocated
> immediately, that's "migration succeeded, but soft offline failed" case,
> so no problem.
> Certainly, there also is a race between cheking TestSetPageHWPoison and
> page allocation, so this issue is handled in patch 2/2.

Yes, the issue of calling soft_offline_free_page() for an 'in use' page
is handled in the new routine set_hwpoison_free_buddy_page() of patch 2/2.

Thanks,
-- 
Mike Kravetz
