Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id A98496B004D
	for <linux-mm@kvack.org>; Tue, 28 May 2013 11:24:07 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id g10so7722903pdj.41
        for <linux-mm@kvack.org>; Tue, 28 May 2013 08:24:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130528151634.GA30672@dhcp22.suse.cz>
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com>
 <CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com> <20130528151634.GA30672@dhcp22.suse.cz>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Tue, 28 May 2013 16:23:46 +0100
Message-ID: <CAHkRjk5Hm9zQJ0xWupoPcQotoXabcUsM9QmQDFXorei9CV7Heg@mail.gmail.com>
Subject: Re: TLB and PTE coherency during munmap
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Max Filippov <jcmvbkbc@gmail.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-xtensa@linux-xtensa.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>

On 28 May 2013 16:16, Michal Hocko <mhocko@suse.cz> wrote:
> On Sun 26-05-13 06:50:46, Max Filippov wrote:
>> Is it intentional that threads of a process that invoked munmap syscall
>> can see TLB entries pointing to already freed pages, or it is a bug?
>>
>> I'm talking about zap_pmd_range and zap_pte_range:
>>
>>       zap_pmd_range
>>         zap_pte_range
>>           arch_enter_lazy_mmu_mode
>>             ptep_get_and_clear_full
>>             tlb_remove_tlb_entry
>>             __tlb_remove_page
>>           arch_leave_lazy_mmu_mode
>>         cond_resched
>>
>> With the default arch_{enter,leave}_lazy_mmu_mode, tlb_remove_tlb_entry
>> and __tlb_remove_page there is a loop in the zap_pte_range that clears
>> PTEs and frees corresponding pages,
>
> The page is not freed at that time (at least not for the generic
> mmu_gather implementation). It is stored into mmu_gather and then freed
> along with the tlb flush in tlb_flush_mmu.

Actually for the UP case, the page gets freed in __tlb_remove_page()
since tlb_fast_mode() is 1.

--
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
