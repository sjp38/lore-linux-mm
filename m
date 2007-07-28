Date: Sat, 28 Jul 2007 02:08:23 +0200
From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge
	plans for 2.6.23]
Message-ID: <20070728000823.GA14933@atjola.homenet>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com> <20070727030040.0ea97ff7.akpm@linux-foundation.org> <1185531918.8799.17.camel@Homer.simpson.net> <200707271345.55187.dhazelton@enter.net> <46AA3680.4010508@gmail.com> <20070727231545.GA14457@atjola.homenet> <20070727232919.GA8960@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20070727232919.GA8960@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Rene Herman <rene.herman@gmail.com>, Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 2007.07.28 01:29:19 +0200, Andi Kleen wrote:
> > Any faults in that reasoning?
> 
> GNU sort uses a merge sort with temporary files on disk. Not sure
> how much it keeps in memory during that, but it's probably less
> than 150MB. At some point the dirty limit should kick in and write back the 
> data of the temporary files; so it's not quite the same as anonymous memory. 
> But it's not that different given.

Hm, does that change anything? The files need to be read at the end (so
they go into the cache) and are delete afterwards (cache gets freed I
guess?).

> It would be better to measure than to guess. At least Andrew's measurements
> on 128MB actually didn't show updatedb being really that big a problem.

Here's a before/after memory usage for an updatedb run:
root@atjola:~# free -m
             total       used       free     shared    buffers     cached
Mem:          2011       1995         15          0        269        779
-/+ buffers/cache:        946       1064
Swap:         1945          0       1945
root@atjola:~# updatedb
root@atjola:~# free -m
             total       used       free     shared    buffers     cached
Mem:          2011       1914         96          0        209        746
-/+ buffers/cache:        958       1052
Swap:         1945          0       1944

81MB more unused RAM afterwards.

If anyone can make use of that, here's a snippet from /proc/$PID/smaps
of updatedb's sort process, when it was at about its peak memory usage
(according to the RSS column in top), which was about 50MB.

2b90ab3c1000-2b90ae4c3000 rw-p 2b90ab3c1000 00:00 0 
Size:              50184 kB
Rss:               50184 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:     50184 kB
Referenced:        50184 kB

> Perhaps some people have much more files or simply a less efficient
> updatedb implementation?

sort (GNU coreutils) 5.97

GNU updatedb version 4.2.31

> I guess the people who complain here that loudly really need to supply
> some real numbers. 

Just to clarify: I'm not complaining either way, neither about not
merging swap prefetch, nor about someone wanting that to be merge. It
was rather the "discussion" that caught my attention... Just in case ;-)

Bjorn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
