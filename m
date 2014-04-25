Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 611176B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 15:09:44 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id q5so3161725wiv.4
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 12:09:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ay7si2136102wib.50.2014.04.25.12.09.41
        for <linux-mm@kvack.org>;
        Fri, 25 Apr 2014 12:09:42 -0700 (PDT)
Date: Fri, 25 Apr 2014 21:09:31 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm: get_user_pages(write,force) refuse to COW in
	shared areas
Message-ID: <20140425190931.GA11323@redhat.com>
References: <alpine.LSU.2.11.1404040120110.6880@eggly.anvils> <20140424133055.GA13269@redhat.com> <alpine.LSU.2.11.1404241518510.4454@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1404241518510.4454@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Roland Dreier <roland@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mauro Carvalho Chehab <m.chehab@samsung.com>, Omar Ramirez Luna <omar.ramirez@copitl.com>, Inki Dae <inki.dae@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rdma@vger.kernel.org, linux-media@vger.kernel.org

On 04/24, Hugh Dickins wrote:
>
> On Thu, 24 Apr 2014, Oleg Nesterov wrote:
>
> > So, what do you think about the patch below? It is probably fine in any case,
> > but is there any "strong" reason to follow the gup's behaviour and forbid the
> > anon page in VM_MAYSHARE && !VM_MAYWRITE vma?
>
> I don't think there is a "strong" reason to forbid it.
>
> The strongest reason is simply that it's much safer if uprobes follows
> the same conventions as mm, and get_user_pages() happens to have
> forbidden that all along.
>
> The philosophical reason to forbid it is that the user mmapped with
> MAP_SHARED, and it's merely a kernel-internal detail that we flip off
> VM_SHARED and treat these read-only shared mappings very much like
> private mappings.  The user asked for MAP_SHARED, and we prefer to
> respect that by not letting private COWs creep in.
>
> We could treat those mappings even more like private mappings, and
> allow the COWs; but better to be strict about it, so long as doing
> so doesn't give you regressions.

Great, thanks a lot! I was worried I missed something subtle.

And I forgot to mention, there is another reason why I would like to
change uprobes to follow the same convention. I still think it would
be better to kill __replace_page() and use gup(FOLL_WRITE | FORCE)
in uprobe_write_opcode().


> > --- x/kernel/events/uprobes.c
> > +++ x/kernel/events/uprobes.c
> > @@ -127,12 +127,13 @@ struct xol_area {
> >   */
> >  static bool valid_vma(struct vm_area_struct *vma, bool is_register)
> >  {
> > -	vm_flags_t flags = VM_HUGETLB | VM_MAYEXEC | VM_SHARED;
> > +	vm_flags_t flags = VM_HUGETLB | VM_MAYEXEC;
>
> I think a one-line patch changing VM_SHARED to VM_MAYSHARE would do it,
> wouldn't it?  And save you from having to export is_cow_mapping()
> from mm/memory.c.  (I used is_cow_mapping() because I had to make the
> test more complex anyway, just to exclude the case which had been
> oddly handled before.)

Indeed, thanks!

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
