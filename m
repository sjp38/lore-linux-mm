Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 21C236B002B
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 23:22:14 -0500 (EST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 8 Nov 2012 21:22:13 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 7FBF7C40003
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 21:22:07 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA94M9IQ243780
	for <linux-mm@kvack.org>; Thu, 8 Nov 2012 21:22:09 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA94M8SS005269
	for <linux-mm@kvack.org>; Thu, 8 Nov 2012 21:22:09 -0700
Message-ID: <509C84ED.8090605@linux.vnet.ibm.com>
Date: Thu, 08 Nov 2012 22:22:05 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: kswapd0: excessive CPU usage
References: <507688CC.9000104@suse.cz> <106695.1349963080@turing-police.cc.vt.edu> <5076E700.2030909@suse.cz> <118079.1349978211@turing-police.cc.vt.edu> <50770905.5070904@suse.cz> <119175.1349979570@turing-police.cc.vt.edu> <5077434D.7080008@suse.cz> <50780F26.7070007@suse.cz> <20121012135726.GY29125@suse.de> <507BDD45.1070705@suse.cz> <20121015110937.GE29125@suse.de> <5093A3F4.8090108@redhat.com> <5093A631.5020209@suse.cz> <509422C3.1000803@suse.cz>
In-Reply-To: <509422C3.1000803@suse.cz>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Zdenek Kabelac <zkabelac@redhat.com>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Robert Jennings <rcj@linux.vnet.ibm.com>

On 11/02/2012 02:45 PM, Jiri Slaby wrote:
> On 11/02/2012 11:53 AM, Jiri Slaby wrote:
>> On 11/02/2012 11:44 AM, Zdenek Kabelac wrote:
>>>>> Yes, applying this instead of the revert fixes the issue as well.
>>>
>>> I've applied this patch on 3.7.0-rc3 kernel - and I still see excessive
>>> CPU usage - mainly  after  suspend/resume
>>>
>>> Here is just simple  kswapd backtrace from running kernel:
>>
>> Yup, this is what we were seeing with the former patch only too. Try to
>> apply the other one too:
>> https://patchwork.kernel.org/patch/1673231/
>>
>> For me I would say, it is fixed by the two patches now. I won't be able
>> to report later, since I'm leaving to a conference tomorrow.
> 
> Damn it. It recurred right now, with both patches applied. After I
> started a java program which consumed some more memory. Though there are
> still 2 gigs free, kswap is spinning:
> [<ffffffff810b00da>] __cond_resched+0x2a/0x40
> [<ffffffff811318a0>] shrink_slab+0x1c0/0x2d0
> [<ffffffff8113478d>] kswapd+0x66d/0xb60
> [<ffffffff810a25d0>] kthread+0xc0/0xd0
> [<ffffffff816aa29c>] ret_from_fork+0x7c/0xb0
> [<ffffffffffffffff>] 0xffffffffffffffff

I'm also hitting this issue in v3.7-rc4.  It appears that the last
release not effected by this issue was v3.3.  Bisecting the changes
included for v3.4-rc1 showed that this commit introduced the issue:

fe2c2a106663130a5ab45cb0e3414b52df2fff0c is the first bad commit
commit fe2c2a106663130a5ab45cb0e3414b52df2fff0c
Author: Rik van Riel <riel@redhat.com>
Date:   Wed Mar 21 16:33:51 2012 -0700

    vmscan: reclaim at order 0 when compaction is enabled
...

This is plausible since the issue seems to be in the kswapd + compaction
realm.  I've yet to figure out exactly what about this commit results in
kswapd spinning.

I would be interested if someone can confirm this finding.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
