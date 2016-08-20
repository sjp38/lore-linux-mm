Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A38D6B0038
	for <linux-mm@kvack.org>; Sat, 20 Aug 2016 03:55:09 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s207so172729367oie.1
        for <linux-mm@kvack.org>; Sat, 20 Aug 2016 00:55:09 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0203.hostedemail.com. [216.40.44.203])
        by mx.google.com with ESMTPS id 70si7974626itz.31.2016.08.20.00.55.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Aug 2016 00:55:08 -0700 (PDT)
Message-ID: <1471679705.4036.2.camel@perches.com>
Subject: Re: [PATCH 0/2] fs, proc: optimize smaps output formatting
From: Joe Perches <joe@perches.com>
Date: Sat, 20 Aug 2016 00:55:05 -0700
In-Reply-To: <20160820072927.GA23645@dhcp22.suse.cz>
References: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
	 <1471601580-17999-1-git-send-email-mhocko@kernel.org>
	 <1471628595.3893.23.camel@perches.com>
	 <20160820072927.GA23645@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jann Horn <jann@thejh.net>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sat, 2016-08-20 at 09:29 +0200, Michal Hocko wrote:
> On Fri 19-08-16 10:43:15, Joe Perches wrote:
> > 
> > On Fri, 2016-08-19 at 12:12 +0200, Michal Hocko wrote:
> > > 
> > > Hi,
> > > this is rebased on top of next-20160818. Joe has pointed out that
> > > meminfo is using a similar trick so I have extracted guts of what we
> > > have already and made it more generic to be usable for smaps as well
> > > (patch 1). The second patch then replaces seq_printf with seq_write
> > > and show_val_kb which should have smaller overhead and my measuring (in
> > > kvm) shows quite a nice improvements. I hope kvm is not playing tricks
> > > on me but I didn't get to test on a real HW.
> > 
> > Hi Michal.
> > 
> > A few comments:
> > 
> > For the first patch:
> > 
> > I think this isn't worth the expansion in object size (x86-64 defconfig)
> > 
> > $ size fs/proc/meminfo.o*
> >    text	   data	    bss	    dec	    hex	filename
> >    2698	      8	      0	   2706	    a92	fs/proc/meminfo.o.new
> >    2142	      8	      0	   2150	    866	fs/proc/meminfo.o.old
> > 
> > Creating a new static in task_mmu would be smaller and faster code.
> Hmm, nasty...
> add/remove: 0/0 grow/shrink: 2/1 up/down: 1081/-24 (1057)
> function                                     old     new   delta
> meminfo_proc_show                           1134    1745    +611
> show_smap                                    560    1030    +470
> show_val_kb                                  140     116     -24
> Total: Before=91716, After=92773, chg +1.15%
> 
> it seems to be calls to seq_write which blown up the size. So I've tried
> to put seq_write back to show_val_kb and did only sizeof() inside those
> macros and that reduced the size but not fully back to the original code
> size. So it seems the value shifts consumed some portion of that as well.
> I've ended up with the following incremental diff which leads to
>    text    data     bss     dec     hex filename
>  100728    1443     400  102571   190ab fs/proc/built-in.o.next
>  101658    1443     400  103501   1944d fs/proc/built-in.o.patched
>  100951    1443     400  102794   1918a fs/proc/built-in.o.incremental
> 
> There is still some increase wrt. the baseline but I guess that can be
> explained by single seq_printf -> many show_name_val_kb calls.
> 
> If that looks acceptable I will respin both patches. I would really
> like to prefer to not duplicate show_val_kb into task_mmu as much as
> possible, though.

I think the patch set I'll send you in a few minutes
will speed up /proc/<pid>/smaps a whole lot more.

Please test it using your little test bench.

cheers, Joe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
