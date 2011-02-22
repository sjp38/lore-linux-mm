Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E1CEC8D003C
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 18:48:37 -0500 (EST)
Date: Wed, 23 Feb 2011 00:48:33 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH 3/5] page_cgroup: make page tracking available for blkio
Message-ID: <20110222234833.GG23723@linux.develer.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
 <1298394776-9957-4-git-send-email-arighi@develer.com>
 <20110222130145.37cb151e@bike.lwn.net>
 <20110222230146.GB23723@linux.develer.com>
 <20110222162729.054fe596@bike.lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110222162729.054fe596@bike.lwn.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Vivek Goyal <vgoyal@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Gui Jianfeng <guijianfeng@cn.fujitsu.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 22, 2011 at 04:27:29PM -0700, Jonathan Corbet wrote:
> On Wed, 23 Feb 2011 00:01:47 +0100
> Andrea Righi <arighi@develer.com> wrote:
> 
> > > My immediate observation is that you're not really tracking the "owner"
> > > here - you're tracking an opaque 16-bit token known only to the block
> > > controller in a field which - if changed by anybody other than the block
> > > controller - will lead to mayhem in the block controller.  I think it
> > > might be clearer - and safer - to say "blkcg" or some such instead of
> > > "owner" here.
> > 
> > Basically the idea here was to be as generic as possible and make this
> > feature potentially available also to other subsystems, so that cgroup
> > subsystems may represent whatever they want with the 16-bit token.
> > However, no more than a single subsystem may be able to use this feature
> > at the same time.
> 
> That makes me nervous; it can't really be used that way unless we want to
> say that certain controllers are fundamentally incompatible and can't be
> allowed to play together.  For whatever my $0.02 are worth (given the
> state of the US dollar, that's not a whole lot), I'd suggest keeping the
> current mechanism, but make it clear that it belongs to your controller.
> If and when another controller comes along with a need for similar
> functionality, somebody can worry about making it more general.

OK, I understand. I'll use "blkio" instead of "owner". Also because I
wouldn't like to introduce additional logic and overhead to check if two
controllers are using this feature at the same time. Better to hard-code
this information in the name of the functions.

Probably the most generic solution is the one that you suggested:
replace the mem_cgroup with a pointer to css_set. I'll also try to
investigate this way.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
