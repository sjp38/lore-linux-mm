Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id EFA816B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 17:00:30 -0500 (EST)
Received: by iecrp18 with SMTP id rp18so62450292iec.9
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 14:00:30 -0800 (PST)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com. [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id e9si2612023ioj.105.2015.03.03.14.00.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 14:00:30 -0800 (PST)
Received: by iecrl12 with SMTP id rl12so62438327iec.4
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 14:00:30 -0800 (PST)
Date: Tue, 3 Mar 2015 14:00:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: fix anon_vma->degree underflow in anon_vma endless
 growing prevention
In-Reply-To: <1425384142-5064-1-git-send-email-chianglungyu@gmail.com>
Message-ID: <alpine.DEB.2.10.1503031400060.16235@chino.kir.corp.google.com>
References: <1425384142-5064-1-git-send-email-chianglungyu@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Yu <chianglungyu@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Tue, 3 Mar 2015, Leon Yu wrote:

> I have constantly stumbled upon "kernel BUG at mm/rmap.c:399!" after upgrading
> to 3.19 and had no luck with 4.0-rc1 neither.
> 
> So, after looking into new logic introduced by commit 7a3ef208e662, ("mm:
> prevent endless growth of anon_vma hierarchy"), I found chances are that
> unlink_anon_vmas() is called without incrementing dst->anon_vma->degree in
> anon_vma_clone() due to allocation failure. If dst->anon_vma is not NULL in
> error path, its degree will be incorrectly decremented in unlink_anon_vmas()
> and eventually underflow when exiting as a result of another call to
> unlink_anon_vmas(). That's how "kernel BUG at mm/rmap.c:399!" is triggered
> for me.
> 
> This patch fixes the underflow by dropping dst->anon_vma when allocation
> fails. It's safe to do so regardless of original value of dst->anon_vma
> because dst->anon_vma doesn't have valid meaning if anon_vma_clone() fails.
> Besides, callers don't care dst->anon_vma in such case neither.
> 
> Signed-off-by: Leon Yu <chianglungyu@gmail.com>
> Fixes: 7a3ef208e662 ("mm: prevent endless growth of anon_vma hierarchy")
> Cc: stable@vger.kernel.org # v3.19

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
