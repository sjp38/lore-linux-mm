Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id D2BEB6B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 16:58:23 -0400 (EDT)
Message-ID: <1366664301.9609.140.camel@gandalf.local.home>
Subject: Re: [PATCH] slab: Remove unnecessary __builtin_constant_p()
From: Steven Rostedt <rostedt@goodmis.org>
Date: Mon, 22 Apr 2013 16:58:21 -0400
In-Reply-To: <20130422134415.32c7f2cac07c924bff3017a4@linux-foundation.org>
References: <1366225776.8817.28.camel@pippen.local.home>
	 <alpine.DEB.2.02.1304171702380.24494@chino.kir.corp.google.com>
	 <20130422134415.32c7f2cac07c924bff3017a4@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Behan Webster <behanw@converseincode.com>

On Mon, 2013-04-22 at 13:44 -0700, Andrew Morton wrote:
> On Wed, 17 Apr 2013 17:03:21 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
> > On Wed, 17 Apr 2013, Steven Rostedt wrote:
> > 
> > > The slab.c code has a size check macro that checks the size of the
> > > following structs:
> > > 
> > > struct arraycache_init
> > > struct kmem_list3
> > > 
> > > The index_of() function that takes the sizeof() of the above two structs
> > > and does an unnecessary __builtin_constant_p() on that. As sizeof() will
> > > always end up being a constant making this always be true. The code is
> > > not incorrect, but it just adds added complexity, and confuses users and
> > > wastes the time of reviewers of the code, who spends time trying to
> > > figure out why the builtin_constant_p() was used.
> > > 
> > > This patch is just a clean up that makes the index_of() code a little
> > > bit less complex.
> > > 
> > > Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
> > 
> > Acked-by: David Rientjes <rientjes@google.com>
> > 
> > Adding Pekka to the cc.
> 
> I ducked this patch because it seemed rather pointless - but a little
> birdie told me that there is a secret motivation which seems pretty
> reasonable to me.  So I shall await chirp-the-second, which hopefully
> will have a fuller and franker changelog ;)

<little birdie voice>
The real motivation behind this patch was it prevents LLVM (Clang) from
compiling the kernel. There's currently a bug in Clang where it can't
determine if a variable is constant or not, so instead, when
__builtin_constant_p() is used, it just treats it like it isn't a
constant (always taking the slow *safe* path).

Unfortunately, the "confusing" code of slub.c that unnecessarily uses
the __builtin_constant_p() will fail to compile if the variable passed
in is not constant. As Clang will say constants are not constant at this
point, the compile fails.

When looking into this, we found the only two users of the index_of()
static function that has this issue, passes in size_of(), which will
always be a constant, making the check redundant.

Note, this is a bug in Clang that will hopefully be fixed soon. But for
now, this strange redundant compile time check is preventing Clang from
even testing the Linux kernel build.
</little birdie voice>

And I still think the original change log has rational for the change,
as it does make it rather confusing to what is happening there.

-- Steve



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
