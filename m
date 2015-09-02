Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 23DC76B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 05:41:49 -0400 (EDT)
Received: by wiclp12 with SMTP id lp12so12536172wic.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 02:41:48 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id ea13si3308618wic.118.2015.09.02.02.41.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 02:41:48 -0700 (PDT)
Received: by wibz8 with SMTP id z8so59102524wib.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 02:41:47 -0700 (PDT)
Message-ID: <55E6C458.3040901@plexistor.com>
Date: Wed, 02 Sep 2015 12:41:44 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] dax, pmem: add support for msync
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com> <20150831233803.GO3902@dastard> <20150901100804.GA7045@node.dhcp.inet.fi> <20150901224922.GR3902@dastard> <20150902091321.GA2323@node.dhcp.inet.fi> <55E6C36C.3090402@plexistor.com>
In-Reply-To: <55E6C36C.3090402@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@osdl.org>, x86@kernel.org, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 09/02/2015 12:37 PM, Boaz Harrosh wrote:
>>  
>> +               /*
>> +                * Make sure that for VM_MIXEDMAP VMA has both
>> +                * vm_ops->page_mkwrite and vm_ops->pfn_mkwrite or has none.
>> +                */
>> +               if ((vma->vm_ops->page_mkwrite || vma->vm_ops->pfn_mkwrite) &&
>> +                               vma->vm_flags & VM_MIXEDMAP) {
>> +                       VM_BUG_ON_VMA(!vma->vm_ops->page_mkwrite, vma);
>> +                       VM_BUG_ON_VMA(!vma->vm_ops->pfn_mkwrite, vma);
> 
> BTW: the page_mkwrite is used for reading of holes that put zero-pages at the radix tree.
>      One can just map a single global zero-page in pfn-mode for that.
> 
> Kirill Hi. Please don't make these BUG_ONs its counter productive believe me.
> Please make them WARN_ON_ONCE() it is not a crashing bug to work like this.
> (Actually it is not a bug at all in some cases, but we can relax that when a user
>  comes up)
> 
> Thanks
> Boaz
> 

Second thought I do not like this patch. This is why we have xftests for, the fact of it
is that test 080 catches this. For me this is enough.

An FS developer should test his code, and worst case we help him on ML, like we did
in this case.

Thanks
Boaz

>> +               }
>>                 addr = vma->vm_start;
>>                 vm_flags = vma->vm_flags;
>>         } else if (vm_flags & VM_SHARED) {
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
