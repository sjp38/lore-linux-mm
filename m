Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9B6F66B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 03:30:04 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so1290929pbc.38
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 00:30:04 -0800 (PST)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id j5si116479pbs.211.2014.01.08.00.30.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 00:30:03 -0800 (PST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Wed, 8 Jan 2014 18:29:58 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id CA7612CE8040
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 19:29:53 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s088AaFj33357994
	for <linux-mm@kvack.org>; Wed, 8 Jan 2014 19:10:50 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s088TT6j013078
	for <linux-mm@kvack.org>; Wed, 8 Jan 2014 19:29:29 +1100
Message-ID: <52CD0E2F.8000903@linux.vnet.ibm.com>
Date: Wed, 08 Jan 2014 14:07:03 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V3] mm readahead: Fix the readahead fail in case of
 empty numa node
References: <1389003715-29733-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140106105620.GC3312@quack.suse.cz>
In-Reply-To: <20140106105620.GC3312@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/06/2014 04:26 PM, Jan Kara wrote:
> On Mon 06-01-14 15:51:55, Raghavendra K T wrote:
>> Currently, max_sane_readahead returns zero on the cpu with empty numa node,
>> fix this by checking for potential empty numa node case during calculation.
>> We also limit the number of readahead pages to 4k.
>>
>> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
>> ---
>> The current patch limits the readahead into 4k pages (16MB was suggested
>> by Linus).  and also handles the case of memoryless cpu issuing readahead
>> failures.  We still do not consider [fm]advise() specific calculations
>> here.  I have dropped the iterating over numa node to calculate free page
>> idea.  I do not have much idea whether there is any impact on big
>> streaming apps..  Comments/suggestions ?
>    As you say I would be also interested what impact this has on a streaming
> application. It should be rather easy to check - create 1 GB file, drop
> caches. Then measure how long does it take to open the file, call fadvise
> FADV_WILLNEED, read the whole file (for a kernel with and without your
> patch). Do several measurements so that we get some meaningful statistics.
> Resulting numbers can then be part of the changelog. Thanks!
>

Hi Honza,

Thanks for the idea. (sorry for the delay, spent my own time to do some
fadvise and other benchmarking). Here is the result on my x240 machine
with 32 cpu (w/ HT) 128GB ram.

Below test was for 1gb test file as per suggestion.

x base_result
+ patched_result
     N           Min           Max        Median           Avg        Stddev
x  12         7.217         7.444        7.2345     7.2603333    0.06442802
+  12          7.24         7.431         7.243     7.2684167   0.059649672

 From the result we could see that there is not much impact with the
patch.
I shall include the result in changelog when I resend/next version
depending on the others' comment.

---
test file looked something like this:

char buf[4096];

int main()
{
int fd = open("testfile", O_RDONLY);
unsigned long read_bytes = 0;
int sz;
posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED);

do {
	sz = read(fd, buf, 4096);
	read_bytes += sz;
} while (sz > 0);

close(fd);
printf (" Total bytes read = %lu \n", read_bytes);
return 0;
}





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
