Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 059F16B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 20:57:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a6so106333pfn.3
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 17:57:03 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y16si2914329pfm.142.2018.04.10.17.57.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 17:57:02 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, pagemap: Fix swap offset value for PMD migration entry
References: <20180408033737.10897-1-ying.huang@intel.com>
	<20180409174753.4b959a5b3ff732b8f96f5a14@linux-foundation.org>
	<87in8znaj4.fsf@yhuang-dev.intel.com>
	<20180410111222.akgtbqsmrpmm2clt@node.shutemov.name>
Date: Wed, 11 Apr 2018 08:56:58 +0800
In-Reply-To: <20180410111222.akgtbqsmrpmm2clt@node.shutemov.name> (Kirill
	A. Shutemov's message of "Tue, 10 Apr 2018 14:12:22 +0300")
Message-ID: <87r2nmftlx.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrei Vagin <avagin@openvz.org>, Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, Daniel Colascione <dancol@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Tue, Apr 10, 2018 at 08:57:19AM +0800, Huang, Ying wrote:
>> >> the swap offset reported doesn't
>> >> reflect this.  And in the loop to report information of each sub-page,
>> >> the swap offset isn't increased accordingly as that for PFN.
>> >> 
>> >> BTW: migration swap entries have PFN information, do we need to
>> >> restrict whether to show them?
>> >
>> > For what reason?  Address obfuscation?
>> 
>> This is an existing feature for PFN report of /proc/<pid>/pagemap,
>> reason is in following commit log.  I am wondering whether that is
>> necessary for migration swap entries too.
>> 
>> ab676b7d6fbf4b294bf198fb27ade5b0e865c7ce
>> Author:     Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> AuthorDate: Mon Mar 9 23:11:12 2015 +0200
>> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
>> CommitDate: Tue Mar 17 09:31:30 2015 -0700
>> 
>> pagemap: do not leak physical addresses to non-privileged userspace
>> 
>> As pointed by recent post[1] on exploiting DRAM physical imperfection,
>> /proc/PID/pagemap exposes sensitive information which can be used to do
>> attacks.
>> 
>> This disallows anybody without CAP_SYS_ADMIN to read the pagemap.
>> 
>> [1] http://googleprojectzero.blogspot.com/2015/03/exploiting-dram-rowhammer-bug-to-gain.html
>> 
>> [ Eventually we might want to do anything more finegrained, but for now
>>   this is the simple model.   - Linus ]
>
> Note that there's follow up to the commit: 
>
> 1c90308e7a77 ("pagemap: hide physical addresses from non-privileged users")
>
> It introduces pm->show_pfn and it should be applied to swap entries too.

So you think we should hide all swap entry information if
(!pm->show_pfn) regardless they are migration swap entries or not?

Best Regards,
Huang, Ying
