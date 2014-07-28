Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id B9D2B6B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 11:26:46 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id r10so10068498pdi.20
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 08:26:46 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id dn2si9104431pdb.242.2014.07.28.08.26.45
        for <linux-mm@kvack.org>;
        Mon, 28 Jul 2014 08:26:45 -0700 (PDT)
Message-ID: <53D66BB1.8080905@linux.intel.com>
Date: Mon, 28 Jul 2014 08:26:41 -0700
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: don't allow fault_around_bytes to be 0
References: <53D07E96.5000006@oracle.com> <1406533400-6361-1-git-send-email-a.ryabinin@samsung.com> <20140728093611.GA3975@node.dhcp.inet.fi>
In-Reply-To: <20140728093611.GA3975@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrey Ryabinin <a.ryabinin@samsung.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Dave Jones <davej@redhat.com>, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Hugh Dickins <hughd@google.com>

On 07/28/2014 02:36 AM, Kirill A. Shutemov wrote:
> +++ b/mm/memory.c
> @@ -2786,7 +2786,8 @@ static int fault_around_bytes_set(void *data, u64 val)
>  {
>  	if (val / PAGE_SIZE > PTRS_PER_PTE)
>  		return -EINVAL;
> -	fault_around_bytes = val;
> +	/* rounddown_pow_of_two(0) is not defined */
> +	fault_around_bytes = max(val, PAGE_SIZE);
>  	return 0;
>  }

It's also possible to race and have fault_around_bytes change between
when fault_around_mask() and fault_around_pages() are called so that
they don't match any more.  The min()/max() in do_fault_around() should
keep this from doing anything _too_ nasty, but it's worth thinking about
at least.

The safest thing to do might be to use an ACCESS_ONCE() at the beginning
of do_fault_around() for fault_around_bytes and generate
fault_around_mask() from the ACCESS_ONCE() result.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
