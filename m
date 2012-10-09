Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 02F656B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 03:53:44 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id p5so3249324lag.14
        for <linux-mm@kvack.org>; Tue, 09 Oct 2012 00:53:42 -0700 (PDT)
Message-ID: <5073D802.9050207@openvz.org>
Date: Tue, 09 Oct 2012 11:53:38 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm/swap: automatic tuning for swapin readahead
References: <50460CED.6060006@redhat.com> <20120906110836.22423.17638.stgit@zurg> <alpine.LSU.2.00.1210011418270.2940@eggly.anvils> <506AACAC.2010609@openvz.org> <alpine.LSU.2.00.1210031337320.1415@eggly.anvils> <506DB816.9090107@openvz.org> <alpine.LSU.2.00.1210081451410.1384@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1210081451410.1384@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hugh Dickins wrote:
> On Thu, 4 Oct 2012, Konstantin Khlebnikov wrote:
>
>> Here results of my test. Workload isn't very realistic, but at least it
>> threaded: compiling linux-3.6 with defconfig in 16 threads on tmpfs,
>> 512mb ram, dualcore cpu, ordinary hard disk. (test script in attachment)
>>
>> average results for ten runs:
>>
>> 		RA=3	RA=0	RA=1	RA=2	RA=4	Hugh	Shaohua
>> real time	500	542	528	519	500	523	522
>> user time	738	737	735	737	739	737	739
>> sys time	93	93	91	92	96	92	93
>> pgmajfault	62918	110533	92454	78221	54342	86601	77229
>> pgpgin	2070372	795228	1034046	1471010	3177192	1154532	1599388
>> pgpgout	2597278	2022037	2110020	2350380	2802670	2286671	2526570
>> pswpin	462747	138873	202148	310969	739431	232710	341320
>> pswpout	646363	502599	524613	584731	697797	568784	628677
>>
>> So, last two columns shows mostly equal results: +4.6% and +4.4% in
>> comparison to vanilla kernel with RA=3, but your version shows more stable
>> results (std-error 2.7% against 4.8%) (all this numbers in huge table in
>> attachment)
>
> Thanks for doing this, Konstantin, but I'm stuck for anything much to say!
> Shaohua and I are both about 4.5% bad for this particular test, but I'm
> more consistently bad - hurrah!
>
> I suspect (not a convincing argument) that if the test were just slightly
> different (a little more or a little less memory, SSD instead of hard
> disk, diskcache instead of tmpfs), then it would come out differently.

Yes, results depends mostly on tmpfs.

>
> Did you draw any conclusions from the numbers you found?

Yeah, I have some ideas:

Numbers for vanilla kernel shows strong dependence between time and readahead
size. Seems like main problem is that tmpfs does not have it's own readahead,
it can only rely on swap-in readahead. There are about 25% readahead hits for RA=3.
As "pswpin" row shows both your and Shaohua patches makes readahead smaller.


Plus tmpfs doesn't keeps copy for clean pages in the swap (unlike to anon pages).
On swapin path it always marks page dirty and releases swap-entry.
I didn't have any measurements but this particular test definitely re-reads
some files multiple times and writes them back to the swap after that.

>
> I haven't done any more on this in the last few days, except to verify
> that once an anon_vma is judged random with Shaohua's, then it appears
> to be condemned to no-readahead ever after.
>
> That's probably something that a hack like I had in mine would fix,
> but that addition might change its balance further (and increase vma
> or anon_vma size) - not tried yet.
>
> All I want to do right now, is suggest to Andrew that he hold Shaohua's
> patch back from 3.7 for the moment: I'll send a response to Sep 7th's
> mm-commits mail to suggest that - but no great disaster if he ignores me.
>
> Hugh
>
>>
>> Numbers from your tests formatted into table for better readability
>> 				
>> HDD		Vanilla	Shaohua	RA=3	RA=0	RA=4
>> SEQ, ANON	73921	76210	75611	121542	77950
>> SEQ, SHMEM	73601	73176	73855	118322	73534
>> RND, ANON	895392	831243	871569	841680	863871
>> RND, SHMEM	1058375	1053486	827935	756489	834804
>>
>> SDD		Vanilla	Shaohua	RA=3	RA=0	RA=4
>> SEQ, ANON	24634	24198	24673	70018	21125
>> SEQ, SHMEM	24959	24932	25052	69678	21387
>> RND, ANON	43014	26146	28075	25901	28686
>> RND, SHMEM	45349	45215	28249	24332	28226

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
