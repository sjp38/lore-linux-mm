Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f177.google.com (mail-gg0-f177.google.com [209.85.161.177])
	by kanga.kvack.org (Postfix) with ESMTP id B392E6B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 06:52:37 -0500 (EST)
Received: by mail-gg0-f177.google.com with SMTP id 4so329383ggm.36
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 03:52:37 -0800 (PST)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id v3si634247yhv.169.2014.01.08.03.52.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 03:52:36 -0800 (PST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Wed, 8 Jan 2014 17:22:24 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 9E8B01258053
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 17:23:51 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s08BqJ4i13828168
	for <linux-mm@kvack.org>; Wed, 8 Jan 2014 17:22:19 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s08BqK8I023561
	for <linux-mm@kvack.org>; Wed, 8 Jan 2014 17:22:21 +0530
Message-ID: <52CD3DBD.401@linux.vnet.ibm.com>
Date: Wed, 08 Jan 2014 17:29:57 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V3] mm readahead: Fix the readahead fail in case of
 empty numa node
References: <1389003715-29733-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140106105620.GC3312@quack.suse.cz> <52CD0E2F.8000903@linux.vnet.ibm.com> <20140108103843.GA8256@quack.suse.cz>
In-Reply-To: <20140108103843.GA8256@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/08/2014 04:08 PM, Jan Kara wrote:
> On Wed 08-01-14 14:07:03, Raghavendra K T wrote:
>> On 01/06/2014 04:26 PM, Jan Kara wrote:
>>> On Mon 06-01-14 15:51:55, Raghavendra K T wrote:
>> ---
>> test file looked something like this:
>>
>> char buf[4096];
>>
>> int main()
>> {
>> int fd = open("testfile", O_RDONLY);
>> unsigned long read_bytes = 0;
>> int sz;
>> posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED);
>    Hum, but this call should have rather been:
> struct stat st;
>
> fstat(fd, &st);
> posix_fadvise(fd, 0, st.st_size, POSIX_FADV_WILLNEED);
>
> The posix_fadvise() call you had doesn't do anything...
>
> 								Honza

I reran the test with that change, no change the outcome though.
(I had earlier tested with hardcoded size etc.. but fstat was the
correct thing to do.. thanks). will include the result in V4

>
>> do {
>> 	sz = read(fd, buf, 4096);
>> 	read_bytes += sz;
>> } while (sz > 0);
>>
>> close(fd);
>> printf (" Total bytes read = %lu \n", read_bytes);
>> return 0;
>> }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
