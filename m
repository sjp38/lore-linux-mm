Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3086B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 06:59:00 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id lj1so16625175pab.12
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 03:58:59 -0800 (PST)
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com. [202.81.31.144])
        by mx.google.com with ESMTPS id zk9si18060917pac.347.2014.02.18.03.58.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 03:58:59 -0800 (PST)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Tue, 18 Feb 2014 21:58:53 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 158252CE8055
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 22:58:50 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1IBwYgY10486260
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 22:58:36 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1IBwlGx000933
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 22:58:47 +1100
Message-ID: <53034C66.90707@linux.vnet.ibm.com>
Date: Tue, 18 Feb 2014 17:34:54 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V6 ] mm readahead: Fix readahead fail for memoryless cpu
 and limit readahead pages
References: <1392708338-19685-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140218094920.GB29660@quack.suse.cz>
In-Reply-To: <20140218094920.GB29660@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, rientjes@google.com, Linus <torvalds@linux-foundation.org>, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/18/2014 03:19 PM, Jan Kara wrote:
> On Tue 18-02-14 12:55:38, Raghavendra K T wrote:
>> Currently max_sane_readahead() returns zero on the cpu having no local memory node
>> which leads to readahead failure. Fix the readahead failure by returning
>> minimum of (requested pages, 512). Users running application on a memory-less cpu
>> which needs readahead such as streaming application see considerable boost in the
>> performance.
>>
>> Result:
>> fadvise experiment with FADV_WILLNEED on a PPC machine having memoryless CPU
>> with 1GB testfile ( 12 iterations) yielded around 46.66% improvement.
>>
>> fadvise experiment with FADV_WILLNEED on a x240 machine with 1GB testfile
>> 32GB* 4G RAM  numa machine ( 12 iterations) showed no impact on the normal
>> NUMA cases w/ patch.
>    Can you try one more thing please? Compare startup time of some big
> executable (Firefox or LibreOffice come to my mind) for the patched and
> normal kernel on a machine which wasn't hit by this NUMA issue. And don't
> forget to do "echo 3 >/proc/sys/vm/drop_caches" before each test to flush
> the caches. If this doesn't show significant differences, I'm OK with the
> patch.
>

Thanks Honza, I checked with firefox (starting to particular point)..
I do not see any difference. Both the case took around 14sec.

  ( some time it is even faster.. may be because we do not do free page 
calculation?. )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
