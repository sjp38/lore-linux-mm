Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F23B26B03AB
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 09:43:47 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id o3so60099148wjo.1
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 06:43:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v9si27779951wjx.140.2016.12.21.06.43.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Dec 2016 06:43:46 -0800 (PST)
Date: Wed, 21 Dec 2016 15:43:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: A small window for a race condition in
 mm/rmap.c:page_lock_anon_vma_read
Message-ID: <20161221144343.GD593@dhcp22.suse.cz>
References: <23B7B563BA4E9446B962B142C86EF24ADBD62C@CNMAILEX03.lenovo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <23B7B563BA4E9446B962B142C86EF24ADBD62C@CNMAILEX03.lenovo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dashi DS1 Cao <caods1@lenovo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

anon_vma locking is clever^Wsubtle as hell. CC Peter...

On Tue 20-12-16 09:32:27, Dashi DS1 Cao wrote:
> I've collected four crash dumps with similar backtrace. 
> 
> PID: 247    TASK: ffff881fcfad8000  CPU: 14  COMMAND: "kswapd1"
>  #0 [ffff881fcfad7978] machine_kexec at ffffffff81051e9b
>  #1 [ffff881fcfad79d8] crash_kexec at ffffffff810f27e2
>  #2 [ffff881fcfad7aa8] oops_end at ffffffff8163f448
>  #3 [ffff881fcfad7ad0] die at ffffffff8101859b
>  #4 [ffff881fcfad7b00] do_general_protection at ffffffff8163ed3e
>  #5 [ffff881fcfad7b30] general_protection at ffffffff8163e5e8
>     [exception RIP: down_read_trylock+9]
>     RIP: ffffffff810aa9f9  RSP: ffff881fcfad7be0  RFLAGS: 00010286
>     RAX: 0000000000000000  RBX: ffff882b47ddadc0  RCX: 0000000000000000
>     RDX: 0000000000000000  RSI: 0000000000000000  RDI: 91550b2b32f5a3e8

rdi is obviously a mess - smells like a string. So either sombody has
overwritten root_anon_vma or this is really a use after free...

>     RBP: ffff881fcfad7be0   R8: ffffea00ecc28860   R9: ffff883fcffeae28
>     R10: ffffffff81a691a0  R11: 0000000000000001  R12: ffff882b47ddadc1
>     R13: ffffea00ecc28840  R14: 91550b2b32f5a3e8  R15: ffffea00ecc28840
>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000
>  #6 [ffff881fcfad7be8] page_lock_anon_vma_read at ffffffff811a3365
>  #7 [ffff881fcfad7c18] page_referenced at ffffffff811a35e7
>  #8 [ffff881fcfad7c90] shrink_active_list at ffffffff8117e8cc
>  #9 [ffff881fcfad7d48] balance_pgdat at ffffffff81180288
> #10 [ffff881fcfad7e20] kswapd at ffffffff81180813
> #11 [ffff881fcfad7ec8] kthread at ffffffff810a5b8f
> #12 [ffff881fcfad7f50] ret_from_fork at ffffffff81646a98
> 
> I suspect my customer hits into a small window of a race condition in mm/rmap.c: page_lock_anon_vma_read.
> struct anon_vma *page_lock_anon_vma_read(struct page *page)
> {
>         struct anon_vma *anon_vma = NULL;
>         struct anon_vma *root_anon_vma;
>         unsigned long anon_mapping;
> 
>         rcu_read_lock();
>         anon_mapping = (unsigned long)READ_ONCE(page->mapping);
>         if ((anon_mapping & PAGE_MAPPING_FLAGS) != PAGE_MAPPING_ANON)
>                 goto out;
>         if (!page_mapped(page))
>                 goto out;
> 
>         anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
>         root_anon_vma = READ_ONCE(anon_vma->root);

Could you dump the anon_vma and struct page as well?

>         if (down_read_trylock(&root_anon_vma->rwsem)) {
>                 /*
>                  * If the page is still mapped, then this anon_vma is still
>                  * its anon_vma, and holding the mutex ensures that it will
>                  * not go away, see anon_vma_free().
>                  */
>                 if (!page_mapped(page)) {
>                         up_read(&root_anon_vma->rwsem);
>                         anon_vma = NULL;
>                 }
>                 goto out;
>         }
> ...
> }
> 
> Between the time the two "page_mapped(page)" are checked, the address
> (anon_mapping - PAGE_MAPPING_ANON) is unmapped! However it seems
> that anon_vma->root could still be read in but the value is wild. So
> the kernel crashes in down_read_trylock. But it's weird that all the
> "struct page" has its member "_mapcount" still with value 0, not -1,
> in the four crashes.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
