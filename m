Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4DB6B0071
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 04:30:12 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so8490233pbb.31
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 01:30:10 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id qy5si19410371pab.311.2014.03.11.01.30.08
        for <linux-mm@kvack.org>;
        Tue, 11 Mar 2014 01:30:10 -0700 (PDT)
Date: Tue, 11 Mar 2014 17:30:09 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: oops in slab/leaks_show
Message-ID: <20140311083009.GA32004@lge.com>
References: <20140307025703.GA30770@redhat.com>
 <alpine.DEB.2.10.1403071117230.21846@nuc>
 <20140311003459.GA25657@lge.com>
 <20140311010135.GA25845@lge.com>
 <20140311012455.GA5151@redhat.com>
 <20140311025811.GA601@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140311025811.GA601@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Al Viro <viro@zeniv.linux.org.uk>

On Tue, Mar 11, 2014 at 11:58:11AM +0900, Joonsoo Kim wrote:
> On Mon, Mar 10, 2014 at 09:24:55PM -0400, Dave Jones wrote:
> > On Tue, Mar 11, 2014 at 10:01:35AM +0900, Joonsoo Kim wrote:
> >  > On Tue, Mar 11, 2014 at 09:35:00AM +0900, Joonsoo Kim wrote:
> >  > > On Fri, Mar 07, 2014 at 11:18:30AM -0600, Christoph Lameter wrote:
> >  > > > Joonsoo recently changed the handling of the freelist in SLAB. CCing him.
> >  > > > 
> >  > > > > I pretty much always use SLUB for my fuzzing boxes, but thought I'd give SLAB a try
> >  > > > > for a change.. It blew up when something tried to read /proc/slab_allocators
> >  > > > > (Just cat it, and you should see the oops below)
> >  > > 
> >  > > Hello, Dave.
> >  > > 
> >  > > Today, I did a test on v3.13 which contains all my changes on the handling of
> >  > > the freelist in SLAB and couldn't trigger oops by just 'cat /proc/slab_allocators'.
> >  > > 
> >  > > So I look at the code and find that there is race window if there is multiple users
> >  > > doing 'cat /proc/slab_allocators'. Did your test do that?
> >  > 
> >  > Opps, sorry. I am misunderstanding something. Maybe there is no race.
> >  > Anyway, How do you test it?
> > 
> > 1. build kernel with CONFIG_SLAB=y.
> > 2. boot kernel
> > 3. cat /proc/slab_allocators
> 
> Okay. I reproduce it with CONFIG_DEBUG_PAGEALLOC=y.
> 
> I look at the code and find that the problem doesn't come from my patches.
> I think that it is long-lived bug. Let me explain it.
> 
> 'cat /proc/slab_allocators' checks all allocated objects for all slabs.
> The problem is that it considers objects in cpu slab caches as allocated objects.
> These objects in cpu slab caches are unmapped if CONFIG_DEBUG_PAGEALLOC=y, so when we
> try to access it to get the caller information, oops would be triggered.
> 
> I will think more deeply how to fix this problem.
> If I am missing something, please let me know.

Here is the fix for this problem.
Thanks for reporting it.

---------8<---------------------
