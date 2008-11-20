Date: Thu, 20 Nov 2008 01:26:58 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 1/7] mm: remove cgroup_mm_owner_callbacks
In-Reply-To: <6599ad830811191723v3c346a17kf5ae5494987373c1@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0811200125100.21820@blonde.site>
References: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
 <Pine.LNX.4.64.0811200110180.19216@blonde.site>
 <6599ad830811191723v3c346a17kf5ae5494987373c1@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Nov 2008, Paul Menage wrote:
> On Wed, Nov 19, 2008 at 5:11 PM, Hugh Dickins <hugh@veritas.com> wrote:
> >
> >  assign_new_owner:
> >        BUG_ON(c == p);
> >        get_task_struct(c);
> > -       read_unlock(&tasklist_lock);
> > -       down_write(&mm->mmap_sem);
> >        /*
> >         * The task_lock protects c->mm from changing.
> >         * We always want mm->owner->mm == mm
> >         */
> >        task_lock(c);
> > +       /*
> > +        * Delay read_unlock() till we have the task_lock()
> > +        * to ensure that c does not slip away underneath us
> > +        */
> > +       read_unlock(&tasklist_lock);
> 
> How can c slip away when we've done get_task_struct(c) earlier?

I don't know, I did vaguely wonder the same myself: just putting
this back to how it was before (including that comment),
maybe Balbir can enlighten us.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
