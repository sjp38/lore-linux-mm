Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id DD2CE800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 09:21:26 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id k14so3796666wgh.1
        for <linux-mm@kvack.org>; Fri, 07 Nov 2014 06:21:24 -0800 (PST)
Subject: Re: [fuse-devel] [PATCH v5 7/7] add a flag for per-operation
	O_DSYNC semantics
From: Roger Willcocks <roger@filmlight.ltd.uk>
In-Reply-To: <B92AEADD-B22C-4A4A-B64D-96E8869D3282@cam.ac.uk>
References: <cover.1415220890.git.milosz@adfin.com>
	 <c188b04ede700ce5f986b19de12fa617d158540f.1415220890.git.milosz@adfin.com>
	 <x49r3xf28qn.fsf@segfault.boston.devel.redhat.com>
	 <BF30FAEC-D4D3-4079-9ECD-2743747279BD@cam.ac.uk>
	 <CAFboF2y2skt=H4crv54shfnXOmz23W-shYWtHWekK8ZUDkfP=A@mail.gmail.com>
	 <B92AEADD-B22C-4A4A-B64D-96E8869D3282@cam.ac.uk>
Content-Type: text/plain
Date: Fri, 07 Nov 2014 14:21:18 +0000
Message-Id: <1415370078.11083.511.camel@montana.filmlight.ltd.uk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Altaparmakov <aia21@cam.ac.uk>
Cc: Anand Avati <avati@gluster.org>, linux-arch@vger.kernel.org, linux-aio@kvack.org, linux-nfs@vger.kernel.org, Volker Lendecke <Volker.Lendecke@sernet.de>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mgorman@suse.de>, "fuse-devel@lists.sourceforge.net" <fuse-devel@lists.sourceforge.net>, linux-api@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, ceph-devel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com, Milosz Tanski <milosz@adfin.com>


On Fri, 2014-11-07 at 08:43 +0200, Anton Altaparmakov wrote:
> Hi,
> 
> > On 7 Nov 2014, at 07:52, Anand Avati <avati@gluster.org> wrote:
> > On Thu, Nov 6, 2014 at 8:22 PM, Anton Altaparmakov <aia21@cam.ac.uk> wrote:
> > > On 7 Nov 2014, at 01:46, Jeff Moyer <jmoyer@redhat.com> wrote:
> > > Minor nit, but I'd rather read something that looks like this:
> > >
> > >       if (type == READ && (flags & RWF_NONBLOCK))
> > >               return -EAGAIN;
> > >       else if (type == WRITE && (flags & RWF_DSYNC))
> > >               return -EINVAL;
> > 
> > But your version is less logically efficient for the case where "type == READ" is true and "flags & RWF_NONBLOCK" is false because your version then has to do the "if (type == WRITE" check before discovering it does not need to take that branch either, whilst the original version does not have to do such a test at all.
> > 
> > Seriously?
> 
> Of course seriously.
> 
> > Just focus on the code readability/maintainability which makes the code most easily understood/obvious to a new pair of eyes, and leave such micro-optimizations to the compiler..
> 
> The original version is more readable (IMO) and this is not a micro-optimization.  It is people like you who are responsible for the fact that we need faster and faster computers to cope with the inefficient/poor code being written more and more...
> 

Your original version needs me to know that type can only be either READ
or WRITE (and not, for instance, READONLY or READWRITE or some other
random special case) and it rings alarm bells when I first see it. If
you want to keep the micro optimization, you need an assertion to
acknowledge the potential bug and a comment to make the code obvious:

 +            assert(type == READ || type == WRITE);
 +            if (type == READ) {
 +                    if (flags & RWF_NONBLOCK)
 +                            return -EAGAIN;
 +            } else { /* WRITE */
 +                    if (flags & RWF_DSYNC)
 +                            return -EINVAL;
 +            }

but since what's really happening here is two separate and independent
error checks, Jeff's version is still better, even if it does take an
extra couple of nanoseconds.

Actually I'd probably write:

       if (type == READ && (flags & RWF_NONBLOCK))
              return -EAGAIN;

       if (type == WRITE && (flags & RWF_DSYNC))
              return -EINVAL;

(no 'else' since the code will never be reached if the first test is
true).


-- 
Roger Willcocks <roger@filmlight.ltd.uk>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
