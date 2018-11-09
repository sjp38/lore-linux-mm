Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A4FA86B06FA
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 09:10:18 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id w10-v6so1443621plz.0
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 06:10:18 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f17-v6si7955744pfa.123.2018.11.09.06.10.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 06:10:17 -0800 (PST)
Date: Fri, 9 Nov 2018 15:10:12 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
Message-ID: <20181109141012.accx62deekzq5gh5@pathway.suse.cz>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181106143502.GA32748@tigerII.localdomain>
 <20181107102154.pobr7yrl5il76be6@pathway.suse.cz>
 <20181108022138.GA2343@jagdpanzerIV>
 <20181108112443.huqkju4uwrenvtnu@pathway.suse.cz>
 <20181108123049.GA30440@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181108123049.GA30440@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Thu 2018-11-08 21:30:49, Sergey Senozhatsky wrote:
> On (11/08/18 12:24), Petr Mladek wrote:
> > > - It seems that buffered printk attempts to solve too many problems.
> > >   I'd prefer it to address just one.
> > 
> > This API tries to handle continuous lines more reliably.
> > Do I miss anything, please?
> 
> This part:
> 
> +       /* Flush already completed lines if any. */
> +       for (pos = ptr->len - 1; pos >= 0; pos--) {
> +               if (ptr->buf[pos] != '\n')
> +                       continue;
> +               ptr->buf[pos++] = '\0';
> +               printk("%s\n", ptr->buf);
> +               ptr->len -= pos;
> +               memmove(ptr->buf, ptr->buf + pos, ptr->len);
> +               /* This '\0' will be overwritten by next vsnprintf() above. */
> +               ptr->buf[ptr->len] = '\0';
> +               break;
> +       }
> +       return r;
> 
> If I'm not mistaken, this is for the futute "printk injection" work.

No, it does not make sense to distinguish the context at this level.
The buffer is passed as an argument. It should not get passed to another
task or context.

The above code only tries to push complete lines to the main log buffer
and consoles ASAP. It sounds like a Good Idea(tm).


> Right now printk("foo\nbar\n") will end up to be a single logbuf
> entry, with \n in the middle and at the end. So it will look like
> two lines on the serial console:
> 
> 	[123.123] foo
> 	          bar
> 
> Tetsuo does this \n lookup (on every vprintk_buffered) and split lines
> (via memove) for "printk injection", so the output will be
> 
> 	[123.123] foo
> 	[123.124] bar

No, please note that the for cycle searches for '\n' from the end
of the string.

> Which makes it simpler to "inject" printk origin into every printed
> line.
> 
> Without it we can just do
> 
> 	len = vsprintf();
> 	if (len && text[len - 1] == '\n' || overflow)
> 		flush();

I had the same idea. Tetsuo ignored it. I looked for more arguments
and found that '\n' is used in the middle of several pr_cont()
calls, see

     git grep 'pr_cont.*\\n.*[^\\n]"'

Best Regards,
Petr
