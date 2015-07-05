Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id F0A7E280291
	for <linux-mm@kvack.org>; Sun,  5 Jul 2015 12:38:17 -0400 (EDT)
Received: by widjy10 with SMTP id jy10so142688380wid.1
        for <linux-mm@kvack.org>; Sun, 05 Jul 2015 09:38:17 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id lg1si25767447wjc.136.2015.07.05.09.38.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Jul 2015 09:38:16 -0700 (PDT)
Received: by widjy10 with SMTP id jy10so142688123wid.1
        for <linux-mm@kvack.org>; Sun, 05 Jul 2015 09:38:15 -0700 (PDT)
Message-ID: <55995D75.4020001@plexistor.com>
Date: Sun, 05 Jul 2015 19:38:13 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: avoid setting up anonymous pages into file mapping
References: <1435932447-84377-1-git-send-email-kirill.shutemov@linux.intel.com> <55994A08.3030308@plexistor.com> <20150705154441.GA4682@node.dhcp.inet.fi>
In-Reply-To: <20150705154441.GA4682@node.dhcp.inet.fi>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Boaz Harrosh <boaz@plexistor.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 07/05/2015 06:44 PM, Kirill A. Shutemov wrote:
>> Again that could mean a theoretical regression for some in-tree driver,
>> do you know of any such driver?
> 
> I did very little testing with the patch: boot kvm with Fedora and run
> trinity there for a while. More testing is required.
> 

It seems more likely to be a bug in some obscure real HW driver, then
anything virtualized.

Let me run a quick search and see if I can see any obvious candidates
for this ...

<arch/x86/kernel/vsyscall_64.c>
static struct vm_operations_struct gate_vma_ops = {
	.name = gate_vma_name,
};

Perhaps it was done for this one
</arch/x86/kernel/vsyscall_64.c>

<arch/x86/mm/mpx.c>
static struct vm_operations_struct mpx_vma_ops = {
	.name = mpx_mapping_name,
};

Or this

</arch/x86/mm/mpx.c>

<more>
static const struct vm_operations_struct pci_mmap_ops = {

static const struct vm_operations_struct mmap_mem_ops = {

...
</more>

I was looking in-tree for any vm_operations_struct declaration without a .fault
member, there are these above and a slue of HW drivers that only have an .open
and .close so those might populate at open time and never actually ever fault.

Please have a quick look, I did not. I agree about the possible security badness.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
