Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 44B178D0048
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 12:16:00 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p11CuSvh031905
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 07:58:08 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id D460E728084
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 12:15:50 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p11HFoV1138356
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 12:15:50 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p11HFoCf029581
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 12:15:50 -0500
Subject: Re: [RFC][PATCH 0/6] more detailed per-process transparent
 hugepage statistics
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110201153857.GA18740@random.random>
References: <20110201003357.D6F0BE0D@kernel>
	 <20110201153857.GA18740@random.random>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 01 Feb 2011 09:15:47 -0800
Message-ID: <1296580547.27022.3370.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2011-02-01 at 16:38 +0100, Andrea Arcangeli wrote:
> On Mon, Jan 31, 2011 at 04:33:57PM -0800, Dave Hansen wrote:
> > I'm working on some more reports that transparent huge pages and
> > KSM do not play nicely together.  Basically, whenever THP's are
> > present along with KSM, there is a lot of attrition over time,
> > and we do not see much overall progress keeping THP's around:
> > 
> > 	http://sr71.net/~dave/ibm/038_System_Anonymous_Pages.png
> > 
> > (That's Karl Rister's graph, thanks Karl!)
> 
> Well if the pages_sharing/pages_shared count goes up, this is a
> feature not a bug.... You need to print that too in the chart to show
> this is not ok

Here are the KSM sharing bits for the same run:

	http://sr71.net/~dave/ibm/009_KSM_Pages.png

It bounces around a little bit on the ends, but it's fairly static
during the test, even when there's a good downward slope on the THP's.

Hot of the presses, Karl also managed to do a run last night with the
khugepaged scanning rates turned all the way up:

	http://sr71.net/~dave/ibm/038_System_Anonymous_Pages-scan-always.png

The THP's there are a lot more stable.  I'd read that as saying that the
scanning probably just isn't keeping up with whatever is breaking the
pages up.

> KSM will slowdown performance also during copy-on-writes when
> pages_sharing goes up, not only because of creating non-linearity
> inside 2m chunks (which makes mandatory to use ptes and not hugepmd,
> it's not an inefficiency of some sort that can be optimized away
> unfortunately). We sure could change KSM to merge 2M pages instead of
> 4k pages, but then the memory-density would decrease of several order
> of magnitudes making the KSM scan almost useless (ok, with guest
> heavily using THP that may change, but all pagecache is still 4k... so
> for now it'd be next to useless).

Yup, unless we do something special, the odds of sharing those 2MB
suckers are near zero.

> I would prefer to close the issues that you just previously reported,
> sometime with mmap_sem and issues like that, before adding more
> features though but I don't want to defer things either so it's up to
> you.

I'm happy to hold on to them for another release.  I'm actually going to
go look at the freezes I saw now that I have these out in the wild.
I'll probably stick them in a git tree and keep them up to date.

Are there any other THP issues you're chasing at the moment?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
