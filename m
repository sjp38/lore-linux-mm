Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 452F36B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 07:22:00 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so8761903wic.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 04:21:59 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id b19si2632321wiw.16.2015.09.01.04.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 04:21:59 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so3409051wic.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 04:21:58 -0700 (PDT)
Message-ID: <55E58A54.8040805@plexistor.com>
Date: Tue, 01 Sep 2015 14:21:56 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, dax: VMA with vm_ops->pfn_mkwrite wants to be write-notified
References: <1441102961-68041-1-git-send-email-kirill.shutemov@linux.intel.com> <55E583E2.9000200@plexistor.com> <20150901111020.GA7820@node.dhcp.inet.fi>
In-Reply-To: <20150901111020.GA7820@node.dhcp.inet.fi>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, Yigal Korman <yigal@plexistor.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>

On 09/01/2015 02:10 PM, Kirill A. Shutemov wrote:
> On Tue, Sep 01, 2015 at 01:54:26PM +0300, Boaz Harrosh wrote:
>> On 09/01/2015 01:22 PM, Kirill A. Shutemov wrote:
>>> For VM_PFNMAP and VM_MIXEDMAP we use vm_ops->pfn_mkwrite instead of
>>> vm_ops->page_mkwrite to notify abort write access. This means we want
>>> vma->vm_page_prot to be write-protected if the VMA provides this vm_ops.
>>>
>>
>> Hi Kirill
>>
>> I will test with this right away and ACK on this.
>>
>> Hmm so are you saying we might be missing some buffer modifications right now.
>>
>> What would be a theoretical scenario that will cause these missed events?
> 
> On writable mapping with vm_ops->pfn_mkwrite, but without
> vm_ops->page_mkwrite: read fault followed by write access to the pfn.
> Writable pte will be set up on read fault and write fault will not be
> generated.
> 
> I found it examining Dave's complain on generic/080:
> 
> http://lkml.kernel.org/g/20150831233803.GO3902@dastard
> 
> Although I don't think it's the reason.
> 
>> I would like to put a test in our test rigs that should fail today and this
>> patch fixes.
>>
>> [In our system every modified pmem block is also RDMAed to a remote
>>  pmem for HA, a missed modification will make the two copies unsynced]
> 
> It shouldn't be a problem for ext2/ext4 as they provide both pfn_mkwrite
> and page_mkwrite.
> 

Ha right we have both as well, and so should xfs I think (because of the
zero pages thing, in fact any dax.c user should).

Thanks so this verifies why we could not see any such breakage.

ACK-by: Boaz Harrosh <boaz@plexistor.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
