Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id DEB8A6B0005
	for <linux-mm@kvack.org>; Sun,  5 Jun 2016 19:08:15 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id t7so362051835vkf.2
        for <linux-mm@kvack.org>; Sun, 05 Jun 2016 16:08:15 -0700 (PDT)
Received: from mail-qg0-x242.google.com (mail-qg0-x242.google.com. [2607:f8b0:400d:c04::242])
        by mx.google.com with ESMTPS id 63si9300907qkm.83.2016.06.05.16.08.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Jun 2016 16:08:15 -0700 (PDT)
Received: by mail-qg0-x242.google.com with SMTP id t106so5572077qgt.2
        for <linux-mm@kvack.org>; Sun, 05 Jun 2016 16:08:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+b8aCV9-8Qg6oxmOKHWvNsPeDyhz=x0GAtWzyYEC6Z2FA@mail.gmail.com>
References: <1465125103-26764-1-git-send-email-iamyooon@gmail.com> <CACT4Y+b8aCV9-8Qg6oxmOKHWvNsPeDyhz=x0GAtWzyYEC6Z2FA@mail.gmail.com>
From: SeokHoon Yoon <iamyooon@gmail.com>
Date: Mon, 6 Jun 2016 08:08:14 +0900
Message-ID: <CAPjZS4qnmc5zPG==2PB0yPjGPZ6SKc31aT1d0u+PoO1c0uYMVw@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm/kasan: use {READ,WRITE}_MODE not true,false
Content-Type: multipart/alternative; boundary=001a11c1198ad2a8a90534900772
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "sh.yoon@lge.com" <sh.yoon@lge.com>

--001a11c1198ad2a8a90534900772
Content-Type: text/plain; charset=UTF-8

2016-06-05 21:49 GMT+09:00 Dmitry Vyukov <dvyukov@google.com>:

