Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 003ED6B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 14:34:58 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d18so27473672pgh.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 11:34:57 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id m61si2586035plb.90.2017.02.28.11.34.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 11:34:57 -0800 (PST)
Subject: Re: [PATCH v1 1/3] sparc64: NG4 memset/memcpy 32 bits overflow
References: <1488293746-965735-1-git-send-email-pasha.tatashin@oracle.com>
 <1488293746-965735-2-git-send-email-pasha.tatashin@oracle.com>
 <20170228.101218.983689349992464602.davem@davemloft.net>
 <e196c73e-937c-50fa-ed19-a10372548fb7@oracle.com>
 <20170228185914.GF16328@bombadil.infradead.org>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <a3a3a887-c7be-eb31-b73f-e179162fde93@oracle.com>
Date: Tue, 28 Feb 2017 14:34:17 -0500
MIME-Version: 1.0
In-Reply-To: <20170228185914.GF16328@bombadil.infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: David Miller <davem@davemloft.net>, linux-mm@kvack.org, sparclinux@vger.kernel.org

Hi Matthew,

Thank you for your comments, my replies below:

On 02/28/2017 01:59 PM, Matthew Wilcox wrote:
> ... what algorithms are deemed "inefficient" when they take a break every
> 2 billion bytes to, ohidon'tknow, check to see that a higher priority
> process doesn't want the CPU?

I do not see that NG4memcpy() is disabling interrupts so there should 
not be any issues with letting higher priority processes to interrupt 
and do their work. And, as I said my point was mostly for consideration, 
I will revert that bound check in NG4memcpy() to the 2G limit.

> Right, so suppose you're copying half the memory to the other half of
> memory.  Let's suppose it takes a hundred extra instructions every 2GB to
> check that nobody else wants the CPU and dive back into the memcpy code.
> That's 800,000 additional instructions.  Which even on a SPARC CPU is
> going to execute in less than 0.001 second.  CPU memory bandwidth is
> on the order of 100GB/s, so the overall memcpy is going to take about
> 160 seconds.

Sure, the computational overhead is minimal, but still adding and 
maintaining extra code to break-up a single memcpy() has its cost. For 
example: as far I as can tell x86 and powerpc memcpy()s do not have this 
limit, which means that an author of a driver would have to explicitly 
divide memcpy()s into 2G chunks only to work on SPARC (and know about 
this limit too!). If there is a driver that has a memory proportional 
data structure it is possible it will panic the kernel once such driver 
is attached on a larger memory machine.

Another example is memblock allocator that is currently unconditionally 
calls memset() to zero all the allocated memory without breaking it up 
into pieces, and when other CPUs are not yet available to split the work 
to speed it up.

So, if a large chunk of memory is allocated via memblock() allocator, 
(as one example when booted with kernel parameter: "hashdist=0") we will 
have memset() called for 8G and 4G pieces of memory on machine with 7T 
of memory, and that will cause panic if we will add this bound limit to 
memset as well.

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
