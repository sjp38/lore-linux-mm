Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EAE1B6B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 02:25:24 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f144so493718032pfa.3
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 23:25:24 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id i3si15126953pld.88.2017.01.30.23.25.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 23:25:24 -0800 (PST)
Subject: Re: [RFC V2 03/12] mm: Change generic FALLBACK zonelist creation
 process
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-4-khandual@linux.vnet.ibm.com>
 <07bd439c-6270-b219-227b-4079d36a2788@intel.com>
 <434aa74c-e917-490e-85ab-8c67b1a82d95@linux.vnet.ibm.com>
 <f1521ecc-e2a2-7368-07b7-7af6c0e88cc6@intel.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <79bfd849-8e6c-2f6d-0acf-4256a4137526@nvidia.com>
Date: Mon, 30 Jan 2017 23:25:22 -0800
MIME-Version: 1.0
In-Reply-To: <f1521ecc-e2a2-7368-07b7-7af6c0e88cc6@intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/30/2017 05:57 PM, Dave Hansen wrote:
> On 01/30/2017 05:36 PM, Anshuman Khandual wrote:
>>> Let's say we had a CDM node with 100x more RAM than the rest of the
>>> system and it was just as fast as the rest of the RAM.  Would we still
>>> want it isolated like this?  Or would we want a different policy?
>>
>> But then the other argument being, dont we want to keep this 100X more
>> memory isolated for some special purpose to be utilized by specific
>> applications ?
>
> I was thinking that in this case, we wouldn't even want to bother with
> having "system RAM" in the fallback lists.  A device who got its memory
> usage off by 1% could start to starve the rest of the system.  A sane
> policy in this case might be to isolate the "system RAM" from the device's.

I also don't like having these policies hard-coded, and your 100x example above 
helps clarify what can go wrong about it. It would be nicer if, instead, we could 
better express the "distance" between nodes (bandwidth, latency, relative to sysmem, 
perhaps), and let the NUMA system figure out the Right Thing To Do.

I realize that this is not quite possible with NUMA just yet, but I wonder if that's 
a reasonable direction to go with this?

thanks,
john h

>
>>> Why do we need this hard-coded along with the cpuset stuff later in the
>>> series.  Doesn't taking a node out of the cpuset also take it out of the
>>> fallback lists?
>>
>> There are two mutually exclusive approaches which are described in
>> this patch series.
>>
>> (1) zonelist modification based approach
>> (2) cpuset restriction based approach
>>
>> As mentioned in the cover letter,
>
> Well, I'm glad you coded both of them up, but now that we have them how
> to we pick which one to throw to the wolves?  Or, do we just merge both
> of them and let one bitrot? ;)
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
