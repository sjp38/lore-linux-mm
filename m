Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1BB6B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 10:42:24 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id f8so4516224wiw.9
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 07:42:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id o13si9027830wij.21.2014.02.11.07.42.22
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 07:42:23 -0800 (PST)
Date: Tue, 11 Feb 2014 10:10:27 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
Message-ID: <20140211101027.5e32f1c2@redhat.com>
In-Reply-To: <20140210151354.68fe414f81335d4ce0e4c550@linux-foundation.org>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
	<20140210151354.68fe414f81335d4ce0e4c550@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com

On Mon, 10 Feb 2014 15:13:54 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 10 Feb 2014 12:27:44 -0500 Luiz Capitulino <lcapitulino@redhat.com> wrote:
> 
> > HugeTLB command-line option hugepages= allows the user to specify how many
> > huge pages should be allocated at boot. On NUMA systems, this argument
> > automatically distributes huge pages allocation among nodes, which can
> > be undesirable.
> 
> Grumble.  "can be undesirable" is the entire reason for the entire
> patchset.  We need far, far more detail than can be conveyed in three
> words, please!

Right, sorry for that. I'll improve this for v2, but a better introduction
for the series would be something like the following.

Today, HugeTLB provides support for controlling allocation of persistent
huge pages on a NUMA system through sysfs. So, for example, if a sysadmin
wants to allocate 300 2M huge pages on node 1, s/he can do:

 echo 300 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages

This works as long as you have enough contiguous pages, which may work
for 2M pages, but is harder for 1G huge pages. For those, it's better or even
required to reserve them at boot.

To this end we have the hugepages= command-line option, which works but misses
the per node control. This option evenly distributes huge pages among nodes.
However, we have users who want more flexibility. They want to be able to
specify something like: allocate 2 1G huge pages from node0 and 4 1G huge page
from node1. This is what this series implements.

It's basically per node allocation control for 1G huge pages, but it's
important to note that this series is not intrusive. All it does is to set
the initial per node allocation. All the functions and data structure added
by this series are only used once at boot, after that they are discarded and
rest in oblivion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
