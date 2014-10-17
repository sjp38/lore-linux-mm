Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6F96B0069
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 07:12:13 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id l4so472809lbv.38
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 04:12:12 -0700 (PDT)
Received: from smtp1.it.da.ut.ee (mailhost6-1.ut.ee. [2001:bb8:2002:500::46])
        by mx.google.com with ESMTP id l5si1578813lam.12.2014.10.17.04.12.10
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 04:12:11 -0700 (PDT)
Date: Fri, 17 Oct 2014 14:12:09 +0300 (EEST)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: unaligned accesses in SLAB etc.
In-Reply-To: <20141016.165017.1151349565275102498.davem@davemloft.net>
Message-ID: <alpine.LRH.2.11.1410171410210.25429@adalberg.ut.ee>
References: <20141016.160742.1639247937393238792.davem@redhat.com> <alpine.LRH.2.11.1410162313440.19924@adalberg.ut.ee> <20141016.162001.599580415052560455.davem@redhat.com> <20141016.165017.1151349565275102498.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

> From: David Miller <davem@redhat.com>
> Date: Thu, 16 Oct 2014 16:20:01 -0400 (EDT)
> 
> > So I'm going to audit all the code paths to make sure we don't put garbage
> > into the fault_code value.
> 
> There are two code paths where we can put garbage into the fault_code
> value.  And for the dtlb_prot.S case, the value we put in there is
> TLB_TAG_ACCESS which is 0x30, which include bit 0x20 which is that
> FAULT_CODE_BAD_RA indication which is erroneously triggering.
> 
> The other path is via hugepage TLB misses, for the situation where
> we haven't allocated the huge TSB for the thread yet.  That might
> explain some other longer-term problems we've had.
> 
> I'm about to test the following fix:

Thank you - it seems to work fine for me on E3500 on top of 
3.17.0-07551-g052db7e + slab alignment fix.

However, on top of mainline HEAD 3.17.0-09670-g0429fbc it explodes with 
scheduler BUG - just reported to LKML + sched maintainers.

-- 
Meelis Roos (mroos@linux.ee)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
