Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id B1D766B0034
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 12:36:58 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id f12so7620125wgh.3
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 09:36:57 -0700 (PDT)
Message-ID: <520BB225.8030807@gmail.com>
Date: Wed, 14 Aug 2013 18:36:53 +0200
From: Ben Tebulin <tebulin@googlemail.com>
MIME-Version: 1.0
Subject: [Bug] Reproducible data corruption on i5-3340M: Please revert 53a59fc67!
References: <52050382.9060802@gmail.com>
In-Reply-To: <52050382.9060802@gmail.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org

Hello Michal, Johannes, Balbir, Kamezawa and Mailing lists!

Since v3.7.2 on two independent machines a very specific Git repository
fails in 9/10 cases on git-fsck due to an SHA1/memory failures. This
only occurs on a very specific repository and can be reproduced stably
on two independent laptops. Git mailing list ran out of ideas and for me 
this looks like some very exotic kernel issue.

After a _very long session of rebooting and bisecting_ the Linux kernel
(fortunately I had a SSD and ccache!) I was able to pinpoint the cause
to the following patch:

*"mm: limit mmu_gather batching to fix soft lockups on !CONFIG_PREEMPT"*
  787f7301074ccd07a3e82236ca41eefd245f4e07 linux stable    [1]
  53a59fc67f97374758e63a9c785891ec62324c81 upstream commit [2]

More details are available in my previous discussion on the Git mailing:

   http://thread.gmane.org/gmane.comp.version-control.git/231872

Never had any hardware/stability issues _at all_ with these machines. 
Only one repo out of 112 is affected. It's a git-svn clone and even 
recreated copies out of svn do trigger the same failure.

I was able to bisect this error to this very specific commit. 
Furthermore: Reverting this commit in 3.9.11 still solves the error. 

I assume this is a regression of the Linux kernel (not Git) and would 
kindly ask you to revert the afore mentioned commits.

Thanks!
- Ben


I'm not subscribed - please CC me.

[1] https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?id=787f7301074ccd07a3e82236ca41eefd245f4e07
[2] https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=53a59fc67f97374758e63a9c785891ec62324c81

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
