Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 56E3C6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 20:57:23 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id o33-v6so8134675plb.16
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 17:57:23 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id p22si963716pgn.682.2018.04.09.17.57.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 17:57:22 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, pagemap: Fix swap offset value for PMD migration entry
References: <20180408033737.10897-1-ying.huang@intel.com>
	<20180409174753.4b959a5b3ff732b8f96f5a14@linux-foundation.org>
Date: Tue, 10 Apr 2018 08:57:19 +0800
In-Reply-To: <20180409174753.4b959a5b3ff732b8f96f5a14@linux-foundation.org>
	(Andrew Morton's message of "Mon, 9 Apr 2018 17:47:53 -0700")
Message-ID: <87in8znaj4.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrei Vagin <avagin@openvz.org>, Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, Daniel Colascione <dancol@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Sun,  8 Apr 2018 11:37:37 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
>
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> The swap offset reported by /proc/<pid>/pagemap may be not correct for
>> PMD migration entry.  If addr passed into pagemap_range() isn't
>
> pagemap_pmd_range(), yes?

Yes.  Sorry for typo.

>> aligned with PMD start address,
>
> How can this situation come about?

After open /proc/<pid>/pagemap, if user seeks to a page whose address
doesn't aligned with PMD start address.  I have verified this with a
simple test program.

>> the swap offset reported doesn't
>> reflect this.  And in the loop to report information of each sub-page,
>> the swap offset isn't increased accordingly as that for PFN.
>> 
>> BTW: migration swap entries have PFN information, do we need to
>> restrict whether to show them?
>
> For what reason?  Address obfuscation?

This is an existing feature for PFN report of /proc/<pid>/pagemap,
reason is in following commit log.  I am wondering whether that is
necessary for migration swap entries too.

ab676b7d6fbf4b294bf198fb27ade5b0e865c7ce
Author:     Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
AuthorDate: Mon Mar 9 23:11:12 2015 +0200
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Tue Mar 17 09:31:30 2015 -0700

pagemap: do not leak physical addresses to non-privileged userspace

As pointed by recent post[1] on exploiting DRAM physical imperfection,
/proc/PID/pagemap exposes sensitive information which can be used to do
attacks.

This disallows anybody without CAP_SYS_ADMIN to read the pagemap.

[1] http://googleprojectzero.blogspot.com/2015/03/exploiting-dram-rowhammer-bug-to-gain.html

[ Eventually we might want to do anything more finegrained, but for now
  this is the simple model.   - Linus ]

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Acked-by: Andy Lutomirski <luto@amacapital.net>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Seaborn <mseaborn@chromium.org>
Cc: stable@vger.kernel.org
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

Best Regards,
Huang, Ying
