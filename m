Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4453A6B025F
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 21:14:40 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id c85so448405oib.13
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 18:14:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 77si190685oik.236.2017.12.12.18.14.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 18:14:39 -0800 (PST)
Subject: Re: pkeys: Support setting access rights for signal handlers
References: <5fee976a-42d4-d469-7058-b78ad8897219@redhat.com>
 <c034f693-95d1-65b8-2031-b969c2771fed@intel.com>
 <5965d682-61b2-d7da-c4d7-c223aa396fab@redhat.com>
 <aa4d127f-0315-3ac9-3fdf-1f0a89cf60b8@intel.com>
 <20171212231324.GE5460@ram.oc3035372033.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <9dc13a32-b1a6-8462-7e19-cfcf9e2c151e@redhat.com>
Date: Wed, 13 Dec 2017 03:14:36 +0100
MIME-Version: 1.0
In-Reply-To: <20171212231324.GE5460@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, x86@kernel.org, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On 12/13/2017 12:13 AM, Ram Pai wrote:

> On POWER, the value of the pkey_read() i.e contents the AMR
> register(pkru equivalent), is always the same regardless of its
> context; signal handler or not.
> 
> In other words, the permission of any allocated key will not
> reset in a signal handler context.

That's certainly the simpler semantics, but I don't like how they differ 
from x86.

Is the AMR register reset to the original value upon (regular) return 
from the signal handler?

> I was not aware that x86 would reset the key permissions in signal
> handler.  I think, the proposed behavior for PKEY_ALLOC_SETSIGNAL should
> actually be the default behavior.

Note that PKEY_ALLOC_SETSIGNAL does something different: It requests 
that the kernel sets the access rights for the key to the bits specified 
at pkey_alloc time when the signal handler is invoked.  So there is 
still a reset with PKEY_ALLOC_SETSIGNAL, but to a different value.  It 
did not occur to me that it might be desirable to avoid resetting the 
value on a per-key basis.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
