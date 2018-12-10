Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9438E0001
	for <linux-mm@kvack.org>; Sun,  9 Dec 2018 20:35:42 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id 128so12860076itw.8
        for <linux-mm@kvack.org>; Sun, 09 Dec 2018 17:35:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f6sor4815485ioh.30.2018.12.09.17.35.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Dec 2018 17:35:41 -0800 (PST)
MIME-Version: 1.0
References: <cover.1544099024.git.andreyknvl@google.com> <5cc1b789aad7c99cf4f3ec5b328b147ad53edb40.1544099024.git.andreyknvl@google.com>
In-Reply-To: <5cc1b789aad7c99cf4f3ec5b328b147ad53edb40.1544099024.git.andreyknvl@google.com>
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sun, 9 Dec 2018 20:35:13 -0500
Message-ID: <CAP=VYLo-o8vpGrpM_+0jdvxLC9uxw+F7_OtsSfRyq24HR1dDwA@mail.gmail.com>
Subject: Re: [PATCH v13 08/25] kasan: initialize shadow to 0xff for tag-based mode
Content-Type: multipart/alternative; boundary="0000000000008df041057ca0fb9e"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: andreyknvl@google.com
Cc: aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, catalin.marinas@arm.com, will.deacon@arm.com, cl@linux.com, Andrew Morton <akpm@linux-foundation.org>, mark.rutland@arm.com, ndesaulniers@google.com, marc.zyngier@arm.com, dave.martin@arm.com, ard.biesheuvel@linaro.org, ebiederm@xmission.com, mingo@kernel.org, paullawrence@google.com, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, kirill.shutemov@linux.intel.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, rppt@linux.vnet.ibm.com, kasan-dev@googlegroups.com, LKML doc <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild <linux-kbuild@vger.kernel.org>, kcc@google.com, eugenis@google.com, Lee.Smith@arm.com, Ramana.Radhakrishnan@arm.com, Jacob.Bramley@arm.com, Ruben.Ayrapetyan@arm.com, jannh@google.com, markbrand@google.com, cpandya@codeaurora.org, vishwath@google.com, linux-next@vger.kernel.org

--0000000000008df041057ca0fb9e
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 6, 2018 at 7:25 AM Andrey Konovalov <andreyknvl@google.com>
wrote:

> A tag-based KASAN shadow memory cell contains a memory tag, that
> corresponds to the tag in the top byte of the pointer, that points to tha=
t
> memory. The native top byte value of kernel pointers is 0xff, so with
> tag-based KASAN we need to initialize shadow memory to 0xff.
>
> Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  arch/arm64/mm/kasan_init.c | 15 +++++++++++++--
>  include/linux/kasan.h      |  8 ++++++++
>

The version of this in  linux-next breaks arm64 allmodconfig for me:

mm/kasan/common.c: In function =E2=80=98kasan_module_alloc=E2=80=99:
mm/kasan/common.c:481:17: error: =E2=80=98KASAN_SHADOW_INIT=E2=80=99 undecl=
ared (first use
in this function)
   __memset(ret, KASAN_SHADOW_INIT, shadow_size);
                 ^
mm/kasan/common.c:481:17: note: each undeclared identifier is reported only
once for each function it appears in
make[3]: *** [mm/kasan/common.o] Error 1
make[3]: *** Waiting for unfinished jobs....
make[2]: *** [mm/kasan] Error 2
make[2]: *** Waiting for unfinished jobs....
make[1]: *** [mm/] Error 2
make: *** [sub-make] Error 2

An automated git bisect-run points at this:

5c36287813721999e79ac76f637f1ba7e5054402 is the first bad commit
commit 5c36287813721999e79ac76f637f1ba7e5054402
Author: Andrey Konovalov <andreyknvl@google.com>
Date:   Wed Dec 5 11:13:21 2018 +1100

    kasan: initialize shadow to 0xff for tag-based mode

A quick look at the commit makes me think that the case where the
"# CONFIG_KASAN_GENERIC is not set" has not been handled.

I'm using an older gcc 4.8.3 - only used for build testing.

Paul.
--

 mm/kasan/common.c          |  3 ++-
