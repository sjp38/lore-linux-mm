Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECA36B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 06:11:42 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id fp1so769921pdb.7
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 03:11:41 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id gw7si1290759pac.38.2014.10.23.03.11.39
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 03:11:40 -0700 (PDT)
Message-ID: <5448D515.90006@cn.fujitsu.com>
Date: Thu, 23 Oct 2014 18:14:45 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 4/6] SRCU free VMAs
References: <20141020215633.717315139@infradead.org> <20141020222841.419869904@infradead.org>
In-Reply-To: <20141020222841.419869904@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org


>  
> +struct vm_area_struct *find_vma_srcu(struct mm_struct *mm, unsigned long addr)
> +{
> +	struct vm_area_struct *vma;
> +	unsigned int seq;
> +
> +	WARN_ON_ONCE(!srcu_read_lock_held(&vma_srcu));
> +
> +	do {
> +		seq = read_seqbegin(&mm->mm_seq);
> +		vma = __find_vma(mm, addr);

will the __find_vma() loops for ever due to the rotations in the RBtree?

> +	} while (read_seqretry(&mm->mm_seq, seq));
> +
> +	return vma;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
