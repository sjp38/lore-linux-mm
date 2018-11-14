Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 54B5A6B000E
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 04:22:38 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id f22so35858804qkm.11
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 01:22:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x56si967927qtc.123.2018.11.14.01.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 01:22:37 -0800 (PST)
Subject: Re: Memory hotplug softlock issue
References: <20181114070909.GB2653@MiWiFi-R3L-srv>
 <5a6c6d6b-ebcd-8bfa-d6e0-4312bfe86586@redhat.com>
 <20181114090134.GG23419@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <4449a0a2-be72-02bb-9f02-ed2484b160f8@redhat.com>
Date: Wed, 14 Nov 2018 10:22:31 +0100
MIME-Version: 1.0
In-Reply-To: <20181114090134.GG23419@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com

>>
>> The real question is, however, why offlining of the last block doesn't
>> succeed. In __offline_pages() we basically have an endless loop (while
>> holding the mem_hotplug_lock in write). Now I consider this piece of
>> code very problematic (we should automatically fail after X
>> attempts/after X seconds, we should not ignore -ENOMEM), and we've had
>> other BUGs whereby we would run into an endless loop here (e.g. related
>> to hugepages I guess).
> 
> We used to have number of retries previous and it was too fragile. If
> you need a timeout then you can easily do that from userspace. Just do
> timeout $TIME echo 0 > $MEM_PATH/online

I agree that number of retries is not a good measure.

But as far as I can see this happens from the kernel via an ACPI event.
E.g. failing to offline a block after X seconds would still make sense.
(if something takes 120seconds to offline 128MB/2G there is something
very bad going on, we could set the default limit to e.g. 30seconds),
however ...

> 
> I have seen an issue when the migration cannot make a forward progress
> because of a glibc page with a reference count bumping up and down. Most
> probable explanation is the faultaround code. I am working on this and
> will post a patch soon. In any case the migration should converge and if
> it doesn't do then there is a bug lurking somewhere.

... I also agree that this should converge. And if we detect a serious
issue that we can't handle/where we can't converge (e.g. -ENOMEM) we
should abort.

> 
> Failing on ENOMEM is a questionable thing. I haven't seen that happening
> wildly but if it is a case then I wouldn't be opposed.
> 
>> You mentioned memory pressure, if our host is under memory pressure we
>> can easily trigger running into an endless loop there, because we
>> basically ignore -ENOMEM e.g. when we cannot get a page to migrate some
>> memory to be offlined. I assume this is the case here.
>> do_migrate_range() could be the bad boy if it keeps failing forever and
>> we keep retrying.

I've seen quite some issues while playing with virtio-mem, but didn't
have the time to look into the details. Still on my long list of things
to look into.

> 
> My hotplug debugging patches [1] should help to tell us.
> 
> [1] http://lkml.kernel.org/r/20181107101830.17405-1-mhocko@kernel.org
> 


-- 

Thanks,

David / dhildenb
