Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id VAA02756
	for <linux-mm@kvack.org>; Sat, 28 Sep 2002 21:49:22 -0700 (PDT)
Message-ID: <3D968652.28AD6766@digeo.com>
Date: Sat, 28 Sep 2002 21:49:22 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vma->shared list_head initializations
References: <20020928234930.F13817@bitchcake.off.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zach Brown <zab@zabbo.net>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Zach Brown wrote:
> 
> more list_head debugging carnage.
> 

yup

> --- linux-2.5.39/fs/exec.c.fmuta        Sat Sep 28 19:50:20 2002
> +++ linux-2.5.39/fs/exec.c      Sat Sep 28 19:51:08 2002
> @@ -400,6 +400,7 @@
>                 mpnt->vm_ops = NULL;
>                 mpnt->vm_pgoff = 0;
>                 mpnt->vm_file = NULL;
> +               INIT_LIST_HEAD(&mpnt->shared);
>                 mpnt->vm_private_data = (void *) 0;
>                 insert_vm_struct(mm, mpnt);
>                 mm->total_vm = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;

Fair enough, short-term.  But what your patch is really saying
is "this code stinks".

We need to lose all those open-coded accesses to vm_area_cachep,
give that cache a constructor and possibly write some helper
functions.  To lose all this fragile "did I remember to
initialise everything and has anyone added any more fields
since I wrote that code" gunk.

<looks hopefully at Christoph>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
