Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 314AC6B0038
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 12:44:34 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so56040812wib.1
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 09:44:33 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id ew7si17723912wjc.139.2015.06.14.09.44.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 09:44:32 -0700 (PDT)
Received: by wiwd19 with SMTP id d19so55482462wiw.0
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 09:44:31 -0700 (PDT)
Date: Sun, 14 Jun 2015 09:44:22 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: linux 4.1-rc7 deadlock
In-Reply-To: <557A089A.3090202@redhat.com>
Message-ID: <alpine.LSU.2.11.1506140934280.11018@eggly.anvils>
References: <5576D3E7.40302@fedoraproject.org> <5576F3DA.7000106@monom.org> <CAKSJeFLb523beVQHqWhCtaBOECfeYrwWdojb5M8wqQWMfwJ72A@mail.gmail.com> <alpine.LSU.2.11.1506111246170.6716@eggly.anvils> <557A089A.3090202@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prarit Bhargava <prarit@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Morten Stevens <mstevens@fedoraproject.org>, Daniel Wagner <wagi@monom.org>, Dave Chinner <david@fromorbit.com>, Eric Paris <eparis@redhat.com>, Eric Sandeen <esandeen@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 11 Jun 2015, Prarit Bhargava wrote:
> On 06/11/2015 04:06 PM, Hugh Dickins wrote:
> > On Tue, 9 Jun 2015, Morten Stevens wrote:
> >> 2015-06-09 16:10 GMT+02:00 Daniel Wagner <wagi@monom.org>:
> >>> On 06/09/2015 01:54 PM, Morten Stevens wrote:
> > 
> > Reported-by: Prarit Bhargava <prarit@redhat.com>
> > Reported-by: Daniel Wagner <wagi@monom.org>
> > Reported-by: Morten Stevens <mstevens@fedoraproject.org>
> > Not-Yet-Signed-off-by: Hugh Dickins <hughd@google.com>
> > ---
> > 
> >  mm/shmem.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > --- 4.1-rc7/mm/shmem.c	2015-04-26 19:16:31.352191298 -0700
> > +++ linux/mm/shmem.c	2015-06-11 11:08:21.042745594 -0700
> > @@ -3401,7 +3401,7 @@ int shmem_zero_setup(struct vm_area_stru
> >  	struct file *file;
> >  	loff_t size = vma->vm_end - vma->vm_start;
> >  
> > -	file = shmem_file_setup("dev/zero", size, vma->vm_flags);
> > +	file = __shmem_file_setup("dev/zero", size, vma->vm_flags, S_PRIVATE);
> 
> Perhaps,
> 
> 	file = shmem_kernel_file_setup("dev/zero", size, vma->vm_flags) ?

Perhaps.  I couldn't decide whether this is a proper intended use of
shmem_kernel_file_setup(), or a handy reuse of its flag.  Andrew asked
for a comment, so in the end I left that line as is, but refer to
shmem_kernel_file_setup() in the comment.  And that forced me to look a
little closer at the security implications: but we do seem to be safe.

> 
> Tested-by: Prarit Bhargava <prarit@redhat.com>

Thank you: I had been hoping for some corroboration from one of the other
guys (no offence to you, but 33% looks a bit weak!), but now it's Sunday
so I think I'd better send this off in the hope that it makes -rc8.

Hugh

> 
> P.
> 
> >  	if (IS_ERR(file))
> >  		return PTR_ERR(file);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
