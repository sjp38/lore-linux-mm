Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5C0916B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:12:28 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id y8so15872229igp.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 10:12:28 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id s95si21799922ioe.115.2016.02.12.10.12.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Feb 2016 10:12:27 -0800 (PST)
Subject: Re: [PATCH] kvm: do not SetPageDirty from kvm_set_pfn_dirty for file
 mappings
References: <20160211181306.7864.44244.stgit@maxim-thinkpad>
 <87bn7mavl3.fsf@openvz.org>
From: Maxim Patlasov <mpatlasov@virtuozzo.com>
Message-ID: <56BE2084.4080101@virtuozzo.com>
Date: Fri, 12 Feb 2016 10:12:20 -0800
MIME-Version: 1.0
In-Reply-To: <87bn7mavl3.fsf@openvz.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Monakhov <dmonakhov@openvz.org>, pbonzini@redhat.com
Cc: kvm@vger.kernel.org, linux-nvdimm@lists.01.org, gleb@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On 02/12/2016 05:48 AM, Dmitry Monakhov wrote:
> Maxim Patlasov <mpatlasov@virtuozzo.com> writes:
>
>> The patch solves the following problem: file system specific routines
>> involved in ordinary routine writeback process BUG_ON page_buffers()
>> because a page goes to writeback without buffer-heads attached.
>>
>> The way how kvm_set_pfn_dirty calls SetPageDirty works only for anon
>> mappings. For file mappings it is obviously incorrect - there page_mkwrite
>> must be called. It's not easy to add page_mkwrite call to kvm_set_pfn_dirty
>> because there is no universal way to find vma by pfn. But actually
>> SetPageDirty may be simply skipped in those cases. Below is a
>> justification.
> Confirm. I've hit that BUGON
> [ 4442.219121] ------------[ cut here ]------------
> [ 4442.219188] kernel BUG at fs/ext4/inode.c:2285!
> <...>
>
>> When guest modifies the content of a page with file mapping, kernel kvm
>> makes the page dirty by the following call-path:
>>
>> vmx_handle_exit ->
>>   handle_ept_violation ->
>>    __get_user_pages ->
>>     page_mkwrite ->
>>      SetPageDirty
>>
>> Since then, the page is dirty from both guest and host point of view. Then
>> the host makes writeback and marks the page as write-protected. So any
>> further write from the guest triggers call-path above again.
> Please elaborate exact call-path which marks host-page.

wb_workfn ->
  wb_do_writeback ->
   wb_writeback ->
    __writeback_inodes_wb ->
     writeback_sb_inodes ->
      __writeback_single_inode ->
       do_writepages ->
        ext4_writepages ->
         mpage_prepare_extent_to_map ->
          mpage_process_page_bufs ->
           mpage_submit_page ->
            clear_page_dirty_for_io ->
              page_mkclean ->
               rmap_walk->
                 rmap_walk_file ->
                  page_mkclean_one->
                   pte_wrprotect ->
                     pte_clear_flags(pte, _PAGE_RW)

Thanks,
Maxim

>> So, for file mappings, it's not possible to have new data written to a page
>> inside the guest w/o corresponding SetPageDirty on the host.
>>
>> This makes explicit SetPageDirty from kvm_set_pfn_dirty redundant.
>>
>> Signed-off-by: Maxim Patlasov <mpatlasov@virtuozzo.com>
>> ---
>>   virt/kvm/kvm_main.c |    3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
>> index a11cfd2..5a7d3fa 100644
>> --- a/virt/kvm/kvm_main.c
>> +++ b/virt/kvm/kvm_main.c
>> @@ -1582,7 +1582,8 @@ void kvm_set_pfn_dirty(kvm_pfn_t pfn)
>>   	if (!kvm_is_reserved_pfn(pfn)) {
>>   		struct page *page = pfn_to_page(pfn);
>>   
>> -		if (!PageReserved(page))
>> +		if (!PageReserved(page) &&
>> +		    (!page->mapping || PageAnon(page)))
>>   			SetPageDirty(page);
>>   	}
>>   }
>>
>> _______________________________________________
>> Linux-nvdimm mailing list
>> Linux-nvdimm@lists.01.org
>> https://lists.01.org/mailman/listinfo/linux-nvdimm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
