Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C97256B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 09:29:40 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d67so9277796qkg.2
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 06:29:40 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 34si5285648qkt.409.2017.10.04.06.29.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 06:29:39 -0700 (PDT)
Subject: Re: [PATCH v9 08/12] mm: zero reserved and unavailable struct pages
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-9-pasha.tatashin@oracle.com>
 <20171003131817.omzbam3js67edp3s@dhcp22.suse.cz>
 <691dba28-718c-e9a9-d006-88505eb5cd7e@oracle.com>
 <20171004085636.w2rnwf5xxhahzuy7@dhcp22.suse.cz>
 <9198a33d-cd40-dd70-4823-7f70c57ef9a2@oracle.com>
 <20171004125743.fm6mf2artbga76et@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <d743668c-6b7e-1775-a5b8-d6e997537990@oracle.com>
Date: Wed, 4 Oct 2017 09:28:55 -0400
MIME-Version: 1.0
In-Reply-To: <20171004125743.fm6mf2artbga76et@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com


> I am not really familiar with the trim_low_memory_range code path. I am
> not even sure we have to care about it because nobody should be walking
> pfns outside of any zone.

According to commit comments first 4K belongs to BIOS, so I think the 
memory exists but BIOS may or may not report it to Linux. So, reserve it 
to make sure we never touch it.

  I am worried that this patch adds a code which
> is not really used and it will just stay that way for ever because
> nobody will dare to change it as it is too obscure and not explained
> very well.

I could explain mine code better. Perhaps add more comments, and explain 
when it can be removed?

  trim_low_memory_range is a good example of this. Why do we
> even reserve this range from the memory block allocator? The memory
> shouldn't be backed by any real memory and thus not in the allocator in
> the first place, no?
> 

Since it is not enforced in memblock that everything in reserved list 
must be part of memory list, we can have it, and we need to make sure 
kernel does not panic. Otherwise, it is very hard to detect such bugs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
