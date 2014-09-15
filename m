Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id D14B56B0036
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 12:24:48 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id v10so4040706qac.7
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 09:24:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t89si15345997qga.63.2014.09.15.09.24.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 09:24:46 -0700 (PDT)
Date: Mon, 15 Sep 2014 18:21:31 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC PATCH v2 5/5] mm, shmem: Show location of non-resident
	shmem pages in smaps
Message-ID: <20140915162131.GA22768@redhat.com>
References: <1410791077-5300-1-git-send-email-jmarchan@redhat.com> <1410791077-5300-6-git-send-email-jmarchan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1410791077-5300-6-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, Randy Dunlap <rdunlap@infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org

Hi Jerome,

Not sure I understand this patch correctly, will try to read it later.
But a couple of nits/questions anyway,

On 09/15, Jerome Marchand wrote:
>
> +The ShmXXX lines only appears for shmem mapping. They show the amount of memory
> +from the mapping that is currently:
> + - resident in RAM but not mapped into any process (ShmNotMapped)

But how can we know that it is not mapped by another process?

And in fact "not mapped" looks confusing (at least to me). IIUC it is actually
mapped even by this process, just it never tried to fault these (resident or
swapped) pages in. Right?

> +void update_shmem_stats(struct mem_size_stats *mss, struct vm_area_struct *vma,
> +			pgoff_t pgoff, unsigned long size)

static?

> +{
> +	int count = 0;
> +
> +	switch (shmem_locate(vma, pgoff, &count)) {
> +	case SHMEM_RESIDENT:
> +		if (!count)
> +			mss->shmem_notmapped += size;
> +		break;
> +	case SHMEM_SWAP:
> +		mss->shmem_swap += size;
> +		break;
> +	}
> +}

It seems that shmem_locate() and shmem_vma() are only defined if CONFIG_SHMEM,
probably this series needs more ifdef's.

And I am not sure why we ignore SHMEM_SWAPCACHE...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
