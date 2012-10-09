Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 021E56B0044
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 20:42:25 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so5017167obc.14
        for <linux-mm@kvack.org>; Mon, 08 Oct 2012 17:42:25 -0700 (PDT)
Message-ID: <507372E8.9090207@gmail.com>
Date: Tue, 09 Oct 2012 08:42:16 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: memmap_init_zone() performance improvement
References: <1349276174-8398-1-git-send-email-mike.yoknis@hp.com> <20121008151656.GM29125@suse.de>
In-Reply-To: <20121008151656.GM29125@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Mike Yoknis <mike.yoknis@hp.com>, mingo@redhat.com, akpm@linux-foundation.org, linux-arch@vger.kernel.org, mmarek@suse.cz, tglx@linutronix.de, hpa@zytor.com, arnd@arndb.de, sam@ravnborg.org, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/08/2012 11:16 PM, Mel Gorman wrote:
> On Wed, Oct 03, 2012 at 08:56:14AM -0600, Mike Yoknis wrote:
>> memmap_init_zone() loops through every Page Frame Number (pfn),
>> including pfn values that are within the gaps between existing
>> memory sections.  The unneeded looping will become a boot
>> performance issue when machines configure larger memory ranges
>> that will contain larger and more numerous gaps.
>>
>> The code will skip across invalid sections to reduce the
>> number of loops executed.
>>
>> Signed-off-by: Mike Yoknis <mike.yoknis@hp.com>
> This only helps SPARSEMEM and changes more headers than should be
> necessary. It would have been easier to do something simple like
>
> if (!early_pfn_valid(pfn)) {
> 	pfn = ALIGN(pfn + MAX_ORDER_NR_PAGES, MAX_ORDER_NR_PAGES) - 1;
> 	continue;
> }

So if present memoy section in sparsemem can have 
MAX_ORDER_NR_PAGES-aligned range are all invalid?
If the answer is yes, when this will happen?

>
> because that would obey the expectation that pages within a
> MAX_ORDER_NR_PAGES-aligned range are all valid or all invalid (ARM is the
> exception that breaks this rule). It would be less efficient on
> SPARSEMEM than what you're trying to merge but I do not see the need for
> the additional complexity unless you can show it makes a big difference
> to boot times.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
