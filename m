Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 61A6F6B0033
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 19:00:51 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id v85so31135141oia.4
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 16:00:51 -0800 (PST)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id 108si11379503otu.26.2017.02.03.16.00.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 16:00:50 -0800 (PST)
Received: by mail-oi0-x22c.google.com with SMTP id u143so20165314oif.3
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 16:00:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hmswhXsnS9q1Ut76f3-a2h5Hx7XYkS1iNyak8wG9VuEw@mail.gmail.com>
References: <201702040648.oOjnlEcm%fengguang.wu@intel.com> <2020f442-8e77-cf14-a6b1-b4b00d0da80b@intel.com>
 <CAPcyv4hmswhXsnS9q1Ut76f3-a2h5Hx7XYkS1iNyak8wG9VuEw@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 3 Feb 2017 16:00:49 -0800
Message-ID: <CAPcyv4hVqxedr9sEigw0Xsr_SoMAnvPrmPNOrX7QYNuCz=DRQA@mail.gmail.com>
Subject: Re: [PATCH] mm: replace FAULT_FLAG_SIZE with parameter to huge_fault
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, linux-ext4 <linux-ext4@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Fri, Feb 3, 2017 at 3:26 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Fri, Feb 3, 2017 at 3:25 PM, Dave Jiang <dave.jiang@intel.com> wrote:
>> On 02/03/2017 03:56 PM, kbuild test robot wrote:
>>> Hi Dave,
>>>
>>> [auto build test ERROR on mmotm/master]
>>> [cannot apply to linus/master linux/master v4.10-rc6 next-20170203]
>>> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>>
>> This one is a bit odd. I just pulled mmotm tree master branch and built
>> with the attached .config and it passed for me (and I don't see this
>> commit in the master branch). I also built linux-next with this patch on
>> top and it also passes with attached .config. Looking at the err log
>> below it seems the code has a mix of partial from before and after the
>> patch. I'm rather confused about it....
>
> This is a false positive. It tried to build it against latest mainline
> instead of linux-next.

On second look it seems I ended up with a duplicate
ext4_huge_dax_fault after "git am" when I apply this on top of
next-20170202.  The following fixes it up for me and tests fine:

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index f8f4f6d068e5..e8ab46efc4f9 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -276,27 +276,6 @@ static int ext4_dax_huge_fault(struct vm_fault *vmf,
        return result;
 }

-static int
-ext4_dax_huge_fault(struct vm_fault *vmf)
-{
-       int result;
-       struct inode *inode = file_inode(vmf->vma->vm_file);
-       struct super_block *sb = inode->i_sb;
-       bool write = vmf->flags & FAULT_FLAG_WRITE;
-
-       if (write) {
-               sb_start_pagefault(sb);
-               file_update_time(vmf->vma->vm_file);
-       }
-       down_read(&EXT4_I(inode)->i_mmap_sem);
-       result = dax_iomap_fault(vmf, &ext4_iomap_ops);
-       up_read(&EXT4_I(inode)->i_mmap_sem);
-       if (write)
-               sb_end_pagefault(sb);
-
-       return result;
-}
-
 static int ext4_dax_fault(struct vm_fault *vmf)
 {
        return ext4_dax_huge_fault(vmf, PE_SIZE_PTE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
