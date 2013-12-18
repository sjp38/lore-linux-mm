Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f49.google.com (mail-oa0-f49.google.com [209.85.219.49])
	by kanga.kvack.org (Postfix) with ESMTP id 33B8A6B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 21:02:50 -0500 (EST)
Received: by mail-oa0-f49.google.com with SMTP id i4so7541048oah.36
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 18:02:49 -0800 (PST)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id w10si12768270obo.17.2013.12.17.18.02.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 18:02:49 -0800 (PST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 18 Dec 2013 07:32:45 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 365801258053
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 07:33:56 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBI22b4M49479878
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 07:32:38 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBI22f7E015125
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 07:32:41 +0530
Date: Wed, 18 Dec 2013 10:02:39 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: mm: kernel BUG at mm/mlock.c:82!
Message-ID: <52b10249.ea34b60a.1e6e.ffff9dc7SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <52AFA331.9070108@oracle.com>
 <52AFE38D.2030008@oracle.com>
 <52AFF35E.7000908@oracle.com>
 <52b00ae4.a377b60a.1c68.ffffe284SMTPIN_ADDED_BROKEN@mx.google.com>
 <6B2BA408B38BA1478B473C31C3D2074E2AFAC0ADF6@SV-EXCHANGE1.Corp.FC.LOCAL>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6B2BA408B38BA1478B473C31C3D2074E2AFAC0ADF6@SV-EXCHANGE1.Corp.FC.LOCAL>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Cc: Bob Liu <bob.liu@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, "npiggin@suse.de" <npiggin@suse.de>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>

Hi Motohiro,
On Tue, Dec 17, 2013 at 08:32:49AM -0800, Motohiro Kosaki wrote:
>
>
>> -----Original Message-----
>> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
>> Behalf Of Wanpeng Li
>> Sent: Tuesday, December 17, 2013 3:27 AM
>> To: Sasha Levin
>> Cc: Bob Liu; Andrew Morton; linux-mm@kvack.org; Michel Lespinasse;
>> npiggin@suse.de; Motohiro Kosaki JP; riel@redhat.com
>> Subject: Re: mm: kernel BUG at mm/mlock.c:82!
>> 
>> Hi Sasha,
>> On Tue, Dec 17, 2013 at 01:46:54AM -0500, Sasha Levin wrote:
>> >On 12/17/2013 12:39 AM, Bob Liu wrote:
>> >>cc'd more people.
>> >>
>> >>On 12/17/2013 09:04 AM, Sasha Levin wrote:
>> >>>Hi all,
>> >>>
>> >>>While fuzzing with trinity inside a KVM tools guest running latest
>> >>>-next kernel, I've stumbled on the following spew.
>> >>>
>> >>>Codewise, it's pretty straightforward. In try_to_unmap_cluster():
>> >>>
>> >>>                 page = vm_normal_page(vma, address, *pte);
>> >>>                 BUG_ON(!page || PageAnon(page));
>> >>>
>> >>>                 if (locked_vma) {
>> >>>                         mlock_vma_page(page);   /* no-op if already
>> >>>mlocked */
>> >>>                         if (page == check_page)
>> >>>                                 ret = SWAP_MLOCK;
>> >>>                         continue;       /* don't unmap */
>> >>>                 }
>> >>>
>> >>>And the BUG triggers once we see that 'page' isn't locked.
>> >>>
>> >>
>> >>Yes, I didn't see any place locked the corresponding page in
>> >>try_to_unmap_cluster().
>> >>
>> >>I'm afraid adding lock_page() over there may cause potential deadlock.
>> >>How about just remove the BUG_ON() in mlock_vma_page()?
>> >
>> >Welp, it's been there for 5 years now - there should be a good reason to
>> justify removing it.
>> >
>> 
>> Page should be locked before invoke try_to_unmap(), this check can't be
>> removed since this bug is just triggered by confirm !check page hold page
>> lock in virtual scan during nolinear VMAs pages aging. Avoid to confirm !check
>> page hold page lock is acceptable.
>
>That's a try_to_unmap()'s assumption and it already have  BUG_ON(!PageLocked(page)).
>We can remove wrong BUG_ON from mlock_vma_page() simply. Mlock_vma_page() doesn't depend on page-locked.
>

There is a race between mlock_vma_page() and munlock_vma_page(). Both of
them should hold page lock and have a BUG_ON assumption. 

Regards,
Wanpeng Li 

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
