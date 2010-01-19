Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F1D6D6001DA
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 02:52:14 -0500 (EST)
Date: Tue, 19 Jan 2010 09:52:05 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
Message-ID: <20100119075205.GI14345@redhat.com>
References: <20100118133755.GG30698@redhat.com>
 <84144f021001180609r4d7fbbd0p972d5bc0e227d09a@mail.gmail.com>
 <20100118141938.GI30698@redhat.com>
 <84144f021001180805q4d1203b8qab8ccb1de87b2866@mail.gmail.com>
 <20100118170816.GA22111@redhat.com>
 <84144f021001181009m52f7eaebp2bd746f92de08da9@mail.gmail.com>
 <20100118181942.GD22111@redhat.com>
 <20100118191031.0088f49a@lxorguk.ukuu.org.uk>
 <20100119071734.GG14345@redhat.com>
 <84144f021001182337o274c8ed3q8ce60581094bc2b9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f021001182337o274c8ed3q8ce60581094bc2b9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 19, 2010 at 09:37:05AM +0200, Pekka Enberg wrote:
> Hi Gleb,
> 
> On Tue, Jan 19, 2010 at 9:17 AM, Gleb Natapov <gleb@redhat.com> wrote:
> > The thread took a direction of bashing mlockall(). This is especially
> > strange since proposed patch actually makes mlockall() more fine
> > grained and thus more useful.
> 
> No, the thread took a direction of you not being able to properly
> explain why we want MMAP_UNLOCKED in the kernel. It seems useless for
It is needed in the kernel because this is the only proper (aka thread
safe) way to mmap area bigger the main memory after mlockall(MCL_FUTURE).
Do you agree we that? Now you can ask why is this needed and this is
valid question.

> real-time and I've yet to figure out why you need _mlockall()_ if it's
> a performance thing.
I don't do real-time so will not argue how useful it is for that,
but it seems to me that people who argue that it is not useful for real
time don't do it either and the only person in this thread who does real
time uses mlockall(). Hmm strange.

In my case (virtualization) I want to test/profile guest under heavy swapping
of a guests memory, so I intentionally create memory shortage by creating
guest much large then host memory, but I want system to swap out only
guest's memory.

> 
> It would be probably useful if you could point us to the application
> source code that actually wants this feature.
> 
This is two line patch to qemu that calls mlockall(MCL_CURRENT|MCL_FUTURE)
at the beginning of the main() and changes guest memory allocation to
use MAP_UNLOCKED flag. All alternative solutions in this thread suggest
that I should rewrite qemu + all library it uses. You see why I can't
take them seriously?

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