> On Sun, Jun 5, 2016 at 1:11 PM, seokhoon.yoon <iamyooon@gmail.com> wrote:
> > When Kasan tell memory access is write or not, use true or false.
> > This expression is simple and convenient.
> >
> > But I think it is possible to more readable. and so change it.
> >
> > Signed-off-by: seokhoon.yoon <iamyooon@gmail.com>
> > ---
> >  mm/kasan/kasan.c  | 32 ++++++++++++++++----------------
> >  mm/kasan/kasan.h  | 12 ++++++++++--
> >  mm/kasan/report.c | 16 ++++++++--------
> >  3 files changed, 34 insertions(+), 26 deletions(-)
> >
> > diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> > index 18b6a2b..642d936 100644
> > --- a/mm/kasan/kasan.c
> > +++ b/mm/kasan/kasan.c
> > @@ -274,7 +274,7 @@ static __always_inline bool
> memory_is_poisoned(unsigned long addr, size_t size)
> >  }
> >
> >  static __always_inline void check_memory_region_inline(unsigned long
> addr,
> > -                                               size_t size, bool write,
> > +                                               size_t size, enum
> acc_type type,
> >                                                 unsigned long ret_ip)
> >  {
> >         if (unlikely(size == 0))
> > @@ -282,39 +282,39 @@ static __always_inline void
> check_memory_region_inline(unsigned long addr,
> >
> >         if (unlikely((void *)addr <
> >                 kasan_shadow_to_mem((void *)KASAN_SHADOW_START))) {
> > -               kasan_report(addr, size, write, ret_ip);
> > +               kasan_report(addr, size, type, ret_ip);
> >                 return;
> >         }
> >
> >         if (likely(!memory_is_poisoned(addr, size)))
> >                 return;
> >
> > -       kasan_report(addr, size, write, ret_ip);
> > +       kasan_report(addr, size, type, ret_ip);
> >  }
> >
> >  static void check_memory_region(unsigned long addr,
> > -                               size_t size, bool write,
> > +                               size_t size, enum acc_type type,
> >                                 unsigned long ret_ip)
> >  {
> > -       check_memory_region_inline(addr, size, write, ret_ip);
> > +       check_memory_region_inline(addr, size, type, ret_ip);
> >  }
> >
> >  void kasan_check_read(const void *p, unsigned int size)
> >  {
> > -       check_memory_region((unsigned long)p, size, false, _RET_IP_);
> > +       check_memory_region((unsigned long)p, size, READ_MODE, _RET_IP_);
> >  }
> >  EXPORT_SYMBOL(kasan_check_read);
> >
> >  void kasan_check_write(const void *p, unsigned int size)
> >  {
> > -       check_memory_region((unsigned long)p, size, true, _RET_IP_);
> > +       check_memory_region((unsigned long)p, size, WRITE_MODE,
> _RET_IP_);
> >  }
> >  EXPORT_SYMBOL(kasan_check_write);
> >
> >  #undef memset
> >  void *memset(void *addr, int c, size_t len)
> >  {
> > -       check_memory_region((unsigned long)addr, len, true, _RET_IP_);
> > +       check_memory_region((unsigned long)addr, len, WRITE_MODE,
> _RET_IP_);
> >
> >         return __memset(addr, c, len);
> >  }
> > @@ -322,8 +322,8 @@ void *memset(void *addr, int c, size_t len)
> >  #undef memmove
> >  void *memmove(void *dest, const void *src, size_t len)
> >  {
> > -       check_memory_region((unsigned long)src, len, false, _RET_IP_);
> > -       check_memory_region((unsigned long)dest, len, true, _RET_IP_);
> > +       check_memory_region((unsigned long)src, len, READ_MODE,
> _RET_IP_);
> > +       check_memory_region((unsigned long)dest, len, WRITE_MODE,
> _RET_IP_);
> >
> >         return __memmove(dest, src, len);
> >  }
> > @@ -331,8 +331,8 @@ void *memmove(void *dest, const void *src, size_t
> len)
> >  #undef memcpy
> >  void *memcpy(void *dest, const void *src, size_t len)
> >  {
> > -       check_memory_region((unsigned long)src, len, false, _RET_IP_);
> > -       check_memory_region((unsigned long)dest, len, true, _RET_IP_);
> > +       check_memory_region((unsigned long)src, len, READ_MODE,
> _RET_IP_);
> > +       check_memory_region((unsigned long)dest, len, WRITE_MODE,
> _RET_IP_);
> >
> >         return __memcpy(dest, src, len);
> >  }
> > @@ -709,7 +709,7 @@ EXPORT_SYMBOL(__asan_unregister_globals);
> >  #define DEFINE_ASAN_LOAD_STORE(size)                                   \
> >         void __asan_load##size(unsigned long addr)                      \
> >         {                                                               \
> > -               check_memory_region_inline(addr, size, false, _RET_IP_);\
> > +               check_memory_region_inline(addr, size, READ_MODE,
> _RET_IP_);\
> >         }                                                               \
> >         EXPORT_SYMBOL(__asan_load##size);                               \
> >         __alias(__asan_load##size)                                      \
> > @@ -717,7 +717,7 @@ EXPORT_SYMBOL(__asan_unregister_globals);
> >         EXPORT_SYMBOL(__asan_load##size##_noabort);                     \
> >         void __asan_store##size(unsigned long addr)                     \
> >         {                                                               \
> > -               check_memory_region_inline(addr, size, true, _RET_IP_); \
> > +               check_memory_region_inline(addr, size, WRITE_MODE,
> _RET_IP_);\
> >         }                                                               \
> >         EXPORT_SYMBOL(__asan_store##size);                              \
> >         __alias(__asan_store##size)                                     \
> > @@ -732,7 +732,7 @@ DEFINE_ASAN_LOAD_STORE(16);
> >
> >  void __asan_loadN(unsigned long addr, size_t size)
> >  {
> > -       check_memory_region(addr, size, false, _RET_IP_);
> > +       check_memory_region(addr, size, READ_MODE, _RET_IP_);
> >  }
> >  EXPORT_SYMBOL(__asan_loadN);
> >
> > @@ -742,7 +742,7 @@ EXPORT_SYMBOL(__asan_loadN_noabort);
> >
> >  void __asan_storeN(unsigned long addr, size_t size)
> >  {
> > -       check_memory_region(addr, size, true, _RET_IP_);
> > +       check_memory_region(addr, size, WRITE_MODE, _RET_IP_);
> >  }
> >  EXPORT_SYMBOL(__asan_storeN);
> >
> > diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> > index 7f7ac51..47cb58c 100644
> > --- a/mm/kasan/kasan.h
> > +++ b/mm/kasan/kasan.h
> > @@ -27,11 +27,19 @@
> >  #define KASAN_ABI_VERSION 1
> >  #endif
> >
> > +/*
> > + * Distinguish memory access
> > + */
> > +enum acc_type {
> > +       READ_MODE,
> > +       WRITE_MODE
> > +};
> > +
> >  struct kasan_access_info {
> >         const void *access_addr;
> >         const void *first_bad_addr;
> >         size_t access_size;
> > -       bool is_write;
> > +       enum acc_type access_type;
> >         unsigned long ip;
> >  };
> >
> > @@ -109,7 +117,7 @@ static inline bool kasan_report_enabled(void)
> >  }
> >
> >  void kasan_report(unsigned long addr, size_t size,
> > -               bool is_write, unsigned long ip);
> > +               enum acc_type type, unsigned long ip);
> >
> >  #ifdef CONFIG_SLAB
> >  void quarantine_put(struct kasan_free_meta *info, struct kmem_cache
> *cache);
> > diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> > index b3c122d..e0bee22 100644
> > --- a/mm/kasan/report.c
> > +++ b/mm/kasan/report.c
> > @@ -96,7 +96,7 @@ static void print_error_description(struct
> kasan_access_info *info)
> >                 bug_type, (void *)info->ip,
> >                 info->access_addr);
> >         pr_err("%s of size %zu by task %s/%d\n",
> > -               info->is_write ? "Write" : "Read",
> > +               info->access_type == WRITE_MODE ? "Write" : "Read",
> >                 info->access_size, current->comm, task_pid_nr(current));
> >  }
> >
> > @@ -267,7 +267,7 @@ static void kasan_report_error(struct
> kasan_access_info *info)
> >                 pr_err("BUG: KASAN: %s on address %p\n",
> >                         bug_type, info->access_addr);
> >                 pr_err("%s of size %zu by task %s/%d\n",
> > -                       info->is_write ? "Write" : "Read",
> > +                       info->access_type == WRITE_MODE ? "Write" :
> "Read",
> >                         info->access_size, current->comm,
> >                         task_pid_nr(current));
> >                 dump_stack();
> > @@ -283,7 +283,7 @@ static void kasan_report_error(struct
> kasan_access_info *info)
> >  }
> >
> >  void kasan_report(unsigned long addr, size_t size,
> > -               bool is_write, unsigned long ip)
> > +               enum acc_type type, unsigned long ip)
> >  {
> >         struct kasan_access_info info;
> >
> > @@ -292,7 +292,7 @@ void kasan_report(unsigned long addr, size_t size,
> >
> >         info.access_addr = (void *)addr;
> >         info.access_size = size;
> > -       info.is_write = is_write;
> > +       info.access_type = type;
> >         info.ip = ip;
> >
> >         kasan_report_error(&info);
> > @@ -302,14 +302,14 @@ void kasan_report(unsigned long addr, size_t size,
> >  #define DEFINE_ASAN_REPORT_LOAD(size)                     \
> >  void __asan_report_load##size##_noabort(unsigned long addr) \
> >  {                                                         \
> > -       kasan_report(addr, size, false, _RET_IP_);        \
> > +       kasan_report(addr, size, READ_MODE, _RET_IP_);    \
> >  }                                                         \
> >  EXPORT_SYMBOL(__asan_report_load##size##_noabort)
> >
> >  #define DEFINE_ASAN_REPORT_STORE(size)                     \
> >  void __asan_report_store##size##_noabort(unsigned long addr) \
> >  {                                                          \
> > -       kasan_report(addr, size, true, _RET_IP_);          \
> > +       kasan_report(addr, size, WRITE_MODE, _RET_IP_);    \
> >  }                                                          \
> >  EXPORT_SYMBOL(__asan_report_store##size##_noabort)
> >
> > @@ -326,12 +326,12 @@ DEFINE_ASAN_REPORT_STORE(16);
> >
> >  void __asan_report_load_n_noabort(unsigned long addr, size_t size)
> >  {
> > -       kasan_report(addr, size, false, _RET_IP_);
> > +       kasan_report(addr, size, READ_MODE, _RET_IP_);
> >  }
> >  EXPORT_SYMBOL(__asan_report_load_n_noabort);
> >
> >  void __asan_report_store_n_noabort(unsigned long addr, size_t size)
> >  {
> > -       kasan_report(addr, size, true, _RET_IP_);
> > +       kasan_report(addr, size, WRITE_MODE, _RET_IP_);
> >  }
> >  EXPORT_SYMBOL(__asan_report_store_n_noabort);
>
>
> Hello seokhoon.yoon,
>
> Hi Dmitry,
thanks for your replies.


>
> Where exactly do you hit readability problems?
>

I don`t hit readablity problem,but kasan need to abstract this expression.
I think more abstraction give us more readablity. isn't it? :)


> I would say that the only problematic place is where we initialize the
> value:
>
>     kasan_report(addr, size, true, _RET_IP_);
>     check_memory_region(addr, size, true, _RET_IP_);
>
Here it is really difficult to say what true/false mean. Even if you
> know that it is access type, you don't necessary remember if true

means write or read. That could be solved by adding comments:
>
>     kasan_report(addr, size, /* write = */ true, _RET_IP_);
>
> In all other places one sees that we are talking about "write".


thanks.

--001a11c1198ad2a8a90534900772
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">=
2016-06-05 21:49 GMT+09:00 Dmitry Vyukov <span dir=3D"ltr">&lt;<a href=3D"m=
ailto:dvyukov@google.com" target=3D"_blank">dvyukov@google.com</a>&gt;</spa=
n>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;=
border-left-width:1px;border-left-style:solid;border-left-color:rgb(204,204=
,204);padding-left:1ex">On Sun, Jun 5, 2016 at 1:11 PM, seokhoon.yoon &lt;<=
a href=3D"mailto:iamyooon@gmail.com">iamyooon@gmail.com</a>&gt; wrote:<br>
&gt; When Kasan tell memory access is write or not, use true or false.<br>
&gt; This expression is simple and convenient.<br>
&gt;<br>
&gt; But I think it is possible to more readable. and so change it.<br>
&gt;<br>
&gt; Signed-off-by: seokhoon.yoon &lt;<a href=3D"mailto:iamyooon@gmail.com"=
>iamyooon@gmail.com</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 mm/kasan/kasan.c=C2=A0 | 32 ++++++++++++++++----------------<br>
&gt;=C2=A0 mm/kasan/kasan.h=C2=A0 | 12 ++++++++++--<br>
&gt;=C2=A0 mm/kasan/report.c | 16 ++++++++--------<br>
&gt;=C2=A0 3 files changed, 34 insertions(+), 26 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c<br>
&gt; index 18b6a2b..642d936 100644<br>
&gt; --- a/mm/kasan/kasan.c<br>
&gt; +++ b/mm/kasan/kasan.c<br>
&gt; @@ -274,7 +274,7 @@ static __always_inline bool memory_is_poisoned(uns=
igned long addr, size_t size)<br>
&gt;=C2=A0 }<br>
&gt;<br>
&gt;=C2=A0 static __always_inline void check_memory_region_inline(unsigned =
long addr,<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0size_t size, bool write,<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0size_t size, enum acc_type type,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long ret_ip)<br>
&gt;=C2=A0 {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(size =3D=3D 0))<br>
&gt; @@ -282,39 +282,39 @@ static __always_inline void check_memory_region_=
inline(unsigned long addr,<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely((void *)addr &lt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0kasan_sha=
dow_to_mem((void *)KASAN_SHADOW_START))) {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0kasan_report(a=
ddr, size, write, ret_ip);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0kasan_report(a=
ddr, size, type, ret_ip);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<b=
r>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (likely(!memory_is_poisoned(addr, =
size)))<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<b=
r>
&gt;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0kasan_report(addr, size, write, ret_ip);<b=
r>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0kasan_report(addr, size, type, ret_ip);<br=
>
&gt;=C2=A0 }<br>
&gt;<br>
&gt;=C2=A0 static void check_memory_region(unsigned long addr,<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0size_t size, bool write,<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0size_t size, enum acc_type type,<=
br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long ret_ip)<br>
&gt;=C2=A0 {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region_inline(addr, size, wri=
te, ret_ip);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region_inline(addr, size, typ=
e, ret_ip);<br>
&gt;=C2=A0 }<br>
&gt;<br>
&gt;=C2=A0 void kasan_check_read(const void *p, unsigned int size)<br>
&gt;=C2=A0 {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region((unsigned long)p, size=
, false, _RET_IP_);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region((unsigned long)p, size=
, READ_MODE, _RET_IP_);<br>
&gt;=C2=A0 }<br>
&gt;=C2=A0 EXPORT_SYMBOL(kasan_check_read);<br>
&gt;<br>
&gt;=C2=A0 void kasan_check_write(const void *p, unsigned int size)<br>
&gt;=C2=A0 {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region((unsigned long)p, size=
, true, _RET_IP_);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region((unsigned long)p, size=
, WRITE_MODE, _RET_IP_);<br>
&gt;=C2=A0 }<br>
&gt;=C2=A0 EXPORT_SYMBOL(kasan_check_write);<br>
&gt;<br>
&gt;=C2=A0 #undef memset<br>
&gt;=C2=A0 void *memset(void *addr, int c, size_t len)<br>
&gt;=C2=A0 {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region((unsigned long)addr, l=
en, true, _RET_IP_);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region((unsigned long)addr, l=
en, WRITE_MODE, _RET_IP_);<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return __memset(addr, c, len);<br>
&gt;=C2=A0 }<br>
&gt; @@ -322,8 +322,8 @@ void *memset(void *addr, int c, size_t len)<br>
&gt;=C2=A0 #undef memmove<br>
&gt;=C2=A0 void *memmove(void *dest, const void *src, size_t len)<br>
&gt;=C2=A0 {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region((unsigned long)src, le=
n, false, _RET_IP_);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region((unsigned long)dest, l=
en, true, _RET_IP_);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region((unsigned long)src, le=
n, READ_MODE, _RET_IP_);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region((unsigned long)dest, l=
en, WRITE_MODE, _RET_IP_);<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return __memmove(dest, src, len);<br>
&gt;=C2=A0 }<br>
&gt; @@ -331,8 +331,8 @@ void *memmove(void *dest, const void *src, size_t =
len)<br>
&gt;=C2=A0 #undef memcpy<br>
&gt;=C2=A0 void *memcpy(void *dest, const void *src, size_t len)<br>
&gt;=C2=A0 {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region((unsigned long)src, le=
n, false, _RET_IP_);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region((unsigned long)dest, l=
en, true, _RET_IP_);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region((unsigned long)src, le=
n, READ_MODE, _RET_IP_);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region((unsigned long)dest, l=
en, WRITE_MODE, _RET_IP_);<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return __memcpy(dest, src, len);<br>
&gt;=C2=A0 }<br>
&gt; @@ -709,7 +709,7 @@ EXPORT_SYMBOL(__asan_unregister_globals);<br>
&gt;=C2=A0 #define DEFINE_ASAN_LOAD_STORE(size)=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0\<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0void __asan_load##size(unsigned long =
addr)=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 \<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0{=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_r=
egion_inline(addr, size, false, _RET_IP_);\<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_r=
egion_inline(addr, size, READ_MODE, _RET_IP_);\<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0EXPORT_SYMBOL(__asan_load##size);=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__alias(__asan_load##size)=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \<br>
&gt; @@ -717,7 +717,7 @@ EXPORT_SYMBOL(__asan_unregister_globals);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0EXPORT_SYMBOL(__asan_load##size##_noa=
bort);=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0\<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0void __asan_store##size(unsigned long=
 addr)=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0\<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0{=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_r=
egion_inline(addr, size, true, _RET_IP_); \<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_r=
egion_inline(addr, size, WRITE_MODE, _RET_IP_);\<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0EXPORT_SYMBOL(__asan_store##size);=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 \<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__alias(__asan_store##size)=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\<br>
&gt; @@ -732,7 +732,7 @@ DEFINE_ASAN_LOAD_STORE(16);<br>
&gt;<br>
&gt;=C2=A0 void __asan_loadN(unsigned long addr, size_t size)<br>
&gt;=C2=A0 {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region(addr, size, false, _RE=
T_IP_);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region(addr, size, READ_MODE,=
 _RET_IP_);<br>
&gt;=C2=A0 }<br>
&gt;=C2=A0 EXPORT_SYMBOL(__asan_loadN);<br>
&gt;<br>
&gt; @@ -742,7 +742,7 @@ EXPORT_SYMBOL(__asan_loadN_noabort);<br>
&gt;<br>
&gt;=C2=A0 void __asan_storeN(unsigned long addr, size_t size)<br>
&gt;=C2=A0 {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region(addr, size, true, _RET=
_IP_);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0check_memory_region(addr, size, WRITE_MODE=
, _RET_IP_);<br>
&gt;=C2=A0 }<br>
&gt;=C2=A0 EXPORT_SYMBOL(__asan_storeN);<br>
&gt;<br>
&gt; diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h<br>
&gt; index 7f7ac51..47cb58c 100644<br>
&gt; --- a/mm/kasan/kasan.h<br>
&gt; +++ b/mm/kasan/kasan.h<br>
&gt; @@ -27,11 +27,19 @@<br>
&gt;=C2=A0 #define KASAN_ABI_VERSION 1<br>
&gt;=C2=A0 #endif<br>
&gt;<br>
&gt; +/*<br>
&gt; + * Distinguish memory access<br>
&gt; + */<br>
&gt; +enum acc_type {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0READ_MODE,<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0WRITE_MODE<br>
&gt; +};<br>
&gt; +<br>
&gt;=C2=A0 struct kasan_access_info {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const void *access_addr;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const void *first_bad_addr;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0size_t access_size;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0bool is_write;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0enum acc_type access_type;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long ip;<br>
&gt;=C2=A0 };<br>
&gt;<br>
&gt; @@ -109,7 +117,7 @@ static inline bool kasan_report_enabled(void)<br>
&gt;=C2=A0 }<br>
&gt;<br>
&gt;=C2=A0 void kasan_report(unsigned long addr, size_t size,<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bool is_write,=
 unsigned long ip);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0enum acc_type =
type, unsigned long ip);<br>
&gt;<br>
&gt;=C2=A0 #ifdef CONFIG_SLAB<br>
&gt;=C2=A0 void quarantine_put(struct kasan_free_meta *info, struct kmem_ca=
che *cache);<br>
&gt; diff --git a/mm/kasan/report.c b/mm/kasan/report.c<br>
&gt; index b3c122d..e0bee22 100644<br>
&gt; --- a/mm/kasan/report.c<br>
&gt; +++ b/mm/kasan/report.c<br>
&gt; @@ -96,7 +96,7 @@ static void print_error_description(struct kasan_acc=
ess_info *info)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bug_type,=
 (void *)info-&gt;ip,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0info-&gt;=
access_addr);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err(&quot;%s of size %zu by task %=
s/%d\n&quot;,<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0info-&gt;is_wr=
ite ? &quot;Write&quot; : &quot;Read&quot;,<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0info-&gt;acces=
s_type =3D=3D WRITE_MODE ? &quot;Write&quot; : &quot;Read&quot;,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0info-&gt;=
access_size, current-&gt;comm, task_pid_nr(current));<br>
&gt;=C2=A0 }<br>
&gt;<br>
&gt; @@ -267,7 +267,7 @@ static void kasan_report_error(struct kasan_access=
_info *info)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err(&q=
uot;BUG: KASAN: %s on address %p\n&quot;,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0bug_type, info-&gt;access_addr);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err(&q=
uot;%s of size %zu by task %s/%d\n&quot;,<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0info-&gt;is_write ? &quot;Write&quot; : &quot;Read&quot;,<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0info-&gt;access_type =3D=3D WRITE_MODE ? &quot;Write&quot; : =
&quot;Read&quot;,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0info-&gt;access_size, current-&gt;comm,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0task_pid_nr(current));<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dump_stac=
k();<br>
&gt; @@ -283,7 +283,7 @@ static void kasan_report_error(struct kasan_access=
_info *info)<br>
&gt;=C2=A0 }<br>
&gt;<br>
&gt;=C2=A0 void kasan_report(unsigned long addr, size_t size,<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bool is_write,=
 unsigned long ip)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0enum acc_type =
type, unsigned long ip)<br>
&gt;=C2=A0 {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct kasan_access_info info;<br>
&gt;<br>
&gt; @@ -292,7 +292,7 @@ void kasan_report(unsigned long addr, size_t size,=
<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0info.access_addr =3D (void *)addr;<br=
>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0info.access_size =3D size;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0info.is_write =3D is_write;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0info.access_type =3D type;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0info.ip =3D ip;<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0kasan_report_error(&amp;info);<br>
&gt; @@ -302,14 +302,14 @@ void kasan_report(unsigned long addr, size_t siz=
e,<br>
&gt;=C2=A0 #define DEFINE_ASAN_REPORT_LOAD(size)=C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\<br>
&gt;=C2=A0 void __asan_report_load##size##_noabort(unsigned long addr) \<br=
>
&gt;=C2=A0 {=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0kasan_report(addr, size, false, _RET_IP_);=
=C2=A0 =C2=A0 =C2=A0 =C2=A0 \<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0kasan_report(addr, size, READ_MODE, _RET_I=
P_);=C2=A0 =C2=A0 \<br>
&gt;=C2=A0 }=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\<br>
&gt;=C2=A0 EXPORT_SYMBOL(__asan_report_load##size##_noabort)<br>
&gt;<br>
&gt;=C2=A0 #define DEFINE_ASAN_REPORT_STORE(size)=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\<br>
&gt;=C2=A0 void __asan_report_store##size##_noabort(unsigned long addr) \<b=
r>
&gt;=C2=A0 {=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0kasan_report(addr, size, true, _RET_IP_);=
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0kasan_report(addr, size, WRITE_MODE, _RET_=
IP_);=C2=A0 =C2=A0 \<br>
&gt;=C2=A0 }=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \<br>
&gt;=C2=A0 EXPORT_SYMBOL(__asan_report_store##size##_noabort)<br>
&gt;<br>
&gt; @@ -326,12 +326,12 @@ DEFINE_ASAN_REPORT_STORE(16);<br>
&gt;<br>
&gt;=C2=A0 void __asan_report_load_n_noabort(unsigned long addr, size_t siz=
e)<br>
&gt;=C2=A0 {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0kasan_report(addr, size, false, _RET_IP_);=
<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0kasan_report(addr, size, READ_MODE, _RET_I=
P_);<br>
&gt;=C2=A0 }<br>
&gt;=C2=A0 EXPORT_SYMBOL(__asan_report_load_n_noabort);<br>
&gt;<br>
&gt;=C2=A0 void __asan_report_store_n_noabort(unsigned long addr, size_t si=
ze)<br>
&gt;=C2=A0 {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0kasan_report(addr, size, true, _RET_IP_);<=
br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0kasan_report(addr, size, WRITE_MODE, _RET_=
IP_);<br>
&gt;=C2=A0 }<br>
&gt;=C2=A0 EXPORT_SYMBOL(__asan_report_store_n_noabort);<br>
<br>
<br>
Hello seokhoon.yoon,<br>
<br></blockquote><div class=3D"gmail_extra">Hi Dmitry,</div><div class=3D"g=
mail_extra">thanks for your replies.</div><div>=C2=A0</div><blockquote clas=
s=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left-width:1px;b=
order-left-style:solid;border-left-color:rgb(204,204,204);padding-left:1ex"=
>
<br>
Where exactly do you hit readability problems?<br></blockquote><div><br></d=
iv><div class=3D"gmail_extra">I don`t hit readablity problem,but kasan need=
 to abstract this expression.</div><div class=3D"gmail_extra">I think more =
abstraction give us more readablity. isn&#39;t it? :)</div><div>=C2=A0</div=
><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border=
-left-width:1px;border-left-style:solid;border-left-color:rgb(204,204,204);=
padding-left:1ex">
I would say that the only problematic place is where we initialize the valu=
e:<br>
<br>
=C2=A0 =C2=A0 kasan_report(addr, size, true, _RET_IP_);<br>
=C2=A0 =C2=A0 check_memory_region(addr, size, true, _RET_IP_);<br></blockqu=
ote><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;bor=
der-left-width:1px;border-left-style:solid;border-left-color:rgb(204,204,20=
4);padding-left:1ex">
Here it is really difficult to say what true/false mean. Even if you<br>
know that it is access type, you don&#39;t necessary remember if true</bloc=
kquote><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;=
border-left-width:1px;border-left-style:solid;border-left-color:rgb(204,204=
,204);padding-left:1ex">
means write or read. That could be solved by adding comments:<br>
<br>
=C2=A0 =C2=A0 kasan_report(addr, size, /* write =3D */ true, _RET_IP_);<br>
<br>
In all other places one sees that we are talking about &quot;write&quot;.</=
blockquote></div></div><div class=3D"gmail_extra"><br></div><div class=3D"g=
mail_extra">thanks.</div></div>

--001a11c1198ad2a8a90534900772--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
