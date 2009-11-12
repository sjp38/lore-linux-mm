Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5050C6B004D
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 15:28:44 -0500 (EST)
Date: Thu, 12 Nov 2009 15:27:48 -0500
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH 0/7] Reduce GFP_ATOMIC allocation failures, candidate
 fix V3
Message-ID: <20091112202748.GC2811@think>
References: <1258054211-2854-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1258054211-2854-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 12, 2009 at 07:30:06PM +0000, Mel Gorman wrote:
> Sorry for the long delay in posting another version. Testing is extremely
> time-consuming and I wasn't getting to work on this as much as I'd have liked.
> 
> Changelog since V2
>   o Dropped the kswapd-quickly-notice-high-order patch. In more detailed
>     testing, it made latencies even worse as kswapd slept more on high-order
>     congestion causing order-0 direct reclaims.
>   o Added changes to how congestion_wait() works
>   o Added a number of new patches altering the behaviour of reclaim
> 
> Since 2.6.31-rc1, there have been an increasing number of GFP_ATOMIC
> failures. A significant number of these have been high-order GFP_ATOMIC
> failures and while they are generally brushed away, there has been a large
> increase in them recently and there are a number of possible areas the
> problem could be in - core vm, page writeback and a specific driver. The
> bugs affected by this that I am aware of are;

Thanks for all the time you've spent on this one.  Let me start with
some more questions about the workload ;)

> 2. A crypted work partition and swap partition was created. On my
>    own setup, I gave no passphrase so it'd be easier to activate without
>    interaction but there are multiple options. I should have taken better
>    notes but the setup goes something like this;
> 
> 	cryptsetup create -y crypt-partition /dev/sda5
> 	pvcreate /dev/mapper/crypt-partition
> 	vgcreate crypt-volume /dev/mapper/crypt-partition
> 	lvcreate -L 5G -n crypt-logical crypt-volume
> 	lvcreate -L 2G -n crypt-swap crypt-volume
> 	mkfs -t ext3 /dev/crypt-volume/crypt-logical
> 	mkswap /dev/crypt-volume/crypt-swap
> 
> 3. With the partition mounted on /scratch, I
> 	cd /scratch
> 	mkdir music
> 	git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git linux-2.6
> 
> 4. On a normal partition, I expand a tarball containing test scripts available at
> 	http://www.csn.ul.ie/~mel/postings/latency-20091112/latency-tests-with-results.tar.gz
> 
> 	There are two helper programs that run as part of the test - a fake
> 	music player and a fake gitk.
> 
> 	The fake music player uses rsync with bandwidth limits to start
> 	downloading a music folder from another machine. It's bandwidth
> 	limited to simulate playing music over NFS.

So the workload is gitk reading a git repo and a program reading data
over the network.  Which part of the workload writes to disk?

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
