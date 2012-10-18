Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 6E6FD6B002B
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 00:15:00 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id hm4so1281223wib.8
        for <linux-mm@kvack.org>; Wed, 17 Oct 2012 21:14:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <507F803A.8000900@jp.fujitsu.com>
References: <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com>
 <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com>
 <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
 <20121017040515.GA13505@redhat.com> <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com>
 <20121017181413.GA16805@redhat.com> <alpine.DEB.2.00.1210171219010.28214@chino.kir.corp.google.com>
 <20121017193229.GC16805@redhat.com> <alpine.DEB.2.00.1210171237130.28214@chino.kir.corp.google.com>
 <20121017194501.GA24400@redhat.com> <alpine.DEB.2.00.1210171318400.28214@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1210171428540.20712@chino.kir.corp.google.com> <507F803A.8000900@jp.fujitsu.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 17 Oct 2012 21:14:38 -0700
Message-ID: <CA+55aFy9uYifEQ20-tQXvFCYSqb2VG74XhM6ZofHJW_VuqWdZQ@mail.gmail.com>
Subject: Re: [patch for-3.7 v2] mm, mempolicy: avoid taking mutex inside
 spinlock when reading numa_maps
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 17, 2012 at 9:06 PM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>         if (vma && vma != priv->tail_vma) {
>                 struct mm_struct *mm = vma->vm_mm;
> +#ifdef CONFIG_NUMA
> +               task_lock(priv->task);
> +               __mpol_put(priv->task->mempolicy);
> +               task_unlock(priv->task);
> +#endif
>                 up_read(&mm->mmap_sem);
>                 mmput(mm);

Please don't put #ifdef's inside code. It makes things really ugly and
hard to read.

And that is *especially* true in this case, since there's a pattern to
all these things:

> +#ifdef CONFIG_NUMA
> +       task_lock(priv->task);
> +       mpol_get(priv->task->mempolicy);
> +       task_unlock(priv->task);
> +#endif

> +#ifdef CONFIG_NUMA
> +       task_lock(priv->task);
> +       __mpol_put(priv->task->mempolicy);
> +       task_unlock(priv->task);
> +#endif

it really sounds like what you want to do is to just abstract a
"numa_policy_get/put(priv)" operation.

So you could make it be something like

  #ifdef CONFIG_NUMA
  static inline numa_policy_get(struct proc_maps_private *priv)
  {
      task_lock(priv->task);
      mpol_get(priv->task->mempolicy);
      task_unlock(priv->task);
  }
  .. same for the "put" function ..
  #else
    #define numa_policy_get(priv) do { } while (0)
    #define numa_policy_put(priv) do { } while (0)
  #endif

and then you wouldn't have to have the #ifdef's in the middle of code,
and I think it will be more readable in general.

Sure, it is going to be a few more actual lines of patch, but there's
no duplicated code sequence, and the added lines are just the syntax
that makes it look better.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
