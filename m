Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE0B26B0026
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 05:27:08 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id u84so7468720vke.13
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 02:27:08 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j93sor3458151uad.281.2018.03.23.02.27.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Mar 2018 02:27:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180322070900.GA5605@ram.oc3035372033.ibm.com>
References: <CAEemH2f0LDqyR5AmUYv17OuBc5-UycckDPWgk46XU_ghQo4diw@mail.gmail.com>
 <871sguep4v.fsf@concordia.ellerman.id.au> <20180308164545.GM1060@ram.oc3035372033.ibm.com>
 <CAEemH2czWDjvJLpL6ynV1+VxCFh_-A-d72tJhA5zwgrAES2nWA@mail.gmail.com>
 <20180320215828.GA5825@ram.oc3035372033.ibm.com> <CAEemH2eewab4nsn6daMRAtn9tDrHoZb_PnbH8xA17ypFCTg6iA@mail.gmail.com>
 <20180322070900.GA5605@ram.oc3035372033.ibm.com>
From: Li Wang <liwang@redhat.com>
Date: Fri, 23 Mar 2018 17:27:06 +0800
Message-ID: <CAEemH2c4p7FqYs9L9X0SyjUvg5Z3pfwsokurJmzq+=y1h2OwbA@mail.gmail.com>
Subject: Re: [bug?] Access was denied by memory protection keys in
 execute-only address
Content-Type: multipart/alternative; boundary="001a1142966c2bc9e405681107e7"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, Cyril Hrubis <chrubis@suse.cz>, Jan Stancek <jstancek@redhat.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, ltp@lists.linux.it, linux-mm@kvack.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

--001a1142966c2bc9e405681107e7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 22, 2018 at 3:09 PM, Ram Pai <linuxram@us.ibm.com> wrote:

> On Wed, Mar 21, 2018 at 02:53:00PM +0800, Li Wang wrote:
> >    On Wed, Mar 21, 2018 at 5:58 AM, Ram Pai <[1]linuxram@us.ibm.com>
> wrote:
> >
> >      On Fri, Mar 09, 2018 at 11:43:00AM +0800, Li Wang wrote:
> >      >    On Fri, Mar 9, 2018 at 12:45 AM, Ram Pai
> >      <[1][2]linuxram@us.ibm.com> wrote:
> >      >
> >      >      On Thu, Mar 08, 2018 at 11:19:12PM +1100, Michael Ellerman
> wrote:
> >      >      > Li Wang <[2][3]liwang@redhat.com> writes:
> >      >      > > Hi,
> >      >      > >
> >      >      am wondering if the slightly different cpu behavior is
> dependent
> ..snip..
> >      on the
> >      >      version of the firmware/microcode?
> >      >
> >      >    =E2=80=8BI also run this reproducer on series ppc kvm machine=
s, but
> none of
> >      them
> >      >    get the FAIL.
> >      >    If you need some more HW info, pls let me know.=E2=80=8B
> >
> >      Hi Li,
> >
> >         Can you try the following patch and see if it solves your
> problem.
> >
> >    =E2=80=8BIt only works on power7 lpar machine.
> >
> >    But for p8 lpar, it still get failure as that before, the thing I
> wondered
> >    is
> >    that why not disable the pkey_execute_disable_supported on p8 machin=
e?
>
> It turns out to be a testcase bug.  On Big endian powerpc ABI, function
> ptrs are basically pointers to function descriptors.  The testcase
> copies functions which results in function descriptors getting copied.
> You have to apply the following patch to your test case for it to
> operate as intended.  Thanks to Michael Ellermen for helping me out.
> Otherwise I would be scratching my head for ever.
>

=E2=80=8BThanks for the explanation, I learned something new about this. :)

And the worth to say, seems the patch only works on powerpc arch,
others(x86_64, etc)
that does not works well, so a simple workaround is to isolate the code
changes
to powerpc system?


Hi Cyril & Jan,

Could any of you take a look at this patch, comments?



