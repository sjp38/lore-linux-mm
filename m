Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5863D6B0358
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 10:48:38 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id i6so1001465wre.6
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 07:48:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f8sor349023wmc.37.2018.01.03.07.48.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 07:48:36 -0800 (PST)
Date: Wed, 3 Jan 2018 16:48:33 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
Message-ID: <20180103154833.fhkbwonz6zhm26ax@gmail.com>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com>
 <20180103084600.GA31648@trogon.sfo.coreos.systems>
 <20180103092016.GA23772@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180103092016.GA23772@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Benjamin Gilbert <benjamin.gilbert@coreos.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org


* Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:

> On Wed, Jan 03, 2018 at 12:46:00AM -0800, Benjamin Gilbert wrote:
> > [resending with less web]
> 
> (adding lkml and x86 developers)
> 
> > Hi all,
> > 
> > In our regression tests on kernel 4.14.11, we're occasionally seeing a run
> > of "bad pmd" messages during boot, followed by a "BUG: unable to handle
> > kernel paging request".  This happens on no more than a couple percent of
> > boots, but we've seen it on AWS HVM, GCE, Oracle Cloud VMs, and local QEMU
> > instances.  It always happens immediately after "Loading compiled-in X.509
> > certificates".  I can't reproduce it on 4.14.10, nor, so far, on 4.14.11
> > with pti=off.  Here's a sample backtrace:

A few other things to check:

first please test the latest WIP.x86/pti branch which has a couple of fixes.

In a -stable kernel tree you should be able to do:

  git pull --no-tags git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git WIP.x86/pti

in particular this recent fix from a couple of hours ago might make a difference:

  52994c256df3: x86/pti: Make sure the user/kernel PTEs match

Note that this commit:

  694d99d40972: x86/cpu, x86/pti: Do not enable PTI on AMD processors

disables PTI on AMD CPUs - so if you'd like to test it more broadly on all CPUs 
then you'll need to add "pti=on" to your boot commandline.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
