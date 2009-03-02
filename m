Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 389B46B0047
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 10:26:26 -0500 (EST)
Message-ID: <49ABFA9D.90801@hp.com>
Date: Mon, 02 Mar 2009 10:26:21 -0500
From: jim owens <jowens@hp.com>
MIME-Version: 1.0
Subject: Re: [patch][rfc] mm: hold page lock over page_mkwrite
References: <20090225093629.GD22785@wotan.suse.de> <20090301081744.GI26138@disturbed> <20090301135057.GA26905@wotan.suse.de> <20090302081953.GK26138@disturbed> <20090302083718.GE1257@wotan.suse.de>
In-Reply-To: <20090302083718.GE1257@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> 
> So assuming there is no reasonable way to do out of core algorithms
> on the filesystem metadata (and likely you don't want to anyway
> because it would be a significant slowdown or diverge of code
> paths), you still only need to reserve one set of those 30-40 pages
> for the entire kernel.
> 
> You only ever need to reserve enough memory for a *single* page
> to be processed. In the worst case that there are multiple pages
> under writeout but can't allocate memory, only one will be allowed
> access to reserves and the others will block until it is finished
> and can unpin them all.

Sure, nobody will mind seeing lots of extra pinned memory ;)

Don't forget to add the space for data transforms and raid
driver operations in the write stack, and whatever else we
may not have thought of.  With good engineering we can make
it so "we can always make forward progress".  But it won't
matter because once a real user drives the system off this
cliff there is no difference between "hung" and "really slow
progress".  They are going to crash it and report a hang.

> Well I'm not saying it is an immediate problem or it would be a
> good use of anybody's time to rush out and try to redesign their
> fs code to fix it ;) But at least for any new core/generic library
> functionality like fsblock, it would be silly not to close the hole
> there (not least because the problem is simpler here than in a
> complex fs).

Hey, I appreciate anything you do in VM to make the ugly
dance with filesystems (my area) a little less ugly.

I'm sure you also appreciate that every time VM tries to
save 32 bytes, someone else tries to take 32 K-bytes.
As they say... memory is cheap :)

jim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
