Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5499A6B0069
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 06:35:58 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id z136so901893qka.13
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 03:35:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s65si1621150qkf.279.2017.12.13.03.35.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 03:35:53 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBDBYhBo142757
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 06:35:52 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2eu3450wbp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 06:35:52 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Wed, 13 Dec 2017 04:35:52 -0700
Date: Wed, 13 Dec 2017 03:35:44 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys: Support setting access rights for signal handlers
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <5fee976a-42d4-d469-7058-b78ad8897219@redhat.com>
 <c034f693-95d1-65b8-2031-b969c2771fed@intel.com>
 <5965d682-61b2-d7da-c4d7-c223aa396fab@redhat.com>
 <aa4d127f-0315-3ac9-3fdf-1f0a89cf60b8@intel.com>
 <20171212231324.GE5460@ram.oc3035372033.ibm.com>
 <9dc13a32-b1a6-8462-7e19-cfcf9e2c151e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9dc13a32-b1a6-8462-7e19-cfcf9e2c151e@redhat.com>
Message-Id: <20171213113544.GG5460@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm <linux-mm@kvack.org>, x86@kernel.org, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On Wed, Dec 13, 2017 at 03:14:36AM +0100, Florian Weimer wrote:
> On 12/13/2017 12:13 AM, Ram Pai wrote:
> 
> >On POWER, the value of the pkey_read() i.e contents the AMR
> >register(pkru equivalent), is always the same regardless of its
> >context; signal handler or not.
> >
> >In other words, the permission of any allocated key will not
> >reset in a signal handler context.
> 
> That's certainly the simpler semantics, but I don't like how they
> differ from x86.
> 
> Is the AMR register reset to the original value upon (regular)
> return from the signal handler?

The AMR bits are not touched upon (regular) return from the signal
handler.

If the signal handler changes the bits in the AMR, they will continue
to be so, even after return from the signal handler.

To illustrate with an example, lets say AMR value is 'x' and signal
handler is invoked.  The value of AMR will be 'x' in the context of the
signal handler.  On return from the signal handler the value of AMR will
continue to be 'x'. However if signal handler changes the value of AMR
to 'y', the value of AMR will be 'y' on return from the signal handler.


> 
> >I was not aware that x86 would reset the key permissions in signal
> >handler.  I think, the proposed behavior for PKEY_ALLOC_SETSIGNAL should
> >actually be the default behavior.
> 
> Note that PKEY_ALLOC_SETSIGNAL does something different: It requests
> that the kernel sets the access rights for the key to the bits
> specified at pkey_alloc time when the signal handler is invoked.  So
> there is still a reset with PKEY_ALLOC_SETSIGNAL, but to a different
> value.  It did not occur to me that it might be desirable to avoid
> resetting the value on a per-key basis.

Ah. ok i see the subtle difference proposed by your semantics.

Will the following behavior work?

'No bits will be reset to its initial value unless the key has been
allocated with PKEY_ALLOC_*RE*SETSIGNAL flag'.

> 
> Thanks,
> Florian

-- 
Ram Pai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
