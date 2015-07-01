Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 06D9F6B0253
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 19:00:22 -0400 (EDT)
Received: by oigx81 with SMTP id x81so43277044oig.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 16:00:21 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id j188si2735485oif.115.2015.07.01.16.00.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 16:00:21 -0700 (PDT)
Message-ID: <55946EA9.2080805@oracle.com>
Date: Wed, 01 Jul 2015 18:50:17 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/11] mm: debug: dump page into a string rather than
 directly on screen
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com> <1431623414-1905-6-git-send-email-sasha.levin@oracle.com> <alpine.DEB.2.10.1506301627030.5359@chino.kir.corp.google.com> <55943DC1.6010209@oracle.com> <alpine.DEB.2.10.1507011422070.14014@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1507011422070.14014@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill@shutemov.name

On 07/01/2015 05:25 PM, David Rientjes wrote:
> On Wed, 1 Jul 2015, Sasha Levin wrote:
> 
>> On 06/30/2015 07:35 PM, David Rientjes wrote:
>>> I don't know how others feel, but this looks strange to me and seems like 
>>> it's only a result of how we must now dump page information 
>>> (dump_page(page) is no longer available, we must do pr_alert("%pZp", 
>>> page)).
>>>
>>> Since we're relying on print formats, this would arguably be better as
>>>
>>> 	pr_alert("Not movable balloon page:\n");
>>> 	pr_alert("%pZp", page);
>>>
>>> to avoid introducing newlines into potentially lengthy messages that need 
>>> a specified loglevel like you've done above.
>>>
>>> But that's not much different than the existing dump_page() 
>>> implementation.
>>>
>>> So for this to be worth it, it seems like we'd need a compelling usecase 
>>> for something like pr_alert("%pZp %pZv", page, vma) and I'm not sure we're 
>>> ever actually going to see that.  I would argue that
>>>
>>> 	dump_page(page);
>>> 	dump_vma(vma);
>>>
>>> would be simpler in such circumstances.
>>
>> I think we can find usecases where we want to dump more information than what's
>> contained in just one page/vma/mm struct. Things like the following from mm/gup.c:
>>
>> 	VM_BUG_ON_PAGE(compound_head(page) != head, page);
>>
>> Where seeing 'head' would be interesting as well.
>>
> 
> I think it's a debate about whether this would be better off handled as
> 
> 	if (VM_BUG_ON(compound_head(page) != head)) {
> 		dump_page(page);
> 		dump_page(head);
> 	}

Since we'd BUG at VM_BUG_ON(), this would be something closer to:

	if (unlikely(compound_head(page) != head)) {
		dump_page(page);
		dump_page(head);
		VM_BUG_ON(1);
	}

But my point here was that while one *could* do it that way, no one does because
it's not intuitive. We both agree that in the example above it would be useful to
see both 'page' and 'head', and yet the code that was written didn't dump any of
them. Why? No one wants to write debug code unless it's easy and short.

> and avoid VM_BUG_ON_PAGE() and the new print formats entirely.  We can 
> improve upon existing VM_BUG_ON(), and BUG_ON() itself since the VM isn't 
> anything special in this regard, to print diagnostic information that may 
> be helpful, but I don't feel like adding special VM_BUG_ON_*() macros or 
> printing formats makes any of this simpler.

This patchset actually kills the VM_BUG_ON_*() macros for exactly that reason:
VM isn't special at all and doesn't need it's own magic code in the form of
VM_BUG_ON_*() macros and dump_*() functions.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
