Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 619EF6B0062
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 05:29:23 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so11774758pbb.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2012 02:29:22 -0700 (PDT)
Date: Mon, 16 Jul 2012 02:28:39 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/3] tmpfs: revert SEEK_DATA and SEEK_HOLE
In-Reply-To: <4FFE42B6.5080705@oracle.com>
Message-ID: <alpine.LSU.2.00.1207160206460.4082@eggly.anvils>
References: <alpine.LSU.2.00.1207091533001.2051@eggly.anvils> <alpine.LSU.2.00.1207091535480.2051@eggly.anvils> <jtj574$tb7$2@dough.gmane.org> <alpine.LSU.2.00.1207111149580.1797@eggly.anvils> <20120711230122.GZ19223@dastard> <4FFE42B6.5080705@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: Dave Chinner <david@fromorbit.com>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 12 Jul 2012, Jeff Liu wrote:
> On 07/12/2012 07:01 AM, Dave Chinner wrote:
> > On Wed, Jul 11, 2012 at 11:55:34AM -0700, Hugh Dickins wrote:
> >>
> >> But your vote would count for a lot more if you know of some app which
> >> would really benefit from this functionality in tmpfs: I've heard of none.
> > 
> > So what? I've heard of no apps that use this functionality on XFS,
> > either, but I have heard of a lot of people asking for it to be
> > implemented over the past couple of years so they can use it.
> > There's been patches written to make coreutils (cp) make use of it
> > instead of parsing FIEMAP output to find holes, though I don't know
> > if that's gone beyond more than "here's some patches"...
> 
> Yes, for apps, cp(1) will make use of it to replace the old FIEMAP for efficient sparse file copy.
> I have implemented an extent-scan module to coreutils a few years ago,
> http://fossies.org/dox/coreutils-8.17/extent-scan_8c_source.html

Thanks for confirming Dave's pointer to cp.

Of course, tmpfs has never supported FIBMAP or FIEMAP;
but SEEK_DATA and SEEK_HOLE do fit it much more naturally.

> 
> It does extent scan through FIEMAP, however, SEEK_DATA/SEEK_HOLE is more convenient and easy to use
> considering the call interface.  So FIEMAP will be replaced by SEEK_XXX once it got supported by EXT4.
> 
> Moreover, I have discussed with Jim who is the coreutils maintainer previously, He would like to post
> extent-scan module to Gnulib so that other GNU utilities which are relied on Gnulib might be a potential
> user of it, at least, GNU tar will definitely need it for sparse file backup.

Thanks for the info.  I confess I'm not hugely swayed by cp and sparse
file archive arguments - I doubt many people care, and I doubt those who
do care are using tmpfs for them.

But my doubts are just ignorance.  I was hoping to hear, not that we have
tools to copy sparse files efficiently (umm, over the network?), but
what apps are actually working live with those sparse files on tmpfs,
and now need to seek around them.  Some math or physics applications?

> > 
> > Besides, given that you can punch holes in tmpfs files, it seems
> > strange to then say "we don't need a method of skipping holes to
> > find data quickly"....
> 
> So its deserve to keep this feature working on tmpfs considering hole punch. :)

Well, thank you, as I said earlier I am on both sides of the argument.
(And feel uncomfortably like a prima donna waiting in the wings until
the audience has shouted long enough for the encore.)

It's now taken out of 3.5, but we can bring it back when there's more
demand.  Your extent-scan is itself waiting for ext4 to support it:
maybe get noisy at me when that's imminent.

Hugh

> 
> Thanks,
> -Jeff
> 
> > 
> > Besides, seek-hole/data is still shiny new and lots of developers
> > aren't even aware of it's presence in recent kernels. Removing new
> > functionality saying "no-one is using it" is like smashing the egg
> > before the chicken hatches (or is it cutting of the chickes's head
> > before it lays the egg?).
> > 
> > Cheers,
> > 
> > Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
