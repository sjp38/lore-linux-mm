Received: by wx-out-0506.google.com with SMTP id h31so1923408wxd
        for <linux-mm@kvack.org>; Tue, 10 Jul 2007 01:41:19 -0700 (PDT)
Message-ID: <661de9470707100141h779e75eev9c09fdb2dfd09b8b@mail.gmail.com>
Date: Tue, 10 Jul 2007 14:11:18 +0530
From: "Balbir Singh" <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm PATCH 4/8] Memory controller memory accounting (v2)
In-Reply-To: <20070710072651.C061D1BF77E@siro.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070706052135.11677.28030.sendpatchset@balbir-laptop>
	 <20070710072651.C061D1BF77E@siro.lan>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: svaidy@linux.vnet.ibm.com, akpm@linux-foundation.org, xemul@openvz.org, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com
List-ID: <linux-mm.kvack.org>

On 7/10/07, YAMAMOTO Takashi <yamamoto@valinux.co.jp> wrote:
> hi,
>
> > diff -puN mm/memory.c~mem-control-accounting mm/memory.c
> > --- linux-2.6.22-rc6/mm/memory.c~mem-control-accounting       2007-07-05 13:45:18.000000000 -0700
> > +++ linux-2.6.22-rc6-balbir/mm/memory.c       2007-07-05 13:45:18.000000000 -0700
>
> > @@ -1731,6 +1736,9 @@ gotten:
> >               cow_user_page(new_page, old_page, address, vma);
> >       }
> >
> > +     if (mem_container_charge(new_page, mm))
> > +             goto oom;
> > +
> >       /*
> >        * Re-check the pte - we dropped the lock
> >        */
>
> it seems that the page will be leaked on error.

You mean meta_page right?

>
> > @@ -2188,6 +2196,11 @@ static int do_swap_page(struct mm_struct
> >       }
> >
> >       delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
> > +     if (mem_container_charge(page, mm)) {
> > +             ret = VM_FAULT_OOM;
> > +             goto out;
> > +     }
> > +
> >       mark_page_accessed(page);
> >       lock_page(page);
> >
>
> ditto.
>
> > @@ -2264,6 +2278,9 @@ static int do_anonymous_page(struct mm_s
> >               if (!page)
> >                       goto oom;
> >
> > +             if (mem_container_charge(page, mm))
> > +                     goto oom;
> > +
> >               entry = mk_pte(page, vma->vm_page_prot);
> >               entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> >
>
> ditto.
>
> can you check the rest of the patch by yourself?  thanks.
>

Excellent catch! I'll review the accounting framework and post the
updated version soon

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
