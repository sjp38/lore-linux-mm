Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3786B0253
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 18:33:40 -0400 (EDT)
Received: by wiga1 with SMTP id a1so137660207wig.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 15:33:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id el3si27688346wib.24.2015.07.01.15.33.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Jul 2015 15:33:38 -0700 (PDT)
Message-ID: <55946AC1.9050300@suse.cz>
Date: Thu, 02 Jul 2015 00:33:37 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 05/11] mm: debug: dump page into a string rather than
 directly on screen
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com> <1431623414-1905-6-git-send-email-sasha.levin@oracle.com> <alpine.DEB.2.10.1506301627030.5359@chino.kir.corp.google.com> <55943DC1.6010209@oracle.com> <alpine.DEB.2.10.1507011422070.14014@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1507011422070.14014@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill@shutemov.name

On 1.7.2015 23:25, David Rientjes wrote:
> On Wed, 1 Jul 2015, Sasha Levin wrote:
> 
>> On 06/30/2015 07:35 PM, David Rientjes wrote:
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
> 
> and avoid VM_BUG_ON_PAGE() and the new print formats entirely.  We can 
> improve upon existing VM_BUG_ON(), and BUG_ON() itself since the VM isn't 
> anything special in this regard,

Well, BUG_ON() is just evaluating a condition that results in executing the UD2
instruction, which traps and the handler prints everything. The file:line info
it prints is emitted in a different section, and the handler has to search for
it to print it, using the trapping address. This all to minimize impact on I$,
branch predictors and whatnot.

VM_BUG_ON_PAGE() etc have to actually emit the extra printing code before
triggering UD2. I'm not sure if there's a way to extend the generic mechanism
here. The file:line info would have to also include information about the extra
things we want to dump, and where the handler would find the necessary pointers
(in the registers saved on UD2 exception, or stack). This could probably be done
with some dwarf debuginfo magic but we know how unreliable that can be. Some of
the data might already be discarded in the non-error path doesn't need it, so it
would have to make sure to store it somewhere for the error purposes.

Now we seem to accept that VM_BUG_ON* is more intrusive than BUG_ON() and it's
not expected to be enabled in default distro kernels etc., so it can afford to
pollute the code with extra prints...

> to print diagnostic information that may 
> be helpful, but I don't feel like adding special VM_BUG_ON_*() macros or 
> printing formats makes any of this simpler.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
