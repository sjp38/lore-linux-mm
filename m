Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1CF6B0007
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 08:02:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i12so4771247wre.6
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 05:02:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y63si279871edy.17.2018.04.13.05.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 05:02:02 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3DC0NQf003985
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 08:02:01 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hasbsqjhg-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 08:02:01 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 13 Apr 2018 13:01:58 +0100
Subject: Re: [PATCH 2/2] mm: vmalloc: Pass proper vm_start into debugobjects
References: <1523619234-17635-1-git-send-email-cpandya@codeaurora.org>
 <1523619234-17635-3-git-send-email-cpandya@codeaurora.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 13 Apr 2018 17:31:49 +0530
MIME-Version: 1.0
In-Reply-To: <1523619234-17635-3-git-send-email-cpandya@codeaurora.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <ee1e7036-ecdf-0f5b-f460-0d71b4a38dd7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>, vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/13/2018 05:03 PM, Chintan Pandya wrote:
> Client can call vunmap with some intermediate 'addr'
> which may not be the start of the VM area. Entire
> unmap code works with vm->vm_start which is proper
> but debug object API is called with 'addr'. This
> could be a problem within debug objects.
> 
> Pass proper start address into debug object API.
> 
> Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
> ---
>  mm/vmalloc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 9ff21a1..28034c55 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1526,8 +1526,8 @@ static void __vunmap(const void *addr, int deallocate_pages)
>  		return;
>  	}
>  
> -	debug_check_no_locks_freed(addr, get_vm_area_size(area));
> -	debug_check_no_obj_freed(addr, get_vm_area_size(area));
> +	debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
> +	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));

This kind of makes sense to me but I am not sure. We also have another
instance of this inside the function vm_unmap_ram() where we call for
debug on locks without even finding the vmap_area first. But it is true
that in both these functions the vmap_area gets freed eventually. Hence
the entire mapping [va->va_start --> va->va_end] gets unmapped. Sounds
like these debug functions should have the entire range as argument.
But I am not sure and will seek Michal's input on this.
