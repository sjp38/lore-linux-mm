Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A271C8D0039
	for <linux-mm@kvack.org>; Sun,  6 Feb 2011 12:54:40 -0500 (EST)
Message-ID: <4D4EE05D.4050906@panasas.com>
Date: Sun, 06 Feb 2011 19:54:37 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/5] IO-less balance dirty pages
References: <1296783534-11585-1-git-send-email-jack@suse.cz>
In-Reply-To: <1296783534-11585-1-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>

On 02/04/2011 03:38 AM, Jan Kara wrote:
>   Hi,
> 
>   I've decided to take my stab at trying to make balance_dirty_pages() not
> submit IO :). I hoped to have something simpler than Fengguang and we'll see
> whether it is good enough.
> 
> The basic idea (implemented in the third patch) is that processes throttled
> in balance_dirty_pages() wait for enough IO to complete. The waiting is
> implemented as follows: Whenever we decide to throttle a task in
> balance_dirty_pages(), task adds itself to a list of tasks that are throttled
> against that bdi and goes to sleep waiting to receive specified amount of page
> IO completions. Once in a while (currently HZ/10, in patch 5 the interval is
> autotuned based on observed IO rate), accumulated page IO completions are
> distributed equally among waiting tasks.
> 
> This waiting scheme has been chosen so that waiting time in
> balance_dirty_pages() is proportional to
>   number_waited_pages * number_of_waiters.
> In particular it does not depend on the total number of pages being waited for,
> thus providing possibly a fairer results.
> 
> I gave the patches some basic testing (multiple parallel dd's to a single
> drive) and they seem to work OK. The dd's get equal share of the disk
> throughput (about 10.5 MB/s, which is nice result given the disk can do
> about 87 MB/s when writing single-threaded), and dirty limit does not get
> exceeded. Of course much more testing needs to be done but I hope it's fine
> for the first posting :).
> 
> Comments welcome.
> 
> 								Honza

So what is the disposition of Wu's patches in light of these ones?
* Do they replace Wu's, or Wu's just get rebased ontop of these at a
  later stage?
* Did you find any hard problems with Wu's patches that delay them for
  a long time?
* Some of the complicated stuff in Wu's patches are the statistics and
  rate control mechanics. Are these the troubled area? Because some of
  these are actually some things that I'm interested in, and that appeal
  to me the most.

In short why aren't Wu's patches ready to be included in 2.6.39?

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
