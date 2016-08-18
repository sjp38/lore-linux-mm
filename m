Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3CF9683094
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 10:26:21 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p85so13622964lfg.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 07:26:21 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id j6si2142786wjy.133.2016.08.18.07.26.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 07:26:19 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id o80so5865883wme.0
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 07:26:19 -0700 (PDT)
Date: Thu, 18 Aug 2016 16:26:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] proc, smaps: reduce printing overhead
Message-ID: <20160818142616.GN30162@dhcp22.suse.cz>
References: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
 <1471526765.4319.31.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1471526765.4319.31.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Jann Horn <jann@thejh.net>

On Thu 18-08-16 06:26:05, Joe Perches wrote:
> On Thu, 2016-08-18 at 13:31 +0200, Michal Hocko wrote:
> 
> []
> 
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> []
> > @@ -721,6 +721,13 @@ void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
> >  {
> >  }
> >  
> > +static void print_name_value_kb(struct seq_file *m, const char *name, unsigned long val)
> > +{
> > +	seq_puts(m, name);
> > +	seq_put_decimal_ull(m, 0, val);
> > +	seq_puts(m, " kB\n");
> > +}
> 
> The seq_put_decimal_ull function has different arguments
> in -next, the separator is changed to const char *.
> 
> $ git log --stat -p -1 49f87a2773000ced0c850639975f43134de48342 -- fs/seq_file.c

OK, I haven't noticed that. I can rebase, although I wonder whether the
change is a universal win. Not that the strlen on a short string would
matter but just look at the usage:
     76 " "
      1 "/"
      1 ""
      1 "cpu  "
      1 "intr "
      1 g ? " " : "",
      1 "\nFDSize:\t"
      1 "\nGid:\t"
      1 "\nNgid:\t"
      1 "\nnonvoluntary_ctxt_switches:\t"
      1 "\nPid:\t"
      1 "\nPPid:\t"
      1 "\nSigQ:\t"
      1 "\nTgid:\t"
      1 "\nTracerPid:\t"
      1 "\nUid:\t"
      1 "Seccomp:\t"
      1 "softirq "
     10 "\t"
      1 "Threads:\t"
      1 "voluntary_ctxt_switches:\t"

Most users simply need a single character. Those few could just seq_puts
for the string followed by seq_put_decimal_ull.
 
> Maybe this change in fs/proc/meminfo.c should be
> made into a public function.
> 
> $ git log --stat -p -1  5e27340c20516104c38668e597b3200f339fc64d
> 
> static void show_val_kb(struct seq_file *m, const char *s, unsigned long num)
> +{
> +       char v[32];
> +       static const char blanks[7] = {' ', ' ', ' ', ' ',' ', ' ', ' '};
> +       int len;
> +
> +       len = num_to_str(v, sizeof(v), num << (PAGE_SHIFT - 10));
> +
> +       seq_write(m, s, 16);
> +
> +       if (len > 0) {
> +               if (len < 8)
> +                       seq_write(m, blanks, 8 - len);
> +
> +               seq_write(m, v, len);
> +       }
> +       seq_write(m, " kB\n", 4);
> +}

Uff, this is just ugly as hell, seriously! a) why does it hardcode the
name to be 16 characters max in such a subtle way and b) doesn't it try
to be overly clever when doing that in the caller doesn't cost all that
much? Sure you can save few bytes in the spaces but then I would just
argue to use \t rather than fixed string length.

That being said, I agree that there should be a common helper I just
really dislike the above.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
