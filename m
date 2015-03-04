Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 583A66B0072
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 12:58:57 -0500 (EST)
Received: by wesk11 with SMTP id k11so47961536wes.11
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 09:58:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j4si30798825wix.56.2015.03.04.09.58.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 09:58:55 -0800 (PST)
Message-ID: <54F747CE.5050204@redhat.com>
Date: Wed, 04 Mar 2015 12:58:38 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: fix anon_vma->degree underflow in anon_vma endless
 growing prevention
References: <1425473541-4924-1-git-send-email-chianglungyu@gmail.com>
In-Reply-To: <1425473541-4924-1-git-send-email-chianglungyu@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Yu <chianglungyu@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, Chris Clayton <chris2553@googlemail.com>, Oded Gabbay <oded.gabbay@amd.com>, Chih-Wei Huang <cwhuang@android-x86.org>, stable@vger.kernel.org

On 03/04/2015 07:52 AM, Leon Yu wrote:
> I have constantly stumbled upon "kernel BUG at mm/rmap.c:399!" after
> upgrading to 3.19 and had no luck with 4.0-rc1 neither.
> 
> So, after looking into new logic introduced by 7a3ef208e662 ("mm: prevent
> endless growth of anon_vma hierarchy"), I found chances are that
> unlink_anon_vmas() is called without incrementing dst->anon_vma->degree in
> anon_vma_clone() due to allocation failure.  If dst->anon_vma is not NULL
> in error path, its degree will be incorrectly decremented in
> unlink_anon_vmas() and eventually underflow when exiting as a result of
> another call to unlink_anon_vmas().  That's how "kernel BUG at
> mm/rmap.c:399!" is triggered for me.
> 
> This patch fixes the underflow by dropping dst->anon_vma when allocation
> fails.  It's safe to do so regardless of original value of dst->anon_vma
> because dst->anon_vma doesn't have valid meaning if anon_vma_clone()
> fails.  Besides, callers don't care dst->anon_vma in such case neither.
> 
> Also suggested by Michal Hocko, we can clean up vma_adjust() a bit as
> anon_vma_clone() now does the work.
> 
> Fixes: 7a3ef208e662 ("mm: prevent endless growth of anon_vma hierarchy")
> Signed-off-by: Leon Yu <chianglungyu@gmail.com>
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: David Rientjes <rientjes@google.com>
> Cc: <stable@vger.kernel.org>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
