Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 48ACA6B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 09:37:46 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so3223060vbk.14
        for <linux-mm@kvack.org>; Mon, 06 Aug 2012 06:37:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120806132410.GA6150@dhcp22.suse.cz>
References: <CAJd=RBC9HhKh5Q0-yXi3W0x3guXJPFz4BNsniyOFmp0TjBdFqg@mail.gmail.com>
	<20120806132410.GA6150@dhcp22.suse.cz>
Date: Mon, 6 Aug 2012 21:37:45 +0800
Message-ID: <CAJd=RBCuvpG49JcTUY+qw-tTdH_vFLgOfJDE3sW97+M04TR+hg@mail.gmail.com>
Subject: Re: [patch v2] hugetlb: correct page offset index for sharing pmd
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 6, 2012 at 9:24 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Sat 04-08-12 14:08:31, Hillf Danton wrote:
>> The computation of page offset index is incorrect to be used in scanning
>> prio tree, as huge page offset is required, and is fixed with well
>> defined routine.
>>
>> Changes from v1
>>       o s/linear_page_index/linear_hugepage_index/ for clearer code
>>       o hp_idx variable added for less change
>>
>>
>> Signed-off-by: Hillf Danton <dhillf@gmail.com>
>> ---
>>
>> --- a/arch/x86/mm/hugetlbpage.c       Fri Aug  3 20:34:58 2012
>> +++ b/arch/x86/mm/hugetlbpage.c       Fri Aug  3 20:40:16 2012
>> @@ -62,6 +62,7 @@ static void huge_pmd_share(struct mm_str
>>  {
>>       struct vm_area_struct *vma = find_vma(mm, addr);
>>       struct address_space *mapping = vma->vm_file->f_mapping;
>> +     pgoff_t hp_idx;
>>       pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
>>                       vma->vm_pgoff;
>
> So we have two indexes now. That is just plain ugly!
>

Two indexes result in less code change here and no change
in page_table_shareable. Plus linear_hugepage_index tells
clearly readers that hp_idx and idx are different.

Anyway I have no strong opinion to keep
page_table_shareable unchanged, but prefer less changes.

Thanks,
              Hillf

>>       struct prio_tree_iter iter;
>> @@ -72,8 +73,10 @@ static void huge_pmd_share(struct mm_str
>>       if (!vma_shareable(vma, addr))
>>               return;
>>
>> +     hp_idx = linear_hugepage_index(vma, addr);
>> +
>>       mutex_lock(&mapping->i_mmap_mutex);
>> -     vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
>> +     vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, hp_idx, hp_idx) {
>>               if (svma == vma)
>>                       continue;
>>
>> --
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
