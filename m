Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 129FC6B0036
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 09:10:36 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y10so153200pdj.35
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 06:10:35 -0700 (PDT)
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com. [202.81.31.144])
        by mx.google.com with ESMTPS id yd10si12911413pab.125.2014.04.29.06.10.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 06:10:32 -0700 (PDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 29 Apr 2014 23:10:19 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 233AF2CE8040
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 23:10:16 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3TDA0aY56754348
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 23:10:01 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3TDAFIR010278
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 23:10:15 +1000
Message-ID: <535FA488.8020405@linux.vnet.ibm.com>
Date: Tue, 29 Apr 2014 18:39:28 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmacache: change vmacache_find() to always check ->vm_mm
References: <535EA976.1080402@linux.vnet.ibm.com> <CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com> <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com> <1398724754.25549.35.camel@buesod1.americas.hpqcorp.net> <CA+55aFz0jrk-O9gq9VQrFBeWTpLt_5zPt9RsJO9htrqh+nKTfA@mail.gmail.com> <20140428161120.4cad719dc321e3c837db3fd6@linux-foundation.org> <CA+55aFwLSW3V76Y_O37Y8r_yaKQ+y0VMk=6SEEBpeFfGzsJUKA@mail.gmail.com> <1398730319.25549.40.camel@buesod1.americas.hpqcorp.net> <535F78A8.80403@linux.vnet.ibm.com> <20140429125255.GA13934@redhat.com>
In-Reply-To: <20140429125255.GA13934@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>

On 04/29/2014 06:22 PM, Oleg Nesterov wrote:
> On 04/29, Srivatsa S. Bhat wrote:
>>
>> I guess I'll hold off on testing this fix until I get to reproduce
>> the bug more reliably..
> 
> perhaps the patch below can help a bit?
> 
> -------------------------------------------------------------------------------
> Subject: [PATCH] vmacache: change vmacache_find() to always check ->vm_mm
> 
> If ->vmacache was corrupted it would be better to detect and report
> the problem asap, check vma->vm_mm before vm_start/vm_end.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> ---
>  mm/vmacache.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmacache.c b/mm/vmacache.c
> index d4224b3..952a324 100644
> --- a/mm/vmacache.c
> +++ b/mm/vmacache.c
> @@ -81,9 +81,10 @@ struct vm_area_struct *vmacache_find(struct mm_struct *mm, unsigned long addr)
>  	for (i = 0; i < VMACACHE_SIZE; i++) {
>  		struct vm_area_struct *vma = current->vmacache[i];
> 
> -		if (vma && vma->vm_start <= addr && vma->vm_end > addr) {
> +		if (vma) {
>  			BUG_ON(vma->vm_mm != mm);
> -			return vma;
> +			if (vma->vm_start <= addr && vma->vm_end > addr)
> +				return vma;
>  		}
>  	}
> 

IIUC, this is similar to commit 50f5aa8a9b2 (mm: don't pointlessly use
BUG_ON() for sanity check). But even with that commit included I was
not able to reproduce the bug again, as reported here:

https://lkml.org/lkml/2014/4/29/187

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
