Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF2D6B0269
	for <linux-mm@kvack.org>; Sat, 16 Jan 2016 13:00:14 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id q63so138487154pfb.1
        for <linux-mm@kvack.org>; Sat, 16 Jan 2016 10:00:14 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id o4si25393695pap.178.2016.01.16.10.00.13
        for <linux-mm@kvack.org>;
        Sat, 16 Jan 2016 10:00:13 -0800 (PST)
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
 <1447181081-30056-2-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.11.1601141356080.13199@eggly.anvils>
 <20160116174953.GU31137@redhat.com>
From: Arjan van de Ven <arjan@linux.intel.com>
Message-ID: <569A852B.6050209@linux.intel.com>
Date: Sat, 16 Jan 2016 10:00:11 -0800
MIME-Version: 1.0
In-Reply-To: <20160116174953.GU31137@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>

On 1/16/2016 9:49 AM, Andrea Arcangeli wrote:
> In short I don't see the KSM sharing limit ever going to be obsolete
> unless the whole pagetable format changes and we don't deal with
> pagetables anymore.

just to put some weight behind Andrea's arguments: this is not theoretical.
We're running 3500 - 7000 virtual machines on a single server quite easily nowadays
and there's quite a bit of memory that KSM will share between them (often
even multiple times)..  so your N in O(N) is 7000 to many multiples there of
in real environments.

And the long hang do happen... once you start getting a bit of memory pressure
(say you go from 7000 to 7200 VMs and you only have memory for 7150) then you
are hitting the long delays *for every page* the VM inspects, and it will inspect
many... since initially they all (all 200Gb of them) are active. My machine was
just completely "out" in this for 24 hours before I decided to just reboot it instead.

Now, you can make it 2x faster (reboot in 12 hours? ;-) ) but there's really a much
higher order reduction of the "long chain" problem needed...
I'm with Andrea that prevention of super long chains is the way to go, we can argue about 250
or 500 or 1000. Numbers will speak there... but from a KSM user perspective, at some point
you reduced the cost of a page by 250x or 500x or 1000x... it's hitting diminishing returns.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
