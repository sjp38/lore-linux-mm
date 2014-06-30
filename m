Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1A26F6B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 10:31:15 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id n15so6182448wiw.16
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 07:31:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ja10si10504429wic.105.2014.06.30.07.31.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jun 2014 07:31:13 -0700 (PDT)
Date: Mon, 30 Jun 2014 10:31:05 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 09/13] memcg: apply walk_page_vma()
Message-ID: <20140630143105.GB4319@nhori.bos.redhat.com>
References: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1403295099-6407-10-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140630122016.GY19833@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140630122016.GY19833@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, Jun 30, 2014 at 03:20:16PM +0300, Kirill A. Shutemov wrote:
> On Fri, Jun 20, 2014 at 04:11:35PM -0400, Naoya Horiguchi wrote:
> > pagewalk.c can handle vma in itself, so we don't have to pass vma via
> > walk->private. And both of mem_cgroup_count_precharge() and
> > mem_cgroup_move_charge() walk over all vmas (not interested in outside vma,)
> > so using walk_page_vma() is preferable.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> My first thought was to suggest walk_page_range(0, -1, &walk) instead
> since we walk over all vmas. But walk_page_range() uses find_vma() on each
> iteration, which is expensive.
> Is there a reason why we cannot use vma->vm_next in walk_page_range()?

Right, we can use vma->vm_next. The old code uses find_vma() because
addr can jump to the next pgd boundary, but that doesn't happen with
this patch, so using vma->vm_next is fine.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
