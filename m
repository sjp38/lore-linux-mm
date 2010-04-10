Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 260476B01E3
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 16:58:44 -0400 (EDT)
Received: by pzk30 with SMTP id 30so3906591pzk.12
        for <linux-mm@kvack.org>; Sat, 10 Apr 2010 13:58:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BC0E556.30304@redhat.com>
References: <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org>
	<20100406090813.GA14098@elte.hu> <20100410184750.GJ5708@random.random>
	<20100410190233.GA30882@elte.hu> <4BC0CFF4.5000207@redhat.com>
	<20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com>
	<4BC0E2C4.8090101@redhat.com> <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com>
	<4BC0E556.30304@redhat.com>
From: Jason Garrett-Glaser <darkshikari@gmail.com>
Date: Sat, 10 Apr 2010 13:58:21 -0700
Message-ID: <m2u28f2fcbc1004101358q431be476xdd3e39221d6b7b04@mail.gmail.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 10, 2010 at 1:53 PM, Avi Kivity <avi@redhat.com> wrote:
> On 04/10/2010 11:49 PM, Jason Garrett-Glaser wrote:
>>
>>> 3-5% improvement. =A0I had to tune khugepaged to scan more aggressively
>>> since
>>> the run is so short. =A0The working set is only ~100MB here though.
>>>
>>
>> I'd try some longer runs with larger datasets to do more testing.
>>
>> Some things to try:
>>
>> 1) Pick a 1080p or even 2160p sequence from
>> http://media.xiph.org/video/derf/
>>
>>
>
> Ok, I'm downloading crown_run 2160p, but it will take a while.

You can always cheat by synthesizing a fake sample like this:

ffmpeg -i input.y4m -s 3840x2160 output.y4m

Or something similar.

Do be careful though; extremely fast presets combined with large input
samples will be disk-bottlenecked, so make sure to keep it small
enough to fit in disk cache and "prime" the cache before testing.

>> 2) Use --preset ultrafast or similar to do a ridiculously
>> memory-bandwidth-limited runthrough.
>>
>>
>
> Large pages improve random-access memory bandwidth but don't change
> sequential access. =A0Which of these does --preset ultrafast change?

Hmm, I'm not quite sure.  The process is strictly sequential, but
there is clearly enough random access mixed in to cause some sort of
change given your previous test.  The main thing faster presets do is
decrease the amount of "work" done at each step, resulting in roughly
the same amount of memory bandwidth being required for each step--but
in a much shorter period of time.  Most "work" done at each step stays
well within the L2 cache.

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
