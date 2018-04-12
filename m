Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D25A6B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 13:28:35 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 35-v6so140244pla.18
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 10:28:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d25-v6si3711427plj.13.2018.04.12.10.28.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Apr 2018 10:28:34 -0700 (PDT)
Date: Thu, 12 Apr 2018 10:28:32 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Bug 198497] New: handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
Message-ID: <20180412172832.GC24728@bombadil.infradead.org>
References: <20180119030447.GA26245@bombadil.infradead.org>
 <d38ff996-8294-81a6-075f-d7b2a60aa2f4@rimuhosting.com>
 <20180119132145.GB2897@bombadil.infradead.org>
 <9d2ddba4-3fb3-0fb4-a058-f2cfd1b05538@redhat.com>
 <32ab6fd6-e3c6-9489-8163-aa73861aa71a@rimuhosting.com>
 <20180126194058.GA31600@bombadil.infradead.org>
 <9ff38687-edde-6b4e-4532-9c150f8ea647@rimuhosting.com>
 <20180131105456.GC28275@bombadil.infradead.org>
 <20180209144726.GD16666@bombadil.infradead.org>
 <20180412101209.311c5ee1759449877b233183@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180412101209.311c5ee1759449877b233183@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: xen@randonwebstuff.com, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

On Thu, Apr 12, 2018 at 10:12:09AM -0700, Andrew Morton wrote:
> On Fri, 9 Feb 2018 06:47:26 -0800 Matthew Wilcox <willy@infradead.org> wrote:
> 
> > 
> > ping?
> > 
> 
> There have been a bunch of updates to this issue in bugzilla
> (https://bugzilla.kernel.org/show_bug.cgi?id=198497).  Sigh, I don't
> know what to do about this - maybe there's some way of getting bugzilla
> to echo everything to linux-mm or something.
> 
> Anyway, please take a look - we appear to have a bug here.  Perhaps
> this bug is sufficiently gnarly for you to prepare a debugging patch
> which we can add to the mainline kernel so we get (much) more debugging
> info when people hit it?

I have a few thoughts ...

 - The debugging patch I prepared appears to be doing its job well.
   People get the message and their machine stays working.
 - The commonality appears to be Xen running 32-bit kernels.  Maybe we
   can kick the problem over to them to solve?
 - If we are seeing corruption purely in the lower bits, *we'll never
   know*.  The radix tree lookup will simply not find anything, and all
   will be well.  That said, the bad PTE values reported in that bug have
   the NX bit and one other bit set; generally bit 32, 33 or 34.  I have
   an idea for adding a parity bit, but haven't had time to implement it.
   Anyone have an intern who wants an interesting kernel project to work on?

Given that this is happening on Xen, I wonder if Xen is using some of the
bits in the page table for its own purposes.
