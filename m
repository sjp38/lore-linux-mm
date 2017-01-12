Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 945F36B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 21:51:55 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id v96so13021281ioi.5
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 18:51:55 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id h82si2119125pfj.218.2017.01.11.18.51.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 18:51:54 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v5 2/9] mm/swap: Add cluster lock
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
	<dbb860bbd825b1aaba18988015e8963f263c3f0d.1484082593.git.tim.c.chen@linux.intel.com>
	<20170111150029.29e942aa00af69f9c3c4e9b1@linux-foundation.org>
	<20170111160729.23e06078@lwn.net>
	<20170111151526.e905b91d6f1ee9f21e6907be@linux-foundation.org>
	<8760ll122g.fsf@yhuang-dev.intel.com>
	<20170111175812.9e459e4c51502265aad5f2dc@linux-foundation.org>
Date: Thu, 12 Jan 2017 10:51:50 +0800
In-Reply-To: <20170111175812.9e459e4c51502265aad5f2dc@linux-foundation.org>
	(Andrew Morton's message of "Wed, 11 Jan 2017 17:58:12 -0800")
Message-ID: <871sw90z3t.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Tim Chen <tim.c.chen@linux.intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 12 Jan 2017 09:47:51 +0800 "Huang\, Ying" <ying.huang@intel.com> wrote:
>
>> >> > 1MB swap space, so for 1TB swap space, the total size will be 80M
>> >> > compared with 8M of current implementation.
>> >
>> > Where did this 80 bytes come from?  That swap_cluster_info is 12 bytes
>> > and could perhaps be squeezed into 8 bytes if we can get away with a
>> > 24-bit "count".
>> 
>> Sorry, I made a mistake when measuring the size of swap_cluster_info
>> when I sent that email, because I turned on the lockdep when measuring.
>> I have sent out a correction email to Jonathan when I realized that
>> later.
>> 
>> So the latest size measuring result is:
>> 
>> If we use bit_spin_lock, the size of cluster_swap_info will,
>> 
>> - increased from 4 bytes to 8 bytes on 64 bit platform
>> - keep as 4 bytes on 32 bit platform
>> 
>> If we use normal spinlock (queue spinlock), the size of cluster_swap_info will,
>> 
>> - increased from 4 bytes to 8 bytes on 64 bit platform
>> - increased from 4 bytes to 8 bytes on 32 bit platform
>> 
>> So the difference occurs on 32 bit platform.  If the size increment on
>> 32 bit platform is OK, then I think it should be good to use normal
>> spinlock instead of bit_spin_lock.  Personally, I am OK for that.  But I
>> don't know whether there will be some embedded world people don't like
>> it.
>
> I think that'll be OK - the difference is small and many small systems
> disable swap anyway.  So can we please try that?  Please do describe
> the additional overhead (with numbers) in the changelog: "additional
> bytes of RAM per GB of swap", for example.  And please also rerun the
> performance tests, see if we can notice the alleged speed improvements
> from switching to a spinlock.

Sure.  I will change it and redo the test.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
