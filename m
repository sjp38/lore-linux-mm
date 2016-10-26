Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id E9C066B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 03:30:08 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id 34so1374355uac.11
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 00:30:08 -0700 (PDT)
Received: from mail-ua0-x242.google.com (mail-ua0-x242.google.com. [2607:f8b0:400c:c08::242])
        by mx.google.com with ESMTPS id d3si252575vkf.62.2016.10.26.00.30.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 00:30:07 -0700 (PDT)
Received: by mail-ua0-x242.google.com with SMTP id 20so68736uak.0
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 00:30:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BD27B76A-AF34-48B9-8D4F-F69AD2C17C66@dilger.ca>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
 <20161025001342.76126-19-kirill.shutemov@linux.intel.com> <20161025072122.GA21708@infradead.org>
 <20161025125431.GA22787@node.shutemov.name> <BD27B76A-AF34-48B9-8D4F-F69AD2C17C66@dilger.ca>
From: Ming Lei <tom.leiming@gmail.com>
Date: Wed, 26 Oct 2016 15:30:05 +0800
Message-ID: <CACVXFVOYXJW1c8LHiwoM9a0nLnkeeGVPUZRvs2=MohFwvhugsQ@mail.gmail.com>
Subject: Re: [PATCHv4 18/43] block: define BIO_MAX_PAGES to HPAGE_PMD_NR if
 huge page cache enabled
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Hellwig <hch@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-block <linux-block@vger.kernel.org>

On Wed, Oct 26, 2016 at 12:13 PM, Andreas Dilger <adilger@dilger.ca> wrote:
> On Oct 25, 2016, at 6:54 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
>>
>> On Tue, Oct 25, 2016 at 12:21:22AM -0700, Christoph Hellwig wrote:
>>> On Tue, Oct 25, 2016 at 03:13:17AM +0300, Kirill A. Shutemov wrote:
>>>> We are going to do IO a huge page a time. So we need BIO_MAX_PAGES to be
>>>> at least HPAGE_PMD_NR. For x86-64, it's 512 pages.
>>>
>>> NAK.  The maximum bio size should not depend on an obscure vm config,
>>> please send a standalone patch increasing the size to the block list,
>>> with a much long explanation.  Also you can't simply increase the size
>>> of the largers pool, we'll probably need more pools instead, or maybe
>>> even implement a similar chaining scheme as we do for struct
>>> scatterlist.
>>
>> The size of required pool depends on architecture: different architectures
>> has different (huge page size)/(base page size).
>>
>> Would it be okay if I add one more pool with size equal to HPAGE_PMD_NR,
>> if it's bigger than than BIO_MAX_PAGES and huge pages are enabled?
>
> Why wouldn't you have all the pool sizes in between?  Definitely 1MB has
> been too small already for high-bandwidth IO.  I wouldn't mind BIOs up to
> 4MB or larger since most high-end RAID hardware does best with 4MB IOs.

I am preparing for the multipage bvec support[1], and once it is ready the
default 256 bvecs should be enough for normal cases.

I will post them out next month for review.

[1] https://github.com/ming1/linux/tree/mp-bvec-0.1-v4.9

Thanks,
Ming

>
> Cheers, Andreas
>
>
>
>
>



-- 
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