>
>
> diff --git a/testcases/kernel/syscalls/mprotect/mprotect04.c
> b/testcases/kernel/syscalls/mprotect/mprotect04.c
> index 1173afd..9fe9001 100644
> --- a/testcases/kernel/syscalls/mprotect/mprotect04.c
> +++ b/testcases/kernel/syscalls/mprotect/mprotect04.c
> @@ -189,18 +189,30 @@ static void clear_cache(void *start, int len)
>  #endif
>  }
>
> +typedef struct {
> +       uintptr_t entry;
> +       uintptr_t toc;
> +       uintptr_t env;
> +} func_descr_t;
> +
> +typedef void (*func_ptr_t)(void);
> +
>  /*
>   * Copy page where &exec_func resides. Also try to copy subsequent page
>   * in case exec_func is close to page boundary.
>   */
> -static void *get_func(void *mem)
> +void *get_func(void *mem)
>  {
>         uintptr_t page_sz =3D getpagesize();
>         uintptr_t page_mask =3D ~(page_sz - 1);
> -       uintptr_t func_page_offset =3D (uintptr_t)&exec_func & (page_sz -=
 1);
> -       void *func_copy_start =3D mem + func_page_offset;
> -       void *page_to_copy =3D (void *)((uintptr_t)&exec_func & page_mask=
);
> +       uintptr_t func_page_offset;
> +       void *func_copy_start, *page_to_copy;
>         void *mem_start =3D mem;
> +       func_descr_t *opd =3D  (func_descr_t *)&exec_func;
> +
> +       func_page_offset =3D (uintptr_t)opd->entry & (page_sz - 1);
> +       func_copy_start =3D mem + func_page_offset;
> +       page_to_copy =3D (void *)((uintptr_t)opd->entry & page_mask);
>
>         /* copy 1st page, if it's not present something is wrong */
>         if (!page_present(page_to_copy)) {
> @@ -228,15 +240,17 @@ static void *get_func(void *mem)
>
>  static void testfunc_protexec(void)
>  {
> -       void (*func)(void);
>         void *p;
> +       func_ptr_t func;
> +       func_descr_t opd;
>
>         sig_caught =3D 0;
>
>         p =3D SAFE_MMAP(cleanup, 0, copy_sz, PROT_READ | PROT_WRITE,
>                  MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
>
> -       func =3D get_func(p);
> +       opd.entry =3D (uintptr_t)get_func(p);
> +       func =3D (func_ptr_t)&opd;
>
>         /* Change the protection to PROT_EXEC. */
>         TEST(mprotect(p, copy_sz, PROT_EXEC));
>
>
> RP
>
>


--=20
Li Wang
liwang@redhat.com

--001a1142966c2bc9e405681107e7
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-family:monospac=
e,monospace"><br></div><div class=3D"gmail_extra"><br><div class=3D"gmail_q=
uote">On Thu, Mar 22, 2018 at 3:09 PM, Ram Pai <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:linuxram@us.ibm.com" target=3D"_blank">linuxram@us.ibm.com</a>&=
gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px =
0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">On W=
ed, Mar 21, 2018 at 02:53:00PM +0800, Li Wang wrote:<br>
<span class=3D"gmail-">&gt;=C2=A0 =C2=A0 On Wed, Mar 21, 2018 at 5:58 AM, R=
am Pai &lt;[1]<a href=3D"mailto:linuxram@us.ibm.com">linuxram@us.ibm.com</a=
>&gt; wrote:<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 On Fri, Mar 09, 2018 at 11:43:00AM +0800, Li Wang =
wrote:<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt;=C2=A0 =C2=A0 On Fri, Mar 9, 2018 at 12:45 AM,=
 Ram Pai<br>
</span><span class=3D"gmail-">&gt;=C2=A0 =C2=A0 =C2=A0 &lt;[1][2]<a href=3D=
"mailto:linuxram@us.ibm.com">linuxram@us.ibm.com</a>&gt; wrote:<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt;=C2=A0 =C2=A0 =C2=A0 On Thu, Mar 08, 2018 at 1=
1:19:12PM +1100, Michael Ellerman wrote:<br>
</span>&gt;=C2=A0 =C2=A0 =C2=A0 &gt;=C2=A0 =C2=A0 =C2=A0 &gt; Li Wang &lt;[=
2][3]<a href=3D"mailto:liwang@redhat.com">liwang@redhat.com</a>&gt; writes:=
<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; Hi,<br>
<span class=3D"gmail-">&gt;=C2=A0 =C2=A0 =C2=A0 &gt;=C2=A0 =C2=A0 =C2=A0 &g=
t; &gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt;=C2=A0 =C2=A0 =C2=A0 am wondering if the sligh=
tly different cpu behavior is dependent<br>
</span>..snip..<br>
<span class=3D"gmail-">&gt;=C2=A0 =C2=A0 =C2=A0 on the<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt;=C2=A0 =C2=A0 =C2=A0 version of the firmware/m=
icrocode?<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt;=C2=A0 =C2=A0 =E2=80=8BI also run this reprodu=
cer on series ppc kvm machines, but none of<br>
&gt;=C2=A0 =C2=A0 =C2=A0 them<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt;=C2=A0 =C2=A0 get the FAIL.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt;=C2=A0 =C2=A0 If you need some more HW info, p=
ls let me know.=E2=80=8B<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 Hi Li,<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Can you try the following patch and s=
ee if it solves your problem.<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =E2=80=8BIt only works on power7 lpar machine.<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 But for p8 lpar, it still get failure as that before, the=
 thing I wondered<br>
&gt;=C2=A0 =C2=A0 is<br>
&gt;=C2=A0 =C2=A0 that why not disable the pkey_execute_disable_supported o=
n p8 machine?<br>
<br>
</span>It turns out to be a testcase bug.=C2=A0 On Big endian powerpc ABI, =
function<br>
ptrs are basically pointers to function descriptors.=C2=A0 The testcase<br>
copies functions which results in function descriptors getting copied.<br>
You have to apply the following patch to your test case for it to<br>
operate as intended.=C2=A0 Thanks to Michael Ellermen for helping me out.<b=
r>
Otherwise I would be scratching my head for ever.<br></blockquote><div><br>=
<div style=3D"font-family:monospace,monospace" class=3D"gmail_default">=E2=
=80=8BThanks for the explanation, I learned something new about this. :) <b=
r><br></div><div style=3D"font-family:monospace,monospace" class=3D"gmail_d=
efault">And the worth to say, seems the patch only works on powerpc arch, o=
thers(x86_64, etc)<br>that does not works well, so a simple workaround is t=
o isolate the code changes<br>to powerpc system?<br></div><div style=3D"fon=
t-family:monospace,monospace" class=3D"gmail_default"><br><br></div><div st=
yle=3D"font-family:monospace,monospace" class=3D"gmail_default">Hi Cyril &a=
mp; Jan, <br><br>Could any of you take a look at this patch, comments?<br><=
/div><br>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0px =
0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">
<br>
<br>
diff --git a/testcases/kernel/syscalls/<wbr>mprotect/mprotect04.c b/testcas=
es/kernel/syscalls/<wbr>mprotect/mprotect04.c<br>
index 1173afd..9fe9001 100644<br>
--- a/testcases/kernel/syscalls/<wbr>mprotect/mprotect04.c<br>
+++ b/testcases/kernel/syscalls/<wbr>mprotect/mprotect04.c<br>
@@ -189,18 +189,30 @@ static void clear_cache(void *start, int len)<br>
=C2=A0#endif<br>
=C2=A0}<br>
<br>
+typedef struct {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0uintptr_t entry;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0uintptr_t toc;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0uintptr_t env;<br>
+} func_descr_t;<br>
+<br>
+typedef void (*func_ptr_t)(void);<br>
+<br>
=C2=A0/*<br>
=C2=A0 * Copy page where &amp;exec_func resides. Also try to copy subsequen=
t page<br>
=C2=A0 * in case exec_func is close to page boundary.<br>
=C2=A0 */<br>
-static void *get_func(void *mem)<br>
+void *get_func(void *mem)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 uintptr_t page_sz =3D getpagesize();<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 uintptr_t page_mask =3D ~(page_sz - 1);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0uintptr_t func_page_offset =3D (uintptr_t)&amp;=
exec_func &amp; (page_sz - 1);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0void *func_copy_start =3D mem + func_page_offse=
t;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0void *page_to_copy =3D (void *)((uintptr_t)&amp=
;exec_func &amp; page_mask);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0uintptr_t func_page_offset;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0void *func_copy_start, *page_to_copy;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 void *mem_start =3D mem;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0func_descr_t *opd =3D=C2=A0 (func_descr_t *)&am=
p;exec_func;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0func_page_offset =3D (uintptr_t)opd-&gt;entry &=
amp; (page_sz - 1);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0func_copy_start =3D mem + func_page_offset;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0page_to_copy =3D (void *)((uintptr_t)opd-&gt;en=
try &amp; page_mask);<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* copy 1st page, if it&#39;s not present somet=
hing is wrong */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page_present(page_to_copy)) {<br>
@@ -228,15 +240,17 @@ static void *get_func(void *mem)<br>
<br>
=C2=A0static void testfunc_protexec(void)<br>
=C2=A0{<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0void (*func)(void);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 void *p;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0func_ptr_t func;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0func_descr_t opd;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 sig_caught =3D 0;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 p =3D SAFE_MMAP(cleanup, 0, copy_sz, PROT_READ =
| PROT_WRITE,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0MAP_PRIVATE |=
 MAP_ANONYMOUS, -1, 0);<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0func =3D get_func(p);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0opd.entry =3D (uintptr_t)get_func(p);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0func =3D (func_ptr_t)&amp;opd;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Change the protection to PROT_EXEC. */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 TEST(mprotect(p, copy_sz, PROT_EXEC));<br>
<br>
<br>
RP<br>
<br>
</blockquote></div><br><br clear=3D"all"><br>-- <br><div class=3D"gmail_sig=
nature">Li Wang<br><a href=3D"mailto:liwang@redhat.com" target=3D"_blank">l=
iwang@redhat.com</a></div>
</div></div>

--001a1142966c2bc9e405681107e7--
