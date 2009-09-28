Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6D7396B0055
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 17:14:37 -0400 (EDT)
Date: Mon, 28 Sep 2009 22:21:27 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: No more bits in vm_area_struct's vm_flags.
In-Reply-To: <4AC03D9C.3020907@crca.org.au>
Message-ID: <Pine.LNX.4.64.0909282200470.11529@sister.anvils>
References: <4AB9A0D6.1090004@crca.org.au> <20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com>
 <4ABC80B0.5010100@crca.org.au> <20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com>
 <4AC0234F.2080808@crca.org.au> <20090928120450.c2d8a4e2.kamezawa.hiroyu@jp.fujitsu.com>
 <20090928033624.GA11191@localhost> <20090928125705.6656e8c5.kamezawa.hiroyu@jp.fujitsu.com>
 <4AC03D9C.3020907@crca.org.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Sep 2009, Nigel Cunningham wrote:
> KAMEZAWA Hiroyuki wrote:
> > Then, Nigel, you have 2 choices I think.
> > 
> > (1) don't merge if vm_hints is set  or (2) pass vm_hints to all
> > __merge() functions.
> > 
> > One of above will be accesptable for stakeholders... I personally
> > like (1) but just trying (2) may be accepted.
> > 
> > What I dislike is making vm_flags to be long long ;)
> 
> Okay. I've gone for option 1 for now.

Arbitrary limitation, but not important at this stage.

> Here's what I currently have (compile testing as I write)...
> 
> 
> 
> vm_flags in struct vm_area_struct is full. Move some of the less commonly
> used flags to a new variable so that other flags that need to be in vm_flags
> (because, for example, they need to be in variables that are passed around)
> can be added.
> 
> Signed-off-by: Nigel Cunningham <nigel@tuxonice.net>

This is quite a small patch (much smaller than my unsigned long long
one, not that I've completed or posted that yet); but I'm afraid that
I do not like it.

First off, do you realize that unsigned long vm_hints adds a pointless
8 bytes to every vm_area_struct on 64-bit systems?  Pointless because
there was already space for the flags you've moved in 64-bit vm_flags.

You might eliminate the bloat by making it an unsigned int or unsigned
char and squeezing it into a gap between other fields; but it still
seems silly to separate them.

I agree that VM_SEQ_READ and VM_RAND_READ are low hanging fruit,
in that they stand out as odd, partly because of the CamelCase
macros which hide them from sight.  But many others of the flags
are their own peculiar cases too.

I don't think there's a great queue of people wanting to add more
read hints: nobody would be more likely to do so than Fengguang,
and even he worries about "vm_hints" limiting its scope.

If you're looking to make more flagspace available, then it would
need to accomodate motley other flags too, so should be called...
vm_flags2?  shudder!

Were it not for the bloat, I wouldn't hesitate over unsigned long long.

As it is, I think that (as I said before) we should first look to see
if we can cull just a few of the flags which have accumulated.  Then
move on to unsigned long long when we have to.

I suggested before that for the moment you reuse VM_MAPPED_COPY,
and you said "Okee doke".  What changed?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
