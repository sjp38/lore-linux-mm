Date: Tue, 12 Nov 2002 18:53:45 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [patch/2.4] ll_rw_blk stomping on bh state [Re: kernel BUG at journal.c:1732! (2.4.19)]
Message-ID: <20021112185345.H2837@redhat.com>
References: <20021028111357.78197071.nutts@penguinmail.com> <20021112150711.F2837@redhat.com> <3DD140F1.F4AED387@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DD140F1.F4AED387@digeo.com>; from akpm@digeo.com on Tue, Nov 12, 2002 at 09:57:05AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Mark Hazell <nutts@penguinmail.com>, adilger@clusterfs.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Nov 12, 2002 at 09:57:05AM -0800, Andrew Morton wrote:
> "Stephen C. Tweedie" wrote:
> > 
> >                 if (maxsector < count || maxsector - count < sector) {
> >                         /* Yecch */
> >                         bh->b_state &= (1 << BH_Lock) | (1 << BH_Mapped);
> > ...
> > Folks, just which buffer flags do we want to preserve in this case?

> Why do we want to clear any flags in there at all?  To prevent
> a storm of error messages from a buffer which has a silly block
> number?

That's the only reason I can think of.  Simply scrubbing all the state
bits is totally the wrong way of going about that, of course.
 
> If so, how about setting a new state bit which causes subsequent
> IO attempts to silently drop the IO on the floor?

The only problem I could think of there would be weird interactions
with LVM if somebody lvextends a volume and the buffer suddenly
becomes valid again.  I can't bring myself to care about breaking that
situation. :-)

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
