Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id B90BD6B0031
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 17:23:21 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so9249523pbc.31
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 14:23:21 -0700 (PDT)
Message-ID: <525477A4.5060504@sr71.net>
Date: Tue, 08 Oct 2013 14:22:44 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] vmsplice: unmap gifted pages for recipient
References: <1381177293-27125-1-git-send-email-rcj@linux.vnet.ibm.com> <1381177293-27125-2-git-send-email-rcj@linux.vnet.ibm.com> <52542F53.4020807@sr71.net> <20131008194819.GB6129@linux.vnet.ibm.com>
In-Reply-To: <20131008194819.GB6129@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <anthony@codemonkey.ws>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

On 10/08/2013 12:48 PM, Robert Jennings wrote:
> * Dave Hansen (dave@sr71.net) wrote:
>> On 10/07/2013 01:21 PM, Robert C Jennings wrote:
>>> +					} else {
>>> +						if (vma)
>>> +							zap_page_range(vma,
>>> +								user_start,
>>> +								(user_end -
>>> +								 user_start),
>>> +								NULL);
>>> +						vma = find_vma_intersection(
>>> +								current->mm,
>>> +								useraddr,
>>> +								(useraddr +
>>> +								 PAGE_SIZE));
>>> +						if (!IS_ERR_OR_NULL(vma)) {
>>> +							user_start = useraddr;
>>> +							user_end = (useraddr +
>>> +								    PAGE_SIZE);
>>> +						} else
>>> +							vma = NULL;
>>> +					}
>>
>> This is pretty unspeakably hideous.  Was there truly no better way to do
>> this?
> 
> I was hoping to find a better way to coalesce pipe buffers and zap
> entire VMAs (and it needs better documentation but your argument is with
> structure and I agree). I would love suggestions for improving this but
> that is not to say that I've abandoned it; I'm still looking for ways
> to make this cleaner.

Doing the VMA search each and every time seems a bit silly.  Do one
find_vma(), the look at the _end_ virtual address of the VMA.  You can
continue to collect your set of zap_page_range() addresses as long as
you do not hit the end of that address range.

If and only if you hit the end of the vma, do the zap_page_range(), and
then look up the VMA again.

Storing the .useraddr still seems odd to me, and you haven't fully
explained why you're doing it or how it is safe, or why you store both
virtual addresses and file locations in it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
