Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id D29266B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 09:05:21 -0500 (EST)
Received: by iecrd18 with SMTP id rd18so58266654iec.5
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 06:05:21 -0800 (PST)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id z12si1513121igu.0.2015.03.03.06.05.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 06:05:20 -0800 (PST)
Received: by igal13 with SMTP id l13so27728164iga.5
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 06:05:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150303133642.GC2409@dhcp22.suse.cz>
References: <1425384142-5064-1-git-send-email-chianglungyu@gmail.com>
	<20150303133642.GC2409@dhcp22.suse.cz>
Date: Tue, 3 Mar 2015 22:05:19 +0800
Message-ID: <CAP06WZxAy=f_CLm9ZnfixV36ziQVQr8CtAoCB7WohT9m6wH8dw@mail.gmail.com>
Subject: Re: [PATCH] mm: fix anon_vma->degree underflow in anon_vma endless
 growing prevention
From: Leon Yu <chianglungyu@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Tue, Mar 3, 2015 at 9:36 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Tue 03-03-15 20:02:15, Leon Yu wrote:
>> I have constantly stumbled upon "kernel BUG at mm/rmap.c:399!" after upgrading
>> to 3.19 and had no luck with 4.0-rc1 neither.
>>
>> So, after looking into new logic introduced by commit 7a3ef208e662, ("mm:
>> prevent endless growth of anon_vma hierarchy"), I found chances are that
>> unlink_anon_vmas() is called without incrementing dst->anon_vma->degree in
>> anon_vma_clone() due to allocation failure. If dst->anon_vma is not NULL in
>> error path, its degree will be incorrectly decremented in unlink_anon_vmas()
>> and eventually underflow when exiting as a result of another call to
>> unlink_anon_vmas(). That's how "kernel BUG at mm/rmap.c:399!" is triggered
>> for me.
>>
>> This patch fixes the underflow by dropping dst->anon_vma when allocation
>> fails. It's safe to do so regardless of original value of dst->anon_vma
>> because dst->anon_vma doesn't have valid meaning if anon_vma_clone() fails.
>> Besides, callers don't care dst->anon_vma in such case neither.
>>
>> Signed-off-by: Leon Yu <chianglungyu@gmail.com>
>> Fixes: 7a3ef208e662 ("mm: prevent endless growth of anon_vma hierarchy")
>> Cc: stable@vger.kernel.org # v3.19
>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>
> I think we can safely remove the following code as well, because it is
> anon_vma_clone which is responsible to do all the cleanups.

Thanks for the input, I'll send v2 with your cleanup.

- Leon

> diff --git a/mm/mmap.c b/mm/mmap.c
> index 943c6ad18b1d..06a6076c92e5 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -774,10 +774,8 @@ again:                     remove_next = 1 + (end > next->vm_end);
>
>                         importer->anon_vma = exporter->anon_vma;
>                         error = anon_vma_clone(importer, exporter);
> -                       if (error) {
> -                               importer->anon_vma = NULL;
> +                       if (error)
>                                 return error;
> -                       }
>                 }
>         }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
