Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id DAC976B0035
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 01:27:50 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id d7so201118bkh.20
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 22:27:50 -0800 (PST)
Received: from mail-la0-x231.google.com (mail-la0-x231.google.com [2a00:1450:4010:c03::231])
        by mx.google.com with ESMTPS id pj2si8993098bkb.195.2014.01.22.22.27.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 22:27:50 -0800 (PST)
Received: by mail-la0-f49.google.com with SMTP id y1so1096555lam.22
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 22:27:49 -0800 (PST)
Date: Thu, 23 Jan 2014 10:27:46 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [Bug 67651] Bisected: Lots of fragmented mmaps cause gimp to
 fail in 3.12 after exceeding vm_max_map_count
Message-ID: <20140123062746.GT1574@moon>
References: <20140122190816.GB4963@suse.de>
 <52E04A21.3050101@mit.edu>
 <20140123055906.GS1574@moon>
 <20140122220910.198121ee.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140122220910.198121ee.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Mel Gorman <mgorman@suse.de>, Pavel Emelyanov <xemul@parallels.com>, gnome@rvzt.net, drawoc@darkrefraction.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On Wed, Jan 22, 2014 at 10:09:10PM -0800, Andrew Morton wrote:
> > > 
> > > That being said, this could cause vma blowups for programs that are
> > > actually using this thing.
> > 
> > Hi Andy, indeed, this could happen. The easiest way is to ignore softdirty bit
> > when we're trying to merge vmas and set it one new merged. I think this should
> > be correct. Once I finish I'll send the patch.
> 
> Hang on.  We think the problem is that gimp is generating vmas which
> *should* be merged, but for unknown reasons they differ in
> VM_SOFTDIRTY, yes?

Yes. One place where I forgot to set softdirty bit is setup_arg_pages. But
it called once on elf load, so it can't cause such effect (but should be
fixed too). Also there is do_brk where vmasoftdirty is missed too :/

Another problem is the potential scenario when we have a bunch of vmas
and clear vma-softdirty bit on them, then we try to map new one, flags
won't match and instead of extending old vma the new one will be created.
I think (if only I'm not missing something) that vma-softdirty should
be ignored in such case (ie inside is_mergeable_vma) and once vma extended
it should be marked as dirty one. Again, I need to think and test more.

> Shouldn't we work out where we're forgetting to set VM_SOFTDIRTY? 
> Putting bandaids over this error when we come to trying to merge the
> vmas sounds very wrong?

I'm looking into this as well.

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
