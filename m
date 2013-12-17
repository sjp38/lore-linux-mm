Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f41.google.com (mail-oa0-f41.google.com [209.85.219.41])
	by kanga.kvack.org (Postfix) with ESMTP id 149256B0037
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 03:27:17 -0500 (EST)
Received: by mail-oa0-f41.google.com with SMTP id j17so6280754oag.28
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 00:27:16 -0800 (PST)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id kv3si10651797obb.149.2013.12.17.00.27.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 00:27:16 -0800 (PST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 17 Dec 2013 13:57:05 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 5F1D03940057
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 13:57:02 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBH8QvK140763442
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 13:56:58 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBH8QxOf002505
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 13:57:00 +0530
Date: Tue, 17 Dec 2013 16:26:57 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: mm: kernel BUG at mm/mlock.c:82!
Message-ID: <52b00ae4.a377b60a.1c68.ffffe284SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <52AFA331.9070108@oracle.com>
 <52AFE38D.2030008@oracle.com>
 <52AFF35E.7000908@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52AFF35E.7000908@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Bob Liu <bob.liu@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, npiggin@suse.de, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com

Hi Sasha,
On Tue, Dec 17, 2013 at 01:46:54AM -0500, Sasha Levin wrote:
>On 12/17/2013 12:39 AM, Bob Liu wrote:
>>cc'd more people.
>>
>>On 12/17/2013 09:04 AM, Sasha Levin wrote:
>>>Hi all,
>>>
>>>While fuzzing with trinity inside a KVM tools guest running latest -next
>>>kernel, I've
>>>stumbled on the following spew.
>>>
>>>Codewise, it's pretty straightforward. In try_to_unmap_cluster():
>>>
>>>                 page = vm_normal_page(vma, address, *pte);
>>>                 BUG_ON(!page || PageAnon(page));
>>>
>>>                 if (locked_vma) {
>>>                         mlock_vma_page(page);   /* no-op if already
>>>mlocked */
>>>                         if (page == check_page)
>>>                                 ret = SWAP_MLOCK;
>>>                         continue;       /* don't unmap */
>>>                 }
>>>
>>>And the BUG triggers once we see that 'page' isn't locked.
>>>
>>
>>Yes, I didn't see any place locked the corresponding page in
>>try_to_unmap_cluster().
>>
>>I'm afraid adding lock_page() over there may cause potential deadlock.
>>How about just remove the BUG_ON() in mlock_vma_page()?
>
>Welp, it's been there for 5 years now - there should be a good reason to justify removing it.
>

Page should be locked before invoke try_to_unmap(), this check can't be removed 
since this bug is just triggered by confirm !check page hold page lock in virtual 
scan during nolinear VMAs pages aging. Avoid to confirm !check page hold page 
lock is acceptable.

Regards,
Wanpeng Li 

>
>Thanks,
>Sasha
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
