Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A51D76B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 19:54:34 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so22006654pac.3
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 16:54:34 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id s131si739784pfs.12.2015.12.01.16.54.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 16:54:33 -0800 (PST)
Subject: Re: memory leak in alloc_huge_page
References: <CACT4Y+amx86fBiqoCpFzTa=nOGayDjLb5CENEskrKeRTy6NSQw@mail.gmail.com>
 <565DEC6C.4030809@oracle.com>
 <CACT4Y+Zsw23LiBhakWUFfO88OuuHsV588g3T9UPfMKxRBLojGQ@mail.gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <565E413D.8050608@oracle.com>
Date: Tue, 1 Dec 2015 16:54:21 -0800
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Zsw23LiBhakWUFfO88OuuHsV588g3T9UPfMKxRBLojGQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Eric Dumazet <edumazet@google.com>

On 12/01/2015 11:45 AM, Dmitry Vyukov wrote:
> On Tue, Dec 1, 2015 at 7:52 PM, Mike Kravetz <mike.kravetz@oracle.com> wrote:
>> On 12/01/2015 06:04 AM, Dmitry Vyukov wrote:

>>> There seems to be another leak if nrg is not NULL on this path, but
>>> it's not what happens in my case since the WARNING does not fire.
>>
>> If nrg is not NULL, then it was added to the resv map and 'should' be
>> free'ed when the map is free'ed.  This is not optimal, but I do not
>> think it would lead to a leak.  I'll take a close look at this code
>> with an emphasis on the leak you discovered.
> 
> 
> Hi Mike,
> 
> Note that it's not just a leak report, it is an actual leak. You
> should be able to reproduce it.
> 

OK, finally found the bug which is in region_del().  It does not correctly
handle a "placeholder" region descriptor that is left after an aborted
operation when the start of the region to be deleted is for the same page.

I will have a patch shortly, after some testing.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
