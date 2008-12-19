Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 612B96B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 15:32:38 -0500 (EST)
Date: Fri, 19 Dec 2008 21:34:45 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
Message-ID: <20081219203445.GB6383@random.random>
References: <491DAF8E.4080506@quantum.com> <200811191526.00036.nickpiggin@yahoo.com.au> <20081119165819.GE19209@random.random> <20081218152952.GW24856@random.random> <494B8AD5.3090901@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <494B8AD5.3090901@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Tim LaBerge <tim.laberge@quantum.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Wang Chen <wangchen@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 19, 2008 at 07:51:49PM +0800, Li Zefan wrote:
> > diff -ur rhel-5.2/kernel/fork.c x/kernel/fork.c
> > --- rhel-5.2/kernel/fork.c	2008-07-10 17:26:43.000000000 +0200
> > +++ x/kernel/fork.c	2008-12-18 15:57:31.000000000 +0100
> > @@ -368,7 +368,7 @@
> >  		rb_parent = &tmp->vm_rb;
> >  
> >  		mm->map_count++;
> > -		retval = copy_page_range(mm, oldmm, mpnt);
> > +		retval = copy_page_range(mm, oldmm, tmp);
> >  
> 
> Could you explain a bit why this change is needed?

This change is needed to pass the child vma (not the parent vma) to
handle_mm_fault. We run handle_mm_fault on the child not on the
parent, so the vma passed to handle_mm_fault has to be the one of the
child obviously. It won't make a difference for the other users of the
vma because both vma are basically the same. Nick did it btw.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
