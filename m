Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE1856B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 19:36:14 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id r5so430060qkb.22
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 16:36:14 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v1si13106470qtg.188.2018.03.06.16.36.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 16:36:13 -0800 (PST)
Subject: Re: [Bug 199037] New: Kernel bug at mm/hugetlb.c:741
From: Mike Kravetz <mike.kravetz@oracle.com>
References: <bug-199037-27@https.bugzilla.kernel.org/>
 <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
 <7ffa77c8-8624-9c69-d1f5-058ef22c460c@oracle.com>
Message-ID: <ecc197fa-ae01-8be8-55ec-e82eb1050f57@oracle.com>
Date: Tue, 6 Mar 2018 16:31:04 -0800
MIME-Version: 1.0
In-Reply-To: <7ffa77c8-8624-9c69-d1f5-058ef22c460c@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, blurbdust@gmail.com

On 03/06/2018 01:46 PM, Mike Kravetz wrote:
> On 03/06/2018 01:31 PM, Andrew Morton wrote:
>>
>> That's VM_BUG_ON(resv_map->adds_in_progress) in resv_map_release().
>>
>> Do you know if earlier kernel versions are affected?
>>
>> It looks quite bisectable.  Does the crash happen every time the test
>> program is run?
> 
> I'll take a look.  There was a previous bug in this area:
> ff8c0c53: mm/hugetlb.c: don't call region_abort if region_chg fails

This is similar to the issue addressed in 045c7a3f ("fix offset overflow
in hugetlbfs mmap").  The problem here is that the pgoff argument passed
to remap_file_pages() is 0x20000000000000.  In the process of converting
this to a page offset and putting it in vm_pgoff, and then converting back
to bytes to compute mapping length we end up with 0.  We ultimately end
up passing (from,to) page offsets into hugetlbfs where from is greater
than to. :( This confuses the heck out the the huge page reservation code
as the 'negative' range looks like an error and we never complete the
reservation process and leave the 'adds_in_progress'.

This issue has existed for a long time.  The VM_BUG_ON just happens to
catch the situation which was previously not reported or had some other
side effect.  Commit 045c7a3f tried to catch these overflow issues when
converting types, but obviously missed this one.  I can easily add a test
for this specific value/condition, but want to think about it a little
more and see if there is a better way to catch all of these.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
