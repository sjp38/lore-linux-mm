Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id KAA25534
	for <linux-mm@kvack.org>; Fri, 15 Nov 2002 10:05:18 -0800 (PST)
Message-ID: <3DD5375D.96736A69@digeo.com>
Date: Fri, 15 Nov 2002 10:05:17 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [patch/2.4] ll_rw_blk stomping on bh state [Re: kernel BUG at
 journal.c:1732! (2.4.19)]
References: <20021028111357.78197071.nutts@penguinmail.com> <20021112150711.F2837@redhat.com> <3DD140F1.F4AED387@digeo.com> <20021112185345.H2837@redhat.com> <20021115173858.S4512@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Mark Hazell <nutts@penguinmail.com>, adilger@clusterfs.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Tue, Nov 12, 2002 at 06:53:45PM +0000, Stephen C. Tweedie wrote:
> 
> > On Tue, Nov 12, 2002 at 09:57:05AM -0800, Andrew Morton wrote:
> > > "Stephen C. Tweedie" wrote:
> > > >
> > > >                 if (maxsector < count || maxsector - count < sector) {
> > > >                         /* Yecch */
> > > >                         bh->b_state &= (1 << BH_Lock) | (1 << BH_Mapped);
> > > > ...
> > > > Folks, just which buffer flags do we want to preserve in this case?
> >
> > > Why do we want to clear any flags in there at all?  To prevent
> > > a storm of error messages from a buffer which has a silly block
> > > number?
> >
> > That's the only reason I can think of.  Simply scrubbing all the state
> > bits is totally the wrong way of going about that, of course.
> 
> So what's the vote on this?  It's a decision between clearing only the
> obvious bit (BH_Dirty) on the one hand, and keeping the code as
> unchanged as possible to reduce the possibility of introducing new
> bugs.
> 
> But frankly I can't see any convincing argument for clearing anything
> except the dirty state in this case.
> 

I'd agree with that.  And the dirty bit will already be cleared, won't it?

Maybe just treat it as an IO error and leave it at that; surely that won't
introduce any problems, given all the testing that has gone into the
error handling paths :)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
