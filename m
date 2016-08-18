Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4081B83094
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 09:26:09 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id e70so53354188ioi.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 06:26:09 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0161.hostedemail.com. [216.40.44.161])
        by mx.google.com with ESMTPS id w2si5040557ita.105.2016.08.18.06.26.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 06:26:08 -0700 (PDT)
Message-ID: <1471526765.4319.31.camel@perches.com>
Subject: Re: [PATCH] proc, smaps: reduce printing overhead
From: Joe Perches <joe@perches.com>
Date: Thu, 18 Aug 2016 06:26:05 -0700
In-Reply-To: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
References: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Jann Horn <jann@thejh.net>, Michal Hocko <mhocko@suse.com>

On Thu, 2016-08-18 at 13:31 +0200, Michal Hocko wrote:

[]

> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
[]
> @@ -721,6 +721,13 @@ void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
>  {
>  }
>  
> +static void print_name_value_kb(struct seq_file *m, const char *name, unsigned long val)
> +{
> +	seq_puts(m, name);
> +	seq_put_decimal_ull(m, 0, val);
> +	seq_puts(m, " kB\n");
> +}

The seq_put_decimal_ull function has different arguments
in -next, the separator is changed to const char *.

$ git log --stat -p -1 49f87a2773000ced0c850639975f43134de48342 -- fs/seq_file.c

Maybe this change in fs/proc/meminfo.c should be
made into a public function.

$ git log --stat -p -1  5e27340c20516104c38668e597b3200f339fc64d

static void show_val_kb(struct seq_file *m, const char *s, unsigned long num)
+{
+       char v[32];
+       static const char blanks[7] = {' ', ' ', ' ', ' ',' ', ' ', ' '};
+       int len;
+
+       len = num_to_str(v, sizeof(v), num << (PAGE_SHIFT - 10));
+
+       seq_write(m, s, 16);
+
+       if (len > 0) {
+               if (len < 8)
+                       seq_write(m, blanks, 8 - len);
+
+               seq_write(m, v, len);
+       }
+       seq_write(m, " kB\n", 4);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
