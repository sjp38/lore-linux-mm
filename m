Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 474786B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 07:40:35 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id l61so8758224wev.13
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 04:40:34 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id du3si3203816wib.62.2015.01.26.04.40.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 04:40:33 -0800 (PST)
Message-ID: <54C635BF.6010906@suse.cz>
Date: Mon, 26 Jan 2015 13:40:31 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V4] mm/thp: Allocate transparent hugepages on local node
References: <1421753671-16793-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20150120164832.abe2e47b760e1a8d7bb6055b@linux-foundation.org> <54C62803.8010105@suse.cz> <20150126121309.GD25833@node.dhcp.inet.fi>
In-Reply-To: <20150126121309.GD25833@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/26/2015 01:13 PM, Kirill A. Shutemov wrote:
> On Mon, Jan 26, 2015 at 12:41:55PM +0100, Vlastimil Babka wrote:
>> On 01/21/2015 01:48 AM, Andrew Morton wrote:
>> > On Tue, 20 Jan 2015 17:04:31 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>> >> + * Should be called with the mm_sem of the vma hold.
>> > 
>> > That's a pretty cruddy sentence, isn't it?  Copied from
>> > alloc_pages_vma().  "vma->vm_mm->mmap_sem" would be better.
>> > 
>> > And it should tell us whether mmap_sem required a down_read or a
>> > down_write.  What purpose is it serving?
>> 
>> This is already said for mmap_sem further above this comment line, which
>> should be just deleted (and from alloc_hugepage_vma comment too).
>> 
>> >> + *
>> >> + */
>> >> +struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
>> >> +				unsigned long addr, int order)
>> > 
>> > This pointlessly bloats the kernel if CONFIG_TRANSPARENT_HUGEPAGE=n?
>> > 
>> > 
>> > 
>> > --- a/mm/mempolicy.c~mm-thp-allocate-transparent-hugepages-on-local-node-fix
>> > +++ a/mm/mempolicy.c
>> 
>> How about this cleanup on top? I'm not fully decided on the GFP_TRANSHUGE test.
>> This is potentially false positive, although I doubt anything else uses the same
>> gfp mask bits.
> 
> This info on gfp mask should be in commit message.

Right. Wanted to get some consensus first.

> And what about WARN_ON_ONCE() if we the matching bits with
> !TRANSPARENT_HUGEPAGE?

Hmm, can't say I like that, but could work.

>> 
>> Should "hugepage" be extra bool parameter instead? Should I #ifdef the parameter
>> only for CONFIG_TRANSPARENT_HUGEPAGE, or is it not worth the ugliness?
> 
> Do we have spare gfp bit? ;)

Seems we have defined 24 out of 32. Not too much to spare, and the use case here
is very narrow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
