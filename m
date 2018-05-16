Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 673BB6B0336
	for <linux-mm@kvack.org>; Wed, 16 May 2018 11:08:57 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a125-v6so996697qkd.4
        for <linux-mm@kvack.org>; Wed, 16 May 2018 08:08:57 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id a11-v6si2842842qtc.235.2018.05.16.08.08.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 08:08:56 -0700 (PDT)
Date: Wed, 16 May 2018 08:08:29 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 14/14] mm: turn on vm_fault_t type checking
Message-ID: <20180516150829.GA4904@magnolia>
References: <20180516054348.15950-1-hch@lst.de>
 <20180516054348.15950-15-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180516054348.15950-15-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

On Wed, May 16, 2018 at 07:43:48AM +0200, Christoph Hellwig wrote:
> Switch vm_fault_t to point to an unsigned int with __bN?twise annotations.
> This both catches any old ->fault or ->page_mkwrite instance with plain
> compiler type checking, as well as finding more intricate problems with
> sparse.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---

<ULTRASNIP>

For the iomap and xfs parts,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

That said...

> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 54f1e05ecf3e..da2b77a19911 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -22,7 +22,8 @@
>  #endif
>  #define AT_VECTOR_SIZE (2*(AT_VECTOR_SIZE_ARCH + AT_VECTOR_SIZE_BASE + 1))
>  
> -typedef int vm_fault_t;
> +typedef unsigned __bitwise vm_fault_t;
> +
>  
>  struct address_space;
>  struct mem_cgroup;
> @@ -619,7 +620,7 @@ struct vm_special_mapping {
>  	 * If non-NULL, then this is called to resolve page faults
>  	 * on the special mapping.  If used, .pages is not checked.
>  	 */
> -	int (*fault)(const struct vm_special_mapping *sm,
> +	vm_fault_t (*fault)(const struct vm_special_mapping *sm,

Uh, we're changing function signatures /and/ redefinining vm_fault_t?
All in the same 90K patch?

I /was/ expecting a series of "convert XXXXX and all callers/users"
patches followed by a trivial one to switch the definition, not a giant
pile of change.  FWIW I don't mind so much if you make a patch
containing a change for some super-common primitive and a hojillion
little diff hunks tree-wide, but only one logical change at a time for a
big patch, please...

I quite prefer seeing the whole series from start to finish all packaged
up in one series, but wow this was overwhelming. :/

--D

<ULTRASNIP>