>  3 files changed, 23 insertions(+), 3 deletions(-)
>
> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
> index 4ebc19422931..7a4a0904cac8 100644
> --- a/arch/arm64/mm/kasan_init.c
> +++ b/arch/arm64/mm/kasan_init.c
> @@ -43,6 +43,15 @@ static phys_addr_t __init kasan_alloc_zeroed_page(int
> node)
>         return __pa(p);
>  }
>
> +static phys_addr_t __init kasan_alloc_raw_page(int node)
> +{
> +       void *p =3D memblock_alloc_try_nid_raw(PAGE_SIZE, PAGE_SIZE,
> +                                               __pa(MAX_DMA_ADDRESS),
> +                                               MEMBLOCK_ALLOC_ACCESSIBLE=
,
> +                                               node);
> +       return __pa(p);
> +}
> +
>  static pte_t *__init kasan_pte_offset(pmd_t *pmdp, unsigned long addr,
> int node,
>                                       bool early)
>  {
> @@ -92,7 +101,9 @@ static void __init kasan_pte_populate(pmd_t *pmdp,
> unsigned long addr,
>         do {
>                 phys_addr_t page_phys =3D early ?
>                                 __pa_symbol(kasan_early_shadow_page)
> -                                       : kasan_alloc_zeroed_page(node);
> +                                       : kasan_alloc_raw_page(node);
> +               if (!early)
> +                       memset(__va(page_phys), KASAN_SHADOW_INIT,
> PAGE_SIZE);
>                 next =3D addr + PAGE_SIZE;
>                 set_pte(ptep, pfn_pte(__phys_to_pfn(page_phys),
> PAGE_KERNEL));
>         } while (ptep++, addr =3D next, addr !=3D end &&
> pte_none(READ_ONCE(*ptep)));
> @@ -239,7 +250,7 @@ void __init kasan_init(void)
>                         pfn_pte(sym_to_pfn(kasan_early_shadow_page),
>                                 PAGE_KERNEL_RO));
>
> -       memset(kasan_early_shadow_page, 0, PAGE_SIZE);
> +       memset(kasan_early_shadow_page, KASAN_SHADOW_INIT, PAGE_SIZE);
>         cpu_replace_ttbr1(lm_alias(swapper_pg_dir));
>
>         /* At this point kasan is fully initialized. Enable error message=
s
> */
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index ec22d548d0d7..c56af24bd3e7 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -153,6 +153,8 @@ static inline size_t kasan_metadata_size(struct
> kmem_cache *cache) { return 0; }
>
>  #ifdef CONFIG_KASAN_GENERIC
>
> +#define KASAN_SHADOW_INIT 0
> +
>  void kasan_cache_shrink(struct kmem_cache *cache);
>  void kasan_cache_shutdown(struct kmem_cache *cache);
>
> @@ -163,4 +165,10 @@ static inline void kasan_cache_shutdown(struct
> kmem_cache *cache) {}
>
>  #endif /* CONFIG_KASAN_GENERIC */
>
> +#ifdef CONFIG_KASAN_SW_TAGS
> +
> +#define KASAN_SHADOW_INIT 0xFF
> +
> +#endif /* CONFIG_KASAN_SW_TAGS */
> +
>  #endif /* LINUX_KASAN_H */
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 5f68c93734ba..7134e75447ff 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -473,11 +473,12 @@ int kasan_module_alloc(void *addr, size_t size)
>
>         ret =3D __vmalloc_node_range(shadow_size, 1, shadow_start,
>                         shadow_start + shadow_size,
> -                       GFP_KERNEL | __GFP_ZERO,
> +                       GFP_KERNEL,
>                         PAGE_KERNEL, VM_NO_GUARD, NUMA_NO_NODE,
>                         __builtin_return_address(0));
>
>         if (ret) {
> +               __memset(ret, KASAN_SHADOW_INIT, shadow_size);
>                 find_vm_area(addr)->flags |=3D VM_KASAN;
>                 kmemleak_ignore(ret);
>                 return 0;
> --
> 2.20.0.rc1.387.gf8505762e3-goog
>
>

--0000000000008df041057ca0fb9e
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr">On Thu, Dec 6, 2018 at 7=
:25 AM Andrey Konovalov &lt;<a href=3D"mailto:andreyknvl@google.com" target=
=3D"_blank">andreyknvl@google.com</a>&gt; wrote:<br><div class=3D"gmail_quo=
te"><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;bor=
der-left:1px solid rgb(204,204,204);padding-left:1ex">A tag-based KASAN sha=
dow memory cell contains a memory tag, that<br>
corresponds to the tag in the top byte of the pointer, that points to that<=
br>
memory. The native top byte value of kernel pointers is 0xff, so with<br>
tag-based KASAN we need to initialize shadow memory to 0xff.<br>
<br>
Reviewed-by: Andrey Ryabinin &lt;<a href=3D"mailto:aryabinin@virtuozzo.com"=
 target=3D"_blank">aryabinin@virtuozzo.com</a>&gt;<br>
Reviewed-by: Dmitry Vyukov &lt;<a href=3D"mailto:dvyukov@google.com" target=
=3D"_blank">dvyukov@google.com</a>&gt;<br>
Signed-off-by: Andrey Konovalov &lt;<a href=3D"mailto:andreyknvl@google.com=
" target=3D"_blank">andreyknvl@google.com</a>&gt;<br>
---<br>
=C2=A0arch/arm64/mm/kasan_init.c | 15 +++++++++++++--<br>
=C2=A0include/linux/kasan.h=C2=A0 =C2=A0 =C2=A0 |=C2=A0 8 ++++++++<br></blo=
ckquote><div><br></div><div>The version of this in=C2=A0 linux-next breaks =
arm64 allmodconfig for me:</div><div><br></div><div>mm/kasan/common.c: In f=
unction =E2=80=98kasan_module_alloc=E2=80=99:<br>mm/kasan/common.c:481:17: =
error: =E2=80=98KASAN_SHADOW_INIT=E2=80=99 undeclared (first use in this fu=
nction)<br>=C2=A0=C2=A0 __memset(ret, KASAN_SHADOW_INIT, shadow_size);<br>=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 ^<br>mm/kasan/common.c:481:17: note: each undeclared =
identifier is reported only once for each function it appears in<br>make[3]=
: *** [mm/kasan/common.o] Error 1<br>make[3]: *** Waiting for unfinished jo=
bs....<br>make[2]: *** [mm/kasan] Error 2<br>make[2]: *** Waiting for unfin=
ished jobs....<br>make[1]: *** [mm/] Error 2<br>make: *** [sub-make] Error =
2</div><div><br></div><div>An automated git bisect-run points at this:<br><=
/div><div><br></div><div>5c36287813721999e79ac76f637f1ba7e5054402 is the fi=
rst bad commit<br>commit 5c36287813721999e79ac76f637f1ba7e5054402<br>Author=
: Andrey Konovalov &lt;<a href=3D"mailto:andreyknvl@google.com" target=3D"_=
blank">andreyknvl@google.com</a>&gt;<br>Date:=C2=A0=C2=A0 Wed Dec 5 11:13:2=
1 2018 +1100<br><br>=C2=A0=C2=A0=C2=A0 kasan: initialize shadow to 0xff for=
 tag-based mode</div><div><br></div><div>A quick look at the commit makes m=
e think that the case where the</div><div>&quot;# CONFIG_KASAN_GENERIC is n=
ot set&quot; has not been handled.</div><div><br></div><div>I&#39;m using a=
n older gcc 4.8.3 - only used for build testing.<br></div><div><br></div><d=
iv>Paul.</div><div>--<br></div><div><br></div><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,20=
4);padding-left:1ex">
=C2=A0mm/kasan/common.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 3 ++-<br>
=C2=A03 files changed, 23 insertions(+), 3 deletions(-)<br>
<br>
diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c<br>
index 4ebc19422931..7a4a0904cac8 100644<br>
--- a/arch/arm64/mm/kasan_init.c<br>
+++ b/arch/arm64/mm/kasan_init.c<br>
@@ -43,6 +43,15 @@ static phys_addr_t __init kasan_alloc_zeroed_page(int no=
de)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return __pa(p);<br>
=C2=A0}<br>
<br>
+static phys_addr_t __init kasan_alloc_raw_page(int node)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0void *p =3D memblock_alloc_try_nid_raw(PAGE_SIZ=
E, PAGE_SIZE,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0__pa(MAX_DMA_ADDRESS),<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0MEMBLOCK_ALLOC_ACCESSIBLE,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0node);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return __pa(p);<br>
+}<br>
+<br>
=C2=A0static pte_t *__init kasan_pte_offset(pmd_t *pmdp, unsigned long addr=
, int node,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bool early)<br>
=C2=A0{<br>
@@ -92,7 +101,9 @@ static void __init kasan_pte_populate(pmd_t *pmdp, unsig=
ned long addr,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 do {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phys_addr_t page_ph=
ys =3D early ?<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __pa_symbol(kasan_early_shadow_page)=
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: kasan_a=
lloc_zeroed_page(node);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: kasan_a=
lloc_raw_page(node);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!early)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0memset(__va(page_phys), KASAN_SHADOW_INIT, PAGE_SIZE);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 next =3D addr + PAG=
E_SIZE;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 set_pte(ptep, pfn_p=
te(__phys_to_pfn(page_phys), PAGE_KERNEL));<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (ptep++, addr =3D next, addr !=3D end &=
amp;&amp; pte_none(READ_ONCE(*ptep)));<br>
@@ -239,7 +250,7 @@ void __init kasan_init(void)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 pfn_pte(sym_to_pfn(kasan_early_shadow_page),<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 PAGE_KERNEL_RO));<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0memset(kasan_early_shadow_page, 0, PAGE_SIZE);<=
br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0memset(kasan_early_shadow_page, KASAN_SHADOW_IN=
IT, PAGE_SIZE);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 cpu_replace_ttbr1(lm_alias(swapper_pg_dir));<br=
>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* At this point kasan is fully initialized. En=
able error messages */<br>
diff --git a/include/linux/kasan.h b/include/linux/kasan.h<br>
index ec22d548d0d7..c56af24bd3e7 100644<br>
--- a/include/linux/kasan.h<br>
+++ b/include/linux/kasan.h<br>
@@ -153,6 +153,8 @@ static inline size_t kasan_metadata_size(struct kmem_ca=
che *cache) { return 0; }<br>
<br>
=C2=A0#ifdef CONFIG_KASAN_GENERIC<br>
<br>
+#define KASAN_SHADOW_INIT 0<br>
+<br>
=C2=A0void kasan_cache_shrink(struct kmem_cache *cache);<br>
=C2=A0void kasan_cache_shutdown(struct kmem_cache *cache);<br>
<br>
@@ -163,4 +165,10 @@ static inline void kasan_cache_shutdown(struct kmem_ca=
che *cache) {}<br>
<br>
=C2=A0#endif /* CONFIG_KASAN_GENERIC */<br>
<br>
+#ifdef CONFIG_KASAN_SW_TAGS<br>
+<br>
+#define KASAN_SHADOW_INIT 0xFF<br>
+<br>
+#endif /* CONFIG_KASAN_SW_TAGS */<br>
+<br>
=C2=A0#endif /* LINUX_KASAN_H */<br>
diff --git a/mm/kasan/common.c b/mm/kasan/common.c<br>
index 5f68c93734ba..7134e75447ff 100644<br>
--- a/mm/kasan/common.c<br>
+++ b/mm/kasan/common.c<br>
@@ -473,11 +473,12 @@ int kasan_module_alloc(void *addr, size_t size)<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D __vmalloc_node_range(shadow_size, 1, sh=
adow_start,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 shadow_start + shadow_size,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0GFP_KERNEL | __GFP_ZERO,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0GFP_KERNEL,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 PAGE_KERNEL, VM_NO_GUARD, NUMA_NO_NODE,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 __builtin_return_address(0));<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__memset(ret, KASAN=
_SHADOW_INIT, shadow_size);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 find_vm_area(addr)-=
&gt;flags |=3D VM_KASAN;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kmemleak_ignore(ret=
);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;<br>
-- <br>
2.20.0.rc1.387.gf8505762e3-goog<br>
<br>
</blockquote></div></div></div></div>

--0000000000008df041057ca0fb9e--
