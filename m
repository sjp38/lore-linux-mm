Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 952366B038A
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 18:34:05 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id l66so24913683pfl.6
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 15:34:05 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i13si11832749pgp.196.2017.03.03.15.34.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 15:34:04 -0800 (PST)
Date: Fri, 3 Mar 2017 15:34:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 1/4] sparc64: NG4 memset 32 bits overflow
Message-Id: <20170303153403.182c7088b14fa8401b9cf8b3@linux-foundation.org>
In-Reply-To: <1488432825-92126-2-git-send-email-pasha.tatashin@oracle.com>
References: <1488432825-92126-1-git-send-email-pasha.tatashin@oracle.com>
	<1488432825-92126-2-git-send-email-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org, David Miller <davem@davemloft.net>

On Thu,  2 Mar 2017 00:33:42 -0500 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> Early in boot Linux patches memset and memcpy to branch to platform
> optimized versions of these routines. The NG4 (Niagra 4) versions are
> currently used on  all platforms starting from T4. Recently, there were M7
> optimized routines added into UEK4 but not into mainline yet. So, even with
> M7 optimized routines NG4 are still going to be used on T4, T5, M5, and M6
> processors.
> 
> While investigating how to improve initialization time of dentry_hashtable
> which is 8G long on M6 ldom with 7T of main memory, I noticed that memset()
> does not reset all the memory in this array, after studying the code, I
> realized that NG4memset() branches use %icc register instead of %xcc to
> check compare, so if value of length is over 32-bit long, which is true for
> 8G array, these routines fail to work properly.
> 
> The fix is to replace all %icc with %xcc in these routines. (Alternative is
> to use %ncc, but this is misleading, as the code already has sparcv9 only
> instructions, and cannot be compiled on 32-bit).
> 
> This is important to fix this bug, because even older T4-4 can have 2T of
> memory, and there are large memory proportional data structures in kernel
> which can be larger than 4G in size. The failing of memset() is silent and
> corruption is hard to detect.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Reviewed-by: Babu Moger <babu.moger@oracle.com>

It sounds like this fix should be backported into -stable kernels?  If
so, which version(s)?

Also, what are the user-visible runtime effects of this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
