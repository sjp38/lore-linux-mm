Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 9AD816B0006
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 04:40:45 -0500 (EST)
Message-ID: <5139B214.3040303@symas.com>
Date: Fri, 08 Mar 2013 01:40:36 -0800
From: Howard Chu <hyc@symas.com>
MIME-Version: 1.0
Subject: Re: mmap vs fs cache
References: <5136320E.8030109@symas.com> <20130307154312.GG6723@quack.suse.cz> <20130308020854.GC23767@cmpxchg.org> <5139975F.9070509@symas.com> <20130308084246.GA4411@shutemov.name>
In-Reply-To: <20130308084246.GA4411@shutemov.name>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Kirill A. Shutemov wrote:
> On Thu, Mar 07, 2013 at 11:46:39PM -0800, Howard Chu wrote:
>> You're misreading the information then. slapd is doing no caching of
>> its own, its RSS and SHR memory size are both the same. All it is
>> using is the mmap, nothing else. The RSS == SHR == FS cache, up to
>> 16GB. RSS is always == SHR, but above 16GB they grow more slowly
>> than the FS cache.
>
> It only means, that some pages got unmapped from your process. It can
> happned, for instance, due page migration. There's nothing worry about: it
> will be mapped back on next page fault to the page and it's only minor
> page fault since the page is in pagecache anyway.

Unfortunately there *is* something to worry about. As I said already - when 
the test spans 30GB, the FS cache fills up the rest of RAM and the test is 
doing a lot of real I/O even though it shouldn't need to. Please, read the 
entire original post before replying.

There is no way that a process that is accessing only 30GB of a mmap should be 
able to fill up 32GB of RAM. There's nothing else running on the machine, I've 
killed or suspended everything else in userland besides a couple shells 
running top and vmstat. When I manually drop_caches repeatedly, then 
eventually slapd RSS/SHR grows to 30GB and the physical I/O stops.

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
