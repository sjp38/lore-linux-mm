Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 76BE76B00A8
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 04:42:16 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8P8gIon030236
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 25 Sep 2009 17:42:19 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 788AE45DE52
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:42:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C08645DE4F
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:42:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 243931DB8041
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:42:18 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id ADDA21DB803F
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:42:17 +0900 (JST)
Date: Fri, 25 Sep 2009 17:40:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: No more bits in vm_area_struct's vm_flags.
Message-Id: <20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4ABC80B0.5010100@crca.org.au>
References: <4AB9A0D6.1090004@crca.org.au>
	<20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com>
	<4ABC80B0.5010100@crca.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Sep 2009 18:34:56 +1000
Nigel Cunningham <ncunningham@crca.org.au> wrote:

> Hi.
> 
> KAMEZAWA Hiroyuki wrote:
> >> I have some code in TuxOnIce that needs a bit too (explicitly mark the
> >> VMA as needing to be atomically copied, for GEM objects), and am not
> >> sure what the canonical way to proceed is. Should a new unsigned long be
> >> added? The difficulty I see with that is that my flag was used in
> >> shmem_file_setup's flags parameter (drm_gem_object_alloc), so that
> >> function would need an extra parameter too..
> > 
> > Hmm, how about adding vma->vm_flags2 ?
> 
> The difficulty there is that some functions pass these flags as arguments.
> 
Ah yes. But I wonder some special flags, which is rarey used, can be moved
to vm_flags2...

For example,

 #define VM_SEQ_READ     0x00008000      /* App will access data sequentially */
 #define VM_RAND_READ    0x00010000      /* App will not benefit from clustered reads */
are all capsuled under
mm.h
 117 #define VM_READHINTMASK                 (VM_SEQ_READ | VM_RAND_READ)
 118 #define VM_ClearReadHint(v)             (v)->vm_flags &= ~VM_READHINTMASK
 119 #define VM_NormalReadHint(v)            (!((v)->vm_flags & VM_READHINTMASK))
 120 #define VM_SequentialReadHint(v)        ((v)->vm_flags & VM_SEQ_READ)
 121 #define VM_RandomReadHint(v)            ((v)->vm_flags & VM_RAND_READ)

Or

105 #define VM_PFN_AT_MMAP  0x40000000      /* PFNMAP vma that is fully mapped at mmap time */
is only used under special situation.

etc..

They'll be able to be moved to other(new) flag field, IIUC.

Thanks,
-Kame




> Regards,
> 
> Nigel
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
