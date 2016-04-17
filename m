Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB9A6B007E
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 20:46:30 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w143so43083902wmw.2
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 17:46:30 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id 3si18205873wmf.111.2016.04.16.17.46.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Apr 2016 17:46:29 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id n3so78353674wmn.0
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 17:46:29 -0700 (PDT)
Date: Sun, 17 Apr 2016 03:46:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH mmotm 5/5] huge tmpfs: add shmem_pmd_fault()
Message-ID: <20160417004626.GA5169@node.shutemov.name>
References: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
 <alpine.LSU.2.11.1604161638230.1907@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1604161638230.1907@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, kernel test robot <xiaolong.ye@intel.com>, Xiong Zhou <jencce.kernel@gmail.com>, Matthew Wilcox <willy@linux.intel.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Apr 16, 2016 at 04:41:33PM -0700, Hugh Dickins wrote:
> The pmd_fault() method gives the filesystem an opportunity to place
> a trans huge pmd entry at *pmd, before any pagetable is exposed (and
> an opportunity to split it on COW fault): now use it for huge tmpfs.
> 
> This patch is a little raw: with more time before LSF/MM, I would
> probably want to dress it up better - the shmem_mapping() calls look
> a bit ugly; it's odd to want FAULT_FLAG_MAY_HUGE and VM_FAULT_HUGE just
> for a private conversation between shmem_fault() and shmem_pmd_fault();
> and there might be a better distribution of work between those two, but
> prising apart that series of huge tests is not to be done in a hurry.
> 
> Good for now, presents the new way, but might be improved later.
> 
> This patch still leaves the huge tmpfs map_team_by_pmd() allocating a
> pagetable while holding page lock, but other filesystems are no longer
> doing so; and we've not yet settled whether huge tmpfs should (like anon
> THP) or should not (like DAX) participate in deposit/withdraw protocol.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Just for record: I don't like ->pmd_fault() approach because it results in
two requests to file system (two shmem_fault() in this case) if we don't
have a huge page to map: one for huge page (failed) and then one for small.
I think this case should be rather common: all mounts without huge pages
enabled. I expect performance regression from this too.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
