Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C517C6B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 07:11:18 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id aq1so161654218obc.2
        for <linux-mm@kvack.org>; Thu, 05 May 2016 04:11:18 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0092.outbound.protection.outlook.com. [104.47.0.92])
        by mx.google.com with ESMTPS id k6si3587280oeu.37.2016.05.05.04.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 May 2016 04:11:17 -0700 (PDT)
Subject: Re: [PATCHv8 1/2] x86/vdso: add mremap hook to vm_special_mapping
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com>
 <1461584223-9418-1-git-send-email-dsafonov@virtuozzo.com>
 <CALCETrVJhooHkMMVY_702p88-jYRJibXi38WB+fAizAt6S3PjQ@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <e0a10957-ddf7-1bc4-fad6-8b5836628fce@virtuozzo.com>
Date: Thu, 5 May 2016 14:09:57 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrVJhooHkMMVY_702p88-jYRJibXi38WB+fAizAt6S3PjQ@mail.gmail.com>
Content-Type: multipart/alternative;
	boundary="------------40018954E1C7A3FC258DB1C3"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>

--------------40018954E1C7A3FC258DB1C3
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit

On 04/26/2016 12:38 AM, Andy Lutomirski wrote:
> On Mon, Apr 25, 2016 at 4:37 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>> Add possibility for userspace 32-bit applications to move
>> vdso mapping. Previously, when userspace app called
>> mremap for vdso, in return path it would land on previous
>> address of vdso page, resulting in segmentation violation.
>> Now it lands fine and returns to userspace with remapped vdso.
>> This will also fix context.vdso pointer for 64-bit, which does not
>> affect the user of vdso after mremap by now, but this may change.
>>
>> As suggested by Andy, return EINVAL for mremap that splits vdso image.
>>
>> Renamed and moved text_mapping structure declaration inside
>> map_vdso, as it used only there and now it complement
>> vvar_mapping variable.
>>
>> There is still problem for remapping vdso in glibc applications:
>> linker relocates addresses for syscalls on vdso page, so
>> you need to relink with the new addresses. Or the next syscall
>> through glibc may fail:
>>    Program received signal SIGSEGV, Segmentation fault.
>>    #0  0xf7fd9b80 in __kernel_vsyscall ()
>>    #1  0xf7ec8238 in _exit () from /usr/lib32/libc.so.6
> Acked-by: Andy Lutomirski <luto@kernel.org>
>
> Ingo, can you apply this?

Hm, so I'm not sure - should I resend those two?
Or just ping?

>> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
>> ---
>> v8: add WARN_ON_ONCE on current->mm != new_vma->vm_mm
>> v7: build fix
>> v6: moved vdso_image_32 check and fixup code into vdso_fix_landing function
>>      with ifdefs around
>> v5: as Andy suggested, add a check that new_vma->vm_mm and current->mm are
>>      the same, also check not only in_ia32_syscall() but image == &vdso_image_32
>> v4: drop __maybe_unused & use image from mm->context instead vdso_image_32
>> v3: as Andy suggested, return EINVAL in case of splitting vdso blob on mremap;
>>      used is_ia32_task instead of ifdefs
>> v2: added __maybe_unused for pt_regs in vdso_mremap
>>
>>   arch/x86/entry/vdso/vma.c | 47 ++++++++++++++++++++++++++++++++++++++++++-----
>>   include/linux/mm_types.h  |  3 +++
>>   mm/mmap.c                 | 10 ++++++++++
>>   3 files changed, 55 insertions(+), 5 deletions(-)
>>
>> diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
>> index 10f704584922..0625b66e5648 100644
>> --- a/arch/x86/entry/vdso/vma.c
>> +++ b/arch/x86/entry/vdso/vma.c
>> @@ -12,6 +12,7 @@
>>   #include <linux/random.h>
>>   #include <linux/elf.h>
>>   #include <linux/cpu.h>
>> +#include <linux/ptrace.h>
>>   #include <asm/pvclock.h>
>>   #include <asm/vgtod.h>
>>   #include <asm/proto.h>
>> @@ -98,10 +99,40 @@ static int vdso_fault(const struct vm_special_mapping *sm,
>>          return 0;
>>   }
>>
>> -static const struct vm_special_mapping text_mapping = {
>> -       .name = "[vdso]",
>> -       .fault = vdso_fault,
>> -};
>> +static void vdso_fix_landing(const struct vdso_image *image,
>> +               struct vm_area_struct *new_vma)
>> +{
>> +#if defined CONFIG_X86_32 || defined CONFIG_IA32_EMULATION
>> +       if (in_ia32_syscall() && image == &vdso_image_32) {
>> +               struct pt_regs *regs = current_pt_regs();
>> +               unsigned long vdso_land = image->sym_int80_landing_pad;
>> +               unsigned long old_land_addr = vdso_land +
>> +                       (unsigned long)current->mm->context.vdso;
>> +
>> +               /* Fixing userspace landing - look at do_fast_syscall_32 */
>> +               if (regs->ip == old_land_addr)
>> +                       regs->ip = new_vma->vm_start + vdso_land;
>> +       }
>> +#endif
>> +}
>> +
>> +static int vdso_mremap(const struct vm_special_mapping *sm,
>> +               struct vm_area_struct *new_vma)
>> +{
>> +       unsigned long new_size = new_vma->vm_end - new_vma->vm_start;
>> +       const struct vdso_image *image = current->mm->context.vdso_image;
>> +
>> +       if (image->size != new_size)
>> +               return -EINVAL;
>> +
>> +       if (WARN_ON_ONCE(current->mm != new_vma->vm_mm))
>> +               return -EFAULT;
>> +
>> +       vdso_fix_landing(image, new_vma);
>> +       current->mm->context.vdso = (void __user *)new_vma->vm_start;
>> +
>> +       return 0;
>> +}
>>
>>   static int vvar_fault(const struct vm_special_mapping *sm,
>>                        struct vm_area_struct *vma, struct vm_fault *vmf)
>> @@ -162,6 +193,12 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
>>          struct vm_area_struct *vma;
>>          unsigned long addr, text_start;
>>          int ret = 0;
>> +
>> +       static const struct vm_special_mapping vdso_mapping = {
>> +               .name = "[vdso]",
>> +               .fault = vdso_fault,
>> +               .mremap = vdso_mremap,
>> +       };
>>          static const struct vm_special_mapping vvar_mapping = {
>>                  .name = "[vvar]",
>>                  .fault = vvar_fault,
>> @@ -195,7 +232,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
>>                                         image->size,
>>                                         VM_READ|VM_EXEC|
>>                                         VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
>> -                                      &text_mapping);
>> +                                      &vdso_mapping);
>>
>>          if (IS_ERR(vma)) {
>>                  ret = PTR_ERR(vma);
>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index c2d75b4fa86c..4d16ab9287af 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -586,6 +586,9 @@ struct vm_special_mapping {
>>          int (*fault)(const struct vm_special_mapping *sm,
>>                       struct vm_area_struct *vma,
>>                       struct vm_fault *vmf);
>> +
>> +       int (*mremap)(const struct vm_special_mapping *sm,
>> +                    struct vm_area_struct *new_vma);
>>   };
>>
>>   enum tlb_flush_reason {
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index bd2e1a533bc1..ba71658dd1a1 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -2930,9 +2930,19 @@ static const char *special_mapping_name(struct vm_area_struct *vma)
>>          return ((struct vm_special_mapping *)vma->vm_private_data)->name;
>>   }
>>
>> +static int special_mapping_mremap(struct vm_area_struct *new_vma)
>> +{
>> +       struct vm_special_mapping *sm = new_vma->vm_private_data;
>> +
>> +       if (sm->mremap)
>> +               return sm->mremap(sm, new_vma);
>> +       return 0;
>> +}
>> +
>>   static const struct vm_operations_struct special_mapping_vmops = {
>>          .close = special_mapping_close,
>>          .fault = special_mapping_fault,
>> +       .mremap = special_mapping_mremap,
>>          .name = special_mapping_name,
>>   };
>>
>> --
>> 2.8.0
>>
>
>


-- 
Regards,
Dmitry Safonov


--------------40018954E1C7A3FC258DB1C3
Content-Type: text/html; charset="utf-8"
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <div class="moz-cite-prefix">On 04/26/2016 12:38 AM, Andy Lutomirski
      wrote:<br>
    </div>
    <blockquote
cite="mid:CALCETrVJhooHkMMVY_702p88-jYRJibXi38WB+fAizAt6S3PjQ@mail.gmail.com"
      type="cite">
      <pre wrap="">On Mon, Apr 25, 2016 at 4:37 AM, Dmitry Safonov <a class="moz-txt-link-rfc2396E" href="mailto:dsafonov@virtuozzo.com">&lt;dsafonov@virtuozzo.com&gt;</a> wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">Add possibility for userspace 32-bit applications to move
vdso mapping. Previously, when userspace app called
mremap for vdso, in return path it would land on previous
address of vdso page, resulting in segmentation violation.
Now it lands fine and returns to userspace with remapped vdso.
This will also fix context.vdso pointer for 64-bit, which does not
affect the user of vdso after mremap by now, but this may change.

As suggested by Andy, return EINVAL for mremap that splits vdso image.

Renamed and moved text_mapping structure declaration inside
map_vdso, as it used only there and now it complement
vvar_mapping variable.

There is still problem for remapping vdso in glibc applications:
linker relocates addresses for syscalls on vdso page, so
you need to relink with the new addresses. Or the next syscall
through glibc may fail:
  Program received signal SIGSEGV, Segmentation fault.
  #0  0xf7fd9b80 in __kernel_vsyscall ()
  #1  0xf7ec8238 in _exit () from /usr/lib32/libc.so.6
</pre>
      </blockquote>
      <pre wrap="">
Acked-by: Andy Lutomirski <a class="moz-txt-link-rfc2396E" href="mailto:luto@kernel.org">&lt;luto@kernel.org&gt;</a>

Ingo, can you apply this?</pre>
    </blockquote>
    <br>
    Hm, so I'm not sure - should I resend those two?<br>
    Or just ping?<br>
    <br>
    <blockquote
cite="mid:CALCETrVJhooHkMMVY_702p88-jYRJibXi38WB+fAizAt6S3PjQ@mail.gmail.com"
      type="cite">
      <blockquote type="cite">
        <pre wrap="">
Signed-off-by: Dmitry Safonov <a class="moz-txt-link-rfc2396E" href="mailto:dsafonov@virtuozzo.com">&lt;dsafonov@virtuozzo.com&gt;</a>
---
v8: add WARN_ON_ONCE on current-&gt;mm != new_vma-&gt;vm_mm
v7: build fix
v6: moved vdso_image_32 check and fixup code into vdso_fix_landing function
    with ifdefs around
v5: as Andy suggested, add a check that new_vma-&gt;vm_mm and current-&gt;mm are
    the same, also check not only in_ia32_syscall() but image == &amp;vdso_image_32
v4: drop __maybe_unused &amp; use image from mm-&gt;context instead vdso_image_32
v3: as Andy suggested, return EINVAL in case of splitting vdso blob on mremap;
    used is_ia32_task instead of ifdefs
v2: added __maybe_unused for pt_regs in vdso_mremap

 arch/x86/entry/vdso/vma.c | 47 ++++++++++++++++++++++++++++++++++++++++++-----
 include/linux/mm_types.h  |  3 +++
 mm/mmap.c                 | 10 ++++++++++
 3 files changed, 55 insertions(+), 5 deletions(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 10f704584922..0625b66e5648 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -12,6 +12,7 @@
 #include &lt;linux/random.h&gt;
 #include &lt;linux/elf.h&gt;
 #include &lt;linux/cpu.h&gt;
+#include &lt;linux/ptrace.h&gt;
 #include &lt;asm/pvclock.h&gt;
 #include &lt;asm/vgtod.h&gt;
 #include &lt;asm/proto.h&gt;
@@ -98,10 +99,40 @@ static int vdso_fault(const struct vm_special_mapping *sm,
        return 0;
 }

-static const struct vm_special_mapping text_mapping = {
-       .name = "[vdso]",
-       .fault = vdso_fault,
-};
+static void vdso_fix_landing(const struct vdso_image *image,
+               struct vm_area_struct *new_vma)
+{
+#if defined CONFIG_X86_32 || defined CONFIG_IA32_EMULATION
+       if (in_ia32_syscall() &amp;&amp; image == &amp;vdso_image_32) {
+               struct pt_regs *regs = current_pt_regs();
+               unsigned long vdso_land = image-&gt;sym_int80_landing_pad;
+               unsigned long old_land_addr = vdso_land +
+                       (unsigned long)current-&gt;mm-&gt;context.vdso;
+
+               /* Fixing userspace landing - look at do_fast_syscall_32 */
+               if (regs-&gt;ip == old_land_addr)
+                       regs-&gt;ip = new_vma-&gt;vm_start + vdso_land;
+       }
+#endif
+}
+
+static int vdso_mremap(const struct vm_special_mapping *sm,
+               struct vm_area_struct *new_vma)
+{
+       unsigned long new_size = new_vma-&gt;vm_end - new_vma-&gt;vm_start;
+       const struct vdso_image *image = current-&gt;mm-&gt;context.vdso_image;
+
+       if (image-&gt;size != new_size)
+               return -EINVAL;
+
+       if (WARN_ON_ONCE(current-&gt;mm != new_vma-&gt;vm_mm))
+               return -EFAULT;
+
+       vdso_fix_landing(image, new_vma);
+       current-&gt;mm-&gt;context.vdso = (void __user *)new_vma-&gt;vm_start;
+
+       return 0;
+}

 static int vvar_fault(const struct vm_special_mapping *sm,
                      struct vm_area_struct *vma, struct vm_fault *vmf)
@@ -162,6 +193,12 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
        struct vm_area_struct *vma;
        unsigned long addr, text_start;
        int ret = 0;
+
+       static const struct vm_special_mapping vdso_mapping = {
+               .name = "[vdso]",
+               .fault = vdso_fault,
+               .mremap = vdso_mremap,
+       };
        static const struct vm_special_mapping vvar_mapping = {
                .name = "[vvar]",
                .fault = vvar_fault,
@@ -195,7 +232,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
                                       image-&gt;size,
                                       VM_READ|VM_EXEC|
                                       VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-                                      &amp;text_mapping);
+                                      &amp;vdso_mapping);

        if (IS_ERR(vma)) {
                ret = PTR_ERR(vma);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index c2d75b4fa86c..4d16ab9287af 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -586,6 +586,9 @@ struct vm_special_mapping {
        int (*fault)(const struct vm_special_mapping *sm,
                     struct vm_area_struct *vma,
                     struct vm_fault *vmf);
+
+       int (*mremap)(const struct vm_special_mapping *sm,
+                    struct vm_area_struct *new_vma);
 };

 enum tlb_flush_reason {
diff --git a/mm/mmap.c b/mm/mmap.c
index bd2e1a533bc1..ba71658dd1a1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2930,9 +2930,19 @@ static const char *special_mapping_name(struct vm_area_struct *vma)
        return ((struct vm_special_mapping *)vma-&gt;vm_private_data)-&gt;name;
 }

+static int special_mapping_mremap(struct vm_area_struct *new_vma)
+{
+       struct vm_special_mapping *sm = new_vma-&gt;vm_private_data;
+
+       if (sm-&gt;mremap)
+               return sm-&gt;mremap(sm, new_vma);
+       return 0;
+}
+
 static const struct vm_operations_struct special_mapping_vmops = {
        .close = special_mapping_close,
        .fault = special_mapping_fault,
+       .mremap = special_mapping_mremap,
        .name = special_mapping_name,
 };

--
2.8.0

</pre>
      </blockquote>
      <pre wrap="">


</pre>
    </blockquote>
    <br>
    <p><br>
    </p>
    <pre class="moz-signature" cols="72">-- 
Regards,
Dmitry Safonov</pre>
  </body>
</html>

--------------40018954E1C7A3FC258DB1C3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
