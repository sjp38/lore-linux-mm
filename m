Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9E06B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 03:16:57 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id n3so94753720lfn.5
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 00:16:57 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j84si14196587lfi.337.2016.10.17.00.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 00:16:55 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9H7EBka030725
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 03:16:54 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 264eys7s5h-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 03:16:53 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Mon, 17 Oct 2016 08:16:52 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3D2BD17D8062
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 08:19:01 +0100 (BST)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9H7GoMv59506764
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 07:16:50 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9H7GnAg023516
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 03:16:50 -0400
Date: Mon, 17 Oct 2016 09:16:48 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: pkeys: Remove easily triggered WARN
References: <20161014182624.4yzw36n4hd7x56wi@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161014182624.4yzw36n4hd7x56wi@codemonkey.org.uk>
Message-Id: <20161017071648.GA3511@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, linux-arch@vger.kernel.org, Dave Hansen <dave@sr71.net>, mgorman@techsingularity.net, arnd@arndb.de, linux-api@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Fri, Oct 14, 2016 at 02:26:24PM -0400, Dave Jones wrote:
> This easy-to-trigger warning shows up instantly when running
> Trinity on a kernel with CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS disabled.
> 
> At most this should have been a printk, but the -EINVAL alone should be more
> than adequate indicator that something isn't available.
> 
> Signed-off-by: Dave Jones <davej@codemonkey.org.uk>
> 
> diff --git a/include/linux/pkeys.h b/include/linux/pkeys.h
> index e4c08c1ff0c5..a1bacf1150b2 100644
> --- a/include/linux/pkeys.h
> +++ b/include/linux/pkeys.h
> @@ -25,7 +25,6 @@ static inline int mm_pkey_alloc(struct mm_struct *mm)
>  
>  static inline int mm_pkey_free(struct mm_struct *mm, int pkey)
>  {
> -	WARN_ONCE(1, "free of protection key when disabled");
>  	return -EINVAL;
>  }

FWIW, are all architectures supposed to wire these new system calls up?

I decided to ignore these on s390 since we can't make any sane use of
them. However mips has them already wired up.

The only difference on s390 (and any other architecture without memory
protection keys with x86 like semantics) would be that pkey_alloc/pkey_free
will return -EINVAL instead of -ENOSYS and that we have a new mprotect
wrapper called pkey_mprotect, if being called with a pkey parameter of -1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
