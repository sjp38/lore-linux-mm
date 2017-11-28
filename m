Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 343176B0261
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 22:37:56 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 82so26381631pfp.5
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 19:37:56 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id s3si23872067plp.730.2017.11.27.19.37.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 19:37:55 -0800 (PST)
Subject: Re: [PATCH 1/1] stackdepot: interface to check entries and size of
 stackdepot.
References: <20171124124429.juonhyw4xbqc65u7@dhcp22.suse.cz>
 <CACT4Y+bF7TGFS+395kyzdw21M==ECgs+dCjV0e3Whkvm1_piDA@mail.gmail.com>
 <20171123162835.6prpgrz3qkdexx56@dhcp22.suse.cz>
 <1511347661-38083-1-git-send-email-maninder1.s@samsung.com>
 <20171124094108epcms5p396558828a365a876d61205b0fdb501fd@epcms5p3>
 <20171124095428.5ojzgfd24sy7zvhe@dhcp22.suse.cz>
 <20171124115707epcms5p4fa19970a325e87f08eadb1b1dc6f0701@epcms5p4>
 <CGME20171122105142epcas5p173b7205da12e1fc72e16ec74c49db665@epcms5p7>
 <20171124133025epcms5p7dc263c4a831552245e60193917a45b07@epcms5p7>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <ad4e2b97-ad94-32f7-3002-ff0cab00d3ab@codeaurora.org>
Date: Tue, 28 Nov 2017 09:07:46 +0530
MIME-Version: 1.0
In-Reply-To: <20171124133025epcms5p7dc263c4a831552245e60193917a45b07@epcms5p7>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: v.narang@samsung.com, Michal Hocko <mhocko@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Maninder Singh <maninder1.s@samsung.com>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "jkosina@suse.cz" <jkosina@suse.cz>, "pombredanne@nexb.com" <pombredanne@nexb.com>, "jpoimboe@redhat.com" <jpoimboe@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "guptap@codeaurora.org" <guptap@codeaurora.org>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, PANKAJ MISHRA <pankaj.m@samsung.com>, Lalit Mohan Tripathi <lalit.mohan@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>

On 11/24/2017 7:00 PM, Vaneet Narang wrote:
> Hi Michal,
>
>>> A WeA haveA beenA gettingA similarA kindA ofA suchA entriesA andA eventually
>>> A stackdepotA reachesA MaxA Cap.A SoA weA foundA thisA interfaceA usefulA inA debugging
>>> A stackdepotA issueA soA sharedA inA community.
> A 
>> ThenA useA itA forA internalA debuggingA andA provideA aA codeA whichA wouldA scale
>> betterA onA smallerA systems.A WeA doA notA needA thisA inA theA kernelA IMHO.A WeA do
>> notA mergeA allA theA debuggingA patchesA weA useA forA internalA development.
> `A 
> Not just debugging but this information can also be used to profile and tune stack depot. 
> Getting count of stack entries would help in deciding hash table size and 
> page order used by stackdepot. 
>
> For less entries, bigger hash table and higher page order slabs might not be required as 
> maintained by stackdepot. As i already mentioned smaller size hashtable can be choosen and 
> similarly lower order  pages can be used for slabs.
>
> If you think its useful, we can share scalable patch to configure below two values based on 
> number of stack entries dynamically.
>
> #define STACK_ALLOC_ORDER 2 
> #define STACK_HASH_SIZE (1L << STACK_HASH_ORDER)
It will be good if this hash table size can be tuned somehow. When CONFIG_PAGE_OWNER is enabled, we expect it to
consume significant amount of memory only when "page_owner" kernel param is set. But since PAGE_OWNER selects
STACKDEPOT, it consumes around 8MB (stack_table) on 64 bit without even a single stack being stored. This is a problem
on low RAM targets where we want to keep CONFIG_PAGE_OWNER enabled by default and for debugging enable the
feature via the kernel param.
I am not sure how feasible it is to configure it dynamically, but I think a hash_size early param and then a memblock alloc
of stack table at boot would work and help low ram devices.

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
