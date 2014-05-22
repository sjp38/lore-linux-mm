Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 687CE6B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 22:20:24 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c13so2065763eek.40
        for <linux-mm@kvack.org>; Wed, 21 May 2014 19:20:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id i9si4546358eex.32.2014.05.21.19.20.21
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 19:20:22 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 0/4] pagecache scanning with /proc/kpagecache
Date: Wed, 21 May 2014 22:19:55 -0400
Message-Id: <537d5ee6.893d0f0a.1334.1ee2SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <20140521154250.95bc3520ad8d192d95efe39b@linux-foundation.org>
References: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com> <20140521154250.95bc3520ad8d192d95efe39b@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>

On Wed, May 21, 2014 at 03:42:50PM -0700, Andrew Morton wrote:
> On Tue, 20 May 2014 22:26:30 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > This patchset adds a new procfs interface to extrace information about
> > pagecache status. In-kernel tool tools/vm/page-types.c has already some
> > code for pagecache scanning without kernel's help, but it's not free
> > from measurement-disturbance, so here I'm suggesting another approach.
> 
> I'm not seeing much explanation of why you think the kernel needs this.
> The overall justification for a change is terribly important so please
> do spend some time on it.

OK. Now I'm developing a patchset which improves memory error (and IO error
in next version) reporting on dirty pagecache (to avoid bad-data consumption.)
The essense of this patchset is that we remember error information on page
cache tree and users need to know which page cache is affected by error.
This is the reason why I need this feature.
# I separate this part from memory error reporting patchset and posted at
# first because I noticed Konstantin's patch just a few days ago and I found
# the person who has the same interest of mine :)

I understand adding procfs interface itself needs much care, so I don't
persist in this specific interface if there're better options. Now I'm
reserching other options Konstantin suggesting.

> As I don't *really* know what the patch is for, I can't comment a lot
> further, but...
> 
> 
> A much nicer interface would be for us to (finally!) implement
> fincore(), perhaps with an enhanced per-present-page payload which
> presents the info which you need (although we don't actually know what
> that info is!).

page/pfn of each page slot and its page cache tag as shown in patch 4/4.

> This would require open() - it appears to be a requirement that the
> caller not open the file, but no reason was given for this.
> 
> Requiring open() would address some of the obvious security concerns,
> but it will still be possible for processes to poke around and get some
> understanding of the behaviour of other processes.  Careful attention
> should be paid to this aspect of any such patchset.

Sorry if I missed your point, but this interface defines fixed mapping
between file position in /proc/kpagecache and in-file page offset of
the target file. So we do not need to use seq_file mechanism, that's
why open() is not defined and default one is used.
The same thing is true for /proc/{kpagecount,kpageflags}, from which
I copied/pasted some basic code.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
