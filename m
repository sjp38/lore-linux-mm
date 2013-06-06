Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 856D46B003D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 00:55:38 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id cm16so55333qab.0
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 21:55:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1370488193-4747-1-git-send-email-hannes@cmpxchg.org>
References: <1370488193-4747-1-git-send-email-hannes@cmpxchg.org>
From: =?UTF-8?B?5YiY6IOc6Juf?= <liushengjiao@gmail.com>
Date: Thu, 6 Jun 2013 12:55:17 +0800
Message-ID: <CA+xU3bhAK99rDz_z+n5Ct=BLcb=0pxHja5k77KUMdojcmN=ntQ@mail.gmail.com>
Subject: Re: [patch 1/2] arch: invoke oom-killer from page fault
Content-Type: multipart/alternative; boundary=90e6ba10af85137c2204de7520e2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

--90e6ba10af85137c2204de7520e2
Content-Type: text/plain; charset=ISO-8859-1

www.all-sky.com


2013/6/6 Johannes Weiner <hannes@cmpxchg.org>

> Since '1c0fe6e mm: invoke oom-killer from page fault', page fault
> handlers should not directly kill faulting tasks in an out of memory
> condition.  Instead, they should be invoking the OOM killer to pick
> the right task.  Convert the remaining architectures.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  arch/arc/mm/fault.c      | 6 ++++--
>  arch/metag/mm/fault.c    | 6 ++++--
>  arch/mn10300/mm/fault.c  | 7 ++++---
>  arch/openrisc/mm/fault.c | 8 ++++----
>  arch/score/mm/fault.c    | 8 ++++----
>  arch/tile/mm/fault.c     | 8 ++++----
>  6 files changed, 24 insertions(+), 19 deletions(-)
>
> diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
> index c0decc1..d5ec60a 100644
> --- a/arch/arc/mm/fault.c
> +++ b/arch/arc/mm/fault.c
> @@ -207,8 +207,10 @@ out_of_memory:
>         }
>         up_read(&mm->mmap_sem);
>
> -       if (user_mode(regs))
> -               do_group_exit(SIGKILL); /* This will never return */
> +       if (user_mode(regs)) {
> +               pagefault_out_of_memory();
> +               return;
> +       }
>
>         goto no_context;
>
> diff --git a/arch/metag/mm/fault.c b/arch/metag/mm/fault.c
> index 2c75bf7..8fddf46 100644
> --- a/arch/metag/mm/fault.c
> +++ b/arch/metag/mm/fault.c
> @@ -224,8 +224,10 @@ do_sigbus:
>          */
>  out_of_memory:
>         up_read(&mm->mmap_sem);
> -       if (user_mode(regs))
> -               do_group_exit(SIGKILL);
> +       if (user_mode(regs)) {
> +               pagefault_out_of_memory();
> +               return 1;
> +       }
>
>  no_context:
>         /* Are we prepared to handle this kernel fault?  */
> diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c
> index d48a84f..8a2e6de 100644
> --- a/arch/mn10300/mm/fault.c
> +++ b/arch/mn10300/mm/fault.c
> @@ -345,9 +345,10 @@ no_context:
>   */
>  out_of_memory:
>         up_read(&mm->mmap_sem);
> -       printk(KERN_ALERT "VM: killing process %s\n", tsk->comm);
> -       if ((fault_code & MMUFCR_xFC_ACCESS) == MMUFCR_xFC_ACCESS_USR)
> -               do_exit(SIGKILL);
> +       if ((fault_code & MMUFCR_xFC_ACCESS) == MMUFCR_xFC_ACCESS_USR) {
> +               pagefault_out_of_memory();
> +               return;
> +       }
>         goto no_context;
>
>  do_sigbus:
> diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
> index e2bfafc..4a41f84 100644
> --- a/arch/openrisc/mm/fault.c
> +++ b/arch/openrisc/mm/fault.c
> @@ -267,10 +267,10 @@ out_of_memory:
>         __asm__ __volatile__("l.nop 1");
>
>         up_read(&mm->mmap_sem);
> -       printk("VM: killing process %s\n", tsk->comm);
> -       if (user_mode(regs))
> -               do_exit(SIGKILL);
> -       goto no_context;
> +       if (!user_mode(regs))
> +               goto no_context;
> +       pagefault_out_of_memory();
> +       return;
>
>  do_sigbus:
>         up_read(&mm->mmap_sem);
> diff --git a/arch/score/mm/fault.c b/arch/score/mm/fault.c
> index 47b600e..6b18fb0 100644
> --- a/arch/score/mm/fault.c
> +++ b/arch/score/mm/fault.c
> @@ -172,10 +172,10 @@ out_of_memory:
>                 down_read(&mm->mmap_sem);
>                 goto survive;
>         }
> -       printk("VM: killing process %s\n", tsk->comm);
> -       if (user_mode(regs))
> -               do_group_exit(SIGKILL);
> -       goto no_context;
> +       if (!user_mode(regs))
> +               goto no_context;
> +       pagefault_out_of_memory();
> +       return;
>
>  do_sigbus:
>         up_read(&mm->mmap_sem);
> diff --git a/arch/tile/mm/fault.c b/arch/tile/mm/fault.c
> index 3d2b81c..f7f99f9 100644
> --- a/arch/tile/mm/fault.c
> +++ b/arch/tile/mm/fault.c
> @@ -573,10 +573,10 @@ out_of_memory:
>                 down_read(&mm->mmap_sem);
>                 goto survive;
>         }
> -       pr_alert("VM: killing process %s\n", tsk->comm);
> -       if (!is_kernel_mode)
> -               do_group_exit(SIGKILL);
> -       goto no_context;
> +       if (is_kernel_mode)
> +               goto no_context;
> +       pagefault_out_of_memory();
> +       return 0;
>
>  do_sigbus:
>         up_read(&mm->mmap_sem);
> --
> 1.8.2.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--90e6ba10af85137c2204de7520e2
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><a href=3D"http://www.all-sky.com">www.all-sky.com</a><br>=
</div><div class=3D"gmail_extra"><br><br><div class=3D"gmail_quote">2013/6/=
6 Johannes Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.or=
g" target=3D"_blank">hannes@cmpxchg.org</a>&gt;</span><br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">Since &#39;1c0fe6e mm: invoke oom-killer fro=
m page fault&#39;, page fault<br>
handlers should not directly kill faulting tasks in an out of memory<br>
condition. =A0Instead, they should be invoking the OOM killer to pick<br>
the right task. =A0Convert the remaining architectures.<br>
<br>
Signed-off-by: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">ha=
nnes@cmpxchg.org</a>&gt;<br>
---<br>
=A0arch/arc/mm/fault.c =A0 =A0 =A0| 6 ++++--<br>
=A0arch/metag/mm/fault.c =A0 =A0| 6 ++++--<br>
=A0arch/mn10300/mm/fault.c =A0| 7 ++++---<br>
=A0arch/openrisc/mm/fault.c | 8 ++++----<br>
=A0arch/score/mm/fault.c =A0 =A0| 8 ++++----<br>
=A0arch/tile/mm/fault.c =A0 =A0 | 8 ++++----<br>
=A06 files changed, 24 insertions(+), 19 deletions(-)<br>
<br>
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c<br>
index c0decc1..d5ec60a 100644<br>
--- a/arch/arc/mm/fault.c<br>
+++ b/arch/arc/mm/fault.c<br>
@@ -207,8 +207,10 @@ out_of_memory:<br>
=A0 =A0 =A0 =A0 }<br>
=A0 =A0 =A0 =A0 up_read(&amp;mm-&gt;mmap_sem);<br>
<br>
- =A0 =A0 =A0 if (user_mode(regs))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_group_exit(SIGKILL); /* This will never re=
turn */<br>
+ =A0 =A0 =A0 if (user_mode(regs)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pagefault_out_of_memory();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
+ =A0 =A0 =A0 }<br>
<br>
=A0 =A0 =A0 =A0 goto no_context;<br>
<br>
diff --git a/arch/metag/mm/fault.c b/arch/metag/mm/fault.c<br>
index 2c75bf7..8fddf46 100644<br>
--- a/arch/metag/mm/fault.c<br>
+++ b/arch/metag/mm/fault.c<br>
@@ -224,8 +224,10 @@ do_sigbus:<br>
=A0 =A0 =A0 =A0 =A0*/<br>
=A0out_of_memory:<br>
=A0 =A0 =A0 =A0 up_read(&amp;mm-&gt;mmap_sem);<br>
- =A0 =A0 =A0 if (user_mode(regs))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_group_exit(SIGKILL);<br>
+ =A0 =A0 =A0 if (user_mode(regs)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pagefault_out_of_memory();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;<br>
+ =A0 =A0 =A0 }<br>
<br>
=A0no_context:<br>
=A0 =A0 =A0 =A0 /* Are we prepared to handle this kernel fault? =A0*/<br>
diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c<br>
index d48a84f..8a2e6de 100644<br>
--- a/arch/mn10300/mm/fault.c<br>
+++ b/arch/mn10300/mm/fault.c<br>
@@ -345,9 +345,10 @@ no_context:<br>
=A0 */<br>
=A0out_of_memory:<br>
=A0 =A0 =A0 =A0 up_read(&amp;mm-&gt;mmap_sem);<br>
- =A0 =A0 =A0 printk(KERN_ALERT &quot;VM: killing process %s\n&quot;, tsk-&=
gt;comm);<br>
- =A0 =A0 =A0 if ((fault_code &amp; MMUFCR_xFC_ACCESS) =3D=3D MMUFCR_xFC_AC=
CESS_USR)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_exit(SIGKILL);<br>
+ =A0 =A0 =A0 if ((fault_code &amp; MMUFCR_xFC_ACCESS) =3D=3D MMUFCR_xFC_AC=
CESS_USR) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pagefault_out_of_memory();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
+ =A0 =A0 =A0 }<br>
=A0 =A0 =A0 =A0 goto no_context;<br>
<br>
=A0do_sigbus:<br>
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c<br>
index e2bfafc..4a41f84 100644<br>
--- a/arch/openrisc/mm/fault.c<br>
+++ b/arch/openrisc/mm/fault.c<br>
@@ -267,10 +267,10 @@ out_of_memory:<br>
=A0 =A0 =A0 =A0 __asm__ __volatile__(&quot;l.nop 1&quot;);<br>
<br>
=A0 =A0 =A0 =A0 up_read(&amp;mm-&gt;mmap_sem);<br>
- =A0 =A0 =A0 printk(&quot;VM: killing process %s\n&quot;, tsk-&gt;comm);<b=
r>
- =A0 =A0 =A0 if (user_mode(regs))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_exit(SIGKILL);<br>
- =A0 =A0 =A0 goto no_context;<br>
+ =A0 =A0 =A0 if (!user_mode(regs))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto no_context;<br>
+ =A0 =A0 =A0 pagefault_out_of_memory();<br>
+ =A0 =A0 =A0 return;<br>
<br>
=A0do_sigbus:<br>
=A0 =A0 =A0 =A0 up_read(&amp;mm-&gt;mmap_sem);<br>
diff --git a/arch/score/mm/fault.c b/arch/score/mm/fault.c<br>
index 47b600e..6b18fb0 100644<br>
--- a/arch/score/mm/fault.c<br>
+++ b/arch/score/mm/fault.c<br>
@@ -172,10 +172,10 @@ out_of_memory:<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 down_read(&amp;mm-&gt;mmap_sem);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto survive;<br>
=A0 =A0 =A0 =A0 }<br>
- =A0 =A0 =A0 printk(&quot;VM: killing process %s\n&quot;, tsk-&gt;comm);<b=
r>
- =A0 =A0 =A0 if (user_mode(regs))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_group_exit(SIGKILL);<br>
- =A0 =A0 =A0 goto no_context;<br>
+ =A0 =A0 =A0 if (!user_mode(regs))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto no_context;<br>
+ =A0 =A0 =A0 pagefault_out_of_memory();<br>
+ =A0 =A0 =A0 return;<br>
<br>
=A0do_sigbus:<br>
=A0 =A0 =A0 =A0 up_read(&amp;mm-&gt;mmap_sem);<br>
diff --git a/arch/tile/mm/fault.c b/arch/tile/mm/fault.c<br>
index 3d2b81c..f7f99f9 100644<br>
--- a/arch/tile/mm/fault.c<br>
+++ b/arch/tile/mm/fault.c<br>
@@ -573,10 +573,10 @@ out_of_memory:<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 down_read(&amp;mm-&gt;mmap_sem);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto survive;<br>
=A0 =A0 =A0 =A0 }<br>
- =A0 =A0 =A0 pr_alert(&quot;VM: killing process %s\n&quot;, tsk-&gt;comm);=
<br>
- =A0 =A0 =A0 if (!is_kernel_mode)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_group_exit(SIGKILL);<br>
- =A0 =A0 =A0 goto no_context;<br>
+ =A0 =A0 =A0 if (is_kernel_mode)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto no_context;<br>
+ =A0 =A0 =A0 pagefault_out_of_memory();<br>
+ =A0 =A0 =A0 return 0;<br>
<br>
=A0do_sigbus:<br>
=A0 =A0 =A0 =A0 up_read(&amp;mm-&gt;mmap_sem);<br>
<span class=3D"HOEnZb"><font color=3D"#888888">--<br>
1.8.2.3<br>
<br>
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-kernel=
&quot; in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">major=
domo@vger.kernel.org</a><br>
More majordomo info at =A0<a href=3D"http://vger.kernel.org/majordomo-info.=
html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><br>
Please read the FAQ at =A0<a href=3D"http://www.tux.org/lkml/" target=3D"_b=
lank">http://www.tux.org/lkml/</a><br>
</font></span></blockquote></div><br></div>

--90e6ba10af85137c2204de7520e2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
