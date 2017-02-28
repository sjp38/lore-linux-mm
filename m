Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD996B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 10:18:43 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d18so19647391pgh.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 07:18:43 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id g23si2035472plj.198.2017.02.28.07.18.42
        for <linux-mm@kvack.org>;
        Tue, 28 Feb 2017 07:18:42 -0800 (PST)
Date: Tue, 28 Feb 2017 10:12:18 -0500 (EST)
Message-Id: <20170228.101218.983689349992464602.davem@davemloft.net>
Subject: Re: [PATCH v1 1/3] sparc64: NG4 memset/memcpy 32 bits overflow
From: David Miller <davem@davemloft.net>
In-Reply-To: <1488293746-965735-2-git-send-email-pasha.tatashin@oracle.com>
References: <1488293746-965735-1-git-send-email-pasha.tatashin@oracle.com>
	<1488293746-965735-2-git-send-email-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@oracle.com
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org

From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 28 Feb 2017 09:55:44 -0500

> @@ -252,19 +248,16 @@ FUNC_NAME:	/* %o0=dst, %o1=src, %o2=len */
>  #ifdef MEMCPY_DEBUG
>  	wr		%g0, 0x80, %asi
>  #endif
> -	srlx		%o2, 31, %g2
> -	cmp		%g2, 0
> -	tne		%XCC, 5
>  	PREAMBLE
>  	mov		%o0, %o3
>  	brz,pn		%o2, .Lexit


This limitation was placed here intentionally, because huge values
are %99 of the time bugs and unintentional.

You will see that every assembler optimized memcpy on sparc64 has
this bug trap, not just NG4.

This is a very useful way to find bugs and length {over,under}flows.
Please do not remove it.

If you have to do 4GB or larger copies, do it in pieces or similar.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
