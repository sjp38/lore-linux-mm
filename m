Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id D36646B0071
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 16:20:10 -0400 (EDT)
Received: by mail-qg0-f54.google.com with SMTP id z107so3170136qgd.13
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 13:20:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c1si42344421qam.57.2014.10.16.13.20.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 13:20:10 -0700 (PDT)
Date: Thu, 16 Oct 2014 16:20:01 -0400 (EDT)
Message-Id: <20141016.162001.599580415052560455.davem@redhat.com>
Subject: Re: unaligned accesses in SLAB etc.
From: David Miller <davem@redhat.com>
In-Reply-To: <alpine.LRH.2.11.1410162313440.19924@adalberg.ut.ee>
References: <alpine.LRH.2.11.1410160956090.13273@adalberg.ut.ee>
	<20141016.160742.1639247937393238792.davem@redhat.com>
	<alpine.LRH.2.11.1410162313440.19924@adalberg.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mroos@linux.ee
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

From: Meelis Roos <mroos@linux.ee>
Date: Thu, 16 Oct 2014 23:16:44 +0300 (EEST)

>> > scripts/Makefile.build:352: recipe for target 'sound/modules.order' failed
>> > make[1]: *** [sound/modules.order] Bus error
>> > make[1]: *** Deleting file 'sound/modules.order'
>> > Makefile:929: recipe for target 'sound' failed
>> 
>> I just reproduced this on my Sun Blade 2500, so it can trigger on UltraSPARC-IIIi
>> systems too.
> 
> My bisection led to the folloowing commit but it seems irrelevant (I 
> have no sun4v on these machines):
> 
> 4ccb9272892c33ef1c19a783cfa87103b30c2784 is the first bad commit
> commit 4ccb9272892c33ef1c19a783cfa87103b30c2784
> Author: bob picco <bpicco@meloft.net>
> Date:   Tue Sep 16 09:26:47 2014 -0400
> 
>     sparc64: sun4v TLB error power off events
> 
> 
> However, the following chunk sound slightly suspicious:
> 
> +       if (fault_code & FAULT_CODE_BAD_RA)
> +               goto do_sigbus;
> +
> 
> because SIGNUS is what I got. For some machines, it killed chekroot 
> during startup, for some shells under some circumstances, for some sshd.

Good catch!

So I'm going to audit all the code paths to make sure we don't put garbage
into the fault_code value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
