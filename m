Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 16C6F6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 14:49:01 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b8so84510412pgn.10
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 11:49:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 33si10526301pll.641.2017.07.26.11.48.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 11:48:59 -0700 (PDT)
Date: Wed, 26 Jul 2017 11:48:56 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 3/3] mm: shm: Use new hugetlb size encoding
 definitions
Message-ID: <20170726184856.GB15980@bombadil.infradead.org>
References: <20170328175408.GD7838@bombadil.infradead.org>
 <1500330481-28476-1-git-send-email-mike.kravetz@oracle.com>
 <1500330481-28476-4-git-send-email-mike.kravetz@oracle.com>
 <20170726095338.GF2981@dhcp22.suse.cz>
 <20170726100718.GG2981@dhcp22.suse.cz>
 <d6c78995-bd4c-3894-0a48-b289ad81104b@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d6c78995-bd4c-3894-0a48-b289ad81104b@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, ak@linux.intel.com, mtk.manpages@gmail.com, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com

On Wed, Jul 26, 2017 at 10:39:30AM -0700, Mike Kravetz wrote:
> In the overview of this RFC, I mentioned still needing to address the
> comment from Aneesh about splitting SHM_HUGE_* definitions into arch
> specific header files.  This is how it is done for mmap.  If an arch
> supports multiple huge page sizes, the 'asm/mman.h' contains definitions
> for those sizes.  There will be a bit of churn (such as header file
> renaming) to do this for shm as well.  So, I keep going back and forth
> asking myself 'is it worth it'?  Some things to consider.
> 
> - We should be consistent between mmap and shm.  Also remember, that I
>   will propose adding the same type of encoding to memfd_create.  So,
>   three system calls will use the encoding.  They should be consistent.

I think mmap is wrong here.  User programs are generally not architecture
specific, so they'll have to test with ifdefs or something awful.
For all we know, POWER 14 and whatever x86 CPU comes out in 2030 will
support (nearly) arbitrary page sizes like Itanium does, and a user
program compiled today should be able to take advantage of it.

> - Adding the arch specific definitions seems the 'most correct', as a
>   user can not use a definition not supported by the arch.  However,
>   even if an arch supports a huge page size it does not mean that the
>   running kernel supports that size.  Therefore, the folllowing is in
>   the man page.
>   "The  range  of  huge page sizes that are supported by the system
>    can be discovered by listing  the  subdirectories  in
>    /sys/kernel/mm/hugepages."
> - Another alternative is to make all known huge page sizes available
>   to all users.  This is 'easier' as the definitions can likely reside
>   in a common header file.  The user will  need to determine what
>   huge page sizes are supported by the running kernel as mentioned in
>   the man page.

That's my preference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
