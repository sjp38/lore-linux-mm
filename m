Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 863716B025F
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 09:13:55 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f75so27274021wmf.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 06:13:55 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id e14si1347004wmd.17.2016.06.02.06.13.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 06:13:54 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id a20so4182279wma.3
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 06:13:54 -0700 (PDT)
Date: Thu, 2 Jun 2016 15:13:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [linux-next-20160602] kernel BUG at mm/rmap.c:1253!
Message-ID: <20160602131352.GQ1995@dhcp22.suse.cz>
References: <201606022014.GFF87050.FJOLVOMQHFOtSF@I-love.SAKURA.ne.jp>
 <20160602115046.GA2001@dhcp22.suse.cz>
 <20160602115949.GL1995@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160602115949.GL1995@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Ebru Akagunduz <ebru.akagunduz@gmail.com>

On Thu 02-06-16 13:59:49, Michal Hocko wrote:
> [CCing Ebru]
> 
> On Thu 02-06-16 13:50:46, Michal Hocko wrote:
> > [CCing Andrea and Kirill]
> 
> Hmm, thinking about it little bit more it might be related to "mm, thp:
> make swapin readahead under down_read of mmap_sem". I didn't get to look
> closer at the patch but maybe revalidate after mmap sem is dropped is
> not sufficient.

so hugepage_vma_revalidate does this:

	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
	hend = vma->vm_end & HPAGE_PMD_MASK;
	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
		return SCAN_ADDRESS_RANGE;

I really do not see why we have to play with hstart and hend. But
address + HPAGE_PMD_SIZE > hend part looks suspicious. address
always have to vm_start <= address && address < vm_end AFAICS.

and the above allows address + HPAGE_PMD_MASK == end.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
