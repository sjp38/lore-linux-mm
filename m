Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 791436B0027
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 09:02:09 -0400 (EDT)
Message-ID: <514C5640.8000902@redhat.com>
Date: Fri, 22 Mar 2013 09:01:52 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] mm: vmscan: Limit the number of pages kswapd reclaims
 at each priority
References: <1363525456-10448-1-git-send-email-mgorman@suse.de> <1363525456-10448-2-git-send-email-mgorman@suse.de> <20130321155705.GA27848@cmpxchg.org> <514BA04D.2090002@gmail.com> <514BD56F.6050709@redhat.com> <514BD665.5020803@gmail.com> <514BE54C.4050106@gmail.com>
In-Reply-To: <514BE54C.4050106@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Huck <will.huckk@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Zlatko Calusic <zcalusic@bitsync.net>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On 03/22/2013 12:59 AM, Will Huck wrote:
> Hi Rik,
> On 03/22/2013 11:56 AM, Will Huck wrote:
>> Hi Rik,
>> On 03/22/2013 11:52 AM, Rik van Riel wrote:
>>> On 03/21/2013 08:05 PM, Will Huck wrote:
>>>
>>>> One offline question, how to understand this in function balance_pgdat:
>>>> /*
>>>>   * Do some background aging of the anon list, to give
>>>>   * pages a chance to be referenced before reclaiming.
>>>>   */
>>>> age_acitve_anon(zone, &sc);
>>>
>>> The anon lrus use a two-handed clock algorithm. New anonymous pages
>>> start off on the active anon list. Older anonymous pages get moved
>>> to the inactive anon list.
>>
>> The file lrus also use the two-handed clock algorithm, correct?
>
> After reinvestigate the codes, the answer is no. But why have this
> difference? I think you are the expert for this question, expect your
> explanation. :-)

Anonymous memory has a smaller amount of memory (on the order
of system memory), most of which is or has been in a working
set at some point.

File system cache tends to have two distinct sets. One part
are the frequently accessed files, another part are the files
that are accessed just once or twice.

The file working set needs to be protected from streaming
IO. We do this by having new file pages start out on the
inactive file list, and only promoted to the active file
list if they get accessed twice.


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
