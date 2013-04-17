Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 590036B003D
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 02:46:26 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5832C3EE0BB
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 15:46:24 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D13945DE51
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 15:46:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 22C0045DE4D
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 15:46:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 145801DB802F
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 15:46:24 +0900 (JST)
Received: from g01jpexchkw35.g01.fujitsu.local (g01jpexchkw35.g01.fujitsu.local [10.0.193.50])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C17FB1DB8037
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 15:46:23 +0900 (JST)
Message-ID: <516E452A.7060703@jp.fujitsu.com>
Date: Wed, 17 Apr 2013 15:46:02 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Bug fix PATCH v3] Reusing a resource structure allocated by
 bootmem
References: <516DEC34.7040008@jp.fujitsu.com> <alpine.DEB.2.02.1304161733340.14583@chino.kir.corp.google.com> <516E2305.3060705@jp.fujitsu.com> <alpine.DEB.2.02.1304162144320.3493@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1304162144320.3493@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, toshi.kani@hp.com, linuxram@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi David,

2013/04/17 13:47, David Rientjes wrote:
> On Wed, 17 Apr 2013, Yasuaki Ishimatsu wrote:
>
>>> Why not simply do what generic sparsemem support does by testing
>>> PageSlab(virt_to_head_page(res)) and calling kfree() if true and freeing
>>> back to bootmem if false?  This should be like a five line patch.
>>
>> Is your explanation about free_section_usemap()?
>> If so, I don't think we can release resource structure like
>> free_section_usemap().
>

> Right, you can't release it like free_section_usemap(), but you're free to
> test for PageSlab(virt_to_head_page(res)) in kernel/resource.c.

O.K. I'll update it.

>
>> In your explanation case, memmap can be released by put_page_bootmem() in
>> free_map_bootmem() since all pages of memmap is used only for memmap.
>> But if my understanding is correct, a page of released resource structure
>> contain other purpose objects allocated by bootmem. So we cannot
>> release resource structure like free_section_usemap().
>>
>
> I'm thinking it would be much easier to just suppress the kfree() if
> !PageSlab.  If you can free an entire page with free_bootmem_late(),
> that would be great,

> but I'm thinking that will take more work than it's
> worth.  It seems fine to just do free_bootmem() and leave those pages as
> reserved.

I think so, too.

> How much memory are we talking about?

Hmm. I don't know correctly.

Here is kernel message of my system. The message is shown by mem_init().

-- 
Memory: 30491076k/33554432k available (5570k kernel code, 2274228k absent, 789128k reserved, 5667k data, 1784k init)
---

Reserved memroy size is 789128k. So part of them is freed after system boot
by  memory hotplug  et al.

Thanks,
Yasuaki Ishimatsu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
