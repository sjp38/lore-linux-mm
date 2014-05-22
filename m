Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 131316B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 22:34:15 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id um1so2007287pbc.18
        for <linux-mm@kvack.org>; Wed, 21 May 2014 19:34:14 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id qf10si8602207pbb.86.2014.05.21.19.34.13
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 19:34:14 -0700 (PDT)
Date: Wed, 21 May 2014 19:33:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/4] pagecache scanning with /proc/kpagecache
Message-Id: <20140521193336.5df90456.akpm@linux-foundation.org>
In-Reply-To: <537d5ee4.4914e00a.5672.ffff85d5SMTPIN_ADDED_BROKEN@mx.google.com>
References: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20140521154250.95bc3520ad8d192d95efe39b@linux-foundation.org>
	<537d5ee4.4914e00a.5672.ffff85d5SMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>

On Wed, 21 May 2014 22:19:55 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> > A much nicer interface would be for us to (finally!) implement
> > fincore(), perhaps with an enhanced per-present-page payload which
> > presents the info which you need (although we don't actually know what
> > that info is!).
> 
> page/pfn of each page slot and its page cache tag as shown in patch 4/4.
> 
> > This would require open() - it appears to be a requirement that the
> > caller not open the file, but no reason was given for this.
> > 
> > Requiring open() would address some of the obvious security concerns,
> > but it will still be possible for processes to poke around and get some
> > understanding of the behaviour of other processes.  Careful attention
> > should be paid to this aspect of any such patchset.
> 
> Sorry if I missed your point, but this interface defines fixed mapping
> between file position in /proc/kpagecache and in-file page offset of
> the target file. So we do not need to use seq_file mechanism, that's
> why open() is not defined and default one is used.
> The same thing is true for /proc/{kpagecount,kpageflags}, from which
> I copied/pasted some basic code.

I think you did miss my point ;) Please do a web search for fincore -
it's a syscall similar to mincore(), only it queries pagecache:
fincore(int fd, loff_t offset, ...).  In its simplest form it queries
just for present/absent, but we could increase the query payload to
incorporate additional per-page info.

It would take a lot of thought and discussion to nail down the
fincore() interface (we've already tried a couple of times).  But
unfortunately, fincore() is probably going to be implemented one day
and it will (or at least could) make /proc/kpagecache obsolete.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
