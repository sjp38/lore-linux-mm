Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD076B0269
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 19:43:02 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id i145so7144107qke.5
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 16:43:02 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f61si8436435qtd.103.2016.12.18.16.43.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 16:43:01 -0800 (PST)
Subject: Re: [RFC PATCH 05/14] sparc64: Add PAGE_SHR_CTX flag
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
 <1481913337-9331-6-git-send-email-mike.kravetz@oracle.com>
 <20161217.221255.1870405962737594028.davem@davemloft.net>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <0311a0ea-097b-be27-3f4d-14bbba46348c@oracle.com>
Date: Sun, 18 Dec 2016 16:42:52 -0800
MIME-Version: 1.0
In-Reply-To: <20161217.221255.1870405962737594028.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bob.picco@oracle.com, nitin.m.gupta@oracle.com, vijay.ac.kumar@oracle.com, julian.calaby@gmail.com, adam.buchbinder@gmail.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org

On 12/17/2016 07:12 PM, David Miller wrote:
> From: Mike Kravetz <mike.kravetz@oracle.com>
> Date: Fri, 16 Dec 2016 10:35:28 -0800
> 
>> @@ -166,6 +166,7 @@ bool kern_addr_valid(unsigned long addr);
>>  #define _PAGE_EXEC_4V	  _AC(0x0000000000000080,UL) /* Executable Page      */
>>  #define _PAGE_W_4V	  _AC(0x0000000000000040,UL) /* Writable             */
>>  #define _PAGE_SOFT_4V	  _AC(0x0000000000000030,UL) /* Software bits        */
>> +#define _PAGE_SHR_CTX_4V  _AC(0x0000000000000020,UL) /* Shared Context       */
>>  #define _PAGE_PRESENT_4V  _AC(0x0000000000000010,UL) /* Present              */
>>  #define _PAGE_RESV_4V	  _AC(0x0000000000000008,UL) /* Reserved             */
>>  #define _PAGE_SZ16GB_4V	  _AC(0x0000000000000007,UL) /* 16GB Page            */
> 
> You really don't need this.
> 
> The VMA is available, and you can obtain the information you need
> about whether this is a shared mapping or not from the. It just isn't
> being passed down into things like set_huge_pte_at().  Simply make it
> do so.
> 

I was more concerned about the page table walk code at tlb/tsb miss time.
Specifically, the code after tsb_miss_page_table_walk_sun4v_fastpath in
tsb.S.  AFAICT, the tsb entries should have been created when the pte entries
were created.  Yet, this code is still walking the page table and creating
tsb entries.  We do not have a pointer to the vma here, and I thought it
would be somewhat difficult to get access.  This is the reason why I went
down the path of a page flag.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
