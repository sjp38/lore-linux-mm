Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id A32C56B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 19:36:13 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id ho8so105860347pac.2
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 16:36:13 -0800 (PST)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id l23si5257653pfi.182.2016.01.26.16.36.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 16:36:12 -0800 (PST)
Received: by mail-pf0-x232.google.com with SMTP id 65so19895970pfd.2
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 16:36:12 -0800 (PST)
Date: Tue, 26 Jan 2016 16:36:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH/RFC 3/3] s390: query dynamic DEBUG_PAGEALLOC setting
In-Reply-To: <20160127001918.GA7089@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.10.1601261633520.6121@chino.kir.corp.google.com>
References: <1453799905-10941-1-git-send-email-borntraeger@de.ibm.com> <1453799905-10941-4-git-send-email-borntraeger@de.ibm.com> <20160126181903.GB4671@osiris> <alpine.DEB.2.10.1601261525580.25141@chino.kir.corp.google.com>
 <20160127001918.GA7089@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org

On Wed, 27 Jan 2016, Joonsoo Kim wrote:

> > I'd agree if CONFIG_DEBUG_PAGEALLOC only did anything when 
> > debug_pagealloc_enabled() is true, but that doesn't seem to be the case.  
> > When CONFIG_DEBUG_SLAB is enabled, for instance, CONFIG_DEBUG_PAGEALLOC 
> > also enables stackinfo storing and poisoning and it's not guarded by 
> > debug_pagealloc_enabled().
> > 
> > It seems like CONFIG_DEBUG_PAGEALLOC enables debugging functionality 
> > outside the scope of the debug_pagealloc=on kernel parameter, so 
> > DEBUG_PAGEALLOC(disabled) actually does mean something.
> 
> Hello, David.
> 
> I tried to fix CONFIG_DEBUG_SLAB case on 04/16 of following patchset.
> 
> http://thread.gmane.org/gmane.linux.kernel.mm/144527
> 
> I found that there are more sites to fix but not so many.
> We can do it.
> 

For the slab case, sure, this can be fixed, but there is other code that 
uses CONFIG_DEBUG_PAGEALLOC to suggest debugging is always enabled and is 
indifferent to debug_pagealloc_enabled().  I find this in powerpc and 
sparc arch code as well as generic vmalloc code.  

If we can convert existing users that only check for 
CONFIG_DEBUG_PAGEALLOC to rather check for debug_pagealloc_enabled() and 
agree that it is only enabled for debug_pagealloc=on, then this would seem 
fine.  However, I think we should at least consult with those users before 
removing an artifact from the kernel log that could be useful in debugging 
why a particular BUG() happened.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
