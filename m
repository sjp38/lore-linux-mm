Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 420DA6B0071
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 03:34:47 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id lz20so8566939obb.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 00:34:46 -0800 (PST)
Message-ID: <50AC9220.70202@gmail.com>
Date: Wed, 21 Nov 2012 16:34:40 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
MIME-Version: 1.0
Subject: Re: Problem in Page Cache Replacement
References: <1353433362.85184.YahooMailNeo@web141101.mail.bf1.yahoo.com> <20121120182500.GH1408@quack.suse.cz> <1353485020.53500.YahooMailNeo@web141104.mail.bf1.yahoo.com> <1353485630.17455.YahooMailNeo@web141106.mail.bf1.yahoo.com>
In-Reply-To: <1353485630.17455.YahooMailNeo@web141106.mail.bf1.yahoo.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: metin d <metdos@yahoo.com>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Cc Fengguang Wu.

On 11/21/2012 04:13 PM, metin d wrote:
>>    Curious. Added linux-mm list to CC to catch more attention. If you run
>> echo 1 >/proc/sys/vm/drop_caches does it evict data-1 pages from memory?
> I'm guessing it'd evict the entries, but am wondering if we could run any more diagnostics before trying this.
>
> We regularly use a setup where we have two databases; one gets used frequently and the other one about once a month. It seems like the memory manager keeps unused pages in memory at the expense of frequently used database's performance.
>
> My understanding was that under memory pressure from heavily accessed pages, unused pages would eventually get evicted. Is there anything else we can try on this host to understand why this is happening?
>
> Thank you,
>
> Metin
>
> On Tue 20-11-12 09:42:42, metin d wrote:
>> I have two PostgreSQL databases named data-1 and data-2 that sit on the
>> same machine. Both databases keep 40 GB of data, and the total memory
>> available on the machine is 68GB.
>>
>> I started data-1 and data-2, and ran several queries to go over all their
>> data. Then, I shut down data-1 and kept issuing queries against data-2.
>> For some reason, the OS still holds on to large parts of data-1's pages
>> in its page cache, and reserves about 35 GB of RAM to data-2's files. As
>> a result, my queries on data-2 keep hitting disk.
>>
>> I'm checking page cache usage with fincore. When I run a table scan query
>> against data-2, I see that data-2's pages get evicted and put back into
>> the cache in a round-robin manner. Nothing happens to data-1's pages,
>> although they haven't been touched for days.
>>
>> Does anybody know why data-1's pages aren't evicted from the page cache?
>> I'm open to all kind of suggestions you think it might relate to problem.
>    Curious. Added linux-mm list to CC to catch more attention. If you run
> echo 1 >/proc/sys/vm/drop_caches
>    does it evict data-1 pages from memory?
>
>> This is an EC2 m2.4xlarge instance on Amazon with 68 GB of RAM and no
>> swap space. The kernel version is:
>>
>> $ uname -r
>> 3.2.28-45.62.amzn1.x86_64
>> Edit:
>>
>> and it seems that I use one NUMA instance, if  you think that it can a problem.
>>
>> $ numactl --hardware
>> available: 1 nodes (0)
>> node 0 cpus: 0 1 2 3 4 5 6 7
>> node 0 size: 70007 MB
>> node 0 free: 360 MB
>> node distances:
>> node   0
>>     0:  10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
