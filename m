Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37D1683099
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 10:41:52 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id u13so38187925uau.2
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 07:41:52 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0049.hostedemail.com. [216.40.44.49])
        by mx.google.com with ESMTPS id 1si1421030qkx.258.2016.08.18.07.41.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 07:41:51 -0700 (PDT)
Message-ID: <1471531306.4319.38.camel@perches.com>
Subject: Re: [PATCH] proc, smaps: reduce printing overhead
From: Joe Perches <joe@perches.com>
Date: Thu, 18 Aug 2016 07:41:46 -0700
In-Reply-To: <20160818142616.GN30162@dhcp22.suse.cz>
References: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
	 <1471526765.4319.31.camel@perches.com>
	 <20160818142616.GN30162@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Jann Horn <jann@thejh.net>

On Thu, 2016-08-18 at 16:26 +0200, Michal Hocko wrote:
> On Thu 18-08-16 06:26:05, Joe Perches wrote:
> > On Thu, 2016-08-18 at 13:31 +0200, Michal Hocko wrote:
> > []
> > > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > []
> > > @@ -721,6 +721,13 @@ void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
> > >  {
> > >  }
> > >  
> > > +static void print_name_value_kb(struct seq_file *m, const char *name, unsigned long val)
> > > +{
> > > +	seq_puts(m, name);
> > > +	seq_put_decimal_ull(m, 0, val);
> > > +	seq_puts(m, " kB\n");
> > > +}
> > The seq_put_decimal_ull function has different arguments
> > in -next, the separator is changed to const char *.
> > 
> > $ git log --stat -p -1 49f87a2773000ced0c850639975f43134de48342 -- fs/seq_file.c
> OK, I haven't noticed that. I can rebase, although I wonder whether the
> change is a universal win. Not that the strlen on a short string would
> matter but just look at the usage:
>      76 " "
>       1 "/"
>       1 ""
>       1 "cpu  "
>       1 "intr "
>       1 g ? " " : "",
>       1 "\nFDSize:\t"
>       1 "\nGid:\t"
>       1 "\nNgid:\t"
>       1 "\nnonvoluntary_ctxt_switches:\t"
>       1 "\nPid:\t"
>       1 "\nPPid:\t"
>       1 "\nSigQ:\t"
>       1 "\nTgid:\t"
>       1 "\nTracerPid:\t"
>       1 "\nUid:\t"
>       1 "Seccomp:\t"
>       1 "softirq "
>      10 "\t"
>       1 "Threads:\t"
>       1 "voluntary_ctxt_switches:\t"
> 
> Most users simply need a single character. Those few could just seq_puts
> for the string followed by seq_put_decimal_ull.
>  
> > 
> > Maybe this change in fs/proc/meminfo.c should be
> > made into a public function.
> > 
> > $ git log --stat -p -1  5e27340c20516104c38668e597b3200f339fc64d
> > 
> > static void show_val_kb(struct seq_file *m, const char *s, unsigned long num)
> > +{
> > +       char v[32];
> > +       static const char blanks[7] = {' ', ' ', ' ', ' ',' ', ' ', ' '};
> > +       int len;
> > +
> > +       len = num_to_str(v, sizeof(v), num << (PAGE_SHIFT - 10));
> > +
> > +       seq_write(m, s, 16);
> > +
> > +       if (len > 0) {
> > +               if (len < 8)
> > +                       seq_write(m, blanks, 8 - len);
> > +
> > +               seq_write(m, v, len);
> > +       }
> > +       seq_write(m, " kB\n", 4);
> > +}
> Uff, this is just ugly as hell, seriously! a) why does it hardcode the
> name to be 16 characters max in such a subtle way and b) doesn't it try
> to be overly clever when doing that in the caller doesn't cost all that
> much?

It's optimized for the meminfo caller which had
16 byte fixed length string prefixes.

>  Sure you can save few bytes in the spaces but then I would just
> argue to use \t rather than fixed string length.

The output formatting can't be changed as it /proc

And your proposed patch is actually inappropriate
as it effectively changes %8lu to %lu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
