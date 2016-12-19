Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1716B0260
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 19:22:41 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 2so42911172uax.4
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 16:22:41 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 46si641822uan.100.2016.12.18.16.22.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 16:22:40 -0800 (PST)
Subject: Re: [RFC PATCH 04/14] sparc64: load shared id into context register 1
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
 <1481913337-9331-5-git-send-email-mike.kravetz@oracle.com>
 <20161217074512.GC23567@ravnborg.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <86a484e6-7b71-383d-b7da-d64b99206fa9@oracle.com>
Date: Sun, 18 Dec 2016 16:22:31 -0800
MIME-Version: 1.0
In-Reply-To: <20161217074512.GC23567@ravnborg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>

On 12/16/2016 11:45 PM, Sam Ravnborg wrote:
> Hi Mike
> 
>> diff --git a/arch/sparc/kernel/fpu_traps.S b/arch/sparc/kernel/fpu_traps.S
>> index 336d275..f85a034 100644
>> --- a/arch/sparc/kernel/fpu_traps.S
>> +++ b/arch/sparc/kernel/fpu_traps.S
>> @@ -73,6 +73,16 @@ do_fpdis:
>>  	ldxa		[%g3] ASI_MMU, %g5
>>  	.previous
>>  
>> +661:	nop
>> +	nop
>> +	.section	.sun4v_2insn_patch, "ax"
>> +	.word		661b
>> +	mov		SECONDARY_CONTEXT_R1, %g3
>> +	ldxa		[%g3] ASI_MMU, %g4
>> +	.previous
>> +	/* Unnecessary on sun4u and pre-Niagara 2 sun4v */
>> +	mov		SECONDARY_CONTEXT, %g3
>> +
>>  	sethi		%hi(sparc64_kern_sec_context), %g2
> 
> You missed the second instruction to patch with here.
> This bug repeats itself further down.
> 
> Just noted while briefly reading the code - did not really follow the code.

Hi Sam,

This is my first sparc assembly code, so I could certainly have this
wrong.  The code I was trying to write has the two nop instructions,
that get patched with the mov and ldxa on sun4v.  Certainly, this is
not elegant.  And, the formatting may lead to some confusion.

Did you perhaps think the mov instruction after the comment was for
patching?  I am just trying to understand your comment.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
