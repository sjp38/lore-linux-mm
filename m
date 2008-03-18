Received: by rv-out-0910.google.com with SMTP id f1so3191942rvb.26
        for <linux-mm@kvack.org>; Tue, 18 Mar 2008 10:51:52 -0700 (PDT)
Message-ID: <84144f020803181051m1b1cb3bdgc254714c64c8ee7a@mail.gmail.com>
Date: Tue, 18 Mar 2008 19:51:52 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
In-Reply-To: <Pine.LNX.4.64.0803181043390.21992@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200803061447.05797.Jens.Osterkamp@gmx.de>
	 <200803121619.45708.Jens.Osterkamp@gmx.de>
	 <Pine.LNX.4.64.0803121630110.10488@schroedinger.engr.sgi.com>
	 <200803181744.58735.Jens.Osterkamp@gmx.de>
	 <Pine.LNX.4.64.0803181043390.21992@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Jens Osterkamp <Jens.Osterkamp@gmx.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008, Jens Osterkamp wrote:
>  > Actually the caller expects exactly that. The kmalloc that I saw was coming
>  > from alloc_thread_info in dup_task_struct. For 4k pages this maps to
>  > __get_free_pages whereas for 64k pages it maps to kmalloc.
>  > The result of __get_free_pages seem to be aligned and kmalloc (with slub_debug)
>  > of course not. That explains the 4k/64k difference and the crash I am seeing...
>  > but I can't think of a reasonable fix right now as I don't understand the
>  > reason for the difference in the allocation code (yet).

On Tue, Mar 18, 2008 at 7:45 PM, Christoph Lameter <clameter@sgi.com> wrote:
>  One simple solution is to create a special slab and specify the alignment
>  you want. The other is to use the page allocator which also gives you
>  guaranteed alignment.

Btw, there are other architectures that use kmalloc() for
alloc_thread_info() which need to be fixed as well. Using the page
allocator directly is probably the best solution here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
