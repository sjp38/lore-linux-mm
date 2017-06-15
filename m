Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 154946B02B4
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 21:12:09 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o62so316108pga.0
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:12:09 -0700 (PDT)
Received: from mail-pg0-x22a.google.com (mail-pg0-x22a.google.com. [2607:f8b0:400e:c05::22a])
        by mx.google.com with ESMTPS id s22si1100513pfk.417.2017.06.14.18.12.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 18:12:08 -0700 (PDT)
Received: by mail-pg0-x22a.google.com with SMTP id a70so104623pge.3
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:12:08 -0700 (PDT)
Date: Wed, 14 Jun 2017 18:12:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Sleeping BUG in khugepaged for i586
In-Reply-To: <20170608144831.GA19903@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1706141809390.124136@chino.kir.corp.google.com>
References: <968ae9a9-5345-18ca-c7ce-d9beaf9f43b6@lwfinger.net> <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org> <caa7a4a3-0c80-432c-2deb-3480df319f65@suse.cz> <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net> <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz>
 <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com> <20170608144831.GA19903@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Larry Finger <Larry.Finger@lwfinger.net>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, 8 Jun 2017, Michal Hocko wrote:

> collapse_huge_page
>   pte_offset_map
>     kmap_atomic
>       kmap_atomic_prot
>         preempt_disable
>   __collapse_huge_page_copy
>   pte_unmap
>     kunmap_atomic
>       __kunmap_atomic
>         preempt_enable
> 
> I suspect, so cond_resched seems indeed inappropriate on 32b systems.
> 

Seems to be an issue for i386 and arm with ARM_LPAE.  I'm slightly 
surprised we can get away with __collapse_huge_page_swapin() for 
VM_FAULT_RETRY, unless that hasn't been encountered yet.  I think the 
cond_resched() in __collapse_huge_page_copy() could be done only for 
!in_atomic() if we choose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
