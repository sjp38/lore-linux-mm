Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5689F28025C
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 01:06:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n24so70785293pfb.0
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 22:06:21 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 7si6455432pfy.231.2016.09.27.22.06.19
        for <linux-mm@kvack.org>;
        Tue, 27 Sep 2016 22:06:20 -0700 (PDT)
Date: Wed, 28 Sep 2016 14:14:45 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Oops in slab.c in CentOS kernel, looking for ideas --
 correction, it's in slub.c
Message-ID: <20160928051445.GA22706@js1304-P5Q-DELUXE>
References: <57EA9A78.8080509@windriver.com>
 <57EABB64.7070607@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57EABB64.7070607@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Friesen <chris.friesen@windriver.com>
Cc: linux-mm@kvack.org

On Tue, Sep 27, 2016 at 12:33:08PM -0600, Chris Friesen wrote:
> 
> Sorry, I had a typo in my earlier message.  The issue is actually in slub.c.
> 
> Chris
> 
> On 09/27/2016 10:12 AM, Chris Friesen wrote:
> >
> >I've got a CentOS 7 kernel that has been slightly modified, but the mm
> >subsystem hasn't been touched.  I'm hoping you can give me some guidance.
> >
> >I have an intermittent Oops that looks like what is below.  The issue
> >is currently occurring on one CPU of one system, but has been seen
> >before infrequently.  Once the corruption occurs it causes an Oops on
> >every call to __mpol_dup() on this CPU.
> >
> >Basically it appears that __mpol_dup() is failing because the value of
> >c->freelist in slab_alloc_node() is corrupt, causing the call to
> >get_freepointer_safe(s, object) to Oops because it tries to dereference
> >"object + s->offset".  (Where s->offset is zero.)
> >
> >In the trace, "kmem_cache_alloc+0x87" maps to the following assembly:
> >    0xffffffff8118be17 <+135>:   mov    (%r12,%rax,1),%rbx
> >
> >This corresponds to this line in get_freepointer():
> >	return *(void **)(object + s->offset);
> >
> >In the assembly code, R12 is "object", and RAX is s->offset.
> >
> >So the question becomes, why is "object" (which corresponds to c->freelist)
> >corrupt?
> >
> >Looking at the value of R12 (0x1ada8000), it's nonzero but also not a
> >valid pointer. Does the value mean anything to you?  (I'm not really
> >a memory subsystem guy, so I'm hoping you might have some ideas.)
> >
> >Do you have any suggestions on how to track down what's going on here?

Please run with kernel parameter "slub_debug=F" or something.
See Documentation/vm/slub.txt.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
