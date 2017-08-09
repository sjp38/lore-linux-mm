Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 369026B02F4
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 06:08:39 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i187so7593551wma.15
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 03:08:39 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id m15si3153177edb.511.2017.08.09.03.08.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 03:08:38 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id y206so6168635wmd.5
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 03:08:38 -0700 (PDT)
Date: Wed, 9 Aug 2017 13:08:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 02/16] mm: Prepare for FAULT_FLAG_SPECULATIVE
Message-ID: <20170809100835.5kz3zf5sd3oqrrj4@node.shutemov.name>
References: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1502202949-8138-3-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502202949-8138-3-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, Aug 08, 2017 at 04:35:35PM +0200, Laurent Dufour wrote:
> @@ -2295,7 +2302,11 @@ static int wp_page_copy(struct vm_fault *vmf)
>  	/*
>  	 * Re-check the pte - we dropped the lock
>  	 */
> -	vmf->pte = pte_offset_map_lock(mm, vmf->pmd, vmf->address, &vmf->ptl);
> +	if (!pte_map_lock(vmf)) {
> +		mem_cgroup_cancel_charge(new_page, memcg, false);
> +		ret = VM_FAULT_RETRY;
> +		goto oom_free_new;

With the change, label is misleading.

> +	}
>  	if (likely(pte_same(*vmf->pte, vmf->orig_pte))) {
>  		if (old_page) {
>  			if (!PageAnon(old_page)) {

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
