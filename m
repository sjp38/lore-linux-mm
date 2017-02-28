Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E013C6B0389
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 10:57:12 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 1so20422443pgz.5
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 07:57:12 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 34si2135547plz.66.2017.02.28.07.57.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 07:57:12 -0800 (PST)
Subject: Re: [PATCH v1 1/3] sparc64: NG4 memset/memcpy 32 bits overflow
References: <1488293746-965735-1-git-send-email-pasha.tatashin@oracle.com>
 <1488293746-965735-2-git-send-email-pasha.tatashin@oracle.com>
 <20170228.101218.983689349992464602.davem@davemloft.net>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <e196c73e-937c-50fa-ed19-a10372548fb7@oracle.com>
Date: Tue, 28 Feb 2017 10:56:57 -0500
MIME-Version: 1.0
In-Reply-To: <20170228.101218.983689349992464602.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org

Hi Dave,

Thank you, I will reinstate the check in memcpy() to limit it to 2G 
memcpy(). Are you OK with keeping the change of icc to xcc for 
consistency, or should I revert it as well?

N4memset() never had this length bound check, and it bit met when I was 
testing the time it takes to zero large hash tables. Are you OK to keep 
the change in memset()?

Also, for consideration, machines are getting bigger, and 2G is becoming 
very small compared to the memory sizes, so some algorithms can become 
inefficient when they have to artificially limit memcpy()s to 2G chunks.

X6-8 scales up to 6T:
http://www.oracle.com/technetwork/database/exadata/exadata-x6-8-ds-2968796.pdf

SPARC M7-16 scales up to 16T:
http://www.oracle.com/us/products/servers-storage/sparc-m7-16-ds-2687045.pdf

2G is just 0.012% of the total memory size on M7-16.

Thank you,
Pasha

On 2017-02-28 10:12, David Miller wrote:
> From: Pavel Tatashin <pasha.tatashin@oracle.com>
> Date: Tue, 28 Feb 2017 09:55:44 -0500
>
>> @@ -252,19 +248,16 @@ FUNC_NAME:	/* %o0=dst, %o1=src, %o2=len */
>>  #ifdef MEMCPY_DEBUG
>>  	wr		%g0, 0x80, %asi
>>  #endif
>> -	srlx		%o2, 31, %g2
>> -	cmp		%g2, 0
>> -	tne		%XCC, 5
>>  	PREAMBLE
>>  	mov		%o0, %o3
>>  	brz,pn		%o2, .Lexit
>
>
> This limitation was placed here intentionally, because huge values
> are %99 of the time bugs and unintentional.
>
> You will see that every assembler optimized memcpy on sparc64 has
> this bug trap, not just NG4.
>
> This is a very useful way to find bugs and length {over,under}flows.
> Please do not remove it.
>
> If you have to do 4GB or larger copies, do it in pieces or similar.
>
> Thank you.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
