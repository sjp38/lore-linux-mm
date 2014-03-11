Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0ECF26B0037
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 22:58:11 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lj1so8132026pab.34
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 19:58:11 -0700 (PDT)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ha5si18666671pbc.60.2014.03.10.19.58.10
        for <linux-mm@kvack.org>;
        Mon, 10 Mar 2014 19:58:11 -0700 (PDT)
Date: Tue, 11 Mar 2014 11:58:11 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: oops in slab/leaks_show
Message-ID: <20140311025811.GA601@lge.com>
References: <20140307025703.GA30770@redhat.com>
 <alpine.DEB.2.10.1403071117230.21846@nuc>
 <20140311003459.GA25657@lge.com>
 <20140311010135.GA25845@lge.com>
 <20140311012455.GA5151@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140311012455.GA5151@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Al Viro <viro@zeniv.linux.org.uk>

On Mon, Mar 10, 2014 at 09:24:55PM -0400, Dave Jones wrote:
> On Tue, Mar 11, 2014 at 10:01:35AM +0900, Joonsoo Kim wrote:
>  > On Tue, Mar 11, 2014 at 09:35:00AM +0900, Joonsoo Kim wrote:
>  > > On Fri, Mar 07, 2014 at 11:18:30AM -0600, Christoph Lameter wrote:
>  > > > Joonsoo recently changed the handling of the freelist in SLAB. CCing him.
>  > > > 
>  > > > > I pretty much always use SLUB for my fuzzing boxes, but thought I'd give SLAB a try
>  > > > > for a change.. It blew up when something tried to read /proc/slab_allocators
>  > > > > (Just cat it, and you should see the oops below)
>  > > 
>  > > Hello, Dave.
>  > > 
>  > > Today, I did a test on v3.13 which contains all my changes on the handling of
>  > > the freelist in SLAB and couldn't trigger oops by just 'cat /proc/slab_allocators'.
>  > > 
>  > > So I look at the code and find that there is race window if there is multiple users
>  > > doing 'cat /proc/slab_allocators'. Did your test do that?
>  > 
>  > Opps, sorry. I am misunderstanding something. Maybe there is no race.
>  > Anyway, How do you test it?
> 
> 1. build kernel with CONFIG_SLAB=y.
> 2. boot kernel
> 3. cat /proc/slab_allocators

Okay. I reproduce it with CONFIG_DEBUG_PAGEALLOC=y.

I look at the code and find that the problem doesn't come from my patches.
I think that it is long-lived bug. Let me explain it.

'cat /proc/slab_allocators' checks all allocated objects for all slabs.
The problem is that it considers objects in cpu slab caches as allocated objects.
These objects in cpu slab caches are unmapped if CONFIG_DEBUG_PAGEALLOC=y, so when we
try to access it to get the caller information, oops would be triggered.

I will think more deeply how to fix this problem.
If I am missing something, please let me know.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
