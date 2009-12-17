Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 60ABE6B008C
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 07:33:48 -0500 (EST)
Date: Thu, 17 Dec 2009 14:33:37 +0200
From: Izik Eidus <ieidus@redhat.com>
Subject: Re: RFC: change swap_map to be 32bits varible instead of 16
Message-ID: <20091217143337.06de62fa@redhat.com>
In-Reply-To: <Pine.LNX.4.64.0912162232520.24424@sister.anvils>
References: <20091216210432.33de4e98@redhat.com>
	<Pine.LNX.4.64.0912162232520.24424@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Dec 2009 23:00:48 +0000 (GMT)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> Hi Izik,
> 
> On Wed, 16 Dec 2009, Izik Eidus wrote:
> > 
> > When i backported Hugh patches into the rhel6 kernel today, I
> > noticed during my testing that at very high load of swap tests i
> > get the following error:
> > 
> > 
> > Dec 16 17:06:25 dhcp-1-211 kernel: swap_dup: swap entry overflow
> > Dec 16 17:06:25 dhcp-1-211 kernel: swap_dup: swap entry overflow
> > Dec 16 17:06:25 dhcp-1-211 kernel: swap_dup: swap entry overflow
> > Dec 16 17:06:25 dhcp-1-211 kernel: swap_dup: swap entry overflow
> > 
> > 
> > The problem probably happen due to the swap_map limitation of being
> > able to address just ~128mb of memory, and with the zero_page mapped
> > when using ksm much more than this amount of memory it was triggered
> > 
> > There may be many soultions to this problem, and I send for RFC the
> > easiest one (just increase the map_count to be unsiged int and allow
> > ~8terabyte of memory)
> 
> The problem here is that you've backported too little: there's a group
> of 9 "swap_info" patches, before the "mm" patches which prepare for
> ksm swapping, and the "ksm" swapping patches themselves.

Ok, that expline.

> 
> I did include the swap_info patches in the latter rollup I sent you
> privately, and did highlight this issue when I sent an earlier rollup:
> it was an amusing surprise to me that KSM suddenly required our years
> old bad assumptions in swapoff to be fixed in a hurry.
> 
> But I didn't Cc you on them when I sent to Andrew, mistakenly thinking
> that they weren't "KSM enough" to be of interest you - I hadn't
> realized that you were planning a backport, sorry.

Yes I have backported by mails I got from the final summbit...

> 
> Maybe you should also include the set of patches which reintroduce the
> zero page (which won't be swapped and won't be inspected by KSM, being
> not PageAnon); but that wouldn't be sufficient in itself, since I
> found it very easy for KSM to overflow the unsigned short *swap_map
> even with non-zero pages.
> 
> Or, dare I say it, maybe you should just use 2.6.33?

Not think is possible (Rhel 6 schdule...) :)

> 
> The patch you sent as RFC, changing from unsigned short to unsigned
> int *swap_map: that may be sufficient - I admit it's a very much
> smaller patch than my lot - I'm not certain.  But it's not the way I
> wanted mainline to go, since most people will never use more than one
> byte of your 32-bit swap map elements, and vmalloc space may be at a
> premium on 32-bit architectures.


No problem, I will just backport your patch`s, no point in making rhel
6 bheave diffrently than what in mainline...

Thanks.

> 
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
