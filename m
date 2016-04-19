Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B86A6B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 22:36:58 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id dx6so4491906pad.0
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 19:36:58 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id r123si6820350pfr.154.2016.04.18.19.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 19:36:57 -0700 (PDT)
Subject: Re: [PATCH v3 1/2] dax: add dax_get_unmapped_area for pmd mappings
References: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
 <1460652511-19636-2-git-send-email-toshi.kani@hpe.com>
 <20160418204708.GB17889@quack2.suse.cz>
From: Toshi Kani <toshi.kani@hpe.com>
Message-ID: <571599BE.7090202@hpe.com>
Date: Mon, 18 Apr 2016 22:36:46 -0400
MIME-Version: 1.0
In-Reply-To: <20160418204708.GB17889@quack2.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "willy@linux.intel.com" <willy@linux.intel.com>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "david@fromorbit.com" <david@fromorbit.com>, "tytso@mit.edu" <tytso@mit.edu>, "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 4/18/2016 4:47 PM, Jan Kara wrote:
> On Thu 14-04-16 10:48:30, Toshi Kani wrote:
>> +
>> +/**
>> + * dax_get_unmapped_area - handle get_unmapped_area for a DAX file
>> + * @filp: The file being mmap'd, if not NULL
>> + * @addr: The mmap address. If NULL, the kernel assigns the address
>> + * @len: The mmap size in bytes
>> + * @pgoff: The page offset in the file where the mapping starts from.
>> + * @flags: The mmap flags
>> + *
>> + * This function can be called by a filesystem for get_unmapped_area().
>> + * When a target file is a DAX file, it aligns the mmap address at the
>> + * beginning of the file by the pmd size.
>> + */
>> +unsigned long dax_get_unmapped_area(struct file *filp, unsigned long addr,
>> +		unsigned long len, unsigned long pgoff, unsigned long flags)
>> +{
>> +	unsigned long off, off_end, off_pmd, len_pmd, addr_pmd;
> I think we need to use 'loff_t' for the offsets for things to work on
> 32-bits.

Agreed. Will change to loff_t.

>> +	if (!IS_ENABLED(CONFIG_FS_DAX_PMD) ||
>> +	    !filp || addr || !IS_DAX(filp->f_mapping->host))
>> +		goto out;
>> +
>> +	off = pgoff << PAGE_SHIFT;
> And here we need to type to loff_t before the shift...

Right.

>> +	off_end = off + len;
>> +	off_pmd = round_up(off, PMD_SIZE);  /* pmd-aligned offset */
>> +
>> +	if ((off_end <= off_pmd) || ((off_end - off_pmd) < PMD_SIZE))
> None of these parenthesis is actually needed (and IMHO they make the code
> less readable, not more).

OK.  Will remove the parenthesis.

>> +		goto out;
>> +
>> +	len_pmd = len + PMD_SIZE;
>> +	if ((off + len_pmd) < off)
>> +		goto out;
>> +
>> +	addr_pmd = current->mm->get_unmapped_area(filp, addr, len_pmd,
>> +						  pgoff, flags);
>> +	if (!IS_ERR_VALUE(addr_pmd)) {
>> +		addr_pmd += (off - addr_pmd) & (PMD_SIZE - 1);
>> +		return addr_pmd;
> Otherwise the patch looks good to me.

Great. Thanks Jan!
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
