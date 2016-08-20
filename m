Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 06DDB6B0038
	for <linux-mm@kvack.org>; Sat, 20 Aug 2016 03:29:32 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so43553057lfe.0
        for <linux-mm@kvack.org>; Sat, 20 Aug 2016 00:29:31 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id yf9si9473734wjb.249.2016.08.20.00.29.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Aug 2016 00:29:30 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i5so5947289wmg.2
        for <linux-mm@kvack.org>; Sat, 20 Aug 2016 00:29:30 -0700 (PDT)
Date: Sat, 20 Aug 2016 09:29:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] fs, proc: optimize smaps output formatting
Message-ID: <20160820072927.GA23645@dhcp22.suse.cz>
References: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
 <1471601580-17999-1-git-send-email-mhocko@kernel.org>
 <1471628595.3893.23.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1471628595.3893.23.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jann Horn <jann@thejh.net>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 19-08-16 10:43:15, Joe Perches wrote:
> On Fri, 2016-08-19 at 12:12 +0200, Michal Hocko wrote:
> > Hi,
> > this is rebased on top of next-20160818. Joe has pointed out that
> > meminfo is using a similar trick so I have extracted guts of what we
> > have already and made it more generic to be usable for smaps as well
> > (patch 1). The second patch then replaces seq_printf with seq_write
> > and show_val_kb which should have smaller overhead and my measuring (in
> > kvm) shows quite a nice improvements. I hope kvm is not playing tricks
> > on me but I didn't get to test on a real HW.
> 
> 
> Hi Michal.
> 
> A few comments:
> 
> For the first patch:
> 
> I think this isn't worth the expansion in object size (x86-64 defconfig)
> 
> $ size fs/proc/meminfo.o*
>    text	   data	    bss	    dec	    hex	filename
>    2698	      8	      0	   2706	    a92	fs/proc/meminfo.o.new
>    2142	      8	      0	   2150	    866	fs/proc/meminfo.o.old
> 
> Creating a new static in task_mmu would be smaller and faster code.

Hmm, nasty...
add/remove: 0/0 grow/shrink: 2/1 up/down: 1081/-24 (1057)
function                                     old     new   delta
meminfo_proc_show                           1134    1745    +611
show_smap                                    560    1030    +470
show_val_kb                                  140     116     -24
Total: Before=91716, After=92773, chg +1.15%

it seems to be calls to seq_write which blown up the size. So I've tried
to put seq_write back to show_val_kb and did only sizeof() inside those
macros and that reduced the size but not fully back to the original code
size. So it seems the value shifts consumed some portion of that as well.
I've ended up with the following incremental diff which leads to
   text    data     bss     dec     hex filename
 100728    1443     400  102571   190ab fs/proc/built-in.o.next
 101658    1443     400  103501   1944d fs/proc/built-in.o.patched
 100951    1443     400  102794   1918a fs/proc/built-in.o.incremental

There is still some increase wrt. the baseline but I guess that can be
explained by single seq_printf -> many show_name_val_kb calls.

If that looks acceptable I will respin both patches. I would really
like to prefer to not duplicate show_val_kb into task_mmu as much as
possible, though.

---
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 6a369fc1949d..de9c561f83b4 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -307,17 +307,3 @@ extern void task_mem(struct seq_file *, struct mm_struct *);
 
 /* prints given value (in kB) padded properly to 8 spaces */
 extern void show_val_kb(struct seq_file *m, unsigned long num);
-
-#define show_name_pages_kb(seq, name, pages)	\
-({						\
- 	BUILD_BUG_ON(!__builtin_constant_p(name));\
- 	seq_write(seq, name, sizeof(name));	\
- 	show_val_kb(seq, (pages) << (PAGE_SHIFT - 10));\
- })
-
-#define show_name_bytes_kb(seq, name, val)	\
-({						\
- 	BUILD_BUG_ON(!__builtin_constant_p(name));\
- 	seq_write(seq, name, sizeof(name));	\
- 	show_val_kb(seq, (val) >> 10);		\
-})
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 65e0bc6213e2..7f2937cd231c 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -39,6 +39,14 @@ void show_val_kb(struct seq_file *m, unsigned long num)
 	seq_write(m, " kB\n", 4);
 }
 
+static void show_name_pages_kb(struct seq_file *m, const char *name,
+		unsigned long pages)
+{
+ 	seq_write(m, name, 16);
+ 	show_val_kb(m, pages << (PAGE_SHIFT - 10));
+}
+
+
 static int meminfo_proc_show(struct seq_file *m, void *v)
 {
 	struct sysinfo i;
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index eebb91d44a58..a92898f20a1f 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -721,6 +721,19 @@ void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
 {
 }
 
+static void show_name_val_kb(struct seq_file *m, const char *name, size_t len,
+		unsigned long val)
+{
+	seq_write(m, name, len);
+ 	show_val_kb(m, val >> 10);
+}
+
+#define show_name_bytes_kb(seq, name, val)	\
+({						\
+ 	BUILD_BUG_ON(!__builtin_constant_p(name));\
+ 	show_name_val_kb(seq, name, sizeof(name), val);\
+})
+
 static int show_smap(struct seq_file *m, void *v, int is_pid)
 {
 	struct vm_area_struct *vma = v;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
