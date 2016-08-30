Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 12A1782F64
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 07:36:49 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so11796723lfe.0
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:36:49 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id s87si17611914lfi.87.2016.08.30.04.36.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 04:36:47 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id k135so825956lfb.1
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:36:47 -0700 (PDT)
Date: Tue, 30 Aug 2016 14:36:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/4] mm: mlock: avoid increase mm->locked_vm on mlock()
 when already mlock2(,MLOCK_ONFAULT)
Message-ID: <20160830113644.GB32187@node.shutemov.name>
References: <1472554781-9835-1-git-send-email-wei.guo.simon@gmail.com>
 <1472554781-9835-3-git-send-email-wei.guo.simon@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1472554781-9835-3-git-send-email-wei.guo.simon@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.guo.simon@gmail.com
Cc: linux-mm@kvack.org, Alexey Klimov <klimov.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Eric B Munson <emunson@akamai.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Shuah Khan <shuah@kernel.org>, Thierry Reding <treding@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue, Aug 30, 2016 at 06:59:39PM +0800, wei.guo.simon@gmail.com wrote:
> From: Simon Guo <wei.guo.simon@gmail.com>
> 
> When one vma was with flag VM_LOCKED|VM_LOCKONFAULT (by invoking
> mlock2(,MLOCK_ONFAULT)), it can again be populated with mlock() with
> VM_LOCKED flag only.
> 
> There is a hole in mlock_fixup() which increase mm->locked_vm twice even
> the two operations are on the same vma and both with VM_LOCKED flags.
> 
> The issue can be reproduced by following code:
> mlock2(p, 1024 * 64, MLOCK_ONFAULT); //VM_LOCKED|VM_LOCKONFAULT
> mlock(p, 1024 * 64);  //VM_LOCKED
> Then check the increase VmLck field in /proc/pid/status(to 128k).
> 
> When vma is set with different vm_flags, and the new vm_flags is with
> VM_LOCKED, it is not necessarily be a "new locked" vma.  This patch
> corrects this bug by prevent mm->locked_vm from increment when old
> vm_flags is already VM_LOCKED.
> 
> Signed-off-by: Simon Guo <wei.guo.simon@gmail.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
