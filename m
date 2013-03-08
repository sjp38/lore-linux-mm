Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 27E516B0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 02:46:48 -0500 (EST)
Message-ID: <5139975F.9070509@symas.com>
Date: Thu, 07 Mar 2013 23:46:39 -0800
From: Howard Chu <hyc@symas.com>
MIME-Version: 1.0
Subject: Re: mmap vs fs cache
References: <5136320E.8030109@symas.com> <20130307154312.GG6723@quack.suse.cz> <20130308020854.GC23767@cmpxchg.org>
In-Reply-To: <20130308020854.GC23767@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Johannes Weiner wrote:
> On Thu, Mar 07, 2013 at 04:43:12PM +0100, Jan Kara wrote:

>>> 2 questions:
>>>    why is there data in the FS cache that isn't owned by (the mmap
>>> of) the process that caused it to be paged in in the first place?
>
> The filesystem cache is shared among processes because the filesystem
> is also shared among processes.  If another task were to access the
> same file, we still should only have one copy of that data in memory.

That's irrelevant to the question. As I already explained, the first 16GB that 
was paged in didn't behave this way. Perhaps "owned" was the wrong word, since 
this is a MAP_SHARED mapping. But the point is that the memory is not being 
accounted in slapd's process size, when it was before, up to 16GB.

> It sounds to me like slapd is itself caching all the data it reads.

You're misreading the information then. slapd is doing no caching of its own, 
its RSS and SHR memory size are both the same. All it is using is the mmap, 
nothing else. The RSS == SHR == FS cache, up to 16GB. RSS is always == SHR, 
but above 16GB they grow more slowly than the FS cache.

> If that is true, shouldn't it really be using direct IO to prevent
> this double buffering of filesystem data in memory?

There is no double buffering.

>>>    is there a tunable knob to discourage the page cache from stealing
>>> from the process?
>
> Try reducing /proc/sys/vm/swappiness, which ranges from 0-100 and
> defaults to 60.

I've already tried setting it to 0 with no effect.

-- 
   -- Howard Chu
   CTO, Symas Corp.           http://www.symas.com
   Director, Highland Sun     http://highlandsun.com/hyc/
   Chief Architect, OpenLDAP  http://www.openldap.org/project/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
