Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 892996B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 20:33:17 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so9795176pbc.15
        for <linux-mm@kvack.org>; Wed, 11 Sep 2013 17:33:16 -0700 (PDT)
Date: Wed, 11 Sep 2013 17:33:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
In-Reply-To: <522EC3D1.4010806@asianux.com>
Message-ID: <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com>
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com>
 <522EC3D1.4010806@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, 10 Sep 2013, Chen Gang wrote:

> > Why?  It can just store the string into the buffer pointed to by the 
> > char *buffer and terminate it appropriately while taking care that it 
> > doesn't exceed maxlen.  Why does the caller need to know the number of 
> > bytes written?  If it really does, you could just do strlen(buffer).
> > 
> > If there's a real reason for it, then that's fine, I just think it can be 
> > made to always succeed and never return < 0.  (And why is nobody checking 
> > the return value today if it's so necessary?)
> > 
> 
> For common printing functions: sprintf(), snprintf(), scnprintf().
> 
> For some of specific printing functions: drivers/usb/host/uhci-debug.c.
> 
> at least they can let caller easy use.
> 

Nobody needs mpol_to_str() to return the number of characters written, 
period.  It's one of the most trivial functions you're going to see in the 
mempolicy code, it takes a pointer to a buffer and it stores characters to 
it for display.  Nobody is going to use it for anything else.  Let's not 
overcomplicate this trivial function.

> > Nobody is using mpol_to_str() to determine if a mempolicy mode is valid :)  
> > If the struct mempolicy really has a bad mode, then just store "unknown" 
> > or store a 0.  If maxlen is insufficient for the longest possible string 
> > stored by mpol_to_str(), then it should be a compile-time error.
> > 
> > 
> 
> Hmm... what you said sounds reasonable if mpol_to_str() is a normal
> static funciton (only used within a file).
> 
> For extern function, callee (inside) can not assume anything of caller
> (outside) beyond the interface. So if failure occurs, better to report
> to caller only, and let caller to check what to do next.
> 

Are you just preaching about the best practices of software engineering?  
mpol_to_str() should never fail at runtime, plain and simple.  If somebody 
introduces a new mode and doesn't update it to print correctly, let's not 
fail the read().  Let's just print "unknown".  And if someone passes too 
small of a buffer, break it at compile time so it gets noticed and fixed.

I guarantee you that any kernel developer who writes code to call 
mpol_to_str() will be happy it never fails at runtime.  Really.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
