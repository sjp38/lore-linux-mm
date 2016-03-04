Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 568086B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 06:26:07 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l68so30351530wml.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 03:26:07 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id e7si3546257wjp.33.2016.03.04.03.26.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 03:26:05 -0800 (PST)
Received: by mail-wm0-x229.google.com with SMTP id p65so16114546wmp.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 03:26:05 -0800 (PST)
Date: Fri, 4 Mar 2016 14:26:03 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: THP-enabled filesystem vs. FALLOC_FL_PUNCH_HOLE
Message-ID: <20160304112603.GA9790@node.shutemov.name>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 03, 2016 at 07:51:50PM +0300, Kirill A. Shutemov wrote:
> Truncate and punch hole that only cover part of THP range is implemented
> by zero out this part of THP.
> 
> This have visible effect on fallocate(FALLOC_FL_PUNCH_HOLE) behaviour.
> As we don't really create hole in this case, lseek(SEEK_HOLE) may have
> inconsistent results depending what pages happened to be allocated.
> Not sure if it should be considered ABI break or not.

Looks like this shouldn't be a problem. man 2 fallocate:

	Within the specified range, partial filesystem blocks are zeroed,
	and whole filesystem blocks are removed from the file.  After a
	successful call, subsequent reads from this range will return
	zeroes.

It means we effectively have 2M filesystem block size.

And I don't see any guarantee about subsequent lseek(SEEK_HOLE) beheviour.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
