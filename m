Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id CBD126B0120
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 12:23:58 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id p5so433716lag.14
        for <linux-mm@kvack.org>; Thu, 04 Oct 2012 09:23:56 -0700 (PDT)
Message-ID: <506DB816.9090107@openvz.org>
Date: Thu, 04 Oct 2012 20:23:50 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm/swap: automatic tuning for swapin readahead
References: <50460CED.6060006@redhat.com> <20120906110836.22423.17638.stgit@zurg> <alpine.LSU.2.00.1210011418270.2940@eggly.anvils> <506AACAC.2010609@openvz.org> <alpine.LSU.2.00.1210031337320.1415@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1210031337320.1415@eggly.anvils>
Content-Type: multipart/mixed;
 boundary="------------040300020909090609050408"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This is a multi-part message in MIME format.
--------------040300020909090609050408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Here results of my test. Workload isn't very realistic, but at least it 
threaded: compiling linux-3.6 with defconfig in 16 threads on tmpfs,
512mb ram, dualcore cpu, ordinary hard disk. (test script in attachment)

average results for ten runs:

		RA=3	RA=0	RA=1	RA=2	RA=4	Hugh	Shaohua
real time	500	542	528	519	500	523	522
user time	738	737	735	737	739	737	739
sys time	93	93	91	92	96	92	93
pgmajfault	62918	110533	92454	78221	54342	86601	77229
pgpgin		2070372	795228	1034046	1471010	3177192	1154532	1599388
pgpgout		2597278	2022037	2110020	2350380	2802670	2286671	2526570
pswpin		462747	138873	202148	310969	739431	232710	341320
pswpout		646363	502599	524613	584731	697797	568784	628677

So, last two columns shows mostly equal results: +4.6% and +4.4% in comparison 
to vanilla kernel with RA=3, but your version shows more stable results 
(std-error 2.7% against 4.8%) (all this numbers in huge table in attachment)



Numbers from your tests formatted into table for better readability
				
HDD		Vanilla	Shaohua	RA=3	RA=0	RA=4
SEQ, ANON	73921	76210	75611	121542	77950
SEQ, SHMEM	73601	73176	73855	118322	73534
RND, ANON	895392	831243	871569	841680	863871
RND, SHMEM	1058375	1053486	827935	756489	834804

SDD		Vanilla	Shaohua	RA=3	RA=0	RA=4
SEQ, ANON	24634	24198	24673	70018	21125
SEQ, SHMEM	24959	24932	25052	69678	21387
RND, ANON	43014	26146	28075	25901	28686
RND, SHMEM	45349	45215	28249	24332	28226

