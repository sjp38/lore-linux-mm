Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB9FF28089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 23:35:24 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z67so218092815pgb.0
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 20:35:24 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f21si8984721pgg.271.2017.02.08.20.35.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 20:35:23 -0800 (PST)
Date: Thu, 9 Feb 2017 12:34:43 +0800
From: Ye Xiaolong <xiaolong.ye@intel.com>
Subject: Re: [kbuild-all] [PATCH] mm: replace FAULT_FLAG_SIZE with parameter
 to huge_fault
Message-ID: <20170209043443.GB13723@yexl-desktop>
References: <201702040648.oOjnlEcm%fengguang.wu@intel.com>
 <2020f442-8e77-cf14-a6b1-b4b00d0da80b@intel.com>
 <CAPcyv4hmswhXsnS9q1Ut76f3-a2h5Hx7XYkS1iNyak8wG9VuEw@mail.gmail.com>
 <CAPcyv4hVqxedr9sEigw0Xsr_SoMAnvPrmPNOrX7QYNuCz=DRQA@mail.gmail.com>
 <86962573-01b7-4ce7-182e-7a77f183cf0e@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86962573-01b7-4ce7-182e-7a77f183cf0e@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, kbuild test robot <lkp@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, kbuild-all@01.org, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ext4 <linux-ext4@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 02/03, Dave Jiang wrote:
>On 02/03/2017 05:00 PM, Dan Williams wrote:
>> On Fri, Feb 3, 2017 at 3:26 PM, Dan Williams <dan.j.williams@intel.com> wrote:
>>> On Fri, Feb 3, 2017 at 3:25 PM, Dave Jiang <dave.jiang@intel.com> wrote:
>>>> On 02/03/2017 03:56 PM, kbuild test robot wrote:
>>>>> Hi Dave,
>>>>>
>>>>> [auto build test ERROR on mmotm/master]
>>>>> [cannot apply to linus/master linux/master v4.10-rc6 next-20170203]
>>>>> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>>>>
>>>> This one is a bit odd. I just pulled mmotm tree master branch and built
>>>> with the attached .config and it passed for me (and I don't see this
>>>> commit in the master branch). I also built linux-next with this patch on
>>>> top and it also passes with attached .config. Looking at the err log
>>>> below it seems the code has a mix of partial from before and after the
>>>> patch. I'm rather confused about it....
>>>
>>> This is a false positive. It tried to build it against latest mainline
>>> instead of linux-next.
>> 
>> On second look it seems I ended up with a duplicate
>> ext4_huge_dax_fault after "git am" when I apply this on top of
>> next-20170202.  The following fixes it up for me and tests fine:
>
>I think it's missing this patch from Ross
>http://marc.info/?l=linux-mm&m=148581319303697&w=2

Yes, 0day applied the patch on top of mmotm/master when this fix commit 0c4044b3f
("ext4: Remove unused function ext4_dax_huge_fault()") hasn't been merged.

Thanks,
Xiaolong
>
>> 
>> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
>> index f8f4f6d068e5..e8ab46efc4f9 100644
>> --- a/fs/ext4/file.c
>> +++ b/fs/ext4/file.c
>> @@ -276,27 +276,6 @@ static int ext4_dax_huge_fault(struct vm_fault *vmf,
>>         return result;
>>  }
>> 
>> -static int
>> -ext4_dax_huge_fault(struct vm_fault *vmf)
>> -{
>> -       int result;
>> -       struct inode *inode = file_inode(vmf->vma->vm_file);
>> -       struct super_block *sb = inode->i_sb;
>> -       bool write = vmf->flags & FAULT_FLAG_WRITE;
>> -
>> -       if (write) {
>> -               sb_start_pagefault(sb);
>> -               file_update_time(vmf->vma->vm_file);
>> -       }
>> -       down_read(&EXT4_I(inode)->i_mmap_sem);
>> -       result = dax_iomap_fault(vmf, &ext4_iomap_ops);
>> -       up_read(&EXT4_I(inode)->i_mmap_sem);
>> -       if (write)
>> -               sb_end_pagefault(sb);
>> -
>> -       return result;
>> -}
>> -
>>  static int ext4_dax_fault(struct vm_fault *vmf)
>>  {
>>         return ext4_dax_huge_fault(vmf, PE_SIZE_PTE);
>> 
>_______________________________________________
>kbuild-all mailing list
>kbuild-all@lists.01.org
>https://lists.01.org/mailman/listinfo/kbuild-all

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
