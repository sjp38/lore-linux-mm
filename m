Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 974E66B0038
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 01:47:01 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id f64so4644212yha.17
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 22:47:01 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r49si14873854yho.217.2013.12.16.22.47.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 22:47:00 -0800 (PST)
Message-ID: <52AFF35E.7000908@oracle.com>
Date: Tue, 17 Dec 2013 01:46:54 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at mm/mlock.c:82!
References: <52AFA331.9070108@oracle.com> <52AFE38D.2030008@oracle.com>
In-Reply-To: <52AFE38D.2030008@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, npiggin@suse.de, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com

On 12/17/2013 12:39 AM, Bob Liu wrote:
> cc'd more people.
>
> On 12/17/2013 09:04 AM, Sasha Levin wrote:
>> Hi all,
>>
>> While fuzzing with trinity inside a KVM tools guest running latest -next
>> kernel, I've
>> stumbled on the following spew.
>>
>> Codewise, it's pretty straightforward. In try_to_unmap_cluster():
>>
>>                  page = vm_normal_page(vma, address, *pte);
>>                  BUG_ON(!page || PageAnon(page));
>>
>>                  if (locked_vma) {
>>                          mlock_vma_page(page);   /* no-op if already
>> mlocked */
>>                          if (page == check_page)
>>                                  ret = SWAP_MLOCK;
>>                          continue;       /* don't unmap */
>>                  }
>>
>> And the BUG triggers once we see that 'page' isn't locked.
>>
>
> Yes, I didn't see any place locked the corresponding page in
> try_to_unmap_cluster().
>
> I'm afraid adding lock_page() over there may cause potential deadlock.
> How about just remove the BUG_ON() in mlock_vma_page()?

Welp, it's been there for 5 years now - there should be a good reason to justify removing it.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