Hugh Dickins wrote:
> On Tue, 2 Oct 2012, Konstantin Khlebnikov wrote:
>> Hugh Dickins wrote:
>>>
>>> If I boot with mem=900M (and 1G swap: either on hard disk sda, or
>>> on Vertex II SSD sdb), and mmap anonymous 1000M (either MAP_PRIVATE,
>>> or MAP_SHARED for a shmem object), and either cycle sequentially round
>>> that making 5M touches (spaced a page apart), or make 5M random touches,
>>> then here are the times in centisecs that I see (but it's only elapsed
>>> that I've been worrying about).
>>>
>>> 3.6-rc7 swapping to hard disk:
>>>       124 user    6154 system   73921 elapsed -rc7 sda seq
>>>       102 user    8862 system  895392 elapsed -rc7 sda random
>>>       130 user    6628 system   73601 elapsed -rc7 sda shmem seq
>>>       194 user    8610 system 1058375 elapsed -rc7 sda shmem random
>>>
>>> 3.6-rc7 swapping to SSD:
>>>       116 user    5898 system   24634 elapsed -rc7 sdb seq
>>>        96 user    8166 system   43014 elapsed -rc7 sdb random
>>>       110 user    6410 system   24959 elapsed -rc7 sdb shmem seq
>>>       208 user    8024 system   45349 elapsed -rc7 sdb shmem random
>>>
>>> 3.6-rc7 + Shaohua's patch (and FAULT_FLAG_RETRY check in do_swap_page),
>>> HDD:
>>>       116 user    6258 system   76210 elapsed shli sda seq
>>>        80 user    7716 system  831243 elapsed shli sda random
>>>       128 user    6640 system   73176 elapsed shli sda shmem seq
>>>       212 user    8522 system 1053486 elapsed shli sda shmem random
>>>
>>> 3.6-rc7 + Shaohua's patch (and FAULT_FLAG_RETRY check in do_swap_page),
>>> SSD:
>>>       126 user    5734 system   24198 elapsed shli sdb seq
>>>        90 user    7356 system   26146 elapsed shli sdb random
>>>       128 user    6396 system   24932 elapsed shli sdb shmem seq
>>>       192 user    8006 system   45215 elapsed shli sdb shmem random
>>>
>>> 3.6-rc7 + my patch, swapping to hard disk:
>>>       126 user    6252 system   75611 elapsed hugh sda seq
>>>        70 user    8310 system  871569 elapsed hugh sda random
>>>       130 user    6790 system   73855 elapsed hugh sda shmem seq
>>>       148 user    7734 system  827935 elapsed hugh sda shmem random
>>>
>>> 3.6-rc7 + my patch, swapping to SSD:
>>>       116 user    5996 system   24673 elapsed hugh sdb seq
>>>        76 user    7568 system   28075 elapsed hugh sdb random
>>>       132 user    6468 system   25052 elapsed hugh sdb shmem seq
>>>       166 user    7220 system   28249 elapsed hugh sdb shmem random
>>>
>>
>> Hmm, It would be nice to gather numbers without swapin readahead at all, just
>> to see the the worst possible case for sequential read and the best for
>> random.
>
> Right, and also interesting to see what happens if we raise page_cluster
> (more of an option than it was, with your or my patch scaling it down).
> Run on the same machine under the same conditions:
>
> 3.6-rc7 + my patch, swapping to hard disk with page_cluster 0 (no readahead):
>      136 user   34038 system  121542 elapsed hugh cluster0 sda seq
>      102 user    7928 system  841680 elapsed hugh cluster0 sda random
>      130 user   34770 system  118322 elapsed hugh cluster0 sda shmem seq
>      160 user    7362 system  756489 elapsed hugh cluster0 sda shmem random
>
> 3.6-rc7 + my patch, swapping to SSD with page_cluster 0 (no readahead):
>      138 user   32230 system   70018 elapsed hugh cluster0 sdb seq
>       88 user    7296 system   25901 elapsed hugh cluster0 sdb random
>      154 user   33150 system   69678 elapsed hugh cluster0 sdb shmem seq
>      166 user    6936 system   24332 elapsed hugh cluster0 sdb shmem random
>
> 3.6-rc7 + my patch, swapping to hard disk with page_cluster 4 (default + 1):
>      144 user    4262 system   77950 elapsed hugh cluster4 sda seq
>       74 user    8268 system  863871 elapsed hugh cluster4 sda random
>      140 user    4880 system   73534 elapsed hugh cluster4 sda shmem seq
>      160 user    7788 system  834804 elapsed hugh cluster4 sda shmem random
>
> 3.6-rc7 + my patch, swapping to SSD with page_cluster 4 (default + 1):
>      124 user    4242 system   21125 elapsed hugh cluster4 sdb seq
>       72 user    7680 system   28686 elapsed hugh cluster4 sdb random
>      122 user    4622 system   21387 elapsed hugh cluster4 sdb shmem seq
>      172 user    7238 system   28226 elapsed hugh cluster4 sdb shmem random
>
> I was at first surprised to see random significantly faster than sequential
> on SSD with readahead off, thinking they ought to come out the same.  But
> no, that's a warning on the limitations of the test: with an mmap of 1000M
> on a machine with mem=900M, the page-by-page sequential is never going to
> rehit cache, whereas the random has a good chance of finding in memory.
>
> Which I presume also accounts for the lower user times throughout
> for random - but then why not the same for shmem random?
>
> I did start off measuring on the laptop with SSD, mmap 1000M mem=500M;
> but once I transferred to the desktop, I rediscovered just how slow
> swapping to hard disk can be, couldn't wait days, so made mem=900M.
>
>> I'll run some tests too, especially I want to see how it works for less
>> synthetic workloads.
>
> Thank you, that would be valuable.  I expect there to be certain midway
> tests on which Shaohao's patch would show up as significantly faster,
> where his per-vma approach would beat the global approach; then the
> global to improve with growing contention between processes.  But I
> didn't devise any such test, and hoped Shaohua might have one.
>
> Hugh


--------------040300020909090609050408
Content-Type: application/x-sh;
 name="test-linux-build.sh"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="test-linux-build.sh"

T=/mnt/tmp
L=linux-3.6.tar.bz2
J=16

swapoff -a
swapon -a
sysctl -q vm.drop_caches=3

date
uname -a
free

T=/mnt/tmp
mount -t tmpfs tmpfs $T -o size=4G

tar xf $L -C $T
make -s -C $T/linux-* defconfig

cat /proc/vmstat > $T/vmstat.a
time -p make -s -C $T/linux-* -j$J all
cat /proc/vmstat > $T/vmstat.b
paste $T/vmstat.a $T/vmstat.b | awk '{print $1, $4-$2}'

umount $T

--------------040300020909090609050408
Content-Type: text/plain;
 name="test-linux-build-results.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="test-linux-build-results.txt"

		0-orig.log 	1-nora.log		1-one.log		2-two.log		4-four.log		5-hugh.log		6-shaohua.log
real time	500 [1.9%]	542 [4.5%]	+8.3%	528 [4.7%]	+5.7%	519 [2.6%]	+3.8%	500 [1.2%]	+0.1%	523 [2.7%]	+4.6%	522 [4.4%]	+4.4%
user time	738 [0.5%]	737 [0.7%]	-0.2%	735 [0.4%]	-0.4%	737 [0.4%]	-0.1%	739 [0.4%]	+0.1%	737 [0.4%]	-0.1%	739 [0.3%]	+0.2%
sys time	93 [1.2%]	93 [1.8%]	+0.6%	91 [0.8%]	-1.4%	92 [1.2%]	-1.3%	96 [0.8%]	+3.8%	92 [0.8%]	-1.0%	93 [1.0%]	+0.5%
pgmajfault	62918 [4.2%]	110533 [6.6%]	+75.7%	92454 [4.6%]	+46.9%	78221 [3.3%]	+24.3%	54342 [2.7%]	-13.6%	86601 [3.8%]	+37.6%	77229 [6.4%]	+22.7%
pgpgin		2070372 [4.0%]	795228 [6.7%]	-61.6%	1034046 [2.9%]	-50.1%	1471010 [4.2%]	-28.9%	3177192 [2.1%]	+53.5%	1154532 [3.4%]	-44.2%	1599388 [6.2%]	-22.7%
pgpgout		2597278 [7.9%]	2022037 [9.4%]	-22.1%	2110020 [4.3%]	-18.8%	2350380 [8.1%]	-9.5%	2802670 [6.8%]	+7.9%	2286671 [7.0%]	-12.0%	2526570 [8.1%]	-2.7%
pswpin		462747 [4.5%]	138873 [6.1%]	-70.0%	202148 [3.4%]	-56.3%	310969 [3.7%]	-32.8%	739431 [2.0%]	+59.8%	232710 [3.6%]	-49.7%	341320 [6.9%]	-26.2%
pswpout		646363 [7.9%]	502599 [9.5%]	-22.2%	524613 [4.4%]	-18.8%	584731 [8.2%]	-9.5%	697797 [6.8%]	+8.0%	568784 [7.0%]	-12.0%	628677 [8.1%]	-2.7%

--------------040300020909090609050408--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
