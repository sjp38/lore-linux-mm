Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f173.google.com (mail-gg0-f173.google.com [209.85.161.173])
	by kanga.kvack.org (Postfix) with ESMTP id 73DA46B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 21:18:02 -0500 (EST)
Received: by mail-gg0-f173.google.com with SMTP id q4so458237ggn.4
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 18:18:02 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id o28si17176045yhd.66.2013.12.17.18.18.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 18:18:01 -0800 (PST)
Message-ID: <52B105CD.1090102@oracle.com>
Date: Wed, 18 Dec 2013 10:17:49 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at mm/mlock.c:82!
References: <52AFA331.9070108@oracle.com> <52AFE38D.2030008@oracle.com> <52AFF35E.7000908@oracle.com> <52b00ae4.a377b60a.1c68.ffffe284SMTPIN_ADDED_BROKEN@mx.google.com> <6B2BA408B38BA1478B473C31C3D2074E2AFAC0ADF6@SV-EXCHANGE1.Corp.FC.LOCAL> <52b10249.ea34b60a.1e6e.ffff9dc7SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <52b10249.ea34b60a.1e6e.ffff9dc7SMTPIN_ADDED_BROKEN@mx.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, "npiggin@suse.de" <npiggin@suse.de>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>

On 12/18/2013 10:02 AM, Wanpeng Li wrote:
> Hi Motohiro,
> On Tue, Dec 17, 2013 at 08:32:49AM -0800, Motohiro Kosaki wrote:
>>
>>
>>> -----Original Message-----
>>> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
>>> Behalf Of Wanpeng Li
>>> Sent: Tuesday, December 17, 2013 3:27 AM
>>> To: Sasha Levin
>>> Cc: Bob Liu; Andrew Morton; linux-mm@kvack.org; Michel Lespinasse;
>>> npiggin@suse.de; Motohiro Kosaki JP; riel@redhat.com
>>> Subject: Re: mm: kernel BUG at mm/mlock.c:82!
>>>
>>> Hi Sasha,
>>> On Tue, Dec 17, 2013 at 01:46:54AM -0500, Sasha Levin wrote:
>>>> On 12/17/2013 12:39 AM, Bob Liu wrote:
>>>>> cc'd more people.
>>>>>
>>>>> On 12/17/2013 09:04 AM, Sasha Levin wrote:
>>>>>> Hi all,
>>>>>>
>>>>>> While fuzzing with trinity inside a KVM tools guest running latest
>>>>>> -next kernel, I've stumbled on the following spew.
>>>>>>
>>>>>> Codewise, it's pretty straightforward. In try_to_unmap_cluster():
>>>>>>
>>>>>>                 page = vm_normal_page(vma, address, *pte);
>>>>>>                 BUG_ON(!page || PageAnon(page));
>>>>>>
>>>>>>                 if (locked_vma) {
>>>>>>                         mlock_vma_page(page);   /* no-op if already
>>>>>> mlocked */
>>>>>>                         if (page == check_page)
>>>>>>                                 ret = SWAP_MLOCK;
>>>>>>                         continue;       /* don't unmap */
>>>>>>                 }
>>>>>>
>>>>>> And the BUG triggers once we see that 'page' isn't locked.
>>>>>>
>>>>>
>>>>> Yes, I didn't see any place locked the corresponding page in
>>>>> try_to_unmap_cluster().
>>>>>
>>>>> I'm afraid adding lock_page() over there may cause potential deadlock.
>>>>> How about just remove the BUG_ON() in mlock_vma_page()?
>>>>
>>>> Welp, it's been there for 5 years now - there should be a good reason to
>>> justify removing it.
>>>>
>>>
>>> Page should be locked before invoke try_to_unmap(), this check can't be
>>> removed since this bug is just triggered by confirm !check page hold page
>>> lock in virtual scan during nolinear VMAs pages aging. Avoid to confirm !check
>>> page hold page lock is acceptable.
>>
>> That's a try_to_unmap()'s assumption and it already have  BUG_ON(!PageLocked(page)).
>> We can remove wrong BUG_ON from mlock_vma_page() simply. Mlock_vma_page() doesn't depend on page-locked.
>>
> 
> There is a race between mlock_vma_page() and munlock_vma_page(). Both of
> them should hold page lock and have a BUG_ON assumption. 

If mlock_vma_page() really need pagelocked, then we have to add
lock_page() in try_to_unmap_cluster().
Else just remove the BUG_ON() to make things simple.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
